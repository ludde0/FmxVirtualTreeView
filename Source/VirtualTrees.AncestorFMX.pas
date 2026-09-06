unit VirtualTrees.AncestorFMX;

{$SCOPEDENUMS ON}

{****************************************************************************************************************}
{ Project          : VirtualTrees                                                                                }
{                                                                                                                }
{ author           : Karol Bieniaszewski                                                                         }
{ year             : 2022                                                                                        }
{ contibutors      :                                                                                             }
{****************************************************************************************************************}

interface

uses
  System.Types,
  VirtualTrees.Types,   // TNodeArray in the OnAfterPaste signature. Listed AFTER
                        // System.Types so its TRect = TRectF / TPoint = TPointF
                        // aliases win over the integer originals.
  System.Classes, System.UITypes, FMX.Graphics,
  VirtualTrees.FMX, VirtualTrees.BaseTree,
  System.Math, FMX.Types,
  FMX.Controls;         // TGestureEvent, the type of the redeclared OnGesture property.
                        // Last, so nothing it declares outranks the aliases above.

type
  /// <summary>
  /// Fired by PasteFromClipboard when the system clipboard holds text that did not come
  /// from a tree in this process. The tree cannot turn text back into nodes - it is
  /// virtual, the application owns the data - so this is where an application that knows
  /// what its text means gets to do it. Leave Handled False and the paste does nothing.
  /// </summary>
  TVTPasteTextEvent = procedure(Sender: TObject; const AText: string; var Handled: Boolean) of object;

  /// <summary>
  /// Fired at the end of a successful PasteFromClipboard with the nodes that now exist at
  /// the destination - the moved nodes for a cut within one tree, the newly created ones
  /// otherwise - and whether the operation was a cut. The tree also selects them and focuses
  /// the first, so an application that only wants to SEE the result needs no handler at all;
  /// this is for the ones that need to act on it.
  /// </summary>
  TVTAfterPasteEvent = procedure(Sender: TObject; const APasted: TNodeArray; ACut: Boolean) of object;

  /// <summary>
  /// Last say over the text a cut or copy puts on the SYSTEM clipboard, fired after the
  /// tree's own GetClipboardText has produced whatever it can. AText arrives holding that
  /// default - the tab separated cut/copy set for a string tree, empty for anything else,
  /// since TBaseVirtualTree holds no text - and whatever is left in it is what other
  /// applications will see. Leaving it empty puts nothing on the clipboard; the in-process
  /// node paste is unaffected either way, because that does not go through text at all.
  /// </summary>
  TVTGetClipboardTextEvent = procedure(Sender: TObject; var AText: string) of object;

{$SCOPEDENUMS OFF}
  /// <summary>
  /// What opens a context menu. Right click is the desktop gesture, press and hold the
  /// touch one; see PopupTrigger, PopupDelay and OnContextMenu.
  /// </summary>
  TVTPopupTrigger = (ptNone, ptRightClick, ptLongPress, ptRightClickOrLongPress);
{$SCOPEDENUMS ON}

  /// <summary>
  /// Fired when PopupTrigger recognises a context gesture. LocalPos is in tree
  /// coordinates and Node/Column are the hit under it - Node is nil and Column is
  /// NoColumn when the gesture landed on empty space.
  /// </summary>
  TVTContextMenuEvent = procedure(Sender: TObject; Node: PVirtualNode; Column: TColumnIndex;
    const LocalPos: TPointF) of object;

type
  TVTAncestorFMX = class abstract(TBaseVirtualTree)
  private
    FInCreate: Boolean;
    FPressInHeader: Boolean;          // this press started on the header, gesture or not
    FPressPos: TPointF;               // where the current press landed, control local
    FPressTravel: TPointF;            // absolute path length per axis since that press
    FTravelPos: TPointF;              // last point FPressTravel was measured from
    FPopupTrigger: TVTPopupTrigger;
    FPopupDelay: Cardinal;
    FPopupTimer: TTimer;            // press-and-hold countdown before a context gesture
    FPopupNode: PVirtualNode;
    FPopupColumn: TColumnIndex;
    FPopupPos: TPointF;
    FPopup: TPopup;
    FOnContextMenu: TVTContextMenuEvent;
    FLastGesturePoint: TPointF;
    FLastGestureTick: UInt64;
    FIsScrolling: Boolean;
    FInertiaTimer: TTimer;
    FInertiaVelocity: TPointF;   // px/ms in both axes
    FCarryVelocity: TPointF;     // speed of a fling that was interrupted by a new touch
    FCarryTick: UInt64;
    FInClientAreaSync: Boolean;  // Re-entry guard for SyncHeaderToClientArea.
    FOnUserGesture: TGestureEvent;
    FOnPasteText: TVTPasteTextEvent;
    FOnAfterPaste: TVTAfterPasteEvent;
    FOnGetClipboardText: TVTGetClipboardTextEvent;
    procedure AccumulatePressTravel(ADeltaX, ADeltaY: Single);
    procedure InternalCutOrCopy(ACut: Boolean);
    function  PanBy(ADeltaX, ADeltaY: Single): Boolean;
    procedure StopFling;
    procedure HandleGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure HandleInertiaTimer(Sender: TObject);
    procedure StartPopupTimer;
    procedure StopPopupTimer;
    procedure PopupTimerProc(Sender: TObject);
    procedure DoContextMenu;
    procedure OpenPopupDeferred(APopup: TPopup);
    procedure SetPopup(const Value: TPopup);
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X: Single; Y: Single); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;

    function PrepareDottedBrush(CurrentDottedBrush: TStrokeBrush; Bits: Pointer; const BitsLinesCount: Word): TStrokeBrush; override;

    function GetClientHeight: Single; override;
    function GetClientWidth: Single; override;
    // Qualified: System.Types.TRect is in scope here too, and this must match the ancestor.
    function GetClientRect: VirtualTrees.FMX.TRect; override;

    procedure HScrollChangeProc(Sender: TObject); override;
    procedure VScrollChangeProc(Sender: TObject); override;

    procedure Resize; override;
    procedure SyncHeaderToClientArea;

    /// <summary>
    /// The text a copy or cut puts on the system clipboard. Empty here - TBaseVirtualTree
    /// holds no text at all - and overridden in TCustomVirtualStringTree, which does.
    /// Called after MarkCutCopyNodes, so the cut/copy set is the right source.
    /// </summary>
    function GetClipboardText: string; virtual;

    /// <summary>
    /// Redeclared, so that an application handler cannot take the pan gesture away from the
    /// tree. TControl.OnGesture is the tree's own HandleGesture and stays that way - see
    /// Create - and whatever is assigned here is called from inside it, before the tree
    /// looks at the gesture itself. The exception is a drag in progress: that owns the
    /// finger, and no gesture reaches the handler until it ends. Descendants publish this
    /// name, so an application still assigns OnGesture as it would on any control.
    /// </summary>
    property OnGesture: TGestureEvent read FOnUserGesture write FOnUserGesture;
  public
    constructor Create(AOwner: TComponent); override;
    procedure CopyToClipboard; override;
    procedure CutToClipboard; override;
    function PasteFromClipboard: Boolean; override;
    property OnPasteText: TVTPasteTextEvent read FOnPasteText write FOnPasteText;
    property OnAfterPaste: TVTAfterPasteEvent read FOnAfterPaste write FOnAfterPaste;
    property OnGetClipboardText: TVTGetClipboardTextEvent read FOnGetClipboardText
      write FOnGetClipboardText;
    destructor Destroy; override;
    procedure ShowScrollBar(Bar: Integer; AShow: Boolean); override;

    /// <summary>
    /// Opens Popup with its top left corner at ALocalPos, which is in tree coordinates.
    /// Does nothing when no Popup is assigned.
    /// </summary>
    procedure ShowPopupAt(const ALocalPos: TPointF);

    /// <summary>
    /// Shown when PopupTrigger recognises a context gesture, after OnContextMenu has had
    /// its say, so a handler can fill it in first. A TPopup is an ordinary control that
    /// works on every platform, which a TPopupMenu does not; the inherited PopupMenu is
    /// used instead when this is nil.
    /// </summary>
    property Popup: TPopup read FPopup write SetPopup;
    /// <summary>
    /// How far the pointer has travelled on each axis since the current press went down,
    /// measured as path length rather than as distance from the start, and reset by every
    /// MouseDown.
    ///
    /// It is there to tell a swipe from a movement along the list. A platform swipe recogniser
    /// is generous about the axis it did not care about, so a mostly vertical drag can still be
    /// reported as a left or right swipe; comparing Y against X in an OnGesture handler is what
    /// separates the two. Both axes always come from the same source, so the ratio is meaningful
    /// even where the source reports in screen rather than local coordinates.
    /// </summary>
    property PressTravel: TPointF read FPressTravel;
    /// <summary>
    /// Milliseconds the press has to be held still before PopupTrigger's long press is
    /// recognised. Zero switches the long press off whatever PopupTrigger says.
    /// </summary>
    property PopupDelay: Cardinal read FPopupDelay write FPopupDelay;
    /// <summary>
    /// Which gesture fires OnContextMenu. Defaults to right click and press and hold on
    /// Windows, press and hold everywhere else.
    /// </summary>
    property PopupTrigger: TVTPopupTrigger read FPopupTrigger write FPopupTrigger;
    property OnContextMenu: TVTContextMenuEvent read FOnContextMenu write FOnContextMenu;
  end;

implementation
uses
  System.SysUtils,
  System.Rtti,
  FMX.Platform,
  FMX.Forms,
  FMX.Menus,            // TPopupMenu, the fallback DoContextMenu shows when Popup is nil.
  VirtualTrees.BaseAncestorFMX,
  VirtualTrees.Debug,
  VirtualTrees.Header;

const
  // Press-and-hold before a context gesture is recognised, and how far the finger may drift
  // while holding before the hold is abandoned. The default sits above the 400 ms
  // cDefaultDragDelay on purpose: where dragging is enabled a hold picks a node up, and an
  // application that wants the context menu instead sets PopupDelay below DragDelay.
  cDefaultPopupDelay  = 500;   // ms
  cPopupMoveTolerance = 8;     // px

var
  // The in-process equivalent of the VCL's CFSTR_VTREFERENCE format: the tree the last cut
  // or copy came from. Text on the system clipboard is for other applications; a paste
  // inside this one moves or copies the real nodes, exactly as the VCL does through OLE.
  // Cleared when that tree is destroyed - see TVTAncestorFMX.Destroy.
  GClipSource: TVTAncestorFMX = nil;
  GClipIsCut: Boolean = False;

function TryGetClipboardService(out AService: IFMXClipboardService): Boolean;
begin
  Result := TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService,
    IInterface(AService));
end;

type
  TVTHeaderCracker = class(TVTHeader);

  // Reaches TControl.OnGesture, which TVTAncestorFMX redeclares under the same name.
  TControlCracker = class(TControl);

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.MouseDown(Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single); //wymaga BaseTree
Var MM: TWMMouse;
  hInfo: THitInfo;
  P: VirtualTrees.FMX.TPoint;
  isNC: Boolean;
  Msg: TMessage;
  PLocal: VirtualTrees.FMX.TPoint;
begin
  // A tap during a fling stops it, the way every touch list behaves, and does NOT also
  // select whatever node happened to be sliding past under the finger.
  if FInertiaTimer.Enabled then begin
    StopFling;
    Exit;
  end;

  // FillTWMMouse packs Shift into Message.Keys, which is all HandleCheckboxClick has to decide
  // whether a real left click happened. A touch does not reliably carry ssLeft, so state it: a
  // tap IS the left button. Harmless on Windows, where a left click already carries it.
  if (Button = TMouseButton.mbLeft) and not (ssLeft in Shift) then
    Include(Shift, ssLeft);

  // This override never calls inherited, so TControl's own click handling - focus included - is
  // skipped and CanFocus alone achieves nothing. Without focus the form never routes KeyDown
  // here, and everything in TBaseVirtualTree.KeyDown is dead: arrows, Home/End, F2, and the
  // Space bar that toggles a check box.
  if CanFocus and not IsFocused then
    SetFocus;

  // TControl.MouseDown is also where OnMouseDown is fired, and this override does not call
  // it - see above - so the event is fired here instead. Without it the property is dead on
  // FMX while it works on the VCL.
  if Assigned(OnMouseDown) then
    OnMouseDown(Self, Button, Shift, X, Y);

  // A new press starts a new measurement - see the PressTravel property.
  FPressPos := PointF(X, Y);
  FTravelPos := FPressPos;
  FPressTravel := PointF(0, 0);

  P.X:= X;
  P.Y:= Y;
  PLocal:= P; // P is replaced by screen coordinates below when isNC
  if ClientRect.Contains(P) then
    begin
      isNc:= false;
    end else
    begin
      isNC:= true;
      P:= ClientToScreen(P);
    end;
  FillTWMMouse(MM, Button, Shift, P.X, P.Y, isNC, false);

  // Remembered for HandleGesture, and set before the two header exits below so it is recorded
  // for a press the header goes on to claim. FMX builds a swipe out of mouse movement and only
  // delivers it once the drag ENDS - by which time the header has finished and cleared its
  // states - so asking there whether the header is tracking is too late a question. This
  // answers the one that matters instead: did this press begin on the header at all.
  FPressInHeader := Header.InHeader(PLocal);

  Msg := TWMMouseToTMessage(MM);
  if TVTHeaderCracker(header).HandleMessage(Msg) then
    exit;//!!!

  // VCL keeps the header in the non-client area, so a header click arrives as
  // WM_NCLBUTTONDOWN and never reaches WMLButtonDown - no node is ever hit tested.
  // FMX has no non-client area, so the header must be excluded explicitly, whether or
  // not HandleMessage claimed the click (it only does so for splitter/drag hits).
  // InHeader compares against HeaderRect = (0, 0, Width, Header.Height), which is
  // control local in FMX - the same space as PLocal - so no conversion is needed.
  if Header.InHeader(PLocal) then
    exit;

  FillTWMMouse(MM, Button, Shift, X, Y, isNC, false);
  // get information about the hit
  GetHitTestInfoAt(X, Y, True, hInfo);

  // A double click is a different event with its own handler, exactly as it is on the VCL,
  // where WM_LBUTTONDBLCLK arrives instead of WM_LBUTTONDOWN and WMLButtonDblClk calls
  // HandleMouseDblClick. FMX has one MouseDown for both, so the two are told apart here.
  //
  // HandleMouseDblClick fires OnNodeDblClick, toggles or edits the node and stops there.
  // HandleMouseDown must NOT also run: its last statement is BeginDrag(False), which arms a
  // drag on the very press that opens the node editor - and the editor then takes the mouse,
  // so no MouseUp reaches the tree to disarm it and the next mouse move starts dragging.
  if ssDouble in Shift then
  begin
    DoStateChange([tsLeftDblClick]);
    try
      // Fires OnDblClick, which TControl.DblClick would have done. Ahead of the tree's own
      // handling, the order the VCL's WMLButtonDblClk produces.
      DblClick;
      HandleMouseDblClick(MM, hInfo);
    finally
      DoStateChange([], [tsLeftDblClick]);
    end;
    Exit; //!!!
  end;

  HandleMouseDown(MM, hInfo);

  // A press and hold is a countdown that MouseUp, a move or a recognised gesture cancels.
  // The hit is remembered now, because by the time the countdown runs out nothing is tracking
  // the pointer any more. A right click is not decided here - see MouseUp.
  if (Button = TMouseButton.mbLeft) and
     (FPopupTrigger in [ptLongPress, ptRightClickOrLongPress]) and
     (FPopupDelay > 0) then
  begin
    FPopupNode := hInfo.HitNode;
    FPopupColumn := hInfo.HitColumn;
    FPopupPos := PointF(X, Y);
    StartPopupTimer;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.MouseUp(Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single); //wymaga BaseTree
Var MM: TWMMouse;
  hInfo: THitInfo;
  P: VirtualTrees.FMX.TPoint;
  isNC: Boolean;
  Msg: TMessage;
  PLocal: VirtualTrees.FMX.TPoint;
  WasDragging: Boolean;
begin
  StopPopupTimer;

  // Read before HandleMouseUp below, which is what ends a drag and clears the flag. A drag
  // started with the right button - which TBaseVirtualTree.HandleMouseDown allows, on both
  // platforms - ends on a right button release, and that release is not also a right click:
  // the same reasoning as PopupTimerProc, which stands down once a drag has begun.
  WasDragging := tsVCLDragging in TreeStates;

  // The counterpart of the OnMouseDown call in MouseDown: this override does not call
  // inherited either, so TControl never fires OnMouseUp.
  if Assigned(OnMouseUp) then
    OnMouseUp(Self, Button, Shift, X, Y);

  P.X:= X;
  P.Y:= Y;
  PLocal:= P; // P is replaced by screen coordinates below when isNC
  if ClientRect.Contains(P) then
    begin
      isNc:= false;
    end else
    begin
      isNC:= true;
      P:= ClientToScreen(P);
    end;
  FillTWMMouse(MM, Button, Shift, P.X, P.Y, isNC, true);

  Msg := TWMMouseToTMessage(MM);
  if TVTHeaderCracker(header).HandleMessage(Msg) then
    exit;//!!!

  // See the comment in MouseDown. A release above the control (Y < 0) while captured is
  // not in the header, so it still reaches HandleMouseUp, as it would in VCL.
  if Header.InHeader(PLocal) then
    exit;

  FillTWMMouse(MM, Button, Shift, X, Y, isNC, true);
  // get information about the hit
  GetHitTestInfoAt(X, Y, True, hInfo);
  HandleMouseUp(MM, hInfo);

  // The context menu of a right click belongs on the release, which is where Windows puts it
  // and where the VCL tree's own WMRButtonUp puts it. Opening it on the press meant the
  // release that followed counted as a click outside the popup and closed it again.
  if (Button = TMouseButton.mbRight) and not WasDragging and
     (FPopupTrigger in [ptRightClick, ptRightClickOrLongPress]) then
  begin
    FPopupNode := hInfo.HitNode;
    FPopupColumn := hInfo.HitColumn;
    FPopupPos := PointF(X, Y);
    DoContextMenu;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); //wymaga BaseTree
Var M: TCMMouseWheel;
  P: VirtualTrees.FMX.TPoint;
begin
  P:= Screen.MousePos;
  if not ClientRect.Contains(P) then
	P:= ClientToScreen(P);

  M.Msg:= CM_MOUSEWHEEL;
  M.ShiftState:= Shift;
  M.WheelDelta:= WheelDelta;
  M.XPos:= P.X;
  M.YPos:= P.Y;
  M.Result:= 0;
  CMMouseWheel(M);
  Handled:= M.Result<>0;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTAncestorFMX.PrepareDottedBrush(CurrentDottedBrush: TStrokeBrush; Bits: Pointer; const BitsLinesCount: Word): TStrokeBrush;

// Builds both dotted brushes and returns the tree line one; the caller assigns it to
// DottedBrushTreeLines, and the grid line one is stored here directly.
//
// Both fields are cleared before either old brush is released, and only then are the old objects
// freed through local references. That ordering is what makes the destructor safe: nothing can
// leave a freed pointer in a field, so a failure anywhere in the loop below cannot turn into a
// second Free at destruction time. CurrentDottedBrush is a by-value copy of DottedBrushTreeLines,
// which is why that field has to be cleared here rather than left to the caller's assignment.

Var PatternBitmap: TBitmap;
  i_bmp, line, bit: Integer;
  BitmapData: TBitmapData;
  OldGridBrush: TStrokeBrush;
begin
  //FMX pattern brush is different then VCL. Where color is derived from current one...
  //We should have 2 brushes 1 for Tree lines 1 for grid lines
  //and recreate it every time when color is changing

  OldGridBrush := DottedBrushGridLines;
  DottedBrushTreeLines := nil;
  DottedBrushGridLines := nil;

  CurrentDottedBrush.Free;
  OldGridBrush.Free;

  Result := nil;
  for i_bmp:= 1 to 2 do
    begin
      PatternBitmap := TBitmap.Create(8, BitsLinesCount);
      try
        PatternBitmap.Clear(TAlphaColorRec.Null); //fully transparent
        PatternBitmap.Canvas.BeginScene;

        PatternBitmap.Map(TMapAccess.Write, BitmapData);
        try
          {
          DestPitch := PixelFormatBytes[PatternBitmap.PixelFormat];
          System.Move(PAlphaColorArray(BitmapData.Data)[0], PAlphaColorArray(Bits)[0], 8 * 4);
          }
          for line:= 0 to BitsLinesCount-1 do
            begin
              for bit:= 0 to 7 do
                begin
                  if PWordArray(Bits)^[line] and (1 shl bit)=0 then
                    BitmapData.SetPixel(bit, line, clWhite) else
                    begin
                      if i_bmp=1 then
                        BitmapData.SetPixel(bit, line, Colors.TreeLineColor) else
                        BitmapData.SetPixel(bit, line, Colors.GridLineColor);
                    end;
                end;
            end;
        finally
          PatternBitmap.UnMap(BitmapData);
        end;

        PatternBitmap.Canvas.EndScene;

        if i_bmp=1 then
          begin
            Result := TStrokeBrush.Create(TBrushKind.Bitmap, clWhite);
            Result.Bitmap.Bitmap.Assign(PatternBitmap);
          end else
          begin
            DottedBrushGridLines := TStrokeBrush.Create(TBrushKind.Bitmap, clWhite);
            DottedBrushGridLines.Bitmap.Bitmap.Assign(PatternBitmap);
          end;
      finally
        FreeAndNil(PatternBitmap);
      end;
    end;					 
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.Resize;
Var M: TWMSize;
begin
  inherited;

  if FInCreate then
    exit; //!!

  // VCL hands every message to TVTHeader.HandleMessage before the tree's own handler runs, and
  // the header's WM_SIZE branch is the only thing that re-runs AdjustAutoSize - without it an
  // hoAutoResize column does not follow the control. Header first, then the tree, which is the
  // same order as WndProc.
  SyncHeaderToClientArea;

  M.Msg:= WM_SIZE;
  M.SizeType:= SIZE_RESTORED;
  M.Width:= Width;
  M.Height:= Height;
  M.Result:= 0;
  WMSize(M);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.VScrollChangeProc(Sender: TObject);
Var M: TWMHScroll;
begin
  M.Msg:= WM_VSCROLL;
  M.ScrollCode:= SB_THUMBPOSITION;
  M.Pos:= GetScrollPos(SB_VERT);
  M.ScrollBar:= SB_VERT;
  M.Result:= 0;

  WMVScroll(M);
  Repaint;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.StopFling;

// Halts a running fling but remembers how fast it was going, so that a flick which
// follows straight after can add to it instead of starting from zero.

begin
  if FInertiaTimer.Enabled then begin
    FCarryVelocity := FInertiaVelocity;
    FCarryTick := TThread.GetTickCount64;
    FInertiaTimer.Enabled := False;
  end;
  FInertiaVelocity := PointF(0, 0);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTAncestorFMX.PanBy(ADeltaX, ADeltaY: Single): Boolean;

// Moves the view by the given pixel delta and reports whether it actually moved.
// A single OffsetXY assignment, not one per axis: OffsetX and OffsetY each trigger a
// full scrollbar update and repaint of their own.
// DoSetOffsetXY already clamps to ClientWidth - FRangeX and ClientHeight - FRangeY,
// so no range checking belongs here.
// Point() is qualified because System.Types comes last in the uses clause, and its
// integer Point() would otherwise hide the Single one in VirtualTrees.FMX.

var
  AOldX, AOldY: Single;
begin
  AOldX := OffsetX;
  AOldY := OffsetY;

  OffsetXY := TPointF.Create(AOldX + ADeltaX, AOldY + ADeltaY);

  Result := (OffsetX <> AOldX) or (OffsetY <> AOldY);
  if Result then begin
    Repaint;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.HandleGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
  var Handled: Boolean);

// Touch panning, both axes, tracked 1:1 with the finger.
//
// This is what TControl.OnGesture holds for the lifetime of the tree, so an application
// handler - assigned to the redeclared OnGesture property and called below, ahead of the
// tree's own panning - can answer the gestures it cares about without the list losing the
// ability to scroll. A handler that sets Handled takes the gesture completely, panning
// included. A drag in progress comes before both.
//
// Both axes matter: with columns wider than the screen the horizontal scrollbar is the only
// other way to move sideways, and it is a poor target for a finger. Panning by pixel rather than
// by synthetic mouse wheel also keeps the content under the finger, since CMMouseWheel rounds to
// whole notches and then again to whole lines.
//
// EventInfo.Location is only ever used to form deltas, so it does not matter whether a given
// platform reports it in screen or in local coordinates.
//
// The platform's own InertiaVector is deliberately ignored: it is absent on some targets and
// scaled differently on others. The velocity is measured here instead.

const
  cVelocityBlend = 0.7;   // weight of the newest sample, smooths jittery input
  cMinFlingSpeed = 0.15;  // px/ms, below this a lift-off is a tap and not a fling
  cPanGain       = 1.0;   // 1.0 = content follows the finger exactly. Raise to cheat.
  cFlingGain     = 3.0;   // lift-off speed multiplier, how far a hard flick throws the list
  cMaxFlingSpeed = 20.0;  // px/ms ceiling, keeps a wild flick from taking seconds to settle
  cCarryFactor   = 0.8;   // how much of an interrupted fling carries into the next one
  cCarryWindowMs = 600;   // a stale carry speed is ignored after this long
var
  ADeltaX, ADeltaY: Single;
  AElapsed: Int64;
  ANow: UInt64;
begin
  // A column resize or a column reorder is a horizontal drag on the header, and the platform
  // is perfectly happy to recognise that as a swipe. The finger is on the header, not on a
  // row, so nothing below may act on the node under it, and the application handler must not
  // even be asked - in the demo, dragging column 1 wider turned into a delete of the selected
  // node. Handled, so the gesture does not travel on to a parent scrolling container either.
  //
  // FPressInHeader, not Header.States alone: a mouse-built gesture arrives when the drag ends,
  // after the header has cleared its states, so the state test alone catches nothing. The flag
  // is set in MouseDown and holds until the next press.
  //
  // Ahead of CancelPendingSelectFMX as well: a header drag never made a selection pending in
  // the first place, and cancelling one that belongs to the row underneath would be wrong.
  if FPressInHeader or (Header.States <> []) then begin
    Handled := True;
    Exit; //!!!
  end;

  // Any recognised gesture means the press was part of something larger than a tap, so the
  // node it landed on was never chosen. First of all, and whatever the gesture turns out to
  // be: a swipe may take the touch with it - a touch platform does not always follow a
  // consumed gesture with a MouseUp - and a selection left pending would then land on the next
  // release, on whatever row happened to be under the finger by then.
  CancelPendingSelectFMX;
  StopPopupTimer;

  // A drag'n drop in progress owns the finger, and that holds for every gesture rather than for
  // panning alone. Panning would move the node and the list under it by the same amount, so the
  // node never goes anywhere relative to the rows; and a swipe, a zoom or anything else an
  // application recognises would be acting on a finger that is already carrying a node.
  // Scrolling during a drag is still possible - the tree does it itself, and only near the top
  // and bottom of the visible area (UpdateDragScrollFMX in VirtualTrees.BaseTree).
  //
  // This sits ahead of the application handler, so a handler never sees a gesture the drag has
  // claimed. Handled := True so the gesture is not passed on to a parent scrolling container
  // either.
  if tsVCLDragging in TreeStates then begin
    Handled := True;
    Exit;
  end;

  if Assigned(FOnUserGesture) then begin
    FOnUserGesture(Self, EventInfo, Handled);
    if Handled then
      Exit; //!!!
  end;

  if EventInfo.GestureID <> igiPan then Exit;

  // A pan while a drag is only PENDING means the user is scrolling, not picking something up.
  // Say so before moving anything: MouseMove reaches the same conclusion on its own, but there
  // is no guarantee it fires at all once the platform has claimed the touch for a gesture, and
  // without this the hold countdown would go off in the middle of a scroll.
  if tsVCLDragPending in TreeStates then
    CancelPendingDragFMX;

  if TInteractiveGestureFlag.gfBegin in EventInfo.Flags then begin
    FIsScrolling := True;
    FLastGesturePoint := EventInfo.Location;
    FLastGestureTick := TThread.GetTickCount64;
    StopFling;  // a new touch always stops a running fling, but its speed is kept
  end else if FIsScrolling then begin
    ADeltaX := EventInfo.Location.X - FLastGesturePoint.X;
    ADeltaY := EventInfo.Location.Y - FLastGesturePoint.Y;

    // The other half of the measurement MouseMove starts - see AccumulatePressTravel.
    AccumulatePressTravel(ADeltaX, ADeltaY);

    ANow := TThread.GetTickCount64;
    AElapsed := Int64(ANow - FLastGestureTick);
    if AElapsed < 1 then begin
      AElapsed := 1;  // two samples in the same millisecond, avoid dividing by zero
    end;

    PanBy(ADeltaX * cPanGain, ADeltaY * cPanGain);

    // Smoothed px/ms velocity, so gfEnd can hand a sensible speed to the inertia timer.
    FInertiaVelocity.X := cVelocityBlend * (ADeltaX / AElapsed) + (1 - cVelocityBlend) * FInertiaVelocity.X;
    FInertiaVelocity.Y := cVelocityBlend * (ADeltaY / AElapsed) + (1 - cVelocityBlend) * FInertiaVelocity.Y;

    FLastGesturePoint := EventInfo.Location;
    FLastGestureTick := ANow;
  end;

  if TInteractiveGestureFlag.gfEnd in EventInfo.Flags then begin
    FIsScrolling := False;

    // Only fling if the finger was still moving on lift-off. Starting the timer after a
    // slow drag just burns frames doing nothing.
    if (Abs(FInertiaVelocity.X) < cMinFlingSpeed) and (Abs(FInertiaVelocity.Y) < cMinFlingSpeed) then begin
      FInertiaTimer.Enabled := False;
      FCarryVelocity := PointF(0, 0);
      Exit;
    end;

    FInertiaVelocity.X := FInertiaVelocity.X * cFlingGain;
    FInertiaVelocity.Y := FInertiaVelocity.Y * cFlingGain;

    // Flick again while the list is still gliding and the speeds add up, the way a long
    // touch list is expected to behave. One fling can only ever cover
    // cMaxFlingSpeed * Interval / (1 - cDecayPerTick) pixels, so on a list of thousands
    // of rows this compounding is what actually gets you from one end to the other.
    if (TThread.GetTickCount64 - FCarryTick) <= cCarryWindowMs then begin
      if Sign(FCarryVelocity.X) = Sign(FInertiaVelocity.X) then begin
        FInertiaVelocity.X := FInertiaVelocity.X + FCarryVelocity.X * cCarryFactor;
      end;
      if Sign(FCarryVelocity.Y) = Sign(FInertiaVelocity.Y) then begin
        FInertiaVelocity.Y := FInertiaVelocity.Y + FCarryVelocity.Y * cCarryFactor;
      end;
    end;
    FCarryVelocity := PointF(0, 0);

    FInertiaVelocity.X := EnsureRange(FInertiaVelocity.X, -cMaxFlingSpeed, cMaxFlingSpeed);
    FInertiaVelocity.Y := EnsureRange(FInertiaVelocity.Y, -cMaxFlingSpeed, cMaxFlingSpeed);

    FInertiaTimer.Enabled := True;
  end;

  Handled := True;
end;

procedure TVTAncestorFMX.HandleInertiaTimer(Sender: TObject);

// Kinetic scrolling after the finger has left the screen.
//
// FInertiaVelocity is px/ms in both axes, so the distance for one tick is simply
// velocity * interval. Decelerating the velocity rather than a wheel-notch count is what makes a
// hard flick glide further than a gentle one.

const
  cDecayPerTick = 0.975;  // 2.5 % slower per 16 ms frame. Lower it for a shorter glide.
  cStopSpeed    = 0.05;   // px/ms, below this the movement is invisible anyway
begin
  // Second line of defence behind Destroy: a timer message can already be in the queue when
  // destruction starts.
  if csDestroying in ComponentState then begin
    FInertiaTimer.Enabled := False;
    Exit;
  end;

  // Stop as soon as the tree cannot move any further, otherwise the timer keeps running
  // against the clamp in DoSetOffsetXY for the rest of the decay.
  if not PanBy(FInertiaVelocity.X * FInertiaTimer.Interval,
               FInertiaVelocity.Y * FInertiaTimer.Interval) then begin
    FInertiaTimer.Enabled := False;
    FInertiaVelocity := PointF(0, 0);
    Exit;
  end;

  FInertiaVelocity.X := FInertiaVelocity.X * cDecayPerTick;
  FInertiaVelocity.Y := FInertiaVelocity.Y * cDecayPerTick;

  if (Abs(FInertiaVelocity.X) < cStopSpeed) and (Abs(FInertiaVelocity.Y) < cStopSpeed) then begin
    FInertiaTimer.Enabled := False;
    FInertiaVelocity := PointF(0, 0);
  end;
end;

procedure TVTAncestorFMX.HScrollChangeProc(Sender: TObject);
Var M: TWMHScroll;
begin
  M.Msg:= WM_HSCROLL;
  M.ScrollCode:= SB_THUMBPOSITION;
  M.Pos:= GetScrollPos(SB_HORZ);
  M.ScrollBar:= SB_HORZ;
  M.Result:= 0;

  WMHScroll(M);
  Repaint;
end;

//----------------------------------------------------------------------------------------------------------------------

constructor TVTAncestorFMX.Create(AOwner: TComponent);
begin
  FInCreate:= true;

  inherited;

  BackgroundOffsetX:= 0;
  BackgroundOffsetY:= 0;
  Margin:= 4;
  TextMargin:= 4;
  Indent:= 18; //???

  // Enable pan gesture
  Touch.InteractiveGestures := [TInteractiveGesture.Pan];

  // The tree's own handler, and the only thing TControl.OnGesture ever holds: this class
  // redeclares OnGesture, so an application assigning it lands in FOnUserGesture and
  // HandleGesture calls that itself. Written through a cracker because the redeclaration
  // hides the inherited property by name.
  TControlCracker(Self).OnGesture := HandleGesture;

  // Setup inertia timer
  FInertiaTimer := TTimer.Create(Self);
  FInertiaTimer.Enabled := False;
  FInertiaTimer.Interval := 16;  // Approx. 60 FPS
  FInertiaTimer.OnTimer := HandleInertiaTimer;

  FPopupDelay := cDefaultPopupDelay;
{$IFDEF MSWINDOWS}
  FPopupTrigger := ptRightClickOrLongPress;
{$ELSE}
  FPopupTrigger := ptLongPress;
{$ENDIF}

  FInCreate:= false;
end;

procedure TVTAncestorFMX.SyncHeaderToClientArea;

// Hands the header a synthetic WM_SIZE, which is the only thing that makes
// TVirtualTreeColumns.AdjustAutoSize re-run. Called whenever the usable client width
// changes: on a control resize and on a scrollbar appearing or disappearing.
//
// Only Msg is filled in. The header's WM_SIZE branch reads nothing else, and building a
// full TWMSize here would mean relying on that record having the same layout as TMessage,
// which it does not have to on FMX.
//
// The guard is not optional: AdjustAutoSize -> SetWidth -> DoColumnResize ->
// UpdateHorizontalScrollBar -> ShowScrollBar comes straight back here.

var
  Msg: TMessage;
begin
  if FInCreate or FInClientAreaSync then
    Exit; //!!!
  if not Assigned(Header) then
    Exit; //!!!

  FInClientAreaSync := True;
  try
    Msg := Default(TMessage);
    Msg.Msg := WM_SIZE;
    TVTHeaderCracker(Header).HandleMessage(Msg);
  finally
    FInClientAreaSync := False;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TVTAncestorFMX.Destroy;

// A fling that is still running when the window closes would keep ticking into a control that is
// being torn down. The timer is owned by this control, so it is not destroyed until
// TComponent.DestroyComponents at the very end of the inherited destructor - by which time the
// node store, the header and the options are already gone.

begin
  if Assigned(FInertiaTimer) then begin
    FInertiaTimer.Enabled := False;
    FInertiaTimer.OnTimer := nil;   // A message already queued cannot find its way back in.
  end;
  if Assigned(FPopupTimer) then begin
    FPopupTimer.Enabled := False;
    FPopupTimer.OnTimer := nil;
  end;
  // A pending cut or copy must not outlive the tree it came from.
  if GClipSource = Self then
    GClipSource := nil;
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTAncestorFMX.GetClipboardText: string;
begin
  Result := '';
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.CopyToClipboard;
begin
  InternalCutOrCopy(False);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.CutToClipboard;
begin
  // The toReadOnly test is repeated from TBaseVirtualTree.CutToClipboard rather than reached
  // through inherited: this is the most derived override, so inherited would run after the
  // work rather than instead of it.
  if toReadOnly in TreeOptions.MiscOptions then
    Exit;
  InternalCutOrCopy(True);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.InternalCutOrCopy(ACut: Boolean);

// Marks the selection and publishes it two ways: as text on the system clipboard for other
// applications, and as a reference for a paste inside this one. Nothing is deleted here,
// even for a cut - the VCL model is that a cut is a promise redeemed by a paste, and if no
// paste follows, the marks are simply cleared and nothing was lost.

var
  LClip: IFMXClipboardService;
  LText: string;
begin
  if SelectedCount = 0 then
    Exit;

  // A cut or copy REPLACES the pending set, it does not add to it. MarkCutCopyNodes only ever
  // ORs vsCutOrCopy into the current selection, so without this a second cut would leave the
  // first one's nodes marked and a later paste would move those too. The stale marks are
  // invisible after a copy, because the ghosting is drawn for tsCutPending only.
  CancelCutOrCopy;
  if Assigned(GClipSource) and (GClipSource <> Self) then
    GClipSource.CancelCutOrCopy;   // The other tree's ghosting is stale now too.

  MarkCutCopyNodes;
  if ACut then
    DoStateChange([tsCutPending], [tsCopyPending])
  else
    DoStateChange([tsCopyPending], [tsCutPending]);

  GClipSource := Self;
  GClipIsCut := ACut;

  LText := GetClipboardText;   // After MarkCutCopyNodes: the set is what was just marked.
  if Assigned(FOnGetClipboardText) then
    FOnGetClipboardText(Self, LText);   // A draw tree has no text of its own to offer.
  if (LText <> '') and TryGetClipboardService(LClip) then
    LClip.SetClipboard(LText);

  Invalidate;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTAncestorFMX.PasteFromClipboard: Boolean;

// Two paths. If the last cut or copy came from a tree in this process and that tree is
// still alive, the real nodes are moved or copied - structure, check states and all - the
// way the VCL does it through its own clipboard format. Otherwise all that exists is text,
// which cannot be turned back into nodes, so it goes to OnPasteText.
//
// Copying nodes serializes them, so a tree whose node data holds managed types (a string,
// an interface, a dynamic array) must handle OnSaveNode and OnLoadNode or only the record's
// unmanaged fields survive. That is true of the VCL as well.

var
  LSource: TVTAncestorFMX;
  LNodes, LPasted: TNodeArray;
  LTarget, LNew: PVirtualNode;
  LMode: TVTNodeAttachMode;
  LClip: IFMXClipboardService;
  LValue: TValue;
  LHandled, LCut: Boolean;
  I, N: Integer;
begin
  Result := False;
  if toReadOnly in TreeOptions.MiscOptions then
    Exit;

  LSource := GClipSource;
  if Assigned(LSource) then begin
    LNodes := LSource.GetSortedCutCopySet(True);
    if Length(LNodes) > 0 then begin
      LCut := GClipIsCut;
      LTarget := FocusedNode;
      if Assigned(LTarget) then
        LMode := DefaultPasteMode
      else
        LMode := amAddChildLast;   // No focused node, so the root of THIS tree.

      SetLength(LPasted, Length(LNodes));
      N := 0;
      BeginUpdate;
      try
        for I := 0 to High(LNodes) do begin

          if LCut and (LSource = Self) then begin
            // Within one tree a cut is a genuine move: the node keeps its identity, its data,
            // its children and its expanded state, and OnNodeMoving fires. MoveTo returns
            // nothing, but it does not have to - the pointer is still valid afterwards.
            if Assigned(LTarget) then
              LSource.MoveTo(LNodes[I], LTarget, LMode, False)
            else
              LSource.MoveTo(LNodes[I], Self, LMode, False);
            LNew := LNodes[I];
          end else begin
            if Assigned(LTarget) then
              LNew := LSource.CopyTo(LNodes[I], LTarget, LMode, False)
            else
              LNew := LSource.CopyTo(LNodes[I], Self, LMode, False);

            // A cut ACROSS two trees is copy-then-delete rather than MoveTo. MoveTo would
            // serialize the node into the target tree and hand back nothing, so there would
            // be no way to report which node was pasted. The cost is that OnNodeCopying and
            // OnFreeNode fire where OnNodeMoving would have.
            if LCut and Assigned(LNew) then
              LSource.DeleteNode(LNodes[I]);
          end;

          if Assigned(LNew) then begin
            LPasted[N] := LNew;
            System.Inc(N);
          end;
        end;
      finally
        EndUpdate;
      end;
      SetLength(LPasted, N);

      // Not FinishCutOrCopy: that deletes everything still marked, and after a move within
      // one tree the nodes are still marked and now live at the destination.
      LSource.CancelCutOrCopy;
      GClipSource := nil;

      // Selecting what was just pasted IS the status - it says where the nodes went without
      // the application writing a line - and it makes a second paste land relative to them
      // rather than to whatever happened to be focused before.
      if N > 0 then begin
        ClearSelection;
        for I := 0 to High(LPasted) do
          Selected[LPasted[I]] := True;
        FocusedNode := LPasted[0];
      end;
      if Assigned(FOnAfterPaste) then
        FOnAfterPaste(Self, LPasted, LCut);

      Result := True;
      Exit;
    end;
  end;

  if Assigned(FOnPasteText) and TryGetClipboardService(LClip) then begin
    LValue := LClip.GetClipboard;
    if not LValue.IsEmpty and LValue.IsType<string> then begin
      LHandled := False;
      FOnPasteText(Self, LValue.AsString, LHandled);
      Result := LHandled;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.ShowScrollBar(Bar: Integer; AShow: Boolean);

// In the VCL, showing or hiding a scrollbar changes the client area and Windows follows up with
// a WM_SIZE of its own accord. On FMX the control's own size does not change, so without this
// nothing tells the header that ClientWidth just moved by ScrollBarSize - filling an empty tree
// with nodes brings up the vertical scrollbar and the auto-sized column overlaps it until the
// next resize.

var
  OldH, OldV: Boolean;
begin
  OldH := HScrollBar.Visible;
  OldV := VScrollBar.Visible;

  inherited;

  if (HScrollBar.Visible <> OldH) or (VScrollBar.Visible <> OldV) then
    SyncHeaderToClientArea;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.StartPopupTimer;

// The touch half of PopupTrigger: the press only becomes a context gesture once the finger
// has stayed put for PopupDelay ms, the same shape as the tree's own drag countdown.

begin
  if not Assigned(FPopupTimer) then begin
    FPopupTimer := TTimer.Create(Self);
    FPopupTimer.OnTimer := PopupTimerProc;
  end;
  FPopupTimer.Enabled := False;      // restart the countdown if it was already running
  FPopupTimer.Interval := Integer(FPopupDelay);
  FPopupTimer.Enabled := True;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.StopPopupTimer;
begin
  if Assigned(FPopupTimer) then
    FPopupTimer.Enabled := False;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.PopupTimerProc(Sender: TObject);

// One shot, same pattern as the inertia and drag timers: disable first, then act.

begin
  StopPopupTimer;

  // The press may have ended between the countdown being armed and this firing.
  if TreeStates * [tsLeftButtonDown, tsMiddleButtonDown, tsRightButtonDown] = [] then
    Exit;

  // A drag that has already begun owns the finger. With the default delays DragDelay runs out
  // first, so press and hold picks a node up wherever dragging is enabled; PopupDelay below
  // DragDelay reverses that and opens the context menu instead.
  if tsVCLDragging in TreeStates then
    Exit;

  // Past here the hold IS the context gesture, so the drag it would otherwise have turned
  // into must not start on the next move.
  CancelPendingDragFMX;

  DoContextMenu;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.DoContextMenu;

// The handler runs first, so it can build the menu for the node the gesture landed on before
// anything is shown. Popup comes before PopupMenu because it is the one that works on every
// platform; nothing at all is shown when neither is assigned, which is what a tree that only
// wants the event gets.

var
  AScreenPos: TPointF;
begin
  if Assigned(FOnContextMenu) then
    FOnContextMenu(Self, FPopupNode, FPopupColumn, FPopupPos);

  if Assigned(FPopup) then begin
    // TPlacement.Mouse puts the menu where the pointer or the finger is, which is what a
    // context menu means and what saves converting anything.
    FPopup.Placement := TPlacement.Mouse;
    OpenPopupDeferred(FPopup);
  end else if Assigned(PopupMenu) then begin
    AScreenPos := ClientToScreen(FPopupPos);
    TPopupMenu(PopupMenu).PopupComponent := Self;
    TPopupMenu(PopupMenu).Popup(AScreenPos.X, AScreenPos.Y);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.SetPopup(const Value: TPopup);
begin
  if FPopup <> Value then begin
    FPopup := Value;
    if Assigned(FPopup) then
      FPopup.FreeNotification(Self);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FPopup) then
    FPopup := nil;
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.ShowPopupAt(const ALocalPos: TPointF);

// TPopup places itself in the coordinates of the scene, so the tree local point is converted
// first. A one pixel rectangle is enough: TPlacement.Absolute anchors the popup to its top
// left corner and the size is never used.

var
  AScenePos: TPointF;
begin
  if not Assigned(FPopup) then
    Exit;

  AScenePos := LocalToAbsolute(ALocalPos);
  FPopup.Placement := TPlacement.Absolute;
  FPopup.PlacementRectangle.Rect := TRectF.Create(AScenePos, 1, 1);
  OpenPopupDeferred(FPopup);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.OpenPopupDeferred(APopup: TPopup);

// A popup opened from inside MouseUp, or from the hold timer with the button still down, sees
// the rest of that same gesture as a click outside itself and closes again before it has been
// drawn. Queued, it opens once the input that asked for it has been dealt with.

begin
  TThread.ForceQueue(nil,
    procedure
    begin
      APopup.IsOpen := True;
    end);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.MouseMove(Shift: TShiftState; X: Single; Y: Single);

// A finger that moves is scrolling or dragging, not holding. HandleGesture catches the same
// thing once the platform recognises a pan, but a slow drift never becomes a gesture and
// would otherwise leave the countdown running.

begin
  AccumulatePressTravel(X - FTravelPos.X, Y - FTravelPos.Y);
  FTravelPos := PointF(X, Y);

  if Assigned(FPopupTimer) and FPopupTimer.Enabled and
     ((Abs(X - FPopupPos.X) > cPopupMoveTolerance) or
      (Abs(Y - FPopupPos.Y) > cPopupMoveTolerance)) then
    StopPopupTimer;

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTAncestorFMX.AccumulatePressTravel(ADeltaX, ADeltaY: Single);

// Path length, not net displacement: a finger that goes down and comes back up again has still
// travelled vertically, and that is what the question "was this a swipe or a list movement"
// turns on. Fed from MouseMove and from the pan gesture both, because a touch platform that has
// claimed the touch for a gesture does not promise to go on delivering mouse moves.
//
// The two sources may report in different coordinate spaces, which does not matter here: only
// the ratio between the axes is ever read, and both axes come from the same source each time.

begin
  FPressTravel.X := FPressTravel.X + Abs(ADeltaX);
  FPressTravel.Y := FPressTravel.Y + Abs(ADeltaY);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTAncestorFMX.GetClientHeight: Single;
begin
  Result:= ClientRect.Height;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTAncestorFMX.GetClientWidth: Single;
begin
  Result:= ClientRect.Width;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTAncestorFMX.GetClientRect: VirtualTrees.FMX.TRect;
begin
  Result:= ClipRect;
  if Assigned(Header) then
    begin
      if TVTHeaderOption.hoVisible in Header.Options then
        Result.Top := Result.Top + Header.Height;
    end;
  if FVScrollBar.Visible then
    Result.Right := Result.Right - VScrollBar.Width;
  if HScrollBar.Visible then
    Result.Bottom := Result.Bottom - HScrollBar.Height;

  if Result.Left>Result.Right then
    Result.Left:= Result.Right;

  if Result.Top>Result.Bottom then
    Result.Top:= Result.Bottom;
end;

end.
