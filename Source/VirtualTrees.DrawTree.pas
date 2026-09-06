unit VirtualTrees.DrawTree;

interface
{$IFDEF FRAMEWORK_FMX}
  {$DEFINE VT_FMX}
{$ELSE}
  {$DEFINE VT_VCL}
{$ENDIF}

{$IFDEF VT_FMX}
uses
    System.Types
  , System.Classes
  , VirtualTrees.Types
  , VirtualTrees
  , VirtualTrees.BaseTree
  , VirtualTrees.FMX
  , FMX.Controls   // TControl.GetCanvas is inlined; without this the two Canvas
                   // references below cost an H2443 each.
  ;
{$ELSE}
uses
    System.Types
  , System.Classes
  , VirtualTrees.Types
  , VirtualTrees
  , VirtualTrees.BaseTree;
{$ENDIF}

type
  // Tree descendant to let an application draw its stuff itself.
  TCustomVirtualDrawTree = class(TVTAncestor)
  private
    FOnDrawNode: TVTDrawNodeEvent;
    FOnGetCellContentMargin: TVTGetCellContentMarginEvent;
    FOnGetNodeWidth: TVTGetNodeWidthEvent;
  protected
    function DoGetCellContentMargin(Node: PVirtualNode; Column: TColumnIndex;
      CellContentMarginType: TVTCellContentMarginType = ccmtAllSides; Canvas: TCanvas = nil): TPoint; override;
    function DoGetNodeWidth(Node: PVirtualNode; Column: TColumnIndex; Canvas: TCanvas = nil): TDimension; override;
    procedure DoPaintNode(var PaintInfo: TVTPaintInfo); override;
    /// <summary>
    /// A draw tree holds no text of its own, so the one method TBaseVirtualTree leaves
    /// abstract for TCustomVirtualStringTree to answer is answered here with nothing.
    /// It is what makes the class concrete - without it every Create is a W1020.
    /// </summary>
    procedure DoPaintText(Node: PVirtualNode; const Canvas: TCanvas; Column: TColumnIndex;
      TextType: TVSTTextType); override;
    function GetDefaultHintKind: TVTHintKind; override;

    property OnDrawNode: TVTDrawNodeEvent read FOnDrawNode write FOnDrawNode;
    property OnGetCellContentMargin: TVTGetCellContentMarginEvent read FOnGetCellContentMargin write FOnGetCellContentMargin;
    property OnGetNodeWidth: TVTGetNodeWidthEvent read FOnGetNodeWidth write FOnGetNodeWidth;
  end;

{$IFDEF VT_FMX}
  // Nothing in this class is Windows-only, so it is offered on every platform the rest
  // of the FMX tree supports.
  [ComponentPlatformsAttribute(pidAllPlatforms)]
{$ELSE}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
{$ENDIF}
  TVirtualDrawTree = class(TCustomVirtualDrawTree)
  private
    function GetOptions: TVirtualTreeOptions;
    procedure SetOptions(const Value: TVirtualTreeOptions);
  protected
    function GetOptionsClass: TTreeOptionsClass; override;
  public
    property Canvas;
{$IFDEF VT_VCL}
    property LastDragEffect;
{$ENDIF}
    // Public, not published: streaming this property back in overrides the check images
    // the tree picks for the current theme.
    property CheckImageKind;
  published
    property Action;
    property Align;
    property Alignment;
    property Anchors;
    property AnimationDuration;
    property AutoExpandDelay;
    property AutoScrollDelay;
    property AutoScrollInterval;
    property Background;
    property BackgroundOffsetX;
    property BackgroundOffsetY;
    property BiDiMode;
    property BevelEdges;
    property BevelInner;
    property BevelOuter;
    property BevelKind;
    property BevelWidth;
    property BorderStyle;
    property BottomSpace;
    property ButtonFillMode;
    property ButtonStyle;
    property BorderWidth;
    property ChangeDelay;
    property ClipboardFormats;
{$IFDEF VT_VCL}
    property Color;
{$ENDIF}
    property Colors;
{$IFDEF VT_VCL}
    property Constraints;
    property Ctl3D;
{$ENDIF}
    property CustomCheckImages;
    property DefaultNodeHeight;
    property DefaultPasteMode;
{$IFDEF VT_VCL}
    property DragCursor;
{$ENDIF}
    property DragHeight;
{$IFDEF VT_VCL}
    property DragKind;
{$ENDIF}
    property DragImageKind;
    property DragMode;
    property DragOperations;
    property DragType;
    property DragWidth;
    property DrawSelectionMode;
    property EditDelay;
    property Enabled;
    property Font;
    property Header;
    property HintMode;
    property HotCursor;
    property Images;
    property IncrementalSearch;
    property IncrementalSearchDirection;
    property IncrementalSearchStart;
    property IncrementalSearchTimeout;
    property Indent;
    property LineMode;
    property LineStyle;
    property Margin;
    property NodeAlignment;
    property NodeDataSize;
    property OperationCanceled;
{$IFDEF VT_VCL}
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentCtl3D;
    property ParentFont;
{$ENDIF}
    property ParentShowHint;
{$IFDEF VT_FMX}
    property Popup;
    property PopupDelay;
{$ENDIF}
    property PopupMenu;
{$IFDEF VT_FMX}
    property PopupTrigger;
{$ENDIF}
    property RootNodeCount;
    property ScrollBarOptions;
    property SelectionBlendFactor;
    property SelectionCurveRadius;
    property ShowHint;
    property StateImages;
    property TabOrder;
    property TabStop default True;
    property TextMargin;
    property TreeOptions: TVirtualTreeOptions read GetOptions write SetOptions;
    property Visible;
    property WantTabs;

    property OnAddToSelection;
    property OnAdvancedHeaderDraw;
    property OnAfterAutoFitColumn;
    property OnAfterAutoFitColumns;
    property OnAfterCellPaint;
    property OnAfterColumnExport;
    property OnAfterColumnWidthTracking;
    property OnAfterGetMaxColumnWidth;
    property OnAfterHeaderExport;
    property OnAfterHeaderHeightTracking;
    property OnAfterItemErase;
    property OnAfterItemPaint;
    property OnAfterNodeExport;
    property OnAfterPaint;
    property OnAfterTreeExport;
    property OnBeforeAutoFitColumn;
    property OnBeforeAutoFitColumns;
    property OnBeforeCellPaint;
    property OnBeforeColumnExport;
    property OnBeforeColumnWidthTracking;
    property OnBeforeDrawTreeLine;
    property OnBeforeGetMaxColumnWidth;
    property OnBeforeHeaderExport;
    property OnBeforeHeaderHeightTracking;
    property OnBeforeItemErase;
    property OnBeforeItemPaint;
    property OnBeforeNodeExport;
    property OnBeforePaint;
    property OnBeforeTreeExport;
    property OnCanSplitterResizeColumn;
    property OnCanSplitterResizeHeader;
    property OnCanSplitterResizeNode;
    property OnChange;
    property OnChecked;
    property OnChecking;
    property OnClick;
    property OnCollapsed;
    property OnCollapsing;
    property OnColumnChecked;
    property OnColumnChecking;
    property OnColumnClick;
    property OnColumnDblClick;
    property OnColumnExport;
    property OnColumnResize;
    property OnColumnVisibilityChanged;
    property OnColumnWidthDblClickResize;
    property OnColumnWidthTracking;
    property OnCompareNodes;
{$IFDEF VT_FMX}
    property OnContextMenu;
{$ENDIF}
{$IFDEF VT_VCL}
    property OnContextPopup;
{$ENDIF}
    property OnCreateDataObject;
{$IFDEF VT_VCL}
    property OnCreateDragManager;
{$ENDIF}
    property OnCreateEditor;
    property OnDblClick;
    property OnDragAllowed;
    property OnDragOver;
    property OnDragDrop;
    property OnDrawHint;
    property OnDrawNode;
    property OnEdited;
    property OnEditing;
{$IFDEF VT_VCL}
    property OnEndDock;
    property OnEndDrag;
{$ENDIF}
    property OnEndOperation;
    property OnEnter;
    property OnExit;
    property OnExpanded;
    property OnExpanding;
    property OnFocusChanged;
    property OnFocusChanging;
    property OnFreeNode;
    property OnGetCellIsEmpty;
    property OnGetCursor;
    property OnGetHeaderCursor;
    property OnGetHelpContext;
    property OnGetHintKind;
    property OnGetHintSize;
    property OnGetImageIndex;
    property OnGetImageIndexEx;
    property OnGetLineStyle;
    property OnGetNodeDataSize;
    property OnGetNodeWidth;
    property OnGetPopupMenu;
{$IFDEF VT_VCL}
    property OnGetUserClipboardFormats;
{$ENDIF}
    property OnHeaderAddPopupItem;
    property OnHeaderClick;
    property OnHeaderDblClick;
    property OnHeaderDragged;
    property OnHeaderDraggedOut;
    property OnHeaderDragging;
    property OnHeaderDraw;
    property OnHeaderDrawQueryElements;
    property OnHeaderHeightTracking;
    property OnHeaderHeightDblClickResize;
    property OnHeaderMouseDown;
    property OnHeaderMouseMove;
    property OnHeaderMouseUp;
    property OnHotChange;
    property OnIncrementalSearch;
    property OnInitChildren;
    property OnInitNode;
    property OnKeyAction;
    property OnKeyDown;
{$IFDEF VT_VCL}
    property OnKeyPress;
{$ENDIF}
    property OnKeyUp;
    property OnLoadNode;
    property OnLoadTree;
    property OnMeasureItem;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnNodeClick;
    property OnNodeCopied;
    property OnNodeCopying;
    property OnNodeDblClick;
    property OnNodeExport;
    property OnNodeHeightTracking;
    property OnNodeHeightDblClickResize;
    property OnNodeMoved;
    property OnNodeMoving;
    property OnPaintBackground;
    property OnPrepareButtonBitmaps;
    property OnRemoveFromSelection;
{$IFDEF VT_VCL}
    property OnRenderOLEData;
{$ENDIF}
    property OnResetNode;
    property OnResize;
    property OnSaveNode;
    property OnSaveTree;
    property OnScroll;
    property OnShowScrollBar;
{$IFDEF VT_VCL}
    property OnStartDock;
    property OnStartDrag;
{$ENDIF}
    property OnStartOperation;
    property OnStateChange;
    property OnStructureChange;
    property OnUpdating;
{$IFDEF VT_VCL}
    property OnCanResize;
{$ENDIF}
    property OnGesture;
    property Touch;
{$IFDEF VT_VCL}
    property StyleElements;
{$ENDIF}
  end;

implementation

uses
{$IFDEF VT_FMX}
  // Guarded. Implementation uses are searched BEFORE interface uses, so an unconditional
  // FMX.Graphics here hides the TCanvas alias that VirtualTrees.BaseTree resolves to
  // Vcl.Graphics.TCanvas, and every method below takes the wrong Canvas type.
  FMX.Graphics,
{$ELSE}
  // TCustomStyleEngine for the style hook registration at the bottom of this unit.
  Vcl.Themes,
{$ENDIF}
  VirtualTrees.StyleHooks;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualDrawTree.DoGetCellContentMargin(Node: PVirtualNode; Column: TColumnIndex;
  CellContentMarginType: TVTCellContentMarginType = ccmtAllSides; Canvas: TCanvas = nil): TPoint;

begin
  Result := Point(0, 0);
  if Canvas = nil then
    Canvas := Self.Canvas;

  if Assigned(FOnGetCellContentMargin) then
    FOnGetCellContentMargin(Self, Canvas, Node, Column, CellContentMarginType, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualDrawTree.DoGetNodeWidth(Node: PVirtualNode; Column: TColumnIndex; Canvas: TCanvas = nil): TDimension;

begin
  Result := 2 * TextMargin;
  if Canvas = nil then
    Canvas := Self.Canvas;

  if Assigned(FOnGetNodeWidth) then
    FOnGetNodeWidth(Self, Canvas, Node, Column, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualDrawTree.DoPaintNode(var PaintInfo: TVTPaintInfo);

begin
  if Assigned(FOnDrawNode) then
    FOnDrawNode(Self, PaintInfo);
end;

procedure TCustomVirtualDrawTree.DoPaintText(Node: PVirtualNode; const Canvas: TCanvas;
  Column: TColumnIndex; TextType: TVSTTextType);

// Deliberately empty. Nothing in the painter reaches this for a draw tree - only
// TCustomVirtualStringTree.PaintNormalText and PaintStaticText call it - so the body has
// no work to do. It exists to make the class concrete.

begin
end;

function TCustomVirtualDrawTree.GetDefaultHintKind: TVTHintKind;

begin
  Result := vhkOwnerDraw;
end;

//----------------- TVirtualDrawTree -----------------------------------------------------------------------------------

function TVirtualDrawTree.GetOptions: TVirtualTreeOptions;

begin
  Result := inherited TreeOptions as TVirtualTreeOptions;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualDrawTree.SetOptions(const Value: TVirtualTreeOptions);

begin
  TreeOptions.Assign(Value);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualDrawTree.GetOptionsClass: TTreeOptionsClass;

begin
  Result := TVirtualTreeOptions;
end;

initialization
{$IFDEF VT_VCL}
  TCustomStyleEngine.RegisterStyleHook(TVirtualDrawTree, TVclStyleScrollBarsHook);
{$ENDIF}
finalization
{$IFDEF VT_VCL}
  TCustomStyleEngine.UnRegisterStyleHook(TVirtualDrawTree, TVclStyleScrollBarsHook);
{$ENDIF}
end.
