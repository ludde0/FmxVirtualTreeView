program TestTreeViewFmx;

uses
  System.SysUtils,
  System.IOUtils,
  System.StartUpCopy,
  FMX.Forms,
  VirtualTrees in '..\..\Source\VirtualTrees.pas',
  VirtualTrees.AncestorFMX in '..\..\Source\VirtualTrees.AncestorFMX.pas',
  VirtualTrees.BaseAncestorFMX in '..\..\Source\VirtualTrees.BaseAncestorFMX.pas',
  VirtualTrees.BaseTree in '..\..\Source\VirtualTrees.BaseTree.pas',
  VirtualTrees.Classes in '..\..\Source\VirtualTrees.Classes.pas',
  VirtualTrees.Colors in '..\..\Source\VirtualTrees.Colors.pas',
  VirtualTrees.DataObject in '..\..\Source\VirtualTrees.DataObject.pas',
  VirtualTrees.Debug in '..\..\Source\VirtualTrees.Debug.pas',
  VirtualTrees.DragImage in '..\..\Source\VirtualTrees.DragImage.pas',
  VirtualTrees.DragnDrop in '..\..\Source\VirtualTrees.DragnDrop.pas',
  VirtualTrees.DrawTree in '..\..\Source\VirtualTrees.DrawTree.pas',
  VirtualTrees.EditLink in '..\..\Source\VirtualTrees.EditLink.pas',
  VirtualTrees.Export in '..\..\Source\VirtualTrees.Export.pas',
  VirtualTrees.FMX in '..\..\Source\VirtualTrees.FMX.pas',
  VirtualTrees.Header in '..\..\Source\VirtualTrees.Header.pas',
  VirtualTrees.StyleHooks in '..\..\Source\VirtualTrees.StyleHooks.pas',
  VirtualTrees.Utils in '..\..\Source\VirtualTrees.Utils.pas',
  VirtualTrees.Types in '..\..\Source\VirtualTrees.Types.pas',
  uFormFmx in 'uFormFmx.pas' {FormFmx};

{$R *.res}

// ---------------------------------------------------------------------------------------
// Fatal logging
//
// An AV on shutdown is hard to catch because there is barely any program left to catch it
// with. Three separate nets are needed, and which one fires tells you where the fault is:
//
//   Application.OnException  - the exception reached the message loop. Something raised
//                              while the form was still processing messages, e.g. during
//                              OnClose/OnCloseQuery, or in a timer tick.
//   except around Run        - it escaped the loop entirely.
//   the markers below        - nothing was caught, but the log stops after "run returned",
//                              which puts the fault in the teardown after Run: form and
//                              component destructors, then unit finalization.
//
// The log is appended, never truncated, so a rare fault is not erased by the next dozen
// clean runs. Every write is wrapped: a logger that raises during shutdown would hide the
// very thing it was added to find.
// ---------------------------------------------------------------------------------------

type
  TFatalLog = class
  public
    procedure HandleException(Sender: TObject; E: Exception);
    procedure Note(const AText: string);
    procedure Fatal(const AWhere: string; E: Exception);
  end;

var
  FatalLog: TFatalLog;

function LogFileName: string;
begin
{$IFDEF ANDROID}
  Result := TPath.Combine(TPath.GetPublicPath, 'TestTreeViewFmx.errors.log');
{$ELSE}
  Result := TPath.ChangeExtension(ParamStr(0), '.errors.log');
{$ENDIF}
end;

procedure TFatalLog.Note(const AText: string);
begin
  try
    TFile.AppendAllText(LogFileName,
      FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + '  ' + AText + sLineBreak,
      TEncoding.UTF8);
  except
    // Deliberately swallowed. See the header comment.
  end;
end;

procedure TFatalLog.Fatal(const AWhere: string; E: Exception);
var
  LText: string;
begin
  if not Assigned(E) then begin
    Note(AWhere + ': unknown exception');
    Exit;
  end;

  LText := AWhere + ': ' + E.ClassName + ' - ' + E.Message;
  // StackTrace is empty unless a provider is installed. Delphi-StackTrace
  // (github.com/thatlr/Delphi-StackTrace, with map2pdb.exe) fills it in and is worth
  // adding before hunting this one - a class name and a message will not be enough.
  if E.StackTrace <> '' then
    LText := LText + sLineBreak + E.StackTrace;
  Note(LText);
end;

procedure TFatalLog.HandleException(Sender: TObject; E: Exception);
begin
  Fatal('OnException', E);
  // Not re-raised: the point is to survive long enough to write the log. Comment the line
  // below back in if you would rather have the debugger break on it.
  // raise E;
end;

begin
{$WARN SYMBOL_PLATFORM OFF}
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
{$WARN SYMBOL_PLATFORM ON}

  FatalLog := TFatalLog.Create;
  try
    FatalLog.Note('--- start ---');
    try
      Application.Initialize;
      Application.OnException := FatalLog.HandleException;
      Application.CreateForm(TFormFmx, FormFmx);
  FatalLog.Note('run');
      Application.Run;
      // Reaching this means the message loop ended cleanly - everything after it is
      // destruction. The form is freed HERE, inside the guard, rather than left to the
      // Application destructor during unit finalization, where there is nothing left to
      // catch an AV with and nothing left to write it down. If the log ends at
      // "run returned", the fault is in the form or one of its components going away.
      FatalLog.Note('run returned');
      FreeAndNil(FormFmx);
      FatalLog.Note('main form destroyed');
    except
      on E: Exception do
        FatalLog.Fatal('main', E);
    end;
    FatalLog.Note('--- exit ---');
  finally
    FreeAndNil(FatalLog);
  end;
end.
