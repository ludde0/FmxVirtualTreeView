unit uFormFmx;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, VirtualTrees,
  VirtualTrees.FMX, VirtualTrees.DrawTree, FMX.StdCtrls, FMX.Edit, VirtualTrees.Types,
  FMX.Controls.Presentation, FMX.Layouts, System.ImageList, FMX.ImgList,
  FMX.Objects, FMX.Gestures, FMX.ListBox;

type
  TFormFmx = class(TForm)
    Button_AddNodesAsChildren: TButton;
    Button_AddNodesToRoot: TButton;
    Button_ClearTree: TButton;
    Button_Close: TButton;
    Button_Test: TButton;
    CheckBox_CustomDraw: TCheckBox;
    CheckBox_DrawTree: TCheckBox;
    CheckBox_MultiLine: TCheckBox;
    CheckBox_MultiSelect: TCheckBox;
    ComboBox_LongPress: TComboBox;
    Edit_Filter: TEdit;
    Edit_NodeCount: TEdit;
    ImageList_Tree: TImageList;
    Label_AddNodes: TLabel;
    Label_Filter: TLabel;
    Label_LongPress: TLabel;
    Label_Status: TLabel;
    Label_Title: TLabel;
    Layout_AddNodes: TLayout;
    Layout_Bottom: TLayout;
    Layout_ClearTree: TLayout;
    Layout_Controls: TLayout;
    Layout_Drag: TLayout;
    Layout_Draw: TLayout;
    Layout_Main: TLayout;
    Layout_Top: TLayout;
    Layout_Tree: TLayout;
    Rectangle_Filter: TRectangle;
    procedure Button_AddNodesClick(Sender: TObject);
    procedure Button_ClearTreeClick(Sender: TObject);
    procedure Button_CloseClick(Sender: TObject);
    procedure Button_TestClick(Sender: TObject);
    procedure CheckBox_CustomDrawChange(Sender: TObject);
    procedure CheckBox_DrawTreeChange(Sender: TObject);
    procedure CheckBox_MultiLineChange(Sender: TObject);
    procedure CheckBox_MultiSelectChange(Sender: TObject);
    procedure ComboBox_LongPressChange(Sender: TObject);
    procedure Edit_FilterTyping(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FCheckedCount: Integer;           // Nodes touched by the check propagation in progress.
    FDrawTree: TVirtualDrawTree;
    FGestureManager: TGestureManager;
    FPopup: TPopup;                   // The context menu both trees share.
    FPopupCollapse: TButton;
    FPopupDelete: TButton;
    FPopupExpand: TButton;
    FPopupLabel: TLabel;              // Names the node the gesture landed on.
    FPopupNode: PVirtualNode;         // That node, for as long as the popup is open.
    FStringTree: TVirtualStringTree;
    FUseApplyColumnWidths: Boolean;
    FUseMultiline: Boolean;           // Wrap long captions, or shorten them with an ellipsis.
    FUserResizedColumns: Boolean;     // Once the user drags a column, stop imposing percentages.
    procedure AdjustSizes;
    procedure ApplyColumnWidths(const AColumnWidths: array of Single);
    procedure ApplyColumnWidthsTo(ATree: TBaseVirtualTree; const AColumnWidths: array of Single);
    function  ApplyFilter(ATree: TBaseVirtualTree; const AFilter: string): Integer;
    procedure ApplyLongPressOption(ATree: TBaseVirtualTree);
    procedure ApplyMultilineOption(ATree: TBaseVirtualTree);
    procedure ConfigureTree(ATree: TBaseVirtualTree);
    procedure CreateDrawTree;
    procedure CreatePopup;
    procedure CreateStringTree;
    function  GetActiveTree: TBaseVirtualTree;
    procedure HideOddRootNodes(ATree: TBaseVirtualTree);
    procedure PopupItemClick(Sender: TObject);
    procedure SetStatus(const AText: string);
    procedure VTAfterPaste(Sender: TObject; const APasted: TNodeArray; ACut: Boolean);
    procedure VTBeforeItemPaint(Sender: TBaseVirtualTree; Canvas: TCanvas; Node: PVirtualNode;
      Rect: TRect; var CustomDraw: Boolean);
    procedure VTChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VTChecking(Sender: TBaseVirtualTree; Node: PVirtualNode;
      var NewState: TCheckState; var Allowed: Boolean);
    procedure VTColumnResize(Sender: TVTHeader; Column: TColumnIndex);
    procedure VTCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode;
      Column: TColumnIndex; var Result: Integer);
    procedure VTContextMenu(Sender: TObject; Node: PVirtualNode; Column: TColumnIndex;
      const LocalPos: TPointF);
    procedure VTDragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      var Allowed: Boolean);
    procedure VTDragDrop(Sender: TBaseVirtualTree; Source: TObject; DataObject: TVTDragDataObject;
      Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure VTDragOver(Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState;
      State: TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
    procedure VTDropOutside(Sender: TBaseVirtualTree; const ScreenPos: TPointF;
      var Handled: Boolean);
    procedure VTDrawNode(Sender: TBaseVirtualTree; const PaintInfo: TVTPaintInfo);
    procedure VTFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VTGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
      var Handled: Boolean);
    procedure VTGetClipboardText(Sender: TObject; var AText: string);
    procedure VTGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: TImageIndex);
    procedure VTGetNodeWidth(Sender: TBaseVirtualTree; HintCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; var NodeWidth: TDimension);
    procedure VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure VTHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
    procedure VTIncrementalSearch(Sender: TBaseVirtualTree; Node: PVirtualNode;
      const SearchText: string; var Result: Integer);
    procedure VTInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
      var InitialStates: TVirtualNodeInitStates);
    procedure VTLoadNode(Sender: TBaseVirtualTree; Node: PVirtualNode; Stream: TStream);
    procedure VTMeasureItem(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
      var NodeHeight: TDimension);
    procedure VTNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: string);
    procedure VTNodeDblClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
    procedure VTPasteText(Sender: TObject; const AText: string; var Handled: Boolean);
    procedure VTSaveNode(Sender: TBaseVirtualTree; Node: PVirtualNode; Stream: TStream);
    procedure VTStateChange(Sender: TBaseVirtualTree; Enter, Leave: TVirtualTreeStates);
    /// <summary>
    /// The tree currently on screen. Every button, every resize and every diagnostic goes
    /// through this rather than naming a field, which is the whole reason two trees can
    /// share one form without an if-then at each call site.
    /// </summary>
    property  ActiveTree: TBaseVirtualTree read GetActiveTree;
    property  UseApplyColumnWidths: Boolean read FUseApplyColumnWidths write FUseApplyColumnWidths;
  end;

var
  FormFmx: TFormFmx;

function AdjSize(ASize: Integer; Factor: Single = 1.0): Integer; overload;
function AdjSize(ASize: Single; Factor: Single = 1.0): Single; overload;

implementation

{$R *.fmx}

uses System.TypInfo, System.StrUtils, FMX.DialogService,
  VirtualTrees.AncestorFMX, VirtualTrees.BaseAncestorFMX,
  VirtualTrees.Debug, VirtualTrees.BaseTree;
  // TypInfo: GetEnumName. StrUtils: ContainsText for the filter. DialogService: the
  // asynchronous confirmation the swipe gesture shows. AncestorFMX: TVTAncestorFMX for
  // the cracker.

const
  // Initial column widths as a fraction of the tree's usable width.
  // The last column always absorbs the rounding remainder, so these need
  // not add up to exactly 1.0 - but it looks better if they do.
  cColPercent: array [0 .. 1] of Single = (0.70, 0.30);

  cCustomDrawFontSize = 12.0;   // Logical units, scaled by AdjSize for Android.

  // Appended to every third caption, so the tree shows wrapped and unwrapped rows next to
  // each other. A uniform wall of two line nodes would not prove that the height is being
  // measured per node rather than simply doubled.
  cLongCaptionTail =
    ' - and this one carries a caption long enough that it cannot fit on a single line of ' +
    'the main column, which is the whole point: the row has to grow to hold it.';

  // Master switch for the checkbox demo. Check images are painted through the same
  // GetCheckImage/PaintCheckImage path as the VCL, so until that path exists on FMX
  // this either paints nothing or faults on a nil image list. One place to turn it off.
  cUseCheckSupport = True;

  // How many nodes of one check propagation are written to the log. A parent of 3000
  // children fires the check events 3000 times and the log is the slowest thing in reach.
  cMaxCheckLog = 5;

  // ComboBox_LongPress: what a press and hold on a touch screen does. The items are filled in
  // FormCreate so these indices and the captions cannot drift apart. See ApplyLongPressOption.
  cLongPressDrag  = 0;
  cLongPressPopup = 1;
  cLongPressItems: array [cLongPressDrag .. cLongPressPopup] of string =
    ('Drag', 'Context menu');

  // PopupDelay used where DragDelay is 0 and there is therefore no drag countdown to beat.
  cPopupDelayNoDrag = 500;   // ms

type
  // GetOffsets, GetCheckImage, PaintCheckImage and PaintNodeButton are protected. Custom
  // drawing needs all four, and reaching them through a cracker is far better than
  // reimplementing the layout: this way the box is painted exactly where the hit test
  // will later look for it.
  //
  // TVTAncestorFMX and not TBaseVirtualTree: a cracker only reaches what itself and its
  // OWN ancestors declare, and the clipboard events are declared one level below the base
  // tree, on the FMX ancestor that implements copy, cut and paste. Everything protected on
  // TBaseVirtualTree is still reachable, because TVTAncestorFMX descends from it.
  TVSTCracker = class(TVTAncestorFMX);

  // This is a very simple record we use to store data in the nodes.
  // Since the application is responsible to manage all data including the node's caption
  // this record can be considered as minimal requirement in all VT applications.
  // Extend it to whatever your application needs.
  PNodeData = ^TNodeData;
  TNodeData = record
    Caption: string;
  end;

function AdjSize(ASize: Integer; Factor: Single = 1.0): Integer;
begin
{$IF Defined(ANDROID) or Defined(IOS)}
  Result := Round(ASize * Factor * 1.35);
{$ELSE}
  Result := Round(ASize * Factor);
{$ENDIF}
end;

function AdjSize(ASize: Single; Factor: Single = 1.0): Single;
begin
{$IF Defined(ANDROID) or Defined(IOS)}
  Result := ASize * Factor * 1.35;
{$ELSE}
  Result := ASize * Factor;
{$ENDIF}
end;

function DraggedNodes(ATree: TBaseVirtualTree): TNodeArray;

// The nodes a drag actually carries. FocusedNode alone was never right for more than one node,
// and the tree's own FDragSelection is only filled by the OLE path (TBaseVirtualTree.DoDragging,
// inside {$IFDEF VT_VCL}) - a dtVCL drag never populates it on either platform. So the selection
// is read here instead, at the moment it is needed; nothing changes it while a drag is running.
//
// Resolve = True is the important argument: it drops any node whose parent is also in the set.
// A child travels with its parent, and moving it a second time in its own right would either
// undo the first move or hit MoveTo's SWrongMoveError.
//
// The fallback keeps the single node case working when nothing is selected at all - which is
// what happens with toMultiSelect off and a click that only focused a node.

begin
  Result := nil;
  if not Assigned(ATree) then Exit;
  Result := ATree.GetSortedSelection(True);
  if (Length(Result) = 0) and Assigned(ATree.FocusedNode) then begin
    SetLength(Result, 1);
    Result[0] := ATree.FocusedNode;
  end;
end;

function CheckStateToStr(const AState: TCheckState): string;
begin
  // GetEnumName rather than a case statement: the demo then cannot drift out of sync
  // with the enum, and a state added to the library still prints something readable.
  Result := GetEnumName(TypeInfo(TCheckState), Ord(AState));
end;

function MouseButtonToStr(const AButton: TMouseButton): string;
begin
  case AButton of
    TMouseButton.mbLeft:   Result := 'Left';
    TMouseButton.mbRight:  Result := 'Right';
    TMouseButton.mbMiddle: Result := 'Middle';
  else
    Result := 'Unknown';
  end;
end;

function DropModeToStr(const AMode: TDropMode): string;
begin
  case AMode of
    dmAbove:  Result := 'above';
    dmOnNode: Result := 'onto';
    dmBelow:  Result := 'below';
  else
    Result := 'nowhere (root)';
  end;
end;

function HitPositionToStr(const APositions: TVTHeaderHitPositions): string;
begin
  Result := '';
  if hhiNoWhere in APositions then Result := Result + 'NoWhere ';
  if hhiOnColumn in APositions then Result := Result + 'OnColumn ';
  if hhiOnIcon in APositions then Result := Result + 'OnIcon ';
  if hhiOnCheckbox in APositions then Result := Result + 'OnCheckbox ';
  Result := Trim(Result);
  if Result = '' then Result := '<empty>';
end;

function ShiftStateToStr(const AShift: TShiftState): string;
begin
  Result := '';
  if ssShift in AShift then Result := Result + 'Shift ';
  if ssAlt in AShift then Result := Result + 'Alt ';
  if ssCtrl in AShift then Result := Result + 'Ctrl ';
  if ssLeft in AShift then Result := Result + 'Left ';
  if ssRight in AShift then Result := Result + 'Right ';
  if ssMiddle in AShift then Result := Result + 'Middle ';
  if ssDouble in AShift then Result := Result + 'Double ';
  Result := Trim(Result);
  if Result = '' then Result := '<none>';
end;

procedure TFormFmx.AdjustSizes;
begin
  Layout_AddNodes.Height := AdjSize(Layout_AddNodes.Height);
  Layout_Bottom.Height := AdjSize(Layout_Bottom.Height);
  Layout_ClearTree.Height := AdjSize(Layout_ClearTree.Height);
  Layout_Drag.Height := AdjSize(Layout_Drag.Height);
  Layout_Controls.Height := AdjSize(Layout_Controls.Height);
  Layout_Draw.Height := AdjSize(Layout_Draw.Height);
  Layout_Top.Height := AdjSize(Layout_Top.Height);
  CheckBox_CustomDraw.Width := AdjSize(CheckBox_CustomDraw.Width);
  CheckBox_DrawTree.Width := AdjSize(CheckBox_DrawTree.Width);
  CheckBox_MultiSelect.Width := AdjSize(CheckBox_MultiSelect.Width);
  CheckBox_MultiLine.Width := AdjSize(CheckBox_MultiLine.Width);
  ComboBox_LongPress.Width := AdjSize(ComboBox_LongPress.Width);
  Label_LongPress.Width := AdjSize(Label_LongPress.Width);
  Label_Title.Width := AdjSize(Label_Title.Width);
  Label_Filter.Width := AdjSize(Label_Filter.Width);
  Label_AddNodes.Width := AdjSize(Label_AddNodes.Width);
  Button_AddNodesAsChildren.Width := AdjSize(Button_AddNodesAsChildren.Width);
  Edit_NodeCount.Width := AdjSize(Edit_NodeCount.Width);
  Button_AddNodesToRoot.Width := AdjSize(Button_AddNodesToRoot.Width);
  Button_ClearTree.Width := AdjSize(Button_ClearTree.Width);
  Button_Close.Width := AdjSize(Button_Close.Width);
  Button_Test.Width := AdjSize(Button_Test.Width);
end;

procedure TFormFmx.ApplyColumnWidths(const AColumnWidths: array of Single);

// BOTH trees, not just the visible one. The hidden tree still has a header, and if it is
// left out it comes back on screen with the widths it had when it was last shown.

begin
  ApplyColumnWidthsTo(FStringTree, AColumnWidths);
  ApplyColumnWidthsTo(FDrawTree, AColumnWidths);
end;

procedure TFormFmx.ApplyColumnWidthsTo(ATree: TBaseVirtualTree; const AColumnWidths: array of Single);
const
  cMinUsableWidth = 50;     // Below this the form is not laid out yet.
var
  Avail: Single;
  I, W, Used: Integer;
begin
  if not FUseApplyColumnWidths or not Assigned(ATree) then Exit;

  if Length(AColumnWidths) <> ATree.Header.Columns.Count then begin
    raise Exception.Create('Array of column widths must correspond to "Header.Columns.Count"');
  end;

  if FUserResizedColumns then Exit;
  if ATree.Header.Columns.Count = 0 then Exit;

  // ClientWidth of a hidden tree is still meaningful - it is aligned to the same layout as
  // the visible one - but during startup it can be zero, hence the guard below.
  Avail := ATree.ClientWidth;
  if Avail < cMinUsableWidth then Exit;   // Not laid out yet - we will be called again on resize.

  Used := 0;
  for I := 0 to ATree.Header.Columns.Count - 2 do begin
    if I > High(AColumnWidths) then Break;
    W := Round(Avail * AColumnWidths[I]);
    ATree.Header.Columns[I].Width := W;
    Used := Used + W;
  end;

  // The last column takes whatever is left
  W := Round(Avail) - Used;
  if W < AdjSize(20) then W := AdjSize(20);
  ATree.Header.Columns[ATree.Header.Columns.Count - 1].Width := W;
end;

function TFormFmx.ApplyFilter(ATree: TBaseVirtualTree; const AFilter: string): Integer;

// Hides every node whose caption does not contain AFilter, and returns how many did match.
// An empty filter clears the whole thing.
//
// Filtering is a per node flag, not a separate list: IsFiltered puts vsFiltered into the
// node's states and the tree then skips it while painting and while walking the visible
// nodes. It stays in the structure, so GetFirst/GetNext below still reach it.
//
// Two passes, because a match deep in the tree is worthless if its parents stay hidden.
// The first hides everything, the second re-shows each match and walks up its parent chain
// re-showing and expanding those as well.
//
// GetFirst and GetNext rather than the NoInit versions: an uninitialised node has no data
// record yet, so there would be no caption to match against.

var
  LNode: PVirtualNode;
  LParent: PVirtualNode;
  LData: PNodeData;
  LText: string;
begin
  Result := 0;
  if not Assigned(ATree) then Exit;

  LText := Trim(AFilter);
  ATree.BeginUpdate;
  try
    LNode := ATree.GetFirst;
    while Assigned(LNode) do begin
      ATree.IsFiltered[LNode] := LText <> '';
      LNode := ATree.GetNext(LNode);
    end;

    if LText = '' then Exit;

    LNode := ATree.GetFirst;
    while Assigned(LNode) do begin
      LData := ATree.GetNodeData(LNode);
      if Assigned(LData) and ContainsText(LData.Caption, LText) then begin
        Inc(Result);
        ATree.IsFiltered[LNode] := False;
        LParent := LNode.Parent;
        while Assigned(LParent) and (LParent <> ATree.RootNode) do begin
          ATree.IsFiltered[LParent] := False;
          ATree.Expanded[LParent] := True;
          LParent := LParent.Parent;
        end;
      end;
      LNode := ATree.GetNext(LNode);
    end;
  finally
    ATree.EndUpdate;
  end;
end;

procedure TFormFmx.ApplyLongPressOption(ATree: TBaseVirtualTree);

// A touch screen has exactly one press-and-hold gesture, and two things want it: picking a node
// up to drag it, and opening the context menu. There is no arrangement in which both work, so
// the application has to say which, and this demo puts that choice in ComboBox_LongPress.
//
// Both are timers started by the same press, and whichever runs out first wins - see
// TBaseVirtualTree.DragDelayTimerFMX and TVTAncestorFMX.PopupTimerProc, which bails out when a
// drag has already begun. So the switch is simply which delay is shorter:
//
//   Drag         - PopupTrigger drops the long press and keeps the right click, so nothing
//                  competes with DragDelay. On Android that means no context menu at all, which
//                  is the honest consequence of giving the gesture to dragging.
//   Context menu - the long press comes back and PopupDelay goes below DragDelay, so the menu
//                  opens and the pending drag is cancelled. Dragging still works on the desktop,
//                  where a press and a drag are told apart by the mouse moving.
//
// Leaving DragDelay alone in both cases: it is what stops a scrolling swipe from turning into a
// drag, and that is needed whichever way the hold is spent.

const
  cPopupBeforeDrag = 150;   // ms the menu should beat the drag by, to be unambiguous
var
  LT: TVSTCracker;
begin
  if not Assigned(ATree) then Exit;   // Called from the combobox before the trees exist.

  LT := TVSTCracker(ATree);
  if ComboBox_LongPress.ItemIndex = cLongPressPopup then begin
    LT.PopupTrigger := ptRightClickOrLongPress;
    if LT.DragDelay = 0 then begin
      // Desktop: no drag countdown to beat, so the hold can take its own time.
      LT.PopupDelay := cPopupDelayNoDrag;
    end else if LT.DragDelay > cPopupBeforeDrag then begin
      LT.PopupDelay := LT.DragDelay - cPopupBeforeDrag;
    end else if LT.DragDelay > 1 then begin
      LT.PopupDelay := LT.DragDelay div 2;
    end else begin
      // Never 0 - that switches the long press off however PopupTrigger is set.
      LT.PopupDelay := 1;
    end;
  end else begin
    LT.PopupTrigger := ptRightClick;
  end;
end;

procedure TFormFmx.ApplyMultilineOption(ATree: TBaseVirtualTree);

// Both halves of the switch in one place, because the option and the node states have to
// agree: toVariableNodeHeight is what makes the tree ask how tall each row is, and the
// per-node vsMultiline is what makes the string tree wrap rather than shorten. Turning the
// option off alone would leave the nodes marked multiline and measured tall.
//
// The captions and vsMultiline both come from OnInitNode, so the nodes are initialised again
// - ForceReinit, or already initialised ones are left as they are.

var
  LT: TVSTCracker;
begin
  if not Assigned(ATree) then Exit;   // Called from the checkbox before the trees exist.

  LT := TVSTCracker(ATree);
  LT.BeginUpdate;
  try
    if FUseMultiline then begin
      LT.TreeOptions.MiscOptions := LT.TreeOptions.MiscOptions + [toVariableNodeHeight];
    end else begin
      LT.TreeOptions.MiscOptions := LT.TreeOptions.MiscOptions - [toVariableNodeHeight];
    end;
    LT.ReinitNode(nil, True, True);
  finally
    LT.EndUpdate;
  end;
  LT.Invalidate;
end;

procedure TFormFmx.Button_AddNodesClick(Sender: TObject);
var
  Count: Integer;
  Start: UInt64;
  No   : Integer;
  LTree: TBaseVirtualTree;
begin
  // Add some nodes to the treeview.
  Start := TThread.GetTickCount64;
  No := (Sender as TButton).Tag;

  Count := StrToIntDef(Edit_NodeCount.Text, 0);
  if Count <= 0 then begin
    SetStatus('Node count must be a positive number.');
    Exit;
  end;

  LTree := ActiveTree;   // Whichever tree the Draw tree checkbox is currently showing.

  case No of
    0: begin // add to root
      LTree.BeginUpdate;
      try
        TVSTCracker(LTree).RootNodeCount := TVSTCracker(LTree).RootNodeCount + Cardinal(Count);
      finally
        LTree.EndUpdate;
      end;
      HideOddRootNodes(LTree);
    end;
    1: begin // add as child
      if Assigned(LTree.FocusedNode) then begin
        LTree.BeginUpdate;
        try
          LTree.ChildCount[LTree.FocusedNode] :=
            LTree.ChildCount[LTree.FocusedNode] + Cardinal(Count);
          LTree.Expanded[LTree.FocusedNode] := True;
        finally
          LTree.EndUpdate;
        end;
        LTree.InvalidateToBottom(LTree.FocusedNode);
      end else begin
        SetStatus('No focused node - select one first.');
        // MessageDialog does not block on Android - it returns at once and answers through
        // the callback - so nothing may follow it here that the Exit below would skip.
        TDialogService.MessageDialog(
          'Select a node first: new nodes are added as children of the focused one.',
          TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0,
          procedure(const AResult: TModalResult)
          begin
            // Nothing to do: the dialog only tells the user why the button did nothing.
          end);
        Exit;
      end;
    end;
  end;

  SetStatus(Format('Last operation duration: %d ms', [TThread.GetTickCount64 - Start]));
end;

procedure TFormFmx.Button_ClearTreeClick(Sender: TObject);
var
  Start: UInt64;
begin
  Start := TThread.GetTickCount64;
  ActiveTree.Clear;
  SetStatus(Format('Last operation duration: %d ms', [TThread.GetTickCount64 - Start]));
end;

procedure TFormFmx.Button_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFormFmx.Button_TestClick(Sender: TObject);
begin
  ActiveTree.SortTree(0, sdDescending, True);
end;

procedure TFormFmx.CheckBox_CustomDrawChange(Sender: TObject);

// Both, so the setting is not silently different on whichever tree is hidden. Note this
// checkbox outranks the other one: OnBeforeItemPaint returning CustomDraw = True skips the
// whole default item painter, and OnDrawNode is called from inside it - so with custom draw
// on, the draw tree's own paint event does not fire at all.

begin
  if Assigned(FStringTree) then FStringTree.Invalidate;
  if Assigned(FDrawTree) then FDrawTree.Invalidate;
end;

procedure TFormFmx.CheckBox_DrawTreeChange(Sender: TObject);

// Swapping rather than showing both side by side: at phone width two trees are unreadable,
// and the point is that the same data and the same handlers drive either class - not a
// pixel comparison. Focus has to move with the swap or the keyboard talks to a hidden tree.

begin
  if not (Assigned(FStringTree) and Assigned(FDrawTree)) then Exit;

  FDrawTree.Visible := CheckBox_DrawTree.IsChecked;
  FStringTree.Visible := not CheckBox_DrawTree.IsChecked;

  if ActiveTree.CanFocus then begin
    ActiveTree.SetFocus;
  end;

  if CheckBox_DrawTree.IsChecked then begin
    SetStatus('TVirtualDrawTree - every cell painted by OnDrawNode. No text, no inline editing.');
  end else begin
    SetStatus('TVirtualStringTree - text through OnGetText, editable, clipboard text for free.');
  end;
end;

procedure TFormFmx.CheckBox_MultiLineChange(Sender: TObject);
begin
  FUseMultiline := CheckBox_MultiLine.IsChecked;
  ApplyMultilineOption(FStringTree);
  ApplyMultilineOption(FDrawTree);
  if FUseMultiline then begin
    SetStatus('Multiline: every fourth caption is long and wraps, and each row is measured.');
  end else begin
    SetStatus('Single line: long captions are shortened with an ellipsis, rows are uniform.');
  end;
end;

procedure TFormFmx.CheckBox_MultiSelectChange(Sender: TObject);
var
  LT: TVSTCracker;
begin
  LT := TVSTCracker(GetActiveTree);
  if CheckBox_MultiSelect.IsChecked then begin
    LT.TreeOptions.SelectionOptions := LT.TreeOptions.SelectionOptions + [toMultiSelect];
  end else begin
    LT.TreeOptions.SelectionOptions := LT.TreeOptions.SelectionOptions - [toMultiSelect];
  end;
end;

procedure TFormFmx.ComboBox_LongPressChange(Sender: TObject);

// Both trees, so the setting is not silently different on whichever one is hidden.

begin
  ApplyLongPressOption(FStringTree);
  ApplyLongPressOption(FDrawTree);
  if ComboBox_LongPress.ItemIndex = cLongPressPopup then begin
    SetStatus('Press and hold opens the context menu. Dragging needs a mouse.');
  end else begin
    SetStatus('Press and hold picks a node up. The menu is right click only.');
  end;
end;

procedure TFormFmx.ConfigureTree(ATree: TBaseVirtualTree);

// Everything both trees have in common, which turns out to be nearly all of it. The two
// classes differ only in how a cell's CONTENT is produced - text through OnGetText, or
// pixels through OnDrawNode - so data, options, columns, check boxes, images, sorting and
// the clipboard are configured once, here, and every handler below serves both trees.
//
// The cracker is not a trick to reach something private: TreeOptions, Images, events and
// the rest are PROTECTED on TBaseVirtualTree and only republished as published by each
// concrete class. Assigning them through the base type is what needs the cast.

var
  LT: TVSTCracker;
  AColumn: TVirtualTreeColumn;
begin
  LT := TVSTCracker(ATree);

  LT.Parent := Layout_Tree;
  LT.Align := TAlignLayout.Client;

  LT.Fill.Color := TAlphaColorRec.White;
  LT.Colors.BorderColor := clWindowText;
  LT.Colors.FocusedSelectionColor := clBlue;
  LT.DragType := dtFMX;

  // dmManual, and not offered as a choice, because on FMX it is not really one. VTV reads
  // DragMode as "does the application get a per-node veto": dmAutomatic makes every node
  // draggable and never calls OnDragAllowed, dmManual asks it for each node and column (see
  // TBaseVirtualTree.HandleMouseDown). Both end in the same drag.
  //
  // What decides it here is that FMX routes a dmAutomatic left press to BeginAutoDrag INSTEAD
  // of MouseDown - an else, not an extra call - so the tree is told nothing about the press
  // itself. TBaseVirtualTree.BeginAutoDrag has to rebuild the local point and synthesise the
  // double click to put it back on dmManual's path. It works, but there is no reason to run a
  // demo down the reconstructed road when the direct one is right here.
  LT.DragMode := TDragMode.dmManual;

  LT.DefaultNodeHeight := AdjSize(24);
  // Check box and image sizes follow DefaultNodeHeight on their own - see
  // TBaseVirtualTree.GetCheckImageSize. Assign CheckImageSize/NodeImageSize only to
  // override that, and 0 to go back to automatic.
  LT.Images := ImageList_Tree;

  // Incremental search is isNone by default. isVisibleOnly is what a list is expected to
  // do: type a few letters and the first visible node whose caption starts with them takes
  // the focus. The buffer resets once IncrementalSearchTimeout (1s) has passed.
  LT.IncrementalSearch := isVisibleOnly;

  // Swipe right on a node deletes it - see VTGesture. Only the two horizontal standard
  // gestures are enabled: vertical ones would compete with dragging a node and with the
  // scroll bars, and the interactive set is left alone so panning keeps working.
  //
  // Assigning OnGesture does not cost the tree its pan gesture: TVTAncestorFMX redeclares
  // the property and calls this handler from inside its own, so both run.
  LT.Touch.GestureManager := FGestureManager;
  LT.Touch.StandardGestures := [TStandardGesture.sgLeft, TStandardGesture.sgRight];
  LT.OnGesture := VTGesture;

  // Context menu. Popup is an ordinary FMX control rather than a TPopupMenu, which is what
  // lets one menu serve both platforms.
  //
  // On a touch screen there is only one press-and-hold gesture and two things wanting it, so
  // ApplyLongPressOption decides which one gets it - see ComboBox_LongPress and the comment
  // on that method. A right click still opens the menu on Windows either way.
  LT.Popup := FPopup;
  LT.OnContextMenu := VTContextMenu;
  ApplyLongPressOption(LT);

  LT.TreeOptions.AnimationOptions := LT.TreeOptions.AnimationOptions + [toAnimatedToggle];

  // toFullRowDrag: without it a drag can only be started on the caption or the node image. On a
  // touch screen that is a needlessly small target, and it is also what makes dmManual behave the
  // same here as dmAutomatic does on the VCL side.
  // toVariableNodeHeight is what makes GetNodeHeight ask the application how tall each row
  // is, through OnMeasureItem. Without it every row is DefaultNodeHeight and a wrapped
  // caption is simply clipped. Note the option's setter reinitialises every node, so it is
  // set here - before RootNodeCount at the end of this method - rather than later.
  LT.TreeOptions.MiscOptions :=
    [toEditable, toFullRowDrag, toInitOnSave, toWheelPanning];
  if FUseMultiline then begin
    LT.TreeOptions.MiscOptions := LT.TreeOptions.MiscOptions + [toVariableNodeHeight];
  end;
  if cUseCheckSupport then begin
    // toCheckSupport is what makes the tree look at CheckType[] at all - without it the
    // per-node type is stored and then ignored, which looks exactly like a paint bug.
    LT.TreeOptions.MiscOptions := LT.TreeOptions.MiscOptions + [toCheckSupport];
    // Additive so the rest of the AutoOptions defaults survive. Tristate tracking is what
    // makes a ctTriStateCheckBox parent follow the children below it.
    LT.TreeOptions.AutoOptions := LT.TreeOptions.AutoOptions + [toAutoTristateTracking];
  end;
  // toAutoDropExpand: hover a drag over a collapsed node with children and it opens on its
  // own after AutoExpandDelay (1000 ms by default) - proves the new FMX drag-expand timer.
  // toAutoScroll: hold a drag near the top or bottom edge and the view follows, so a node can
  // be dropped somewhere that was off screen when the drag began. Not in the default set, and
  // UpdateDragScrollFMX refuses to scroll without it, exactly as CanAutoScroll does on the VCL.
  // The finger has to stay in the edge zone for AutoScrollDelay (300 ms) first.
  LT.TreeOptions.AutoOptions := LT.TreeOptions.AutoOptions + [toAutoDropExpand, toAutoScroll];
  // toShowDropmark is in the DEFAULT PaintOptions set, and this line replaces the whole set - so
  // leaving it out turned the insert marker off. On FMX that was invisible twice over: see
  // TBaseVirtualTree.DoPaintDropMark, whose body was {$IFDEF VT_VCL} only.
  LT.TreeOptions.PaintOptions :=
    [toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware,
     toUseBlendedImages];
  LT.TreeOptions.SelectionOptions := [toFullRowSelect]; //, toMultiSelect];
  LT.ScrollBarOptions.Scrollbars := TScrollStyle.ssBoth;

  // Not one of these handlers cares which class it is serving - they all work through
  // Sender and the node record, never through a field naming one particular tree.
  LT.OnBeforeItemPaint := VTBeforeItemPaint;   // Custom draw of whole rows.
  LT.OnChecked := VTChecked;             // After the state changed.
  LT.OnChecking := VTChecking;           // Veto hook, fires before.
  LT.OnStateChange := VTStateChange;     // Start and end of a check propagation.
  LT.OnColumnResize := VTColumnResize;
  LT.OnCompareNodes := VTCompareNodes;   // Required, otherwise hoHeaderClickAutoSort sorts nothing.
  LT.OnDragAllowed := VTDragAllowed;
  LT.OnDragOver := VTDragOver;
  LT.OnDragDrop := VTDragDrop;
  LT.OnDropOutside := VTDropOutside;
  LT.OnNodeDblClick := VTNodeDblClick;   // The edit trigger - string tree only, see there.
  LT.OnFreeNode := VTFreeNode;
  LT.OnGetImageIndex := VTGetImageIndex;
  LT.OnHeaderClick := VTHeaderClick;
  LT.OnInitNode := VTInitNode;
  // Copying a node serializes it, and the tree streams NOTHING of the node's own record -
  // only what these two write and read. Without them a pasted node arrives with an empty
  // caption. A string could not be copied as raw bytes anyway.
  LT.OnLoadNode := VTLoadNode;
  LT.OnMeasureItem := VTMeasureItem;
  LT.OnSaveNode := VTSaveNode;
  LT.OnAfterPaste := VTAfterPaste;
  LT.OnPasteText := VTPasteText;         // Only fires for text from another app.

  LT.Header.Options :=
    [hoVisible, hoColumnResize, hoDrag, hoHeaderClickAutoSort, hoShowSortGlyphs];
  LT.Header.DefaultHeight := AdjSize(30);

  // Columns.Add assigns sequential positions - do not set Position manually unless you
  // really want a different visual order than the creation order.
  AColumn := LT.Header.Columns.Add;
  AColumn.Text := 'Column 1';
  AColumn := LT.Header.Columns.Add;
  AColumn.Text := 'Column 2';

  if FUseApplyColumnWidths then begin
    // Actual widths are percentage based and applied once the form has a real size.
  end else begin
    // Initially the second column (column 1) has a width, the first takes the rest.
    LT.Header.Options := LT.Header.Options + [hoAutoResize];
    LT.Header.AutoSizeIndex := 0;
    AColumn.Width := AdjSize(100);
  end;

  // Let the tree know how much data space we need.
  LT.NodeDataSize := SizeOf(TNodeData);
  // Set an initial number of nodes. Each tree owns its own nodes - they cannot be shared -
  // but both are filled by the same OnInitNode, so the contents match.
  LT.RootNodeCount := 20;
end;

procedure TFormFmx.CreateDrawTree;

// A draw tree holds no text at all. Everything the string tree got for free - the cell
// content, the width a hint or an autosize would need, what incremental search matches
// against, what a copy puts on the system clipboard - has to be answered by hand. That is
// the whole difference between the two classes, and it is these four lines long.

begin
  FDrawTree := TVirtualDrawTree.Create(Self);
  ConfigureTree(FDrawTree);

  FDrawTree.OnDrawNode := VTDrawNode;
  FDrawTree.OnGetNodeWidth := VTGetNodeWidth;
  FDrawTree.OnIncrementalSearch := VTIncrementalSearch;
  FDrawTree.OnGetClipboardText := VTGetClipboardText;

  FDrawTree.Visible := False;   // The string tree is shown first; the checkbox swaps them.
end;

procedure TFormFmx.CreatePopup;

// The context menu, built in code so the demo form keeps only the controls it needs on
// screen. A TPopup is an ordinary FMX control and its content is whatever is put inside it,
// so the same menu works on Windows and on Android - which a TPopupMenu does not.

var
  ARect: TRectangle;
  ALayout: TLayout;

  function AddButton(const AText: string; ATag: Integer): TButton;
  begin
    Result := TButton.Create(FPopup);
    Result.Parent := ALayout;
    Result.Align := TAlignLayout.Top;
    Result.Height := AdjSize(30);
    Result.Margins.Rect := RectF(AdjSize(6), AdjSize(2), AdjSize(6), AdjSize(2));
    Result.Text := AText;
    Result.Tag := ATag;
    Result.OnClick := PopupItemClick;
  end;

begin
  FPopup := TPopup.Create(Self);
  FPopup.Parent := Self;
  FPopup.Width := AdjSize(200);
  FPopup.Height := AdjSize(140);

  // A TPopup draws nothing of its own, so without a background the buttons float over
  // whatever is behind them.
  ARect := TRectangle.Create(FPopup);
  ARect.Parent := FPopup;
  ARect.Align := TAlignLayout.Client;
  ARect.Fill.Color := TAlphaColorRec.White;
  ARect.Stroke.Color := clWindowText;

  ALayout := TLayout.Create(FPopup);
  ALayout.Parent := ARect;
  ALayout.Align := TAlignLayout.Client;

  FPopupLabel := TLabel.Create(FPopup);
  FPopupLabel.Parent := ALayout;
  FPopupLabel.Align := TAlignLayout.Top;
  FPopupLabel.Height := AdjSize(26);
  FPopupLabel.Margins.Rect := RectF(AdjSize(6), AdjSize(4), AdjSize(6), 0);
  FPopupLabel.StyledSettings := FPopupLabel.StyledSettings - [TStyledSetting.Style];
  FPopupLabel.TextSettings.Font.Style := [TFontStyle.fsBold];

  // Top aligned, so they stack under the label in creation order. Kept, because
  // VTContextMenu enables and disables them for the node the gesture landed on.
  FPopupExpand := AddButton('Expand', 0);
  FPopupCollapse := AddButton('Collapse', 1);
  FPopupDelete := AddButton('Delete node', 2);
end;

procedure TFormFmx.CreateStringTree;
begin
  FStringTree := TVirtualStringTree.Create(Self);

  // The only two the draw tree cannot have: the tree asks for text, and an accepted edit
  // gives text back. DoIncrementalSearch and GetClipboardText are already overridden by
  // TCustomVirtualStringTree in terms of the same text, so neither needs a handler here.
  //
  // Before ConfigureTree, not after it: that method ends by setting RootNodeCount, and with
  // toVariableNodeHeight on, every node created there is measured on the spot. A node
  // measured while the tree has no OnGetText yet measures an empty caption and stays one
  // line high until something clears its vsHeightMeasured flag - which is what hovering
  // over a row does, and why such a row grows only when the mouse passes it.
  FStringTree.OnGetText := VTGetText;
  FStringTree.OnNewText := VTNewText;

  ConfigureTree(FStringTree);

  FStringTree.Visible := True;
end;

procedure TFormFmx.Edit_FilterTyping(Sender: TObject);

// Both trees, so the filter still holds after the Draw tree checkbox swaps them. Each tree
// owns its own nodes, so each has to be walked.
//
// OnTyping rather than OnChangeTracking: it fires on every keystroke, including the ones a
// software keyboard produces.

var
  LMatches: Integer;
begin
  LMatches := ApplyFilter(FStringTree, Edit_Filter.Text);
  ApplyFilter(FDrawTree, Edit_Filter.Text);

  if Trim(Edit_Filter.Text) = '' then begin
    SetStatus('Filter cleared - all nodes shown. Nodes expanded by the filter stay expanded.');
  end else begin
    SetStatus(Format('Filter "%s": %d node(s) match.', [Trim(Edit_Filter.Text), LMatches]));
  end;
end;

procedure TFormFmx.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  UseApplyColumnWidths := False;
  AdjustSizes;
  // Before the trees, because ConfigureTree calls ApplyLongPressOption, which reads ItemIndex.
  // Drag is the default: it is what the drag'n drop side of this demo is for, and the context
  // menu still has the right click on the desktop.
  ComboBox_LongPress.Items.BeginUpdate;
  try
    ComboBox_LongPress.Items.Clear;
    for I := Low(cLongPressItems) to High(cLongPressItems) do
      ComboBox_LongPress.Items.Add(cLongPressItems[I]);
  finally
    ComboBox_LongPress.Items.EndUpdate;
  end;
  ComboBox_LongPress.ItemIndex := cLongPressDrag;
  // Before the trees: ConfigureTree hands this to every tree it sets up.
  FGestureManager := TGestureManager.Create(Self);
  // Before the trees, because ConfigureTree reads it. Off by default: measuring every row is
  // what a tree does slowly, and the point of this demo is how fast it is without that.
  FUseMultiline := False;
  CheckBox_MultiLine.IsChecked := FUseMultiline;
  // Before the trees as well: ConfigureTree assigns this popup to every tree it sets up.
  CreatePopup;
  CreateStringTree;
  CreateDrawTree;
  CheckBox_DrawTree.IsChecked := False;   // The string tree is what starts on screen.
end;

procedure TFormFmx.FormResize(Sender: TObject);
begin
  ApplyColumnWidths(cColPercent);
end;

procedure TFormFmx.FormShow(Sender: TObject);
begin
  ApplyColumnWidths(cColPercent);
end;

function TFormFmx.GetActiveTree: TBaseVirtualTree;
begin
  if Assigned(FDrawTree) and FDrawTree.Visible then begin
    Result := FDrawTree;
  end else begin
    Result := FStringTree;
  end;
end;

procedure TFormFmx.HideOddRootNodes(ATree: TBaseVirtualTree);
var
  Node: PVirtualNode;
  C: Integer;
begin
  // Demo of IsVisible: hide every second ROOT node. Note GetNextSibling, not GetNext -
  // GetNext would descend into children and the parity would follow the traversal order
  // rather than the root index.
  ATree.BeginUpdate;
  try
    C := 0;
    Node := ATree.GetFirstChild(nil);
    while Assigned(Node) do begin
      ATree.IsVisible[Node] := (C mod 2) = 0;
      Node := ATree.GetNextSibling(Node);
      C := C + 1;
    end;
  finally
    ATree.EndUpdate;
  end;
end;

procedure TFormFmx.PopupItemClick(Sender: TObject);

// Acts on the node VTContextMenu remembered, not on the focused one: the two are the same
// here because that handler selects the node, but a menu that reads its own state cannot be
// broken by anything the tree does between the gesture and the click.

var
  LTree: TBaseVirtualTree;
begin
  FPopup.IsOpen := False;

  if not Assigned(FPopupNode) then begin
    SetStatus('The gesture landed on empty space, so there is no node to act on.');
    Exit;
  end;

  LTree := ActiveTree;
  case TComponent(Sender).Tag of
    0: LTree.FullExpand(FPopupNode);
    1: LTree.FullCollapse(FPopupNode);
    2: begin
         LTree.DeleteNode(FPopupNode);
         FPopupNode := nil;   // Freed - nothing may reach it again.
       end;
  end;
end;

procedure TFormFmx.SetStatus(const AText: string);

// One place where the status line is written, so every call site reads identically in this
// demo and in the VCL one, where the same method assigns Label_Status.Caption instead.

begin
  Label_Status.Text := AText;
end;

procedure TFormFmx.VTAfterPaste(Sender: TObject; const APasted: TNodeArray; ACut: Boolean);

// The tree has already selected the pasted nodes and focused the first, so this only has to
// say in words what the selection already shows.

const
  VERB: array [Boolean] of string = ('Copied', 'Moved');
begin
  SetStatus(Format('%s %d node(s) - now selected.', [VERB[ACut], Length(APasted)]));
end;

procedure TFormFmx.VTBeforeItemPaint(Sender: TBaseVirtualTree;
  Canvas: TCanvas; Node: PVirtualNode; Rect: TRect; var CustomDraw: Boolean);

// CustomDraw = True means the tree paints NOTHING for this row: no background, no tree
// lines, no toggle button, no check box, no images, no text. All of it is done below.
//
// The layout is asked for rather than guessed. GetOffsets is the same routine the painter
// and the hit test use, so a check box drawn at ofsCheckBox is exactly where a tap will
// later be looked for. Offsets are relative to the CELL and this handler is handed the
// whole ITEM rect; the two coincide while the main column is leftmost and the tree is not
// scrolled horizontally, which holds here but is not a general truth.

var
  Data: PNodeData;
  LTree: TVSTCracker;
  LOffsets: TVTOffsets;
  LImageInfo: TVTImageInfo;
  LImageIndex: TImageIndex;
  LGhosted: Boolean;
  LKind: TVTImageKind;
  LRowHeight: Single;
  LTop: Single;
begin
  CustomDraw := CheckBox_CustomDraw.IsChecked;
  // CustomDraw = False means "tree, paint this row yourself". Painting anyway would only
  // be overdrawn by the default painter - so leave immediately.
  if not CustomDraw then Exit;
  if not Assigned(Node) then Exit;

  LTree := TVSTCracker(Sender);
  LRowHeight := Rect.Bottom - Rect.Top;
  LTree.GetOffsets(Node, LOffsets, ofsRightOfText, Sender.Header.MainColumn);
  // Draw background depending on if the node is focused.
  if Sender.Selected[Node] then begin
    if Sender.Focused then begin
      Canvas.Brush.Color := TAlphaColorRec.DarkBlue;
    end else begin
      Canvas.Brush.Color := clGray;
    end;
  end else begin
    if Sender.Focused then begin
      Canvas.Brush.Color := TAlphaColorRec.Beige;
    end else begin
      Canvas.Brush.Color := clWhite;
    end;
  end;
  // Rect is tree local here, so the tree's Position within its parent must not be added.
  Rect.Right := Round(Sender.Width);
  Canvas.FillRect(Rect);

  // Draw text
  if Sender.Selected[Node] then begin
    if Sender.Focused then begin
      Canvas.Fill.Color := TAlphaColorRec.White;
    end else begin
      Canvas.Fill.Color := clBlack;
    end;
  end else begin
    Canvas.Fill.Color := clWindowText;
  end;

  // --- toggle button ------------------------------------------------------
  // Same call the tree makes, so expanded/collapsed, hot and selected glyphs all match.
  if (toShowButtons in LTree.TreeOptions.PaintOptions) and (vsHasChildren in Node.States) then
    LTree.PaintNodeButton(Canvas, Node, Sender.Header.MainColumn, Rect,
      LOffsets[ofsToggleButton], (LRowHeight - Sender.ButtonSize) / 2, bdLeftToRight);

  // --- check box ----------------------------------------------------------
  if (toCheckSupport in LTree.TreeOptions.MiscOptions) and (Node.CheckType <> ctNone) then begin
    LImageInfo.Index := LTree.GetCheckImage(Node);
    if LImageInfo.Index > -1 then begin
      LImageInfo.Images := Sender.CheckImages;
      LImageInfo.Ghosted := False;
      LImageInfo.XPos := Rect.Left + LOffsets[ofsCheckBox];
      LImageInfo.YPos := Rect.Top + (LRowHeight - Sender.CheckImageSize) / 2;
      LTree.PaintCheckImage(Canvas, LImageInfo, Sender.Selected[Node]);
    end;
  end;

  // --- node image ---------------------------------------------------------
  // The image list belongs to this form, so it is drawn directly rather than through the
  // tree's PaintImage - and the index comes from the same handler the tree would call, so
  // custom draw and normal draw can never disagree about which picture belongs to a node.
  if Assigned(ImageList_Tree) then begin
    LImageIndex := -1;
    LGhosted := False;
    if Sender.Selected[Node] then LKind := ikSelected else LKind := ikNormal;
    VTGetImageIndex(Sender, Node, LKind, Sender.Header.MainColumn, LGhosted, LImageIndex);
    if LImageIndex > -1 then begin
      LTop := Rect.Top + (LRowHeight - Sender.NodeImageSize) / 2;
      ImageList_Tree.Draw(Canvas,
        TRectF.Create(Round(Rect.Left + LOffsets[ofsImage]), Round(LTop),
          Round(Rect.Left + LOffsets[ofsImage]) + Round(Sender.NodeImageSize),
          Round(LTop) + Round(Sender.NodeImageSize)),
        LImageIndex, 1.0);
    end;
  end;


  Data := Node.GetData;
  if not Assigned(Data) then Exit;

  // Every attribute we care about is set explicitly on each call, so no save/restore
  // of the canvas state is needed. 'Arial' does not exist on Android and silently
  // falls back, so the platform default family is used instead.
  Canvas.Font.Size := AdjSize(cCustomDrawFontSize);
  // Text starts where the tree would start it - past the button, the box and the image.
  Rect.Left := Rect.Left + LOffsets[ofsText];
  Canvas.FillText(Rect, Data.Caption, False, 1, [], TTextAlign.Leading, TTextAlign.Center);
end;

procedure TFormFmx.VTChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);

// Fires after CheckState has already changed. With toAutoTristateTracking on, a click on
// a child also lands here once for every parent the tree re-evaluates, so this is a place
// to read state - never to write it back, or the recursion is yours to own.
//
// One line per node is what a handler must not do here. Checking a parent of 3000 children
// fires this 3000 times, and 3000 status writes are 3000 repaints of the form - which is
// what makes a large check look like the app has hung. The first node reports itself and
// the rest are counted, with the total written once by VTStateChange when the propagation
// has finished.

begin
  if not Assigned(Node) then Exit;

  System.Inc(FCheckedCount);
  if FCheckedCount > 1 then Exit;

  SetStatus(Format('Checked: Level %d, Index %d -> %s',
    [Sender.GetNodeLevel(Node), Node.Index, CheckStateToStr(Sender.CheckState[Node])]));
end;

procedure TFormFmx.VTChecking(Sender: TBaseVirtualTree; Node: PVirtualNode;
  var NewState: TCheckState; var Allowed: Boolean);

// The veto hook - Allowed := False discards the click. Permissive here on purpose: it
// exists so a tap can be proved to reach the tree even while nothing repaints yet.
//
// Logging is capped for the same reason the status line is: a propagation across thousands
// of children would spend longer writing the log than changing the check states.

begin
  Allowed := True;
  if not Assigned(Node) then Exit;
  if FCheckedCount >= cMaxCheckLog then Exit;

  TDebug.Log(Format('Checking: Index %d -> %s', [Node.Index, CheckStateToStr(NewState)]));
end;

procedure TFormFmx.VTColumnResize(Sender: TVTHeader; Column: TColumnIndex);
begin
  // The user has taken over - stop forcing the percentages on every form resize.
  FUserResizedColumns := True;
end;

procedure TFormFmx.VTCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode;
  Column: TColumnIndex; var Result: Integer);
var
  Data1, Data2: PNodeData;
begin
  Result := 0;
  if not (Assigned(Node1) and Assigned(Node2)) then Exit;
  Data1 := Sender.GetNodeData(Node1);
  Data2 := Sender.GetNodeData(Node2);
  if not (Assigned(Data1) and Assigned(Data2)) then Exit;
  Result := CompareText(Data1.Caption, Data2.Caption);
end;

procedure TFormFmx.VTContextMenu(Sender: TObject; Node: PVirtualNode; Column: TColumnIndex;
  const LocalPos: TPointF);

// Fired by PopupTrigger - a right click on the desktop, a press and hold on a touch screen.
// The tree shows Popup as soon as this returns, so this is the place to fill the menu in for
// the node the gesture landed on. Nothing is shown at all when neither Popup nor PopupMenu
// is assigned, which is what a tree that only wants the event gets.

var
  LTree: TBaseVirtualTree;
  LData: PNodeData;
  LCaption: string;
begin
  LTree := TBaseVirtualTree(Sender);
  FPopupNode := Node;

  if Assigned(Node) then begin
    // A hold is not a click, so on a touch screen nothing has selected the node yet. Doing
    // it here is what makes the menu visibly belong to the row under the finger.
    LTree.ClearSelection;
    LTree.Selected[Node] := True;
    LTree.FocusedNode := Node;

    LData := LTree.GetNodeData(Node);
    if Assigned(LData) then begin
      LCaption := LData.Caption;
    end else begin
      LCaption := '<no data>';
    end;
  end else begin
    LCaption := '<no node>';
  end;

  FPopupLabel.Text := LCaption;

  // An item that cannot do anything says so by being disabled, rather than by doing nothing
  // when it is pressed. Both buttons expand or collapse the whole subtree, so both need
  // children to work on.
  FPopupExpand.Enabled := Assigned(Node) and LTree.HasChildren[Node] and not LTree.Expanded[Node];
  FPopupCollapse.Enabled := Assigned(Node) and LTree.HasChildren[Node] and LTree.Expanded[Node];
  FPopupDelete.Enabled := Assigned(Node);

  SetStatus(Format('ContextMenu: %s  Col=%d  at (%.0f, %.0f)',
    [LCaption, Column, LocalPos.X, LocalPos.Y]));
end;

procedure TFormFmx.VTDragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  var Allowed: Boolean);

// DragMode is dmManual on this platform rather than dmAutomatic - see the comment on DragMode
// in ConfigureTree. This is the veto hook that stands in for it: with DragMode = dmManual,
// HandleMouseDown only starts a drag when this returns True (and the hit was on the label, or
// toFullRowDrag is set - neither of which this handler controls). Permissive here on purpose,
// same as VTChecking above - this demo wants every node draggable, unconditionally.

begin
  Allowed := True;
end;

procedure TFormFmx.VTDragDrop(Sender: TBaseVirtualTree; Source: TObject; DataObject: TVTDragDataObject;
  Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);

// Reparents EVERY dragged node under (or beside) Sender.DropTargetNode. The old version moved
// Sender.FocusedNode and nothing else, which is why a multi selection dropped exactly one node.
//
// Direction matters once there is more than one node. amInsertBefore puts each node immediately
// before the target, so walking the list FORWARDS leaves them in their original order. amInsertAfter
// and amAddChildFirst both put the newest node closest to the target, so those two are walked
// BACKWARDS - otherwise a three node drag arrives upside down.
//
// MoveTo has to be called ON THE TREE THAT OWNS THE SOURCE NODES (see its own Assert), which is
// LSourceTree, not necessarily Sender - the two only differ if a second tree were ever visible at
// the same time, which this demo does not do, but the call is written to be correct either way.

var
  LSourceTree: TBaseVirtualTree;
  LNodes: TNodeArray;
  LTargetNode: PVirtualNode;
  LAttachMode: TVTNodeAttachMode;
  LSortNote: string;
  I: Integer;

  // A drop says where the user wants the nodes; auto sort says the tree decides. They cannot both
  // hold, and auto sort wins by default: toAutoSort is in the standard AutoOptions and
  // TBaseVirtualTree.EndUpdate re-sorts the whole tree on the way out, so a node inserted between
  // two siblings is put straight back where it came from before the screen is ever repainted.
  // Nothing is wrong with the drop - it is undone a microsecond later, which is indistinguishable
  // from a drag that did nothing.
  //
  // Note that this happens with NO sort column set at all. EndUpdate passes Header.SortColumn to
  // SortTree unguarded, and SortTree's own test is "Column > InvalidColumn" - which NoColumn (-1)
  // passes, InvalidColumn being -2. OnCompareNodes is then called with Column = -1 and this demo,
  // like most, ignores the column and compares captions. Clearing Header.SortColumn is therefore
  // no help, and would make things worse: DoSetSortColumn re-sorts when EITHER toAutoSort or
  // hoHeaderClickAutoSort is set, so assigning NoColumn triggers exactly the sort being avoided.
  //
  // Dropping toAutoSort is what actually stops it, and it is the honest answer anyway: reordering
  // by hand means the order is now the user's, the way a file manager works. A header click still
  // sorts, because hoHeaderClickAutoSort is a separate option and stays.
  function ReleaseAutoSort(ATree: TBaseVirtualTree): string;
  var
    LColumn: TColumnIndex;
  begin
    Result := '';
    if not (toAutoSort in TVSTCracker(ATree).TreeOptions.AutoOptions) then Exit;
    TVSTCracker(ATree).TreeOptions.AutoOptions :=
      TVSTCracker(ATree).TreeOptions.AutoOptions - [toAutoSort];
    LColumn := ATree.Header.SortColumn;
    if LColumn > NoColumn then
      Result := Format(' (column %d not sorted)', [LColumn])
    else
      Result := ' (auto sort off)';
  end;

begin
  if not (Source is TBaseVirtualTree) then Exit;
  LSourceTree := TBaseVirtualTree(Source);
  LTargetNode := Sender.DropTargetNode;

  LNodes := DraggedNodes(LSourceTree);
  if Length(LNodes) = 0 then Exit;

  // Same refusals as VTDragOver. Re-tested here because OnDragOver is advisory - a host that
  // ignores Accept, or a target that changed between the last move and the drop, must not be able
  // to drive MoveTo into raising.
  if Assigned(LTargetNode) then begin
    for I := 0 to High(LNodes) do begin
      if LTargetNode = LNodes[I] then Exit;
      if (LSourceTree = Sender) and Sender.HasAsParent(LTargetNode, LNodes[I]) then Exit;
    end;
  end;

  case Mode of
    dmAbove: LAttachMode := amInsertBefore;
    dmBelow: LAttachMode := amInsertAfter;
  else
    LAttachMode := amAddChildFirst;   // dmOnNode, or dmNowhere - dropped on empty space, goes to the root.
  end;

  // Before the moves, because the loop below runs inside BeginUpdate/EndUpdate.
  LSortNote := ReleaseAutoSort(Sender);

  LSourceTree.BeginUpdate;
  try
    if LAttachMode = amInsertBefore then begin
      for I := 0 to High(LNodes) do
        LSourceTree.MoveTo(LNodes[I], LTargetNode, LAttachMode, False);
    end else begin
      for I := High(LNodes) downto 0 do
        LSourceTree.MoveTo(LNodes[I], LTargetNode, LAttachMode, False);
    end;
  finally
    LSourceTree.EndUpdate;
  end;

  // Dropping ONTO a collapsed node would otherwise look like the nodes vanished.
  if Assigned(LTargetNode) and (LAttachMode in [amAddChildFirst, amAddChildLast]) then
    Sender.Expanded[LTargetNode] := True;

  SetStatus(Format('Dropped %d node(s) %s target node.%s',
    [Length(LNodes), DropModeToStr(Mode), LSortNote]));
end;

procedure TFormFmx.VTDragOver(Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState;
  State: TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer; var Accept: Boolean);

// Whether Sender will accept a drop at the current position. Refused when there is nothing being
// dragged, when the target IS one of the dragged nodes, or - same tree only - when the target is a
// descendant of one of them (MoveTo raises SWrongMoveError on that move, so it has to be caught
// here rather than left to fail at drop time).
//
// Every dragged node is tested, not just the focused one: with toMultiSelect on, a drop that is
// legal for the focused node can still be illegal for one of its companions, and a single MoveTo
// raising halfway through the loop in VTDragDrop would leave the tree half moved.
//
// Shift is always [] on FMX - see the comment above the library's own DragEnter/DragOver
// overrides - so this demo does not attempt a Ctrl-for-copy distinction on that platform.

var
  LSourceTree: TBaseVirtualTree;
  LNodes: TNodeArray;
  LTargetNode: PVirtualNode;
  I: Integer;
begin
  Accept := False;
  if not (Source is TBaseVirtualTree) then Exit;

  LSourceTree := TBaseVirtualTree(Source);
  LTargetNode := Sender.DropTargetNode;

  // Called on every mouse move, so this rebuilds the selection array rather often. Fine for a
  // demo; a real application with thousands of selected nodes would snapshot it once in
  // OnDragAllowed / OnStartDrag instead and read the snapshot here.
  LNodes := DraggedNodes(LSourceTree);
  if Length(LNodes) = 0 then Exit;

  if Assigned(LTargetNode) then begin
    for I := 0 to High(LNodes) do begin
      if LTargetNode = LNodes[I] then Exit;
      if (LSourceTree = Sender) and Sender.HasAsParent(LTargetNode, LNodes[I]) then Exit;
    end;
  end;

  Accept := True;
end;

procedure TFormFmx.VTDropOutside(Sender: TBaseVirtualTree; const ScreenPos: TPointF;
  var Handled: Boolean);

// The drag was let go with the pointer off the tree. Handled stays False, so the tree cancels
// the drag and nothing moves - which is the point of the event on a touch screen, where there
// is no Escape key and a drag that has begun otherwise has to be carried back to where it
// started before it can be let go safely.
//
// An application that wants a trash or stop target outside the tree implements it here: test
// ScreenPos against that control's AbsoluteRect, act on the dragged nodes, and set Handled to
// True so the tree leaves the drop alone. The ghost is painted by the tree and is therefore
// clipped to it, so such a target wants its own highlight rather than relying on the ghost
// being visible over it.

begin
  Handled := False;
  SetStatus(Format('Drag cancelled - released off the tree at (%.0f, %.0f).',
    [ScreenPos.X, ScreenPos.Y]));
end;

procedure TFormFmx.VTDrawNode(Sender: TBaseVirtualTree; const PaintInfo: TVTPaintInfo);

// The draw tree's entire reason to exist. By the time this fires the tree has already
// painted the row background, the tree lines, the toggle button, the check box and the
// node image - all of that is class independent and comes free. What is left is the
// CONTENT of one cell, and here it is deliberately different per column to show that a
// draw tree is not limited to text:
//
//   column 0 - the caption, plus a bar whose length encodes the node's depth
//   column 1 - the child count
//
// ContentRect, not CellRect: the former already excludes the button, box and image, so
// this lands exactly where the string tree would have put its text.

var
  Data: PNodeData;
  R: TRect;
  LBar: TRect;
  LLevel: Integer;
begin
  Data := Sender.GetNodeData(PaintInfo.Node);
  if not Assigned(Data) then Exit;

  R := PaintInfo.ContentRect;
  R.Left := R.Left + TVSTCracker(Sender).TextMargin;   // TextMargin is protected.
  R.Right := R.Right - TVSTCracker(Sender).TextMargin;

  PaintInfo.Canvas.Font.Size := AdjSize(cCustomDrawFontSize);
  if Sender.Selected[PaintInfo.Node] and Sender.Focused then begin
    PaintInfo.Canvas.Fill.Color := TAlphaColorRec.White;
  end else begin
    PaintInfo.Canvas.Fill.Color := clWindowText;
  end;

  case PaintInfo.Column of
    0: begin
      LLevel := Sender.GetNodeLevel(PaintInfo.Node);

      // A depth bar along the bottom of the cell - two pixels high, one step wider per
      // level. Nothing a string tree could express through OnGetText.
      LBar := R;
      LBar.Top := LBar.Bottom - AdjSize(3);
      LBar.Right := LBar.Left + AdjSize(12) * (LLevel + 1);
      if LBar.Right > R.Right then LBar.Right := R.Right;
      PaintInfo.Canvas.Brush.Color := TAlphaColorRec.Steelblue;
      PaintInfo.Canvas.FillRect(LBar);

      PaintInfo.Canvas.FillText(R, Data.Caption, False, 1, [],
        TTextAlign.Leading, TTextAlign.Center);
    end;
    1: begin
      PaintInfo.Canvas.FillText(R, Format('%d children', [PaintInfo.Node.ChildCount]),
         False, 1, [], TTextAlign.Leading, TTextAlign.Center);
    end;
  end;
end;

procedure TFormFmx.VTFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PNodeData;
begin
  Data := Sender.GetNodeData(Node);
  // Explicitely free the string, the VCL cannot know that there is one but needs to free
  // it nonetheless. For more fields in such a record which must be freed use Finalize(Data^)
  // instead touching every member individually.
  if Assigned(Data) then begin
    Finalize(Data^);
  end;
end;

procedure TFormFmx.VTGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
  var Handled: Boolean);

// Swipe right across a node to delete it, after a confirmation.
//
// The node is taken from the tree, not from the gesture. FMX delivers MouseDown before it
// recognises a gesture, so by the time this runs the tree has already hit tested the point
// the finger landed on - and that node is what the user pointed at, whatever coordinate space
// EventInfo.Location happens to be in on this target. Mapping the gesture point by hand was
// what deleted a node several rows away.
//
// LastHitInfo rather than FocusedNode: with SelectOnMouseUp the press only marks a node and
// the selection waits for the finger to come up, which for a swipe never happens - so the
// focus may still be on a completely different row. The focused node is the fallback, and the
// geometry after that, logged alongside so the three can be compared on a device.
//
// TDialogService.MessageDialog does not block on Android: it returns at once and calls back
// when the user answers. Everything that happens to the node therefore has to be inside the
// callback, and the node is captured by the closure. A demo can rely on that reference; an
// application that changes the tree from elsewhere would re-find the node instead.

const
  // How much vertical movement a swipe is allowed, as a fraction of its horizontal movement.
  // A real flick across a row is nearly all X; anything with this much Y in it was going up or
  // down the list.
  cSwipeMaxVerticalRatio = 0.5;
var
  LTree: TBaseVirtualTree;
  LLocal: TPointF;
  LNode: PVirtualNode;
  LHitNode: PVirtualNode;
  LData: PNodeData;
  LCaption: string;
  LTravel: TPointF;
begin
  if EventInfo.GestureID <> sgiRight then Exit;
  if not (Sender is TBaseVirtualTree) then Exit;

  LTree := TBaseVirtualTree(Sender);

  // A movement along the list is not a swipe. The platform recogniser is generous about the axis
  // it was not looking for, so a mostly vertical drag can still arrive here as a right swipe -
  // and deleting a node because the user was dragging one is the worst way to get this wrong.
  //
  // PressTravel is the tree's own measurement of how far the pointer has moved on each axis
  // since the press, fed from both MouseMove and the pan gesture, so this compares like with
  // like whatever coordinate space EventInfo.Location happens to be in on this target.
  //
  // Note this is only ever reached BEFORE a drag has started: TVTAncestorFMX.HandleGesture
  // refuses every gesture outright while tsVCLDragging is set. The window this closes is the
  // one between the press and DragDelay running out.
  LTravel := TVSTCracker(LTree).PressTravel;
  if LTravel.Y > LTravel.X * cSwipeMaxVerticalRatio then begin
    SetStatus(Format('Swipe ignored - that movement was mostly up and down (%.0f x, %.0f y).',
      [LTravel.X, LTravel.Y]));
    Exit;
  end;

  LLocal := LTree.ScreenToClient(EventInfo.Location);
  LHitNode := LTree.GetNodeAt(LLocal.X, LLocal.Y);

  LNode := LTree.LastHitInfo.HitNode;
  if not Assigned(LNode) then begin
    LNode := LTree.FocusedNode;
  end;
  if not Assigned(LNode) then begin
    LNode := LHitNode;
  end;

  TDebug.Log(Format('Gesture %d at (%.0f, %.0f) -> local (%.0f, %.0f): pressed %p, focused %p, hit %p',
    [EventInfo.GestureID, EventInfo.Location.X, EventInfo.Location.Y,
     LLocal.X, LLocal.Y, Pointer(LTree.LastHitInfo.HitNode), Pointer(LTree.FocusedNode),
     Pointer(LHitNode)]));

  if not Assigned(LNode) then begin
    SetStatus('Swipe right: no node to delete - tap a node first.');
    Exit;
  end;

  Handled := True;

  LCaption := '<no caption>';
  LData := LTree.GetNodeData(LNode);
  if Assigned(LData) then LCaption := LData.Caption;

  TDialogService.MessageDialog(
    Format('Delete "%s" and all of its children?', [LCaption]),
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrYes then begin
        LTree.DeleteNode(LNode);
        SetStatus(Format('Deleted "%s".', [LCaption]));
      end else begin
        SetStatus('Delete cancelled.');
      end;
    end);
end;

procedure TFormFmx.VTGetClipboardText(Sender: TObject; var AText: string);

// AText arrives empty for a draw tree - TBaseVirtualTree has no text to offer - so without
// this a Ctrl+C would still move nodes correctly inside the app but put nothing on the
// system clipboard for anything else. GetSortedCutCopySet, not the selection: the marking
// has already happened and the marked set is what a paste will act on.

var
  LNodes: TNodeArray;
  Data: PNodeData;
  I: Integer;
begin
  AText := '';
  LNodes := TVSTCracker(Sender).GetSortedCutCopySet(True);
  for I := 0 to High(LNodes) do begin
    Data := TVSTCracker(Sender).GetNodeData(LNodes[I]);
    if Assigned(Data) then
      AText := AText + Data.Caption + sLineBreak;
  end;
end;

procedure TFormFmx.VTGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: TImageIndex);
begin
  // This event is asked for FOUR different kinds. Answering them all with the same index
  // is why two images appeared side by side: ikState painted one in the state slot and
  // ikNormal another next to it, with ikOverlay landing a third on top of that. Only the
  // normal/selected pair is wanted here.
  if (Column = 0) and (Kind in [ikNormal, ikSelected]) then begin
    ImageIndex := Node.Index mod 3;
  end;
end;

procedure TFormFmx.VTGetNodeWidth(Sender: TBaseVirtualTree; HintCanvas: TCanvas;
  Node: PVirtualNode; Column: TColumnIndex; var NodeWidth: TDimension);

// The string tree measures its own text; a draw tree cannot, because only the application
// knows what it drew. Anything that asks how wide a node is - autosize, hints, horizontal
// scroll extent - gets 2 * TextMargin and nothing else without this.

var
  Data: PNodeData;
  LSize: TSize;
begin
  Data := Sender.GetNodeData(Node);
  if not Assigned(Data) then Exit;
  if Column <> 0 then Exit;

  HintCanvas.Font.Size := AdjSize(cCustomDrawFontSize);
  // GetTextExtentPoint32W is the port's own shim over the FMX canvas, and it is what
  // TCustomVirtualStringTree.DoTextMeasuring uses - so the draw tree measures text exactly
  // the way the string tree does rather than by a second, possibly different, route.
  GetTextExtentPoint32W(HintCanvas, Data.Caption, Length(Data.Caption), LSize);
  NodeWidth := LSize.cx + 2 * TVSTCracker(Sender).TextMargin;
end;

procedure TFormFmx.VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: string);
var
  Data: PNodeData;
begin
  // A handler for the OnGetText event is always needed as it provides the tree with the string
  // data to display.
  CellText := '';
  Data := Sender.GetNodeData(Node);
  if Assigned(Data) then begin
    CellText := Data.Caption;
  end;
end;

procedure TFormFmx.VTHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
var
  S: string;
  ColumnText: string;
begin
  if HitInfo.Column > NoColumn then begin
    ColumnText := Sender.Columns[HitInfo.Column].Text;
  end else begin
    ColumnText := '<none>';
  end;

  // Y is header local (0..Header.Height) in both VCL and FMX - see HandleClick.
  S := Format('HeaderClick: Col=%d (%s)  Btn=%s  X=%.0f  Y=%.0f of %.0f  Pos=[%s]  Shift=[%s]',
    [HitInfo.Column, ColumnText,
     MouseButtonToStr(HitInfo.Button),
     HitInfo.X, HitInfo.Y, Sender.Height,
     HitPositionToStr(HitInfo.HitPosition),
     ShiftStateToStr(HitInfo.Shift)]);

  // Diagnostic for the Android sort problem. Both TVTHeader.DoSetSortColumn and
  // SetSortDirection invalidate the glyph BEFORE testing (Tree.UpdateCount = 0), and
  // only call SortTree when that test passes. DoHeaderClick fires after that block, so
  // what we read here is the same counter the guard just tested. If Android shows a
  // non-zero UpdateCount where Windows shows 0, the guard is what is swallowing the sort.
  S := S + Format('  UpdateCount=%d  SortCol=%d  SortDir=%d',
    [ActiveTree.UpdateCount, Sender.SortColumn, Ord(Sender.SortDirection)]);

  SetStatus(S);
  TDebug.Log(S);
end;

procedure TFormFmx.VTIncrementalSearch(Sender: TBaseVirtualTree; Node: PVirtualNode;
  const SearchText: string; var Result: Integer);

// Zero means "this node matches". TCustomVirtualStringTree overrides DoIncrementalSearch in
// terms of its own text, so the string tree needs no handler; the draw tree has no text and
// would silently match nothing without this one.

var
  Data: PNodeData;
begin
  Result := 1;
  Data := Sender.GetNodeData(Node);
  if not Assigned(Data) then Exit;
  if CompareText(Copy(Data.Caption, 1, Length(SearchText)), SearchText) = 0 then begin
    Result := 0;
  end;
end;

procedure TFormFmx.VTInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var
  Data: PNodeData;
begin
  // ivsMultiline is the only way to put vsMultiline into a node's states at init time - see
  // TBaseVirtualTree.InitNode - and vsMultiline is what makes the string tree wrap a caption
  // across several lines instead of shortening it with an ellipsis.
  //
  // String tree only. A draw tree paints its own cells, so wrapping there would be this
  // form's job in VTDrawNode, and ComputeNodeHeight - which VTMeasureItem measures with - is
  // a string tree method: TBaseVirtualTree has no text to measure.
  if FUseMultiline and (Sender is TCustomVirtualStringTree) then begin
    Include(InitialStates, ivsMultiline);
  end;

  Data := Sender.GetNodeData(Node);
  if not Assigned(Data) then Exit;
  // Construct a node caption. This event is triggered once for each node but
  // appears asynchronously, which means when the node is displayed not when it is added.
  Data.Caption := Format('Level %d, Index %d', [Sender.GetNodeLevel(Node), Node.Index]);

  // Every fourth node gets a caption that cannot fit on one line - only when the tree is
  // going to wrap it. Without multiline there would be nothing to see but an ellipsis.
  if FUseMultiline and ((Node.Index mod 4) = 0) then begin
    Data.Caption := Data.Caption + cLongCaptionTail;
  end;

  // One check type per level, so a single tree exercises all three painters: tri-state
  // at the root (follows its children), plain boxes below it, radio buttons deeper still.
  // VT keeps radio siblings mutually exclusive by itself, no handler needed for that.
  if cUseCheckSupport then begin
    case Sender.GetNodeLevel(Node) of
      0: Sender.CheckType[Node] := ctTriStateCheckBox;
      1: Sender.CheckType[Node] := ctCheckBox;
    else
      Sender.CheckType[Node] := ctRadioButton;
    end;
  end;
end;

procedure TFormFmx.VTLoadNode(Sender: TBaseVirtualTree; Node: PVirtualNode; Stream: TStream);

// The other half of VSTSaveNode. Node is nil when the tree is loading its own user data
// rather than a node's, which this demo never writes.

var
  Data: PNodeData;
  Len: Integer;
  S: string;
begin
  if not Assigned(Node) then Exit;
  Data := Sender.GetNodeData(Node);
  if not Assigned(Data) then Exit;

  Stream.ReadBuffer(Len, SizeOf(Len));
  SetLength(S, Len);
  if Len > 0 then begin
    Stream.ReadBuffer(PChar(S)^, Len * SizeOf(Char));
  end;
  Data.Caption := S;
end;

procedure TFormFmx.VTMeasureItem(Sender: TBaseVirtualTree; TargetCanvas: TCanvas;
  Node: PVirtualNode; var NodeHeight: TDimension);

// How tall one row has to be. Fires only with toVariableNodeHeight set, and only while the
// node's vsHeightMeasured flag is clear - so once per node, and again after a column resize,
// which is where TBaseVirtualTree.DoColumnResize clears that flag for every multiline node.
// Nothing else has to be done to re-wrap on resize; the next paint re-measures.
//
// NodeHeight starts from DefaultNodeHeight rather than from the value passed in. The incoming
// value is the height the node already has, so building on it would let a row grow when a
// column narrows and never shrink again when it widens.
//
// TargetCanvas arrives carrying whatever font was last used on it. ComputeNodeHeight measures
// "by using its current font settings" and sets none of its own, so assigning the font here is
// not optional - without it the row is measured in one font and painted in another, and the
// mismatch only shows on whichever platform's default font happens to differ.

var
  LTree: TCustomVirtualStringTree;
  LHeight: TDimension;
begin
  NodeHeight := TVSTCracker(Sender).DefaultNodeHeight;

  if not Assigned(Node) then Exit;
  if not Assigned(TargetCanvas) then Exit;   // Can be nil before the tree has ever painted.
  if not (vsMultiline in Node.States) then Exit;
  if not (Sender is TCustomVirtualStringTree) then Exit;

  LTree := TCustomVirtualStringTree(Sender);
  TargetCanvas.Font.Assign(TVSTCracker(Sender).Font);

  // The main column: that is the one the tree indents and wraps text in, and the one this
  // demo puts the long captions in. A form with long text in several columns would measure
  // each of them and keep the largest - a row is as tall as its tallest cell.
  LHeight := LTree.ComputeNodeHeight(TargetCanvas, Node, Sender.Header.MainColumn);

  // ComputeNodeHeight returns the height of the TEXT. The margin the tree leaves above and
  // below it is the application's to add, exactly as it is on the horizontal axis in
  // VTGetNodeWidth.
  LHeight := LHeight + 2 * TVSTCracker(Sender).TextMargin;

  // Never below DefaultNodeHeight: the check box and the node image are sized from it, and a
  // one-word caption would otherwise produce a row too short to draw them in.
  if LHeight > NodeHeight then begin
    NodeHeight := LHeight;
  end;
end;

procedure TFormFmx.VTNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; NewText: string);

// The edit link writes back through Text[Node, Column], which lands here. Nothing else
// stores the value - the tree holds no text of its own.

var
  Data: PNodeData;
begin
  Data := Sender.GetNodeData(Node);
  if not Assigned(Data) then Exit;
  Data.Caption := NewText;
end;

procedure TFormFmx.VTNodeDblClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);

// toEditOnClick and toEditOnDblClick both depend on the edit delay timer, and the
// SetTimer call that starts it is inside {$IFDEF VT_VCL} in TBaseVirtualTree.MouseUp -
// StopTimer is an empty stub on FMX. So the trigger is wired by hand here instead.
//
// Queued rather than called inline: this fires from inside the tree's double click
// handling, which has more to do after the event returns. Creating and focusing an editor
// midway through that is asking for trouble.

var
  LTree: TCustomVirtualStringTree;
  LNode: PVirtualNode;
  LColumn: TColumnIndex;
begin
  if not Assigned(HitInfo.HitNode) then Exit;

  // Inline editing is a string tree feature. The editor writes back through
  // Text[Node, Column], and a draw tree has no such property - it would need its own
  // OnCreateEditor and an edit link that knows what the node data means.
  if not (Sender is TCustomVirtualStringTree) then begin
    SetStatus('Inline editing is a string tree feature - the draw tree has no text to edit.');
    Exit;
  end;
  LTree := TCustomVirtualStringTree(Sender);

  LNode := HitInfo.HitNode;
  LColumn := HitInfo.HitColumn;
  if LColumn <= NoColumn then begin
    LColumn := LTree.Header.MainColumn;
  end;

  TThread.ForceQueue(nil,
    procedure
    begin
      LTree.EditNode(LNode, LColumn);
    end);
end;

procedure TFormFmx.VTPasteText(Sender: TObject; const AText: string; var Handled: Boolean);

// Reached only when the clipboard text did not come from a tree in this process - a paste
// inside the app moves or copies the real nodes and never gets here. A real application
// would parse the text into nodes; this one just proves the path runs.

begin
  SetStatus(Format('Pasted %d characters of foreign text - not turned into nodes.',
    [Length(AText)]));
  Handled := True;
end;

procedure TFormFmx.VTSaveNode(Sender: TBaseVirtualTree; Node: PVirtualNode; Stream: TStream);

// Length prefix then the characters. Deliberately not WriteComponent or a TStringStream:
// this has to round trip exactly, and the reader has to know where the string ends.

var
  Data: PNodeData;
  Len: Integer;
begin
  if not Assigned(Node) then Exit;
  Data := Sender.GetNodeData(Node);
  if not Assigned(Data) then Exit;

  Len := Length(Data.Caption);
  Stream.WriteBuffer(Len, SizeOf(Len));
  if Len > 0 then begin
    Stream.WriteBuffer(PChar(Data.Caption)^, Len * SizeOf(Char));
  end;
end;

procedure TFormFmx.VTStateChange(Sender: TBaseVirtualTree; Enter, Leave: TVirtualTreeStates);

// tsCheckPropagation is set while one check click is being carried through the tree and
// cleared when the last node has been dealt with, so this is the one place that knows a
// bulk check has finished - and the only place a status line about it can be written
// without writing one per node.

begin
  if tsCheckPropagation in Enter then begin
    FCheckedCount := 0;
  end;

  if tsCheckPropagation in Leave then begin
    if FCheckedCount > 1 then begin
      SetStatus(Format('Checked %d nodes.', [FCheckedCount]));
    end;
    // Back to zero for the next click: DoChecking can fire before the propagation state is
    // entered, and a stale count from the last one would silence its log line.
    FCheckedCount := 0;
  end;
end;

end.

