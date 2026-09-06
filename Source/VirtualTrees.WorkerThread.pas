unit VirtualTrees.WorkerThread;

interface

// One background thread shared by every tree in the process. Trees queue themselves on it
// to have their node caches validated; the thread works through the queue one tree at a
// time and is created with the first tree and destroyed with the last.
// The queue is signalled through an auto reset event, so the thread sleeps while idle.

uses
  System.Classes,
  System.SyncObjs,
  VirtualTrees;

type
  TWorkerThread = class(TThread)
  private
    FCurrentTree: TBaseVirtualTree;
    FWaiterList: TThreadList;
    FRefCount: Integer;
    class procedure EnsureCreated();
    class procedure Dispose(CanBlock: Boolean);
    procedure WaitForValidationTermination(Tree: TBaseVirtualTree);
  protected
    procedure Execute; override;
  public
    constructor Create();
    destructor Destroy; override;

    /// Reference counted lifetime: the first AddThreadReference creates the thread, the
    /// matching last ReleaseThreadReference shuts it down.
    class procedure AddThreadReference;
    class procedure ReleaseThreadReference(ACanBlock: Boolean = False);

    class procedure AddTree(Tree: TBaseVirtualTree);
    class procedure RemoveTree(Tree: TBaseVirtualTree);

    property CurrentTree: TBaseVirtualTree read FCurrentTree;
  end;

implementation

uses
  VirtualTrees.Types,
  System.Types,
  System.SysUtils;

type
  TBaseVirtualTreeCracker = class(TBaseVirtualTree)
  end;

var
  WorkerThread: TWorkerThread = nil;
  // Auto reset: every SetEvent releases exactly one pass through the wait loop.
  WorkEvent: TEvent = nil;

//----------------- TWorkerThread --------------------------------------------------------------------------------------

class procedure TWorkerThread.EnsureCreated();
begin
  if not Assigned(WorkEvent) then
    WorkEvent := TEvent.Create(nil, False, False, '');

  if not Assigned(WorkerThread) then
    WorkerThread := TWorkerThread.Create();
end;

class procedure TWorkerThread.Dispose;

// Shuts the thread down and releases the event with it. Both are destroyed here rather than
// left to FreeOnTerminate: the event can only be freed once nothing can still wait on it,
// and with a self freeing thread there is no moment at which that is known to be true.
//
// Free waits for Execute to return. That does not deadlock against the Synchronize and
// Queue calls the thread makes, because TThread.WaitFor pumps them while it waits when it
// is called from the main thread. CanBlock is therefore no longer about lifetime; it is
// kept so existing calls still compile.

var
  LRef: TWorkerThread;
begin
  if not Assigned(WorkerThread) then
    Exit;

  LRef := WorkerThread;
  WorkerThread := nil;         // no tree can queue itself from here on
  LRef.Terminate();
  if Assigned(WorkEvent) then
    WorkEvent.SetEvent();      // wake the wait loop so it sees Terminated
  LRef.Free;                   // returns once Execute has left
  FreeAndNil(WorkEvent);
end;


class procedure TWorkerThread.AddThreadReference;
begin
  TWorkerThread.EnsureCreated();
  TInterlocked.Increment(WorkerThread.FRefCount);
end;

//----------------------------------------------------------------------------------------------------------------------

class procedure TWorkerThread.ReleaseThreadReference(ACanBlock: Boolean);
begin
  if Assigned(WorkerThread) then
  begin
    if TInterlocked.Decrement(WorkerThread.FRefCount) = 0 then
    begin
      WorkerThread.Dispose(ACanBlock);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

constructor TWorkerThread.Create();

// Not FreeOnTerminate: Dispose owns this object and frees it explicitly, which is what
// makes the point at which the work event can be released knowable.

begin
  inherited Create(False);
  FWaiterList := TThreadList.Create;
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TWorkerThread.Destroy;

begin
  // First let the ancestor stop the thread before freeing our resources.
  inherited;
  FWaiterList.Free;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TWorkerThread.WaitForValidationTermination(Tree: TBaseVirtualTree);
begin
  // Wait for any references to this tree to be released.
  while FCurrentTree = Tree do
  begin
    Sleep(1);
    if (toVariableNodeHeight in TBaseVirtualTreeCracker(Tree).TreeOptions.MiscOptions) then
      CheckSynchronize(); // We need to call CheckSynchronize here because we are using TThread.Synchronize in TBaseVirtualTree.MeasureItemHeight()
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TWorkerThread.Execute();

// Does some background tasks, like validating tree caches.

var
  EnterStates: TVirtualTreeStates;
  lCurrentTree: TBaseVirtualTree;

begin
  TThread.NameThreadForDebugging('VirtualTrees.TWorkerThread');
  while not Terminated do
  begin
    WorkEvent.WaitFor(INFINITE);
    if Terminated then
      exit;

    // Get the next waiting tree.
    with FWaiterList.LockList do
    try
      if Count > 0 then
      begin
        lCurrentTree := Items[0];
        // Remove this tree from waiter list.
        Delete(0);
        // If there is yet another tree to work on then set the work event to keep looping.
        if Count > 0 then
          WorkEvent.SetEvent();
      end
      else
        lCurrentTree := nil;
    finally
      FWaiterList.UnlockList;
    end;

    // Something to do?
    if Assigned(lCurrentTree) then
    begin
      try
        TBaseVirtualTreeCracker(lCurrentTree).ChangeTreeStatesAsync([tsValidating], [tsUseCache, tsValidationNeeded]);
        FCurrentTree := lCurrentTree;
        EnterStates := [];
        if not (tsStopValidation in FCurrentTree.TreeStates) and TBaseVirtualTreeCracker(FCurrentTree).DoValidateCache then
          EnterStates := [tsUseCache];

      finally
        // Cleared before the state change: CancelValidation waits on FCurrentTree and
        // would deadlock if it still pointed at this tree.
        FCurrentTree := nil;
        TBaseVirtualTreeCracker(lCurrentTree).ChangeTreeStatesAsync(EnterStates, [tsValidating, tsStopValidation]);
        Queue(TBaseVirtualTreeCracker(lCurrentTree).UpdateEditBounds);
      end;
    end;
  end;//while
end;

//----------------------------------------------------------------------------------------------------------------------

class procedure TWorkerThread.AddTree(Tree: TBaseVirtualTree);

begin
  Assert(Assigned(Tree), 'Tree must not be nil.');
  TWorkerThread.EnsureCreated();

  // Remove validation stop flag, just in case it is still set.
  TBaseVirtualTreeCracker(Tree).DoStateChange([], [tsStopValidation]);
  with WorkerThread.FWaiterList.LockList do
  try
    if IndexOf(Tree) = -1 then
      Add(Tree);
  finally
    WorkerThread.FWaiterList.UnlockList;
  end;

  WorkEvent.SetEvent();
end;

//----------------------------------------------------------------------------------------------------------------------

class procedure TWorkerThread.RemoveTree(Tree: TBaseVirtualTree);

begin
  if not Assigned(WorkerThread) then
    exit;
  Assert(Assigned(Tree), 'Tree must not be nil.');

  with WorkerThread.FWaiterList.LockList do
  try
    Remove(Tree);
  finally
    WorkerThread.FWaiterList.UnlockList;
  end;
  // The tree may be the one currently being validated, so wait for that to finish before
  // returning - the caller is usually about to destroy it.
  WorkerThread.WaitForValidationTermination(Tree);
end;

//----------------------------------------------------------------------------------------------------------------------

initialization

finalization

  // Safety net for a reference that was never released - without it the thread and its
  // event would still be alive when the process shuts down.
  TWorkerThread.Dispose(True);

end.
