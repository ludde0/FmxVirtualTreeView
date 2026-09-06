unit VirtualTrees.BaseAncestorFMX;

{$SCOPEDENUMS ON}

{****************************************************************************************************************}
{ Project          : VirtualTrees                                                                                }
{                                                                                                                }
{ author           : Karol Bieniaszewski                                                                         }
{ year             : 2022                                                                                        }
{ contibutors      :                                                                                             }
{****************************************************************************************************************}

interface

// The FMX half of the tree's platform layer. TVTBaseAncestorFMX descends from TRectangle,
// so the tree is an ordinary FMX control that paints itself, with two TScrollBar children
// standing in for the window scrollbars the VCL side gets from Windows. The Win32 shaped
// methods below (InvalidateRect, RedrawWindow, GetScrollInfo, GetSystemMetrics, ...) exist
// so the shared tree code can call the same names on both frameworks; most of them come
// down to a Repaint here.
// TVTBaseAncestorVcl is the counterpart - keep the abstract method list in sync with it.

uses
  {$IFDEF MSWINDOWS}
  WinApi.Windows,
  {$ENDIF}
  System.Classes, System.UITypes,
  FMX.Objects, FMX.Graphics, FMX.Controls, FMX.StdCtrls, FMX.Forms, FMX.ImgList,
  VirtualTrees.Types, VirtualTrees.FMX;


type
  TVTBaseAncestorFMX = class abstract(TRectangle)
  strict private
    FFont: TFont;
    procedure SetFont(const Value: TFont);
  private
    FDottedBrushTreeLines: TStrokeBrush;                  // used to paint dotted lines without special pens
    FDottedBrushGridLines: TStrokeBrush;                  // used to paint dotted lines without special pens
    FInCreate: Boolean;

    function GetFillColor: TAlphaColor;
    procedure SetFillColor(const Value: TAlphaColor);
  protected
    FBevelEdges: TBevelEdges;
    FBevelInner: TBevelCut;
    FBevelOuter: TBevelCut;
    FBevelKind: TBevelKind;
    FBevelWidth: TBevelWidth;
    FBorderWidth: TBorderWidth;
    FHandleAllocated: Boolean;
    FBiDiMode: TBiDiMode;
    FHScrollBar: TScrollBar;
    FVScrollBar: TScrollBar;
    FScrollBarSize: Single;
    FUseRightToLeftAlignment: Boolean;
    procedure SetScrollBarSize(const Value: Single);

    procedure SetBevelCut(Index: Integer; const Value: TBevelCut);
    procedure SetBevelEdges(const Value: TBevelEdges);
    procedure SetBevelKind(const Value: TBevelKind);
    procedure SetBevelWidth(const Value: TBevelWidth);
    procedure SetBorderWidth(Value: TBorderWidth);
    procedure SetBiDiMode(Value: TBiDiMode);

    function GetClientHeight: Single; virtual; abstract;
    function GetClientWidth: Single; virtual; abstract;
    function GetClientRect: TRect; virtual; abstract;
    procedure UpdateStyleElements; virtual; abstract;

    procedure DoStartDrag(var DragObject: TVTDragDataObject); virtual; abstract;
    procedure DoStateChange(Enter: TVirtualTreeStates; Leave: TVirtualTreeStates = []); virtual; abstract;
    procedure DoEndDrag(Target: TObject; X, Y: TDimension); virtual; abstract;
    procedure DragCanceled; virtual; abstract;

    function CreateSystemImageSet(): TImageList;
    procedure SetWindowTheme(const Theme: string); virtual;

    procedure ChangeScale(M, D: Integer{$if CompilerVersion >= 31}; isDpiChange: Boolean{$endif}); virtual; abstract;
    function GetControlsAlignment: TAlignment; virtual; abstract;
    function PrepareDottedBrush(CurrentDottedBrush: TStrokeBrush; Bits: Pointer; const BitsLinesCount: Word): TStrokeBrush; virtual; abstract;
    function GetSelectedCount(): Integer; virtual; abstract;
    procedure MarkCutCopyNodes; virtual; abstract;
    function GetSortedCutCopySet(Resolve: Boolean): TNodeArray; virtual; abstract;
    function GetSortedSelection(Resolve: Boolean): TNodeArray; virtual; abstract;
    procedure WriteNode(Stream: TStream; Node: PVirtualNode);  virtual; abstract;

    procedure NotifyAccessibleEvent(pEvent: Uint32 = EVENT_OBJECT_STATECHANGE); virtual;
  protected //properties
    property DottedBrushTreeLines: TStrokeBrush read FDottedBrushTreeLines write FDottedBrushTreeLines;
    property DottedBrushGridLines: TStrokeBrush read FDottedBrushGridLines write FDottedBrushGridLines;

    procedure HScrollChangeProc(Sender: TObject); virtual; abstract;
    procedure VScrollChangeProc(Sender: TObject); virtual; abstract;
  public //methods
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function ClientToScreen(P: TPoint): TPoint;
    function ScreenToClient(P: TPoint): TPoint;
    procedure RecreateWnd;
    procedure ShowScrollBar(Bar: Integer; AShow: Boolean); virtual;
    function SetScrollInfo(Bar: Integer; const ScrollInfo: TScrollInfo; Redraw: Boolean): TDimension;
    function GetScrollInfo(Bar: Integer; var ScrollInfo: TScrollInfo): Boolean;
    function GetScrollPos(Bar: Integer): TDimension;
    function GetScrollBarForBar(Bar: Integer): TScrollBar;

    // Not abstract, even though this class never does anything with them:
    // TBaseVirtualTree.CutToClipboard calls inherited, which would land on an abstract method
    // and raise EAbstractError. TVTAncestorFMX carries the real implementation.
    procedure CopyToClipboard; virtual;
    procedure CutToClipboard; virtual;
    function PasteFromClipboard: Boolean; virtual;

    /// <summary>
    /// Alias for IsFocused to make same as Vcl Focused
    /// </summary>
    function Focused(): Boolean; inline;

    /// <summary>
    /// Convert mouse message to TMouseButton
    /// Created as method, to be available in whole hierarchy without specifing Unit file name (prevent circular unit ref).
    /// </summary>
    class function KeysToShiftState(Keys: LongInt): TShiftState; static;

    function GetParentForm(Control: TControl; TopForm: Boolean = True): TCustomForm;

    /// <summary>
    /// Alias for Repaint on FMX to be compatible with VCL
    /// </summary>
    procedure Invalidate(); inline;
    /// <summary>
    /// Alias for Repaint on FMX to be compatible with VCL
    /// </summary>
    function InvalidateRect(lpRect: PRect; bErase: Boolean): Boolean; inline;
    /// <summary>
    /// Alias for Repaint on FMX to be compatible with VCL
    /// </summary>
    function UpdateWindow(): Boolean; inline;
    /// <summary>
    /// Alias for Repaint on FMX to be compatible with VCL
    /// </summary>
    function RedrawWindow(lprcUpdate: PRect; hrgnUpdate: NativeUInt; flags: UINT): Boolean; overload; inline;
    /// <summary>
    /// Alias for Repaint on FMX to be compatible with VCL
    /// </summary>
    function RedrawWindow(const lprcUpdate: TRect; hrgnUpdate: NativeUInt; flags: UINT): Boolean; overload; inline;

    /// <summary>
    /// Alias for Repaint on FMX to be compatible with VCL
    /// </summary>
    function SendWM_SETREDRAW(Updating: Boolean): NativeUInt; inline;

    /// <summary>
    /// Simulate Windows GetSystemMetrics
    /// </summary>
    function GetSystemMetrics(nIndex: Integer): Integer;

    /// <summary>
    /// The canvas to measure text and node sizes with. A tree that is not yet on a form has
    /// no Canvas, e.g. when nodes are added in the constructor of a frame whose parent is set
    /// afterwards, so the shared FMX measure canvas is used until it has one.
    /// </summary>
    function MeasuringCanvas: TCanvas;

    procedure Sort(Node: PVirtualNode; Column: TColumnIndex; Direction: TSortDirection; DoInit: Boolean = True); reintroduce; overload; virtual; abstract;
  public //properties
    property Font: TFont read FFont write SetFont;
    property ClientRect: TRect read GetClientRect;
    property ClientWidth: Single read GetClientWidth;
    property ClientHeight: Single read GetClientHeight;
    property UseRightToLeftAlignment: Boolean read FUseRightToLeftAlignment write FUseRightToLeftAlignment default false;
    property BevelEdges: TBevelEdges read FBevelEdges write SetBevelEdges default [TBevelEdge.beLeft, TBevelEdge.beTop, TBevelEdge.beRight, TBevelEdge.beBottom];
    property BevelInner: TBevelCut index 0 read FBevelInner write SetBevelCut default TBevelCut.bvRaised;
    property BevelOuter: TBevelCut index 1 read FBevelOuter write SetBevelCut default TBevelCut.bvLowered;
    property BevelKind: TBevelKind read FBevelKind write SetBevelKind default TBevelKind.bkNone;
    property BevelWidth: TBevelWidth read FBevelWidth write SetBevelWidth default 1;
    property BorderWidth: TBorderWidth read FBorderWidth write SetBorderWidth;
    property BiDiMode: TBiDiMode read FBiDiMode write SetBiDiMode;
    property HScrollBar: TScrollBar read FHScrollBar;
    property VScrollBar: TScrollBar read FVScrollBar;
    /// <summary>
    /// Thickness of both scrollbars in logical pixels. The FMX default is far too thin to
    /// hit with a finger. Applied to all FMX targets rather than only the mobile ones, so
    /// that a desktop build looks the same as the device it is being tested for.
    /// </summary>
    property ScrollBarSize: Single read FScrollBarSize write SetScrollBarSize;
    property HandleAllocated: Boolean read FHandleAllocated;

    /// <summary>
    /// Alias for Fill.Color to make same use as Vcl Color property
    /// </summary>
    property Color: TAlphaColor read GetFillColor write SetFillColor;
  end;

implementation

uses
  System.SysUtils, FMX.TextLayout, FMX.Utils, FMX.Types;

const
  cDefaultScrollBarSize = 24;  // logical px. Big enough for a fingertip on a phone.

//-------- TVTBaseAncestorFMX ------------------------------------------------------------------------------------------

class function TVTBaseAncestorFMX.KeysToShiftState(Keys: LongInt): TShiftState;
begin
  Result := TShiftState(Word(Keys));
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTBaseAncestorFMX.NotifyAccessibleEvent(pEvent: Uint32);
begin
  // Empty by intention: accessibility notification is platform specific and FMX has no
  // cross-platform equivalent of the MSAA call the VCL side makes.
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.GetFillColor: TAlphaColor;
begin
  Result:= Fill.Color;
end;

//----------------------------------------------------------------------------------------------------------------------

constructor TVTBaseAncestorFMX.Create(AOwner: TComponent);
begin
  FInCreate:= true;
  inherited;

  FHandleAllocated:= true;
  FUseRightToLeftAlignment:= false;
  FBevelEdges:= [TBevelEdge.beLeft, TBevelEdge.beTop, TBevelEdge.beRight, TBevelEdge.beBottom];
  FBevelInner:= TBevelCut.bvRaised;
  FBevelOuter:= TBevelCut.bvLowered;
  FBevelKind:= TBevelKind.bkNone;
  FBevelWidth:= 1;
  FBorderWidth:= 0;
  FFont:= TFont.Create;

  // The node background: Colors.BackGroundColor reads it straight off Fill.Color, so the
  // shape's own default decides what an untouched tree looks like. Stated here rather than
  // inherited, so that is one plain white list on every platform.
  Fill.Color := TAlphaColorRec.White;

  DisableFocusEffect := True;
  CanFocus := True;
  AutoCapture := True;
  ClipChildren := True;          // keeps the tree from painting outside its own bounds

  FHScrollBar:= TScrollBar.Create(Self);
  FHScrollBar.Parent:= Self;
  FHScrollBar.Orientation:= TOrientation.Horizontal;
  FHScrollBar.Align:= TAlignLayout.MostBottom;
  FHScrollBar.Visible:= true;
  FHScrollBar.OnChange:= HScrollChangeProc;


  FVScrollBar:= TScrollBar.Create(Self);
  FVScrollBar.Parent:= Self;
  FVScrollBar.Orientation:= TOrientation.Vertical;
  FVScrollBar.Align:= TAlignLayout.MostRight;
  FVScrollBar.Visible:= true;
  FVScrollBar.OnChange:= VScrollChangeProc;

  // Sets both bars' thickness and the corner margin between them.
  SetScrollBarSize(cDefaultScrollBarSize);

  SetAcceptsControls(false);

  FInCreate:= false;
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TVTBaseAncestorFMX.Destroy();
begin
  inherited;

  FreeAndNil(FFont);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTBaseAncestorFMX.SetBevelCut(Index: Integer; const Value: TBevelCut);
begin
  case Index of
    0: { BevelInner }
      if Value <> FBevelInner then
      begin
        FBevelInner := Value;
        Repaint;
      end;
    1: { BevelOuter }
      if Value <> FBevelOuter then
      begin
        FBevelOuter := Value;
        Repaint;
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTBaseAncestorFMX.SetBevelEdges(const Value: TBevelEdges);
begin
  if Value <> FBevelEdges then
    begin
      FBevelEdges := Value;
      Repaint;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTBaseAncestorFMX.SetBevelKind(const Value: TBevelKind);
begin
  if Value <> FBevelKind then
    begin
      FBevelKind := Value;
      Repaint;
    end;
end;
//----------------------------------------------------------------------------------------------------------------------

procedure TVTBaseAncestorFMX.SetBevelWidth(const Value: TBevelWidth);
begin
  if Value <> FBevelWidth then
    begin
      FBevelWidth := Value;
      Repaint;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.ScreenToClient(P: TPoint): TPoint;

begin
  Result:= AbsoluteToLocal(P);
end;
//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.ClientToScreen(P: TPoint): TPoint;
begin
  Result:= LocalToAbsolute(P);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTBaseAncestorFMX.Invalidate();
begin
  Repaint;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.InvalidateRect(lpRect: PRect; bErase: Boolean): Boolean;
begin
  Repaint;
  Result:= true;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.UpdateWindow(): Boolean;
begin
  Repaint;
  Result:= true;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.RedrawWindow(lprcUpdate: PRect; hrgnUpdate: NativeUInt; flags: UINT): Boolean;
begin
  Repaint;
  Result:= true;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.RedrawWindow(const lprcUpdate: TRect; hrgnUpdate: NativeUInt; flags: UINT): Boolean;
begin
  Repaint;
  Result:= true;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTBaseAncestorFMX.RecreateWnd();
begin
  Repaint;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTBaseAncestorFMX.ShowScrollBar(Bar: Integer; AShow: Boolean);
begin
  if (Bar=SB_HORZ) or (Bar=SB_BOTH) then
    FHScrollBar.Visible:= AShow;

  if (Bar=SB_VERT) or (Bar=SB_BOTH) then
    FVScrollBar.Visible:= AShow;

  if FHScrollBar.Visible and FVScrollBar.Visible then
    FHScrollBar.Margins.Right:= FScrollBarSize else
    FHScrollBar.Margins.Right:= 0;

  Repaint;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTBaseAncestorFMX.SetScrollBarSize(const Value: Single);
begin
  if Value<=0 then
    Exit; //!!!

  FScrollBarSize:= Value;

  if Assigned(FVScrollBar) then
    FVScrollBar.Width:= Value;

  if Assigned(FHScrollBar) then
    begin
      FHScrollBar.Height:= Value;
      // Keeps the horizontal bar clear of the vertical one. Both bars are this thick, so
      // the margin is the same value rather than either bar's own measurement.
      if FHScrollBar.Visible and FVScrollBar.Visible then
        FHScrollBar.Margins.Right:= Value;
    end;

  Repaint;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.SetScrollInfo(Bar: Integer; const ScrollInfo: TScrollInfo; Redraw: Boolean): TDimension;

// Maps the Win32 style TScrollInfo the tree works in onto an FMX TScrollBar.
//
// The two models differ in where the page size lives. An FMX TScrollBar sizes its thumb as
// ViewportSize / (Max - Min) and lets Value run from Min to Max - ViewportSize, while the tree
// passes nMax already reduced by one page (see UpdateVerticalScrollBar). Adding the viewport back
// onto Max therefore keeps Max - ViewportSize equal to the nMax the tree expects: the scroll
// range is unchanged and the thumb gets its proper size. Leaving ViewportSize at 0 collapses the
// thumb to the minimum the style allows, which is a few pixels and undraggable with a finger.

Var ScrollBar: TScrollBar;
  AViewport: Single;
begin
  ScrollBar:= GetScrollBarForBar(Bar);
  if ScrollBar=nil then
    Exit(0); //!!!

  // Align MostRight spans the full control height, so the vertical bar runs up behind the
  // header. GetClientRect already puts ClientRect.Top at the bottom of the header, so inset the
  // bar by exactly that. Done here because SetScrollInfo is reached from every
  // UpdateVerticalScrollBar - on resize, on range change and on every offset change.
  if Bar=SB_VERT then
    FVScrollBar.Margins.Top:= ClientRect.Top - ClipRect.Top;

  if Bar=SB_VERT then
    AViewport:= ClientHeight else
    AViewport:= ClientWidth;

  if (ScrollInfo.fMask and SIF_RANGE<>0) and (ScrollInfo.nMax<=ScrollInfo.nMin) then
    AViewport:= 0;  // nothing to scroll, the bar is being reset or hidden

  if AViewport<0 then
    AViewport:= 0;

  if ScrollInfo.fMask and SIF_PAGE<>0 then
    begin
      ScrollBar.ViewportSize:= AViewport;
      // A page is a sensible small change too.
      ScrollBar.SmallChange:= AViewport/10;
    end;

  if ScrollInfo.fMask and SIF_RANGE<>0 then
    begin
      ScrollBar.Min:= ScrollInfo.nMin;
      ScrollBar.Max:= ScrollInfo.nMax + AViewport;
    end;

  if ScrollInfo.fMask and SIF_POS<>0 then
    begin
      ScrollBar.Value:= ScrollInfo.nPos;
    end;

  Result:= ScrollBar.Value;

  Repaint;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.GetScrollInfo(Bar: Integer; var ScrollInfo: TScrollInfo): Boolean;
Var ScrollBar: TScrollBar;
begin
  ScrollBar:= GetScrollBarForBar(Bar);
  if ScrollBar=nil then
    Exit(False); //!!!

  Result:= true;

  ScrollInfo.cbSize:= SizeOf(TScrollInfo);
  ScrollInfo.fMask:= SIF_ALL;

  // Mirror of SetScrollInfo: Max carries the viewport that was added there, and the page
  // is the viewport itself, not the small change derived from it.
  ScrollInfo.nMin:= ScrollBar.Min;
  ScrollInfo.nMax:= ScrollBar.Max;
  ScrollInfo.nPage:= ScrollBar.ViewportSize;
  ScrollInfo.nPos:= ScrollBar.Value;
  ScrollInfo.nTrackPos:= ScrollBar.Value;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.GetScrollPos(Bar: Integer): TDimension;
Var ScrollInfo: TScrollInfo;
begin
  GetScrollInfo(Bar, ScrollInfo); //ignore result
  Result:= ScrollInfo.nPos;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.GetScrollBarForBar(Bar: Integer): TScrollBar;
begin
  if (Bar=SB_HORZ) then
    Result:= FHScrollBar else
  if (Bar=SB_VERT) then
    Result:= FVScrollBar else
    Result:= nil;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTBaseAncestorFMX.SetBiDiMode(Value: TBiDiMode);
begin
  if FBiDiMode <> Value then
    begin
      FBiDiMode := Value;
      Repaint;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTBaseAncestorFMX.SetBorderWidth(Value: TBorderWidth);
begin
  if FBorderWidth <> Value then
    begin
      FBorderWidth := Value;
      Repaint;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTBaseAncestorFMX.SetFillColor(const Value: TAlphaColor);
begin
  Fill.Color:= Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTBaseAncestorFMX.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.Focused(): Boolean;
begin
  Result:= IsFocused;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.GetParentForm(Control: TControl; TopForm: Boolean = True): TCustomForm;

// FMX has a single root per control tree, so TopForm makes no difference here.
// A control that is not on a form yet has no root, in which case there is no form to return.

begin
  Result:= nil;
  if Assigned(Control) and Assigned(Control.Root) and (Control.Root.GetObject is TCustomForm) then
    Result:= TCustomForm(Control.Root.GetObject);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.SendWM_SETREDRAW(Updating: Boolean): NativeUInt;
begin
  Repaint;
  Result:= 0;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.MeasuringCanvas: TCanvas;
begin
  Result := Canvas;
  if Result = nil then
    Result := TCanvasManager.MeasureCanvas;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.GetSystemMetrics(nIndex: Integer): Integer;

// Stands in for the Win32 call of the same name. Only the two scrollbar metrics the tree
// asks for are answered; anything else is a programming error rather than a fallback.
// The Windows call has to be qualified - unqualified it would resolve to this method.

begin
  {$IFDEF MSWINDOWS}
  Result:= Winapi.Windows.GetSystemMetrics(nIndex);
  {$ELSE}
  // Off Windows the scrollbars are the FMX ones this class creates, so report their size.
  case nIndex of
    SM_CXVSCROLL,
    SM_CYHSCROLL: Result:= Round(FScrollBarSize);
    else
      raise Exception.Create('Unknown code for GetSystemMetrics: ' + IntToStr(nIndex));
  end;
  {$ENDIF}
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.CreateSystemImageSet(): TImageList;
begin
  Result:= TImageList.Create(Self);
  FillSystemCheckImages(Self, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTBaseAncestorFMX.CopyToClipboard;
begin
  // Empty on purpose - the end of the inherited chain, see the declaration.
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTBaseAncestorFMX.CutToClipboard;
begin
  // Empty on purpose - the end of the inherited chain, see the declaration.
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTBaseAncestorFMX.PasteFromClipboard: Boolean;
begin
  Result := False;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTBaseAncestorFMX.SetWindowTheme(const Theme: string);
begin
  //nothing
end;

end.
