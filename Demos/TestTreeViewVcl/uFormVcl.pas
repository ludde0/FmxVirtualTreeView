unit uFormVcl;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ActiveX, System.SysUtils, System.Variants, System.Classes,
  System.Types, System.UITypes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees.Types, VirtualTrees,
  VirtualTrees.BaseTree, VirtualTrees.DrawTree,
  Vcl.ExtCtrls, Vcl.StdCtrls, System.ImageList, Vcl.ImgList;

type
  TFormVcl = class(TForm)
    Button_AddNodesToChildren: TButton;
    Button_AddNodesToRoot: TButton;
    Button_ClearTree: TButton;
    Button_Close: TButton;
    Button_Test: TButton;
    CheckBox_CustomDraw: TCheckBox;
    CheckBox_DragAutomatic: TCheckBox;
    CheckBox_DragOLE: TCheckBox;
    CheckBox_DrawTree: TCheckBox;
    CheckBox_MultiLine: TCheckBox;
    CheckBox_MultiSelect: TCheckBox;
    Edit_Filter: TEdit;
    Edit_NodeCount: TEdit;
    ImageList_Tree: TImageList;
    Label_AddNodes: TLabel;
    Label_Filter: TLabel;
    Label_Status: TLabel;
    Panel_Bottom: TPanel;
    Panel_Controls: TPanel;
    Panel_Top: TPanel;
    Panel_TreeView: TPanel;
    procedure Button_AddNodesClick(Sender: TObject);
    procedure Button_ClearTreeClick(Sender: TObject);
    procedure Button_CloseClick(Sender: TObject);
    procedure Button_TestClick(Sender: TObject);
    procedure CheckBox_CustomDrawClick(Sender: TObject);
    procedure CheckBox_DragAutomaticClick(Sender: TObject);
    procedure CheckBox_DragOLEClick(Sender: TObject);
    procedure CheckBox_DrawTreeClick(Sender: TObject);
    procedure CheckBox_MultiLineClick(Sender: TObject);
    procedure CheckBox_MultiSelectClick(Sender: TObject);
    procedure Edit_FilterChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FCheckedCount: Integer;           // Nodes touched by the check propagation in progress.
    FDrawTree: TVirtualDrawTree;
    FStringTree: TVirtualStringTree;
    FUseApplyColumnWidths: Boolean;
    FUseMultiline: Boolean;           // Wrap long captions, or shorten them with an ellipsis.
    FUserResizedColumns: Boolean;     // Once the user drags a column, stop imposing percentages.
    procedure AddNodesFromStrings(ATree: TBaseVirtualTree; ATargetNode: PVirtualNode;
      AAttachMode: TVTNodeAttachMode; const AItems: array of string);
    procedure ApplyColumnWidths(const AColumnWidths: array of Single);
    procedure ApplyColumnWidthsTo(ATree: TBaseVirtualTree; const AColumnWidths: array of Single);
    function  ApplyFilter(ATree: TBaseVirtualTree; const AFilter: string): Integer;
    procedure ApplyMultilineOption(ATree: TBaseVirtualTree);
    procedure ConfigureTree(ATree: TBaseVirtualTree);
    procedure CreateDrawTree;
    procedure CreateStringTree;
    function  DrawTreeAsText(ATree: TBaseVirtualTree): string;
    function  GetActiveTree: TBaseVirtualTree;
    procedure HideOddRootNodes(ATree: TBaseVirtualTree);
    function  PasteAndSelect(ATree: TBaseVirtualTree): Integer;
    procedure SetStatus(const AText: string);
    procedure VTBeforeItemPaint(Sender: TBaseVirtualTree; Canvas: TCanvas; Node: PVirtualNode;
      Rect: TRect; var CustomDraw: Boolean);
    procedure VTChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VTChecking(Sender: TBaseVirtualTree; Node: PVirtualNode;
      var NewState: TCheckState; var Allowed: Boolean);
    procedure VTColumnResize(Sender: TVTHeader; Column: TColumnIndex);
    procedure VTCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode;
      Column: TColumnIndex; var Result: Integer);
    procedure VTDragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      var Allowed: Boolean);
    procedure VTDragDrop(Sender: TBaseVirtualTree; Source: TObject; DataObject: TVTDragDataObject;
      Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure VTDragOver(Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState;
      State: TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
    procedure VTDrawNode(Sender: TBaseVirtualTree; const PaintInfo: TVTPaintInfo);
    procedure VTFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VTGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: System.UITypes.TImageIndex);
    procedure VTGetNodeWidth(Sender: TBaseVirtualTree; HintCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; var NodeWidth: TDimension);
    procedure VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure VTGetUserClipboardFormats(Sender: TBaseVirtualTree; var Formats: TFormatEtcArray);
    procedure VTHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
    procedure VTIncrementalSearch(Sender: TBaseVirtualTree; Node: PVirtualNode;
      const SearchText: string; var Result: Integer);
    procedure VTInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
      var InitialStates: TVirtualNodeInitStates);
    procedure VTKeyAction(Sender: TBaseVirtualTree; var CharCode: Word;
      var Shift: TShiftState; var DoDefault: Boolean);
    procedure VTLoadNode(Sender: TBaseVirtualTree; Node: PVirtualNode; Stream: TStream);
    procedure VTMeasureItem(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
      var NodeHeight: TDimension);
    procedure VTNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: string);
    procedure VTNodeDblClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
    procedure VTRenderOLEData(Sender: TBaseVirtualTree; const FormatEtcIn: TFormatEtc;
      out Medium: TStgMedium; ForClipboard: Boolean; var Result: HRESULT);
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
  FormVcl: TFormVcl;

function AdjSize(ASize: Integer; Factor: Single = 1.0): Integer; overload;
function AdjSize(ASize: Single; Factor: Single = 1.0): Single; overload;

implementation

{$R *.dfm}

uses
  Winapi.CommCtrl,
  // Winapi.ActiveX (IDataObject, TFormatEtc, ReleaseStgMedium, DROPEFFECT_*) moved to the
  // interface uses: TFormatEtc and TStgMedium now appear in the OnRenderOLEData handler's
  // signature, which is part of the class declaration.
  Winapi.ShellAPI,             // DragQueryFile, for files dropped from Explorer
  VirtualTrees.DragnDrop,      // StandardOLEFormat - the TFormatEtc VT itself asks with
  VirtualTrees.AncestorVCL,    // TVTAncestorVcl - OnRenderOLEData is declared there, not on the base tree
  VirtualTrees.ClipBoard,      // CF_* format ids
  System.Generics.Collections, // TDictionary, for the paste diff
  System.StrUtils,             // ContainsText, for the filter
  System.TypInfo;   // GetEnumName

const
  // Initial column widths as a fraction of the tree's usable width.
  // The last column always absorbs the rounding remainder, so these need
  // not add up to exactly 1.0 - but it looks better if they do.
  cColPercent: array [0 .. 1] of Single = (0.70, 0.30);

  // Points, not the FMX demo's 12. FMX font sizes are device independent pixels, and 12 of
  // those is about 9 points at 96 dpi - so this is the same size on screen, not a change.
  //
  // Deliberately NOT passed through AdjSize, unlike every other size in this unit. A point
  // is already a physical unit: TFont.Size assigns Height := -MulDiv(Size, PixelsPerInch,
  // 72), so the framework applies the dpi itself. Scaling the point count as well is what
  // made the text twice the size it should be.
  cCustomDrawFontSize = 9;

  // Appended to every third generated caption, so the tree shows wrapped and unwrapped rows
  // next to each other. A uniform wall of two line nodes would not prove that the height is
  // being measured per node rather than simply doubled.
  cLongCaptionTail =
    ' - and this one carries a caption long enough that it cannot fit on a single line of ' +
    'the main column, which is the whole point: the row has to grow to hold it.';

  // Master switch for the checkbox demo, kept so both demos can be turned off at the same
  // place. The VCL check painter has always worked; this is here for symmetry only.
  cUseCheckSupport = True;

  // Indexed by "was it a copy" - see VTDragDrop.
  VERB_COPIED: array [Boolean] of string = ('Moved', 'Copied');

type
  // GetOffsets, GetCheckImage, PaintCheckImage and PaintNodeButton are protected. Custom
  // drawing needs all four, and reaching them through a cracker is far better than
  // reimplementing the layout: this way the box is painted exactly where the hit test
  // will later look for it.
  //
  // TBaseVirtualTree and not TVTAncestorFMX as in the FMX demo: the events that forced the
  // cracker down a level there - OnPasteText, OnAfterPaste, OnGetClipboardText - are the
  // FMX substitute for OLE and do not exist on this side.
  TVSTCracker = class(TBaseVirtualTree);

  // A cracker only reaches what itself and its OWN ancestors declare. OnRenderOLEData is
  // protected one level further down than TBaseVirtualTree - on the VCL ancestor that
  // implements the OLE side - so reaching it needs a second one.
  TVTVclCracker = class(TVTAncestorVcl);

  // This is a very simple record we use to store data in the nodes.
  // Since the application is responsible to manage all data including the node's caption
  // this record can be considered as minimal requirement in all VT applications.
  // Extend it to whatever your application needs.
  PNodeData = ^TNodeData;
  TNodeData = record
    Caption: string;
  end;

  // Where a node sat before a paste. Used to tell what the paste produced - see
  // PasteAndSelect.
  TNodePlace = record
    Parent: PVirtualNode;
  end;

var
  // The form's own dpi, read once in FormCreate. 96 until then, so anything that manages to
  // run earlier gets the unscaled value rather than a wrong one.
  GPPI: Integer = 96;

function AdjSize(ASize: Integer; Factor: Single = 1.0): Integer;
begin
  // The VCL scales the form's font and everything stored in the dfm when Windows is not at
  // 100%, but a size assigned at run time misses that pass and stays raw pixels - which is
  // why a 24 pixel row was not tall enough for text the framework had already grown. This
  // is the opposite number of the FMX version's 1.35 Android factor: same call sites, same
  // purpose, a different thing to scale by.
  Result := MulDiv(Round(ASize * Factor), GPPI, 96);
end;

function AdjSize(ASize: Single; Factor: Single = 1.0): Single;
begin
  Result := ASize * Factor * GPPI / 96;
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

function FormatsToStr(const AFormats: TFormatArray): string;

// What the payload actually carries, by name. This is the single most useful thing to see while
// testing OLE drag and drop - "the drop did nothing" is nearly always "the format I expected is
// not in the list". Registered formats have a name; the predefined ones (CF_TEXT = 1,
// CF_UNICODETEXT = 13, CF_HDROP = 15 ...) do not, so those print as a number.

var
  I, LLen: Integer;
  LBuf: array [0 .. 255] of Char;
  LName: string;
begin
  Result := '';
  for I := 0 to High(AFormats) do begin
    LLen := GetClipboardFormatName(AFormats[I], LBuf, Length(LBuf));
    if LLen > 0 then begin
      SetString(LName, PChar(@LBuf[0]), LLen);
    end else begin
      LName := Format('#%d', [AFormats[I]]);
    end;
    if Result <> '' then Result := Result + ', ';
    Result := Result + LName;
  end;
  if Result = '' then Result := '<none>';
end;

function TryGetOLEFiles(const ADataObject: IDataObject; out AFiles: TArray<string>): Boolean;

// CF_HDROP - what Explorer puts on a file drag. StandardOLEFormat is VT's own prototype record
// (VirtualTrees.DragnDrop); only cfFormat and tymed need overriding, and tymed has to be
// narrowed to HGLOBAL because DragQueryFile wants a global memory handle, not a stream.

var
  LFormat: TFormatEtc;
  LMedium: TStgMedium;
  LCount, I, LLen: Integer;
  LBuf: array [0 .. MAX_PATH] of Char;
begin
  Result := False;
  AFiles := nil;
  if not Assigned(ADataObject) then Exit;

  LFormat := StandardOLEFormat;
  LFormat.cfFormat := CF_HDROP;
  LFormat.tymed := TYMED_HGLOBAL;
  if ADataObject.GetData(LFormat, LMedium) <> S_OK then Exit;
  try
    // $FFFFFFFF asks for the COUNT rather than for a file name.
    LCount := DragQueryFile(LMedium.hGlobal, $FFFFFFFF, nil, 0);
    SetLength(AFiles, LCount);
    for I := 0 to LCount - 1 do begin
      LLen := DragQueryFile(LMedium.hGlobal, I, LBuf, Length(LBuf));
      SetString(AFiles[I], PChar(@LBuf[0]), LLen);
    end;
    Result := LCount > 0;
  finally
    ReleaseStgMedium(LMedium);
  end;
end;

function TryGetOLEText(const ADataObject: IDataObject; out AText: string): Boolean;

// CF_UNICODETEXT - what a text drag from Notepad, an editor or a browser carries. Only the
// Unicode form is asked for: anything that offers CF_TEXT offers this too, through the
// clipboard's automatic synthesis if not directly.

var
  LFormat: TFormatEtc;
  LMedium: TStgMedium;
  LPtr: PChar;
begin
  Result := False;
  AText := '';
  if not Assigned(ADataObject) then Exit;

  LFormat := StandardOLEFormat;
  LFormat.cfFormat := CF_UNICODETEXT;
  LFormat.tymed := TYMED_HGLOBAL;
  if ADataObject.GetData(LFormat, LMedium) <> S_OK then Exit;
  try
    LPtr := GlobalLock(LMedium.hGlobal);
    if Assigned(LPtr) then begin
      try
        AText := LPtr;   // The block is null terminated.
      finally
        GlobalUnlock(LMedium.hGlobal);
      end;
    end;
    Result := AText <> '';
  finally
    ReleaseStgMedium(LMedium);
  end;
end;

procedure ResizeImageListImagesforHighDPI(const ImageList: TCustomImageList);
var
  ii : integer;
  mb, ib, sib, smb : Vcl.Graphics.TBitmap;
  highDPIImageListContainer: TImageList;
  oldSIZE, newSIZE: Integer;
begin
  if Screen.PixelsPerInch = 96 then Exit;

  oldSize := ImageList.Height;

  highDPIImageListContainer := TImageList.Create(nil);
  highDPIImageListContainer.SetSize(oldSize, oldSize);
  try
    // Add from source image list
    for ii := 0 to ImageList.Count -1 do begin
      highDPIImageListContainer.AddImage(ImageList, ii);
    end;

    // Set size to match DPI size (like 250% of 16px = 40px).
    // Note that this also clears the image list!
    newSIZE := MulDiv(oldSize, Screen.PixelsPerInch, 96);
    ImageList.SetSize(newSIZE, newSIZE);

    // Add images back to original ImageList stretched (if DPI scaling > 150%) or centered (if DPI scaling <= 150%)
    for ii := 0 to -1 + highDPIImageListContainer.Count do begin
      sib := Vcl.Graphics.TBitmap.Create; //stretched image
      smb := Vcl.Graphics.TBitmap.Create; //stretched mask
      try
        sib.Width := ImageList.Width;
        sib.Height := ImageList.Height;
        sib.Canvas.FillRect(sib.Canvas.ClipRect);
        smb.Width := ImageList.Width;
        smb.Height := ImageList.Height;
        smb.Canvas.FillRect(smb.Canvas.ClipRect);

        ib := Vcl.Graphics.TBitmap.Create;
        mb := Vcl.Graphics.TBitmap.Create;
        try
          ib.Width := oldSize;
          ib.Height := oldSize;
          ib.Canvas.FillRect(ib.Canvas.ClipRect);

          mb.Width := oldSize;
          mb.Height := oldSize;
          mb.Canvas.FillRect(mb.Canvas.ClipRect);

          ImageList_DrawEx(highDPIImageListContainer.Handle, ii, ib.Canvas.Handle, 0, 0, ib.Width, ib.Height, CLR_NONE, CLR_NONE, ILD_NORMAL);
          ImageList_DrawEx(highDPIImageListContainer.Handle, ii, mb.Canvas.Handle, 0, 0, mb.Width, mb.Height, CLR_NONE, CLR_NONE, ILD_MASK);

          sib.Canvas.StretchDraw(Rect(0, 0, sib.Width, sib.Width), ib);
          smb.Canvas.StretchDraw(Rect(0, 0, smb.Width, smb.Width), mb);
        finally
          ib.Free;
          mb.Free;
        end;

        ImageList.Add(sib, smb);
      finally
        sib.Free;
        smb.Free;
      end;
    end;
  finally
    highDPIImageListContainer.Free;
  end;
end;


procedure TFormVcl.AddNodesFromStrings(ATree: TBaseVirtualTree; ATargetNode: PVirtualNode;
  AAttachMode: TVTNodeAttachMode; const AItems: array of string);

// Turns whatever a foreign drag brought with it - file names, lines of text - into real nodes.
//
// InsertNode does NOT initialize the new node, so OnInitNode fires later, when the node is
// first painted. That is why VTInitNode only invents a caption for a node that has none: the
// caption assigned here would otherwise be overwritten a moment later by "Level 0, Index 7".
//
// Same direction rule as VTDragDrop: amInsertBefore and amAddChildLast put each new node
// FURTHEST from the target, so walking forwards preserves the original order; the other two put
// it CLOSEST, so those are walked backwards. Exactly what ProcessOLEData does internally.

var
  I: Integer;
  LNode: PVirtualNode;
  LData: PNodeData;

  procedure AddOne(AIndex: Integer);
  begin
    LNode := ATree.InsertNode(ATargetNode, AAttachMode);
    LData := ATree.GetNodeData(LNode);
    if Assigned(LData) then LData.Caption := AItems[AIndex];
  end;

begin
  if Length(AItems) = 0 then Exit;

  ATree.BeginUpdate;
  try
    if AAttachMode in [amInsertBefore, amAddChildLast] then begin
      for I := 0 to High(AItems) do AddOne(I);
    end else begin
      for I := High(AItems) downto 0 do AddOne(I);
    end;
  finally
    ATree.EndUpdate;
  end;

  if Assigned(ATargetNode) and (AAttachMode in [amAddChildFirst, amAddChildLast]) then
    ATree.Expanded[ATargetNode] := True;
end;

procedure TFormVcl.ApplyColumnWidths(const AColumnWidths: array of Single);

// BOTH trees, not just the visible one. The hidden tree still has a header, and if it is
// left out it comes back on screen with the widths it had when it was last shown.

begin
  ApplyColumnWidthsTo(FStringTree, AColumnWidths);
  ApplyColumnWidthsTo(FDrawTree, AColumnWidths);
end;

procedure TFormVcl.ApplyColumnWidthsTo(ATree: TBaseVirtualTree; const AColumnWidths: array of Single);
const
  cMinUsableWidth = 50;     // Below this the form is not laid out yet.
var
  Avail: Integer;
  I, W, Used: Integer;
begin
  if not FUseApplyColumnWidths or not Assigned(ATree) then Exit;

  if Length(AColumnWidths) <> ATree.Header.Columns.Count then begin
    raise Exception.Create('Array of column widths must correspond to "Header.Columns.Count"');
  end;

  if FUserResizedColumns then Exit;
  if ATree.Header.Columns.Count = 0 then Exit;

  // ClientWidth of a hidden tree is still meaningful - it is aligned to the same panel as
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
  W := Avail - Used;
  if W < AdjSize(20) then W := AdjSize(20);
  ATree.Header.Columns[ATree.Header.Columns.Count - 1].Width := W;
end;

function TFormVcl.ApplyFilter(ATree: TBaseVirtualTree; const AFilter: string): Integer;

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

procedure TFormVcl.ApplyMultilineOption(ATree: TBaseVirtualTree);

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

procedure TFormVcl.Button_AddNodesClick(Sender: TObject);
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
        MessageDlg('Select a node first: new nodes are added as children of the focused one.',
          mtInformation, [mbOK], 0);
        Exit;
      end;
    end;
  end;

  SetStatus(Format('Last operation duration: %d ms', [TThread.GetTickCount64 - Start]));
end;

procedure TFormVcl.Button_ClearTreeClick(Sender: TObject);
var
  Start: UInt64;
begin
  Start := TThread.GetTickCount64;
  ActiveTree.Clear;
  SetStatus(Format('Last operation duration: %d ms', [TThread.GetTickCount64 - Start]));
end;

procedure TFormVcl.Button_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFormVcl.Button_TestClick(Sender: TObject);
begin
  ActiveTree.SortTree(0, sdDescending, True);
end;

procedure TFormVcl.CheckBox_CustomDrawClick(Sender: TObject);

// OnClick, not OnChange - a VCL TCheckBox has no OnChange, and OnClick fires for a keyboard
// space and for a programmatic Checked := ... as well, so nothing is lost.
//
// Both trees, so the setting is not silently different on whichever tree is hidden. Note
// this checkbox outranks the other one: OnBeforeItemPaint returning CustomDraw = True skips
// the whole default item painter, and OnDrawNode is called from inside it - so with custom
// draw on, the draw tree's own paint event does not fire at all.

begin
  if Assigned(FStringTree) then FStringTree.Invalidate;
  if Assigned(FDrawTree) then FDrawTree.Invalidate;
end;

procedure TFormVcl.CheckBox_DragAutomaticClick(Sender: TObject);
var
  LT: TVSTCracker;
begin
  LT := TVSTCracker(GetActiveTree);
  if CheckBox_DragAutomatic.Checked then begin
    LT.DragMode := TDragMode.dmAutomatic;
  end else begin
    LT.DragMode := TDragMode.dmManual;
  end;
end;

procedure TFormVcl.CheckBox_DragOLEClick(Sender: TObject);
var
  LT: TVSTCracker;
begin
  // dtVCL - TControl's own drag'n drop, driven by CM_DRAG. Inside this application only.
  //         OnDragDrop is handed no data object at all, just the source tree.
  // dtOLE - real Windows OLE drag and drop. Three things become possible that dtVCL cannot
  //         do, and all three are exercised:
  //           * drag nodes between TWO RUNNING COPIES of this demo (start the exe twice)
  //           * drop files from Explorer onto the tree
  //           * drag nodes OUT to Notepad, which gets their captions as text with no code
  //             here at all - TCustomVirtualStringTree registers CF_UNICODETEXT/CF_TEXT and
  //             renders them itself. (A draw tree has no text, so it offers none - that
  //             would need OnGetUserClipboardFormats plus OnRenderOLEData.)
  LT := TVSTCracker(GetActiveTree);
  if CheckBox_DragOLE.Checked then begin
    LT.DragType := TVTDragType.dtOLE;
  end else begin
    LT.DragType := TVTDragType.dtVCL;
  end;
end;

procedure TFormVcl.CheckBox_DrawTreeClick(Sender: TObject);

// Swapping rather than showing both side by side: the point is that the same data and the
// same handlers drive either class - not a pixel comparison. Focus has to move with the
// swap or the keyboard talks to a hidden tree.

begin
  if not (Assigned(FStringTree) and Assigned(FDrawTree)) then Exit;

  FDrawTree.Visible := CheckBox_DrawTree.Checked;
  FStringTree.Visible := not CheckBox_DrawTree.Checked;

  if ActiveTree.CanFocus then begin
    ActiveTree.SetFocus;
  end;

  if CheckBox_DrawTree.Checked then begin
    SetStatus('TVirtualDrawTree - every cell painted by OnDrawNode. No text, no inline editing.');
  end else begin
    SetStatus('TVirtualStringTree - text through OnGetText, editable, clipboard text for free.');
  end;
end;

procedure TFormVcl.CheckBox_MultiLineClick(Sender: TObject);
begin
  FUseMultiline := CheckBox_MultiLine.Checked;
  ApplyMultilineOption(FStringTree);
  ApplyMultilineOption(FDrawTree);
  if FUseMultiline then begin
    SetStatus('Multiline: every fourth caption is long and wraps, and each row is measured.');
  end else begin
    SetStatus('Single line: long captions are shortened with an ellipsis, rows are uniform.');
  end;
end;

procedure TFormVcl.CheckBox_MultiSelectClick(Sender: TObject);
var
  LT: TVSTCracker;
begin
  LT := TVSTCracker(GetActiveTree);
  if CheckBox_MultiSelect.Checked then begin
    LT.TreeOptions.SelectionOptions := LT.TreeOptions.SelectionOptions + [toMultiSelect];
  end else begin
    LT.TreeOptions.SelectionOptions := LT.TreeOptions.SelectionOptions - [toMultiSelect];
  end;
end;

procedure TFormVcl.ConfigureTree(ATree: TBaseVirtualTree);

// Everything both trees have in common, which turns out to be nearly all of it. The two
// classes differ only in how a cell's CONTENT is produced - text through OnGetText, or
// pixels through OnDrawNode - so data, options, columns, check boxes, images and sorting
// are configured once, here, and every handler below serves both trees.
//
// The cracker is not a trick to reach something private: TreeOptions, Images, events and
// the rest are PROTECTED on TBaseVirtualTree and only republished as published by each
// concrete class. Assigning them through the base type is what needs the cast.

var
  LT: TVSTCracker;
  AColumn: TVirtualTreeColumn;
begin
  LT := TVSTCracker(ATree);
  LT.Parent := Panel_TreeView;
  LT.Align := alClient;

  LT.Color := clWhite;
  LT.Colors.BorderColor := clWindowText;
  LT.Colors.FocusedSelectionColor := clBlue;
  LT.DragType := dtVCL;
  LT.DragMode := TDragMode.dmManual;

  LT.DefaultNodeHeight := AdjSize(24);
  // No CheckImageSize/NodeImageSize here as in the FMX demo - those two are {$IFDEF VT_FMX}
  // and exist because FMX scales a 32px list entry into whatever rect it is given. The VCL
  // lists draw at their own size, and the layout offsets are derived from that same size.
  LT.Images := ImageList_Tree;

  // Incremental search is isNone by default. isVisibleOnly is what a list is expected to
  // do: type a few letters and the first visible node whose caption starts with them takes
  // the focus. The buffer resets once IncrementalSearchTimeout (1s) has passed.
  LT.IncrementalSearch := isVisibleOnly;

  LT.TreeOptions.AnimationOptions := LT.TreeOptions.AnimationOptions + [toAnimatedToggle];

  // toEditOnDblClick is the one option the FMX demo cannot have: it runs off the edit delay
  // timer, and the SetTimer that starts it is inside {$IFDEF VT_VCL}. Here it works, so the
  // editor is started by the tree rather than by hand from OnNodeDblClick.
  // toFullRowDrag: without it a drag can only be started on the caption or the node image, which
  // is the same rule the FMX/Android twin has to live with - so both demos set it and both start a
  // drag anywhere in the row.
  // toAcceptOLEDrop is in the DEFAULT MiscOptions set and this line replaces the whole set, so
  // leaving it out is what stops TBaseVirtualTree.CreateWnd from calling RegisterDragDrop - and
  // an unregistered window cannot RECEIVE an OLE drop at all, while its source side goes on
  // working perfectly. Exactly the same trap as toShowDropmark below, and just as quiet.
  // toVariableNodeHeight is what makes GetNodeHeight ask the application how tall each row
  // is, through OnMeasureItem. Without it every row is DefaultNodeHeight and a wrapped
  // caption is simply clipped. Note the option's setter reinitialises every node, so it is
  // set here - before RootNodeCount at the end of this method - rather than later.
  LT.TreeOptions.MiscOptions :=
    [toAcceptOLEDrop, toEditable, toEditOnDblClick, toFullRowDrag, toInitOnSave,
     toWheelPanning];
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
  // own after AutoExpandDelay (1000 ms by default).
  // toAutoScroll: hold a drag near the top or bottom edge and the view follows, so a node can
  // be dropped somewhere that was off screen when the drag began. Not in the default set, and
  // without it CanAutoScroll refuses and nothing scrolls during a drag at all. The pointer has
  // to stay in the edge zone for AutoScrollDelay (300 ms) first.
  LT.TreeOptions.AutoOptions := LT.TreeOptions.AutoOptions + [toAutoDropExpand, toAutoScroll];
  // toShowDropmark is in the DEFAULT PaintOptions set, and this line replaces the whole set - so
  // leaving it out silently turned the insert marker off and made a drag look like it was doing
  // nothing between the nodes.
  LT.TreeOptions.PaintOptions :=
    [toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware,
     toUseBlendedImages];
  LT.TreeOptions.SelectionOptions := [toFullRowSelect];
  // Qualified: Vcl.Forms exports a deprecated TScrollStyle and comes later in the uses
  // clause than System.UITypes, so an unqualified name is a W1000 here.
  LT.ScrollBarOptions.ScrollBars := System.UITypes.TScrollStyle.ssBoth;

  // Not one of these handlers cares which class it is serving - they all work through
  // Sender and the node record, never through a field naming one particular tree.
  LT.OnBeforeItemPaint := VTBeforeItemPaint;   // Custom draw of whole rows.
  LT.OnChecked := VTChecked;             // After the state changed.
  LT.OnChecking := VTChecking;           // Veto hook, fires before.
  LT.OnStateChange := VTStateChange;     // Start and end of a check propagation.
  LT.OnColumnResize := VTColumnResize;
  LT.OnCompareNodes := VTCompareNodes;   // Required, otherwise hoHeaderClickAutoSort sorts nothing.
  // THE dmManual fix. TBaseVirtualTree.DoBeforeDrag returns False when OnDragAllowed is not
  // assigned, and with DragMode = dmManual HandleMouseDown computes
  //   AutoDrag := DoBeforeDrag(...) and (FullRowDrag or IsLabelHit)
  // so an unassigned event means AutoDrag is always False, BeginDrag is never called, no drag ever
  // starts and OnDragOver therefore never fires. dmAutomatic worked only because it takes the
  // other branch (AutoDrag := DragMode = dmAutomatic) and never asks the application at all.
  LT.OnDragAllowed := VTDragAllowed;
  LT.OnDragOver := VTDragOver;
  LT.OnDragDrop := VTDragDrop;
  LT.OnNodeDblClick := VTNodeDblClick;   // The edit trigger - string tree only, see there.
  LT.OnFreeNode := VTFreeNode;
  LT.OnGetImageIndex := VTGetImageIndex;
  LT.OnHeaderClick := VTHeaderClick;
  LT.OnInitNode := VTInitNode;
  LT.OnKeyAction := VTKeyAction;   // Ctrl+X, Ctrl+C and Ctrl+V - see the handler.
  // Copying a node serializes it, and the tree streams NOTHING of the node's own record -
  // only what these two write and read. Without them a pasted node arrives with an empty
  // caption. A string could not be copied as raw bytes anyway.
  LT.OnLoadNode := VTLoadNode;
  LT.OnMeasureItem := VTMeasureItem;
  LT.OnSaveNode := VTSaveNode;
  // No OnAfterPaste, OnPasteText or OnGetClipboardText here. Those three are the FMX port's
  // replacement for OLE; on this side CopyToClipboard and PasteFromClipboard go through the
  // real thing and need no handler at all. What is lost is the draw tree's clipboard TEXT
  // for other applications - the VCL route for that is OnGetUserClipboardFormats plus
  // OnRenderOLEData, which is a demo of its own.

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

procedure TFormVcl.CreateDrawTree;

// A draw tree holds no text at all. Everything the string tree got for free - the cell
// content, the width a hint or an autosize would need, what incremental search matches
// against - has to be answered by hand. That is the whole difference between the two
// classes, and it is these three lines long.

begin
  FDrawTree := TVirtualDrawTree.Create(Self);
  ConfigureTree(FDrawTree);

  FDrawTree.OnDrawNode := VTDrawNode;
  FDrawTree.OnGetNodeWidth := VTGetNodeWidth;
  FDrawTree.OnIncrementalSearch := VTIncrementalSearch;

  // Two more the string tree never needs. TCustomVirtualStringTree registers CF_UNICODETEXT and
  // CF_TEXT for itself and renders them from its own text; a draw tree has no text, so it has to
  // say what it can produce (OnGetUserClipboardFormats) and then produce it (OnRenderOLEData).
  // Without both, dragging a draw tree node to Notepad is refused with no message anywhere - the
  // tree simply offers nothing the target wants.
  TVSTCracker(FDrawTree).OnGetUserClipboardFormats := VTGetUserClipboardFormats;
  TVTVclCracker(FDrawTree as TVTAncestorVcl).OnRenderOLEData := VTRenderOLEData;

  FDrawTree.Visible := False;   // The string tree is shown first; the checkbox swaps them.
end;

procedure TFormVcl.CreateStringTree;
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

function TFormVcl.DrawTreeAsText(ATree: TBaseVirtualTree): string;

// The text a draw tree hands to the outside world, in one place so a drag and a copy cannot
// disagree about it. GetSortedCutCopySet first, because by the time OLE asks during a cut or
// copy the marking has already happened and the marked set is what the operation is about; the
// selection is the fallback for a drag, which marks nothing.

var
  LNodes: TNodeArray;
  LData: PNodeData;
  I: Integer;
begin
  Result := '';
  if not Assigned(ATree) then Exit;

  LNodes := TVSTCracker(ATree).GetSortedCutCopySet(True);
  if Length(LNodes) = 0 then begin
    LNodes := ATree.GetSortedSelection(True);
  end;

  for I := 0 to High(LNodes) do begin
    LData := ATree.GetNodeData(LNodes[I]);
    if Assigned(LData) then begin
      Result := Result + LData.Caption + sLineBreak;
    end;
  end;
end;

procedure TFormVcl.Edit_FilterChange(Sender: TObject);

// Both trees, so the filter still holds after the Draw tree checkbox swaps them. Each tree
// owns its own nodes, so each has to be walked.

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

procedure TFormVcl.FormCreate(Sender: TObject);
begin
  ResizeImageListImagesforHighDPI(ImageList_Tree);
  // Before anything is created, because every size below goes through AdjSize.
  GPPI := CurrentPPI;
  UseApplyColumnWidths := False;
  // Before the trees, because ConfigureTree reads it. Off by default: measuring every row is
  // what a tree does slowly, and the point of this demo is how fast it is without that.
  FUseMultiline := False;
  CheckBox_MultiLine.Checked := FUseMultiline;
  CreateStringTree;
  CreateDrawTree;
  CheckBox_DrawTree.Checked := False;   // The string tree is what starts on screen.
end;

procedure TFormVcl.FormResize(Sender: TObject);
begin
  ApplyColumnWidths(cColPercent);
end;

procedure TFormVcl.FormShow(Sender: TObject);

// The auto size in ConfigureTree runs before RootNodeCount makes the tree taller than its
// own view, so column 0 is sized against a client width that still has no vertical scroll
// bar in it - and column 1 ends up hanging over the right edge by exactly that much.
// Re-assigning the width here recomputes the auto column against the width the tree really
// has. Cheap, and it costs nothing when the percentage path is the one in use.

begin
  ApplyColumnWidths(cColPercent);
  if not UseApplyColumnWidths then begin
    FStringTree.Header.Columns[1].Width := AdjSize(100);
    FDrawTree.Header.Columns[1].Width := AdjSize(100);
  end;
end;

function TFormVcl.GetActiveTree: TBaseVirtualTree;
begin
  if Assigned(FDrawTree) and FDrawTree.Visible then begin
    Result := FDrawTree;
  end else begin
    Result := FStringTree;
  end;
end;

procedure TFormVcl.HideOddRootNodes(ATree: TBaseVirtualTree);
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

function TFormVcl.PasteAndSelect(ATree: TBaseVirtualTree): Integer;

// Pastes, then leaves whatever the paste produced selected, with the first of it focused -
// the state the FMX side ends up in, and the one that makes a paste visible.
//
// The VCL paste path reports nothing about what it inserted, so the tree is compared before
// and after. Two different things have to be recognised:
//
//   * a COPY, or a paste from another process, creates new nodes - they are not in the map
//   * a CUT inside this same tree MOVES the existing nodes, pointers and all - those are in
//     the map but under a different parent
//
// A pointer diff alone therefore finds nothing at all after a cut and paste, which is why
// the parent is recorded as well. Only nodes that are alive after the paste are looked at,
// so nothing here can touch a node the paste destroyed.
//
// A node pasted back under the parent it was already in is not detected, and the selection
// is then left as it was rather than cleared.
//
// GetFirstNoInit/GetNextNoInit walk the structure without initialising anything: only node
// identity and parentage matter here.
//
// Returns the number of nodes pasted, or -1 when the clipboard held nothing this tree could
// use.
//
// With toMultiSelect off the tree keeps a single selection, so only one of several pasted
// nodes stays selected - the focused one.

var
  LBefore: TDictionary<PVirtualNode, TNodePlace>;
  LPlace: TNodePlace;
  LNew: TNodeArray;
  LNode: PVirtualNode;
  LParent: PVirtualNode;
  LTarget: PVirtualNode;
  I: Integer;
begin
  Result := -1;
  if not Assigned(ATree) then Exit;

  LTarget := ATree.FocusedNode;
  LNew := nil;

  LBefore := TDictionary<PVirtualNode, TNodePlace>.Create;
  try
    LNode := ATree.GetFirstNoInit;
    while Assigned(LNode) do begin
      LPlace.Parent := LNode.Parent;
      LBefore.AddOrSetValue(LNode, LPlace);
      LNode := ATree.GetNextNoInit(LNode);
    end;

    if not ATree.PasteFromClipboard then Exit;

    LNode := ATree.GetFirstNoInit;
    while Assigned(LNode) do begin
      if not LBefore.TryGetValue(LNode, LPlace) or (LPlace.Parent <> LNode.Parent) then begin
        SetLength(LNew, Length(LNew) + 1);
        LNew[High(LNew)] := LNode;
      end;
      LNode := ATree.GetNextNoInit(LNode);
    end;
  finally
    LBefore.Free;
  end;

  Result := Length(LNew);
  if Result = 0 then Exit;

  // The target itself, plus the parent chain of anything that landed deeper - a node inside
  // a collapsed parent cannot be seen and cannot take the focus.
  ATree.BeginUpdate;
  try
    if Assigned(LTarget) then begin
      ATree.Expanded[LTarget] := True;
    end;
    for I := 0 to High(LNew) do begin
      LParent := LNew[I].Parent;
      while Assigned(LParent) and (LParent <> ATree.RootNode) do begin
        ATree.Expanded[LParent] := True;
        LParent := LParent.Parent;
      end;
    end;
  finally
    ATree.EndUpdate;
  end;

  // Outside the update block: the selection is what the user is meant to see when the tree
  // repaints, not part of the structural change above.
  ATree.ClearSelection;
  for I := 0 to High(LNew) do begin
    ATree.Selected[LNew[I]] := True;
  end;
  ATree.FocusedNode := LNew[0];
  ATree.ScrollIntoView(LNew[0], False);
end;

procedure TFormVcl.SetStatus(const AText: string);

// One place where the status line is written, so every call site above reads identically
// in the FMX demo and in this one. Add the same three lines to the FMX form and the only
// difference left between the two files is the body of this method.

begin
  Label_Status.Caption := AText;
end;

procedure TFormVcl.VTBeforeItemPaint(Sender: TBaseVirtualTree;
  Canvas: TCanvas; Node: PVirtualNode; Rect: TRect; var CustomDraw: Boolean);

// CustomDraw = True means the tree paints NOTHING for this row: no background, no tree
// lines, no toggle button, no check box, no images, no text. All of it is done below.
//
// The layout is asked for rather than guessed. GetOffsets is the same routine the painter
// and the hit test use, so a check box drawn at ofsCheckBox is exactly where a click will
// later be looked for. Offsets are relative to the CELL and this handler is handed the
// whole ITEM rect; the two coincide while the main column is leftmost and the tree is not
// scrolled horizontally, which holds here but is not a general truth.

var
  Data: PNodeData;
  LTree: TVSTCracker;
  LOffsets: TVTOffsets;
  LImageInfo: TVTImageInfo;
  LImageIndex: System.UITypes.TImageIndex;   // Vcl.ImgList exports a deprecated alias.
  LGhosted: Boolean;
  LKind: TVTImageKind;
  LRowHeight: Integer;
  LTop: Integer;
  LTextRect: TRect;
  LText: string;
begin
  CustomDraw := CheckBox_CustomDraw.Checked;
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
      Canvas.Brush.Color := TColors.Darkblue;
    end else begin
      Canvas.Brush.Color := clGray;
    end;
  end else begin
    if Sender.Focused then begin
      Canvas.Brush.Color := TColors.Beige;
    end else begin
      Canvas.Brush.Color := clWhite;
    end;
  end;
  // Rect is tree local here, so the tree's Left within its parent must not be added.
  // ClientWidth rather than Width: a vertical scroll bar is not part of the row.
  Rect.Right := Sender.ClientWidth;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(Rect);

  // Draw text
  if Sender.Selected[Node] then begin
    if Sender.Focused then begin
      Canvas.Font.Color := clWhite;
    end else begin
      Canvas.Font.Color := clBlack;
    end;
  end else begin
    Canvas.Font.Color := clWindowText;
  end;

  // --- toggle button ------------------------------------------------------
  // Same call the tree makes, so expanded/collapsed, hot and selected glyphs all match.
  // ButtonSize is a Single on both targets, but ButtonX/ButtonY are TDimension - Integer
  // here - so the halving has to be rounded rather than left as a float.
  if (toShowButtons in LTree.TreeOptions.PaintOptions) and (vsHasChildren in Node.States) then
    LTree.PaintNodeButton(Canvas, Node, Sender.Header.MainColumn, Rect,
      LOffsets[ofsToggleButton], Round((LRowHeight - Sender.ButtonSize) / 2), bdLeftToRight);

  // --- check box ----------------------------------------------------------
  // CheckImageSize and NodeImageSize are inside {$IFDEF VT_FMX} in BaseTree - they exist to
  // scale a 32px list into a finger sized box, which is not a problem here. The VCL check
  // list draws one entry at its own size, so that size is what the row centres on.
  if (toCheckSupport in LTree.TreeOptions.MiscOptions) and (Node.CheckType <> ctNone)
    and Assigned(Sender.CheckImages) then begin
    LImageInfo.Index := LTree.GetCheckImage(Node);
    if LImageInfo.Index > -1 then begin
      LImageInfo.Images := Sender.CheckImages;
      LImageInfo.Ghosted := False;
      LImageInfo.XPos := Rect.Left + LOffsets[ofsCheckBox];
      LImageInfo.YPos := Rect.Top + (LRowHeight - Sender.CheckImages.Height) div 2;
      LTree.PaintCheckImage(Canvas, LImageInfo, Sender.Selected[Node]);
    end;
  end;

  // --- node image ---------------------------------------------------------
  // The image list belongs to this form, so it is drawn directly rather than through the
  // tree's PaintImage - and the index comes from the same handler the tree would call, so
  // custom draw and normal draw can never disagree about which picture belongs to a node.
  //
  // Centred on the list's own Height, not on NodeImageSize: the VCL image list draws one
  // entry at its native size and does not scale it into a rect the way FMX does.
  if Assigned(ImageList_Tree) then begin
    LImageIndex := -1;
    LGhosted := False;
    if Sender.Selected[Node] then LKind := ikSelected else LKind := ikNormal;
    VTGetImageIndex(Sender, Node, LKind, Sender.Header.MainColumn, LGhosted, LImageIndex);
    if LImageIndex > -1 then begin
      LTop := Rect.Top + (LRowHeight - ImageList_Tree.Height) div 2;
      ImageList_Tree.Draw(Canvas, Rect.Left + LOffsets[ofsImage], LTop, LImageIndex, True);
    end;
  end;

  Data := Node.GetData;
  if not Assigned(Data) then Exit;

  // Every attribute we care about is set explicitly on each call, so no save/restore of the
  // canvas state is needed. bsClear is the one that matters: TextRect fills the rect with
  // the brush first, and the row background has already been painted above.
  Canvas.Font.Size := cCustomDrawFontSize;   // Points are already dpi relative - see the const.
  Canvas.Brush.Style := bsClear;
  // Text starts where the tree would start it - past the button, the box and the image.
  LTextRect := Rect;
  LTextRect.Left := LTextRect.Left + LOffsets[ofsText];
  // A local, because TCanvas.TextRect takes "var Text: string" - it rewrites the string
  // when tfModifyString is used, and passing Data.Caption would hand it the node's own
  // storage. Format's result could not be passed at all.
  LText := Data.Caption;
  Canvas.TextRect(LTextRect, LText,
    [tfLeft, tfVerticalCenter, tfSingleLine, tfEndEllipsis]);
  Canvas.Brush.Style := bsSolid;
end;

procedure TFormVcl.VTChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);

// Fires after CheckState has already changed. With toAutoTristateTracking on, a click on
// a child also lands here once for every parent the tree re-evaluates, so this is a place
// to read state - never to write it back, or the recursion is yours to own.
//
// One line per node is what a handler must not do here. Checking a parent of 3000 children
// fires this 3000 times, and 3000 status writes are 3000 repaints of the form. The first
// node reports itself and the rest are counted, with the total written once by
// VTStateChange when the propagation has finished.

begin
  if not Assigned(Node) then Exit;

  System.Inc(FCheckedCount);
  if FCheckedCount > 1 then Exit;

  SetStatus(Format('Checked: Level %d, Index %d -> %s',
    [Sender.GetNodeLevel(Node), Node.Index, CheckStateToStr(Sender.CheckState[Node])]));
end;

procedure TFormVcl.VTChecking(Sender: TBaseVirtualTree; Node: PVirtualNode;
  var NewState: TCheckState; var Allowed: Boolean);

// The veto hook - Allowed := False discards the click. Permissive here on purpose: it
// exists so a click can be proved to reach the tree even while nothing repaints yet.

begin
  Allowed := True;
end;

procedure TFormVcl.VTColumnResize(Sender: TVTHeader; Column: TColumnIndex);
begin
  // The user has taken over - stop forcing the percentages on every form resize.
  FUserResizedColumns := True;
end;

procedure TFormVcl.VTCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode;
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

procedure TFormVcl.VTDragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  var Allowed: Boolean);

// The veto hook for DragMode = dmManual, and the reason VTDragOver was never reached before:
// TBaseVirtualTree.DoBeforeDrag has no default of its own, it returns False when this event is
// unassigned. Permissive here on purpose - this demo wants every node draggable, unconditionally.
//
// Identical to the FMX demo's handler of the same name. Note it is consulted for dmManual ONLY;
// with dmAutomatic the tree decides by itself and never calls this at all.

begin
  Allowed := True;
end;

procedure TFormVcl.VTDragDrop(Sender: TBaseVirtualTree; Source: TObject; DataObject: TVTDragDataObject;
  Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);

// Three payloads arrive here, and which one it is depends on DragType and on who started the drag.
//
//   1. dtOLE, and the data object carries CF_VIRTUALTREE - a drag from a Virtual Treeview, this
//      one or one in another running copy of this program. Sender.ProcessDrop does the work.
//   2. dtOLE, and it carries something else - files from Explorer, text from an editor.
//   3. dtVCL - no data object at all, just the source tree. The original hand-written move.
//
// ProcessDrop is worth understanding, because it is where the CFSTR_VTREFERENCE format earns its
// keep. If GetTreeFromDataObject recognises the payload as coming from a tree in THIS process it
// does an optimized move - the real nodes are moved, keeping their identity, their children and
// their expanded state - and then sets Effect to DROPEFFECT_NONE so that the source's DoDragging
// does not ALSO delete them under toAutoDeleteMovedNodes. From another process there is no
// pointer to move, so the nodes are rebuilt from the serialized CF_VIRTUALTREE stream and Effect
// stays MOVE, which is what tells the sending copy to delete its originals. Both cases work; only
// the first keeps anything OnSaveNode does not write.

var
  LSourceTree: TBaseVirtualTree;
  LNodes: TNodeArray;
  LTargetNode: PVirtualNode;
  LAttachMode: TVTNodeAttachMode;
  LFiles: TArray<string>;
  LText: string;
  LLines: TArray<string>;
  LSortNote: string;
  LCopy: Boolean;
  I: Integer;

  // One place where "move or copy" is decided, so the two loop directions below stay readable.
  procedure MoveOrCopy(ATree: TBaseVirtualTree; ANode, ATarget: PVirtualNode;
    AAttachMode: TVTNodeAttachMode; ADoCopy: Boolean);
  begin
    if ADoCopy then
      ATree.CopyTo(ANode, ATarget, AAttachMode, False)
    else
      ATree.MoveTo(ANode, ATarget, AAttachMode, False);
  end;

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
  // sorts, because hoHeaderClickAutoSort is a separate option and stays. Called before the moves,
  // since ProcessDrop and the loops below run inside their own BeginUpdate/EndUpdate.
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

  // Dropping ONTO a collapsed node would otherwise look like the nodes vanished. Every drop path
  // needs this, including the dtOLE one that returns as soon as ProcessDrop has done the work.
  procedure ExpandTarget(ATree: TBaseVirtualTree; ANode: PVirtualNode; AAttachMode: TVTNodeAttachMode);
  begin
    if Assigned(ANode) and (AAttachMode in [amAddChildFirst, amAddChildLast]) then
      ATree.Expanded[ANode] := True;
  end;

begin
  LTargetNode := Sender.DropTargetNode;

  case Mode of
    dmAbove: LAttachMode := amInsertBefore;
    dmBelow: LAttachMode := amInsertAfter;
  else
    LAttachMode := amAddChildFirst;   // dmOnNode, or dmNowhere - dropped on empty space, goes to the root.
  end;

  LSortNote := '';

  // --- 1 and 2: dtOLE. A data object means the drag came through the OLE subsystem. -------------
  if Assigned(DataObject) then begin

    // Before ProcessDrop, which does its own BeginUpdate/EndUpdate around the move.
    LSortNote := ReleaseAutoSort(Sender);

    // ProcessDrop returns False when the payload has no CF_VIRTUALTREE in it, which is a cleaner
    // test than hunting the format id through Formats - and it leaves Effect alone when it fails.
    if Sender.ProcessDrop(DataObject, LTargetNode, Effect, LAttachMode) then begin
      ExpandTarget(Sender, LTargetNode, LAttachMode);
      if Source is TBaseVirtualTree then begin
        SetStatus(Format('OLE: moved nodes %s target node (optimized, same process).%s',
          [DropModeToStr(Mode), LSortNote]));
      end else begin
        SetStatus(Format('OLE: rebuilt nodes %s target node (from another process).%s',
          [DropModeToStr(Mode), LSortNote]));
      end;
      Exit;
    end;

    // Foreign payload. COPY and never MOVE: answering MOVE to a CF_HDROP drag tells Explorer
    // the files have been taken over and it DELETES the originals. Worth being deliberate about.
    Effect := DROPEFFECT_COPY;

    if TryGetOLEFiles(DataObject, LFiles) then begin
      for I := 0 to High(LFiles) do
        LFiles[I] := ExtractFileName(LFiles[I]);
      AddNodesFromStrings(Sender, LTargetNode, LAttachMode, LFiles);
      ExpandTarget(Sender, LTargetNode, LAttachMode);
      SetStatus(Format('OLE: %d file name(s) dropped %s target node.%s',
        [Length(LFiles), DropModeToStr(Mode), LSortNote]));
      Exit;
    end;

    if TryGetOLEText(DataObject, LText) then begin
      LLines := LText.Split([sLineBreak, #10], TStringSplitOptions.ExcludeEmpty);
      AddNodesFromStrings(Sender, LTargetNode, LAttachMode, LLines);
      ExpandTarget(Sender, LTargetNode, LAttachMode);
      SetStatus(Format('OLE: %d line(s) of text dropped %s target node.%s',
        [Length(LLines), DropModeToStr(Mode), LSortNote]));
      Exit;
    end;

    Effect := DROPEFFECT_NONE;
    SetStatus('OLE: nothing here I know how to read - ' + FormatsToStr(Formats));
    Exit;
  end;

  // --- 3: dtVCL / dtFMX. No data object; Source is the tree itself. -----------------------------
  //
  // Ctrl means copy, exactly as it does under dtOLE - the difference was never that the shift
  // state was missing, only that this handler ignored it. On the VCL, TBaseVirtualTree.CMDrag
  // has always built Shift from GetKeyState(VK_SHIFT/VK_CONTROL) before calling DoDragOver and
  // DoDragDrop; under dtOLE it looks automatic only because SuggestDropEffect turns the same
  // Shift into an Effect and ProcessDrop then acts on that. Here there is no Effect to act on,
  // so the choice is ours to make.
  //
  // CopyTo, not MoveTo: it returns the new node and leaves the original where it was. It
  // serializes through OnSaveNode/OnLoadNode, which this demo implements - without them a
  // copied node would arrive with an empty caption.
  if not (Source is TBaseVirtualTree) then Exit;
  LSourceTree := TBaseVirtualTree(Source);
  LCopy := ssCtrl in Shift;

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

  LSortNote := ReleaseAutoSort(Sender);

  LSourceTree.BeginUpdate;
  try
    if LAttachMode = amInsertBefore then begin
      for I := 0 to High(LNodes) do
        MoveOrCopy(LSourceTree, LNodes[I], LTargetNode, LAttachMode, LCopy);
    end else begin
      for I := High(LNodes) downto 0 do
        MoveOrCopy(LSourceTree, LNodes[I], LTargetNode, LAttachMode, LCopy);
    end;
  finally
    LSourceTree.EndUpdate;
  end;

  ExpandTarget(Sender, LTargetNode, LAttachMode);

  SetStatus(Format('%s %d node(s) %s target node.%s',
    [VERB_COPIED[LCopy], Length(LNodes), DropModeToStr(Mode), LSortNote]));
end;

procedure TFormVcl.VTDragOver(Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState;
  State: TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer; var Accept: Boolean);

// Whether Sender will accept a drop at the current position.
//
// Source is NOT always a tree once dtOLE is in play. It is TVTDragManager.FDragSource, which is
// whatever GetTreeFromDataObject made of the payload: the real tree for a drag inside this
// process, and nil for everything else - Explorer, an editor, or another running copy of this
// same program. A foreign drag therefore has to be accepted on faith here, because this event is
// handed no data object to inspect; the real format test happens in VTDragDrop.
//
// Effect is left exactly as TBaseVirtualTree.SuggestDropEffect computed it, which is what makes
// SHIFT mean MOVE when the nodes come from a second running copy of this program: the receiving
// copy rebuilds them from CF_VIRTUALTREE, answers MOVE, and the SENDING copy then deletes its
// originals under toAutoDeleteMovedNodes. Forcing COPY here broke that, and it was never what
// protected Explorer either - VTDragDrop sets Effect to DROPEFFECT_COPY itself before it touches
// a file payload, which is the assignment that matters, because it is the one the drop returns.
//
// For a drag that IS from a tree in this process, the refusals are the old ones: no dragged
// nodes, the target IS one of them, or - same tree only - the target is a descendant of one of
// them, which MoveTo would answer with SWrongMoveError.

var
  LSourceTree: TBaseVirtualTree;
  LNodes: TNodeArray;
  LTargetNode: PVirtualNode;
  I: Integer;
begin
  Accept := False;

  if not (Source is TBaseVirtualTree) then begin
    // Foreign, or from another process. Both are legitimate under dtOLE.
    Accept := True;
    Exit;
  end;

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

procedure TFormVcl.VTDrawNode(Sender: TBaseVirtualTree; const PaintInfo: TVTPaintInfo);

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
  LTextRect: TRect;
  LText: string;
  LLevel: Integer;
begin
  Data := Sender.GetNodeData(PaintInfo.Node);
  if not Assigned(Data) then Exit;

  R := PaintInfo.ContentRect;
  R.Left := R.Left + TVSTCracker(Sender).TextMargin;   // TextMargin is protected.
  R.Right := R.Right - TVSTCracker(Sender).TextMargin;

  PaintInfo.Canvas.Font.Size := cCustomDrawFontSize;
  if Sender.Selected[PaintInfo.Node] and Sender.Focused then begin
    PaintInfo.Canvas.Font.Color := clWhite;
  end else begin
    PaintInfo.Canvas.Font.Color := clWindowText;
  end;

  case PaintInfo.Column of
    0: begin
      LLevel := Sender.GetNodeLevel(PaintInfo.Node);

      // A depth bar along the bottom of the cell - three pixels high, one step wider per
      // level. Nothing a string tree could express through OnGetText.
      LBar := R;
      LBar.Top := LBar.Bottom - AdjSize(3);
      LBar.Right := LBar.Left + AdjSize(12) * (LLevel + 1);
      if LBar.Right > R.Right then LBar.Right := R.Right;
      PaintInfo.Canvas.Brush.Color := TColors.Steelblue;
      PaintInfo.Canvas.Brush.Style := bsSolid;
      PaintInfo.Canvas.FillRect(LBar);

      PaintInfo.Canvas.Brush.Style := bsClear;
      LTextRect := R;
      LText := Data.Caption;   // TextRect takes "var Text: string" - see VTBeforeItemPaint.
      PaintInfo.Canvas.TextRect(LTextRect, LText,
        [tfLeft, tfVerticalCenter, tfSingleLine, tfEndEllipsis]);
    end;
    1: begin
      PaintInfo.Canvas.Brush.Style := bsClear;
      LTextRect := R;
      LText := Format('%d children', [PaintInfo.Node.ChildCount]);
      PaintInfo.Canvas.TextRect(LTextRect, LText,
        [tfLeft, tfVerticalCenter, tfSingleLine]);
    end;
  end;
  PaintInfo.Canvas.Brush.Style := bsSolid;
end;

procedure TFormVcl.VTFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
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

procedure TFormVcl.VTGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: System.UITypes.TImageIndex);
begin
  // This event is asked for FOUR different kinds. Answering them all with the same index
  // is why two images appeared side by side: ikState painted one in the state slot and
  // ikNormal another next to it, with ikOverlay landing a third on top of that. Only the
  // normal/selected pair is wanted here.
  if (Column = 0) and (Kind in [ikNormal, ikSelected]) then begin
    ImageIndex := Node.Index mod 3;
  end;
end;

procedure TFormVcl.VTGetNodeWidth(Sender: TBaseVirtualTree; HintCanvas: TCanvas;
  Node: PVirtualNode; Column: TColumnIndex; var NodeWidth: TDimension);

// The string tree measures its own text; a draw tree cannot, because only the application
// knows what it drew. Anything that asks how wide a node is - autosize, hints, horizontal
// scroll extent - gets 2 * TextMargin and nothing else without this.
//
// TextExtent is what the FMX demo reaches through the port's GetTextExtentPoint32W shim,
// and what TCustomVirtualStringTree.DoTextMeasuring ends up in here - so the draw tree
// measures text exactly the way the string tree does rather than by a second route.

var
  Data: PNodeData;
  LSize: TSize;
begin
  Data := Sender.GetNodeData(Node);
  if not Assigned(Data) then Exit;
  if Column <> 0 then Exit;

  HintCanvas.Font.Size := cCustomDrawFontSize;
  LSize := HintCanvas.TextExtent(Data.Caption);
  NodeWidth := LSize.cx + 2 * TVSTCracker(Sender).TextMargin;
end;

procedure TFormVcl.VTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
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

procedure TFormVcl.VTGetUserClipboardFormats(Sender: TBaseVirtualTree; var Formats: TFormatEtcArray);

// Appends to what the tree already enumerated - never assigns over it, or the native tree format
// that a drop back into a tree needs would be thrown away.
//
// Position in the array is priority, best first, so CF_UNICODETEXT leads. Windows would
// synthesize one of the pair from the other, but a target that asks for exactly what it wants
// then gets a straight answer, and both arrive at VTRenderOLEData below.

var
  I: Integer;
begin
  I := Length(Formats);
  SetLength(Formats, I + 2);

  Formats[I].cfFormat := CF_UNICODETEXT;
  Formats[I].ptd      := nil;
  Formats[I].dwAspect := DVASPECT_CONTENT;
  Formats[I].lindex   := -1;
  Formats[I].tymed    := TYMED_HGLOBAL;

  Formats[I + 1] := Formats[I];
  Formats[I + 1].cfFormat := CF_TEXT;
end;

procedure TFormVcl.VTHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
var
  S: string;
  ColumnText: string;
begin
  if HitInfo.Column > NoColumn then begin
    ColumnText := Sender.Columns[HitInfo.Column].Text;
  end else begin
    ColumnText := '<none>';
  end;

  // Y is header local (0..Header.Height) in both VCL and FMX - see HandleClick. The format
  // specifiers are %d and not the FMX demo's %.0f because TDimension is Integer here, and
  // Format would raise on a float specifier given an integer argument.
  S := Format('HeaderClick: Col=%d (%s)  Btn=%s  X=%d  Y=%d of %d  Pos=[%s]  Shift=[%s]',
    [HitInfo.Column, ColumnText,
     MouseButtonToStr(HitInfo.Button),
     HitInfo.X, HitInfo.Y, Sender.Height,
     HitPositionToStr(HitInfo.HitPosition),
     ShiftStateToStr(HitInfo.Shift)]);

  // The other half of the Android sort diagnostic: both TVTHeader.DoSetSortColumn and
  // SetSortDirection invalidate the glyph BEFORE testing (Tree.UpdateCount = 0), and only
  // call SortTree when that test passes. This is the reference reading - whatever Windows
  // prints here is what Android is being compared against.
  S := S + Format('  UpdateCount=%d  SortCol=%d  SortDir=%d',
    [ActiveTree.UpdateCount, Sender.SortColumn, Ord(Sender.SortDirection)]);

  SetStatus(S);
end;

procedure TFormVcl.VTIncrementalSearch(Sender: TBaseVirtualTree; Node: PVirtualNode;
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

procedure TFormVcl.VTInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
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
  //
  // Only for a node that does not already have one. AddNodesFromStrings creates nodes with
  // InsertNode, which leaves them uninitialized, so this event fires the first time such a node
  // is painted - AFTER its caption was set. Without the test, every file name dropped from
  // Explorer turned into "Level 0, Index n" the moment it scrolled into view.
  if Data.Caption = '' then begin
    Data.Caption := Format('Level %d, Index %d', [Sender.GetNodeLevel(Node), Node.Index]);
    // Every fourth node gets a caption that cannot fit on one line - only when the tree is
    // going to wrap it. Inside the same test as the caption itself: a name dropped from
    // Explorer is the user's text, not ours to extend.
    if FUseMultiline and ((Node.Index mod 4) = 0) then begin
      Data.Caption := Data.Caption + cLongCaptionTail;
    end;
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

procedure TFormVcl.VTKeyAction(Sender: TBaseVirtualTree; var CharCode: Word;
  var Shift: TShiftState; var DoDefault: Boolean);

// Ctrl+X, Ctrl+C and Ctrl+V. The three methods called here are the library's own, on the
// VCL ancestor; this handler exists to own the keys, report what happened and open the
// paste target.
//
// DoDefault := False stops the tree acting on the same key afterwards, so each keystroke
// does its work exactly once whatever the library's own key handling does with it.
//
// Paste goes through PasteAndSelect, which opens the target and hands the selection to the
// nodes that arrived - see there.

var
  LPasted: Integer;
begin
  if not (ssCtrl in Shift) then Exit;

  case CharCode of
    Ord('C'): begin
      DoDefault := False;
      Sender.CopyToClipboard;
      SetStatus(Format('Copied %d node(s) to the clipboard.',
        [Length(Sender.GetSortedSelection(True))]));
    end;

    Ord('X'): begin
      DoDefault := False;
      Sender.CutToClipboard;
      SetStatus(Format('Cut %d node(s) - they are removed when the data is pasted.',
        [Length(Sender.GetSortedSelection(True))]));
    end;

    Ord('V'): begin
      DoDefault := False;
      LPasted := PasteAndSelect(Sender);
      if LPasted < 0 then begin
        SetStatus('Nothing on the clipboard this tree can paste.');
      end else if LPasted = 0 then begin
        SetStatus('Pasted, but nothing moved to a new parent - selection left alone.');
      end else begin
        SetStatus(Format('Pasted %d node(s) - now selected.', [LPasted]));
      end;
    end;
  end;
end;

procedure TFormVcl.VTLoadNode(Sender: TBaseVirtualTree; Node: PVirtualNode; Stream: TStream);

// The other half of VTSaveNode. Node is nil when the tree is loading its own user data
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

procedure TFormVcl.VTMeasureItem(Sender: TBaseVirtualTree; TargetCanvas: TCanvas;
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
// not optional - without it the row is measured in one font and painted in another.

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

procedure TFormVcl.VTNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
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

procedure TFormVcl.VTNodeDblClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);

// The FMX demo wires the edit trigger by hand because the edit delay timer that
// toEditOnDblClick depends on is inside {$IFDEF VT_VCL}. Here that timer works, so
// toEditOnDblClick in MiscOptions would do the same job - this stays as it is so both
// demos take the same route, and so the draw tree gets an explanation rather than
// silence when it is double clicked.
//
// Queued rather than called inline: this fires from inside the mouse handling, which then
// carries on. Creating and focusing an editor midway through that is asking for trouble.

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

procedure TFormVcl.VTRenderOLEData(Sender: TBaseVirtualTree; const FormatEtcIn: TFormatEtc;
  out Medium: TStgMedium; ForClipboard: Boolean; var Result: HRESULT);

// The other half of VTGetUserClipboardFormats. Announcing a format and then failing to render it
// is worse than not announcing it at all: the target accepts the drop and receives nothing.
//
// Ownership of the HGLOBAL passes to the caller together with S_OK, so it must not be freed here.
// On any failure path Medium is left zeroed and Result is an error - never a half filled medium.

var
  LText: string;
  LAnsi: AnsiString;
  LBytes: Integer;
  LPtr: Pointer;
begin
  Result := E_FAIL;
  FillChar(Medium, SizeOf(Medium), 0);

  if (FormatEtcIn.cfFormat <> CF_UNICODETEXT) and (FormatEtcIn.cfFormat <> CF_TEXT) then Exit;
  if (FormatEtcIn.tymed and TYMED_HGLOBAL) = 0 then Exit;

  LText := DrawTreeAsText(Sender);
  if LText = '' then Exit;

  if FormatEtcIn.cfFormat = CF_UNICODETEXT then begin
    LBytes := (Length(LText) + 1) * SizeOf(Char);   // including the terminator
    Medium.hGlobal := GlobalAlloc(GMEM_MOVEABLE or GMEM_ZEROINIT, LBytes);
    if Medium.hGlobal = 0 then begin
      Result := E_OUTOFMEMORY;
      Exit;
    end;
    LPtr := GlobalLock(Medium.hGlobal);
    try
      Move(PChar(LText)^, LPtr^, LBytes);
    finally
      GlobalUnlock(Medium.hGlobal);
    end;
  end else begin
    LAnsi := AnsiString(LText);
    LBytes := Length(LAnsi) + 1;
    Medium.hGlobal := GlobalAlloc(GMEM_MOVEABLE or GMEM_ZEROINIT, LBytes);
    if Medium.hGlobal = 0 then begin
      Result := E_OUTOFMEMORY;
      Exit;
    end;
    LPtr := GlobalLock(Medium.hGlobal);
    try
      Move(PAnsiChar(LAnsi)^, LPtr^, LBytes);
    finally
      GlobalUnlock(Medium.hGlobal);
    end;
  end;

  Medium.tymed := TYMED_HGLOBAL;
  Medium.unkForRelease := nil;
  Result := S_OK;
end;

procedure TFormVcl.VTSaveNode(Sender: TBaseVirtualTree; Node: PVirtualNode; Stream: TStream);

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

procedure TFormVcl.VTStateChange(Sender: TBaseVirtualTree; Enter, Leave: TVirtualTreeStates);

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
