unit VirtualTrees.FMX;

{$SCOPEDENUMS ON}

{***********************************************************}
{ Project          : VirtualTrees                           }
{                                                           }
{ author           : Karol Bieniaszewski                    }
{ year             : 2018                                   }
{ contibutors      :                                        }
{***********************************************************}

interface
uses
    System.Classes
  , System.UITypes
  , System.Types
  , System.ImageList
  , System.Math.Vectors
  , FMX.ImgList
  , FMX.Graphics
  , FMX.Controls
  , FMX.Types
  , FMX.StdCtrls;

//-------- type aliasing -------------------------------------------------------------------------------------------------------------------

type
  TRect = System.Types.TRectF;
  PRect = System.Types.PRectF;
  TPoint = System.Types.TPointF;
  PPoint = System.Types.PPointF;
  PSize = System.Types.PSizeF;
  TSize = System.Types.TSizeF;
  TColor = System.UITypes.TAlphaColor;
  PAnsiChar = System.MarshaledAString;
  UINT = LongWord;
  PUINT = ^UINT;
  TCustomControl = TControl; //Alias for VCL compatibility as on FMX there is not TCustomControl

//------- color aliasing -------------------------------------------------------------------------------------------------------------------

// Stand-ins for the VCL system color constants, so shared code can name a color the same
// way on both frameworks. These are TAlphaColor, i.e. $AARRGGBB with an opaque alpha -
// leaving the alpha byte off makes the color fully transparent, not black.
// They are ordinary opaque colors, not system colors: nothing here follows the OS theme.
const
  clBtnFace = TAlphaColor($FFF0F0F0);
  clBtnText = TAlphaColorRec.Black;
  clBtnHighlight = TAlphaColorRec.DkGray;
  clBtnShadow = TAlphaColorRec.Darkgray;
  // The selection colour, and with it the drop marks and the selection rectangle. Dark
  // enough for clHighlightText (white) to read on it, which Lightblue was not.
  clHighlight = TAlphaColor($FF0078D7);
  // The drop target and drop mark. Standard VirtualTreeView uses clHighlight for these as
  // well, which makes a drop indistinguishable from the selection it is dropped onto.
  clDropTarget = TAlphaColor($FF9B59B6);
  clWindow = TAlphaColorRec.White;
  clWindowText = TAlphaColorRec.Black;
  clHighlightText = TAlphaColorRec.White;
  clWhite = TAlphaColorRec.White;
  clSilver = TAlphaColorRec.Silver;
  clGray = TAlphaColorRec.Gray;
  clBlack = TAlphaColorRec.Black;
  clGreen = TAlphaColorRec.Green;
  clBlue =  TAlphaColorRec.Blue;
  clGrayText =  TAlphaColorRec.DkGray;
  clInactiveCaption = TAlphaColorRec.DkGray;
  clInactiveCaptionText = TAlphaColorRec.White;
  clDkGray = TAlphaColorRec.DkGray;


//------- needed for migration -------------------------------------------------------------------------------------------------------------

const
  { 3D border styles }
  BDR_RAISEDOUTER = 1;
  BDR_SUNKENOUTER = 2;
  BDR_RAISEDINNER = 4;
  BDR_SUNKENINNER = 8;

  BDR_OUTER = 3;
  BDR_INNER = 12;
  BDR_RAISED = 5;
  BDR_SUNKEN = 10;

  EDGE_RAISED = (BDR_RAISEDOUTER or BDR_RAISEDINNER);
  EDGE_SUNKEN = (BDR_SUNKENOUTER or BDR_SUNKENINNER);
  EDGE_ETCHED = (BDR_SUNKENOUTER or BDR_RAISEDINNER);
  EDGE_BUMP = (BDR_RAISEDOUTER or BDR_SUNKENINNER);

  ETO_OPAQUE = 2;
  ETO_CLIPPED = 4;
  ETO_RTLREADING = $80;

  RTLFlag: array[Boolean] of Integer = (0, ETO_RTLREADING);

  { Border flags }
  BF_LEFT = 1;
  BF_TOP = 2;
  BF_RIGHT = 4;
  BF_BOTTOM = 8;

  BF_TOPLEFT = (BF_TOP or BF_LEFT);
  BF_TOPRIGHT = (BF_TOP or BF_RIGHT);
  BF_BOTTOMLEFT = (BF_BOTTOM or BF_LEFT);
  BF_BOTTOMRIGHT = (BF_BOTTOM or BF_RIGHT);
  BF_RECT = (BF_LEFT or BF_TOP or BF_RIGHT or BF_BOTTOM);

  BF_MIDDLE = $800;   { Fill in the middle }
  BF_SOFT = $1000;    { For softer buttons }
  BF_ADJUST = $2000;  { Calculate the space left over }
  BF_FLAT = $4000;    { For flat rather than 3D borders }
  BF_MONO = $8000;    { For monochrome borders }

  { DrawText() Format Flags }
  DT_TOP = 0;
  DT_LEFT = 0;
  DT_CENTER = 1;
  DT_RIGHT = 2;
  DT_VCENTER = 4;
  DT_BOTTOM = 8;
  DT_WORDBREAK = $10;
  DT_SINGLELINE = $20;
  DT_EXPANDTABS = $40;
  DT_TABSTOP = $80;
  DT_NOCLIP = $100;
  DT_EXTERNALLEADING = $200;
  DT_CALCRECT = $400;
  DT_NOPREFIX = $800;
  DT_INTERNAL = $1000;


  DT_EDITCONTROL = $2000;
  DT_PATH_ELLIPSIS = $4000;
  DT_END_ELLIPSIS = $8000;
  DT_MODIFYSTRING = $10000;
  DT_RTLREADING = $20000;
  DT_WORD_ELLIPSIS = $40000;
  DT_NOFULLWIDTHCHARBREAK = $0080000;
  DT_HIDEPREFIX = $00100000;
  DT_PREFIXONLY = $00200000;

  MAXDWORD = DWORD($FFFFFFFF);
  WHEEL_DELTA = 120;            { Value for rolling one detent }
  WHEEL_PAGESCROLL = MAXDWORD;  { Scroll one page }

  { WM_SIZE message wParam values }
  SIZE_RESTORED = 0;
  SIZE_MINIMIZED = 1;
  SIZE_MAXIMIZED = 2;
  SIZE_MAXSHOW = 3;
  SIZE_MAXHIDE = 4;

  { Scroll Bar Constants }
  SB_HORZ = 0;
  SB_VERT = 1;
  SB_CTL =  2;
  SB_BOTH = 3;

  SIF_RANGE = 1;
  SIF_PAGE = 2;
  SIF_POS = 4;
  SIF_DISABLENOSCROLL = 8;
  SIF_TRACKPOS = $10;
  SIF_ALL = (SIF_RANGE or SIF_PAGE or SIF_POS or SIF_TRACKPOS);

  { Scroll Bar Commands }
  SB_LINEUP = 0;
  SB_LINELEFT = 0;
  SB_LINEDOWN = 1;
  SB_LINERIGHT = 1;
  SB_PAGEUP = 2;
  SB_PAGELEFT = 2;
  SB_PAGEDOWN = 3;
  SB_PAGERIGHT = 3;
  SB_THUMBPOSITION = 4;
  SB_THUMBTRACK = 5;
  SB_TOP = 6;
  SB_LEFT = 6;
  SB_BOTTOM = 7;
  SB_RIGHT = 7;
  SB_ENDSCROLL = 8;

  { RedrawWindow() flags }
  RDW_INVALIDATE = 1;
  RDW_INTERNALPAINT = 2;
  RDW_ERASE = 4;
  RDW_VALIDATE = 8;
  RDW_NOINTERNALPAINT = $10;
  RDW_NOERASE = $20;
  RDW_NOCHILDREN = $40;
  RDW_ALLCHILDREN = $80;
  RDW_UPDATENOW = $100;
  RDW_ERASENOW = $200;
  RDW_FRAME = $400;
  RDW_NOFRAME = $800;

  { GetSystemMetrics() codes }
  SM_CXVSCROLL = 2;
  SM_CYHSCROLL = 3;

  EVENT_OBJECT_CREATE              = $8000;  { hwnd + ID + idChild is created item }
  EVENT_OBJECT_DESTROY             = $8001;  { hwnd + ID + idChild is destroyed item }
  EVENT_OBJECT_SHOW                = $8002;  { hwnd + ID + idChild is shown item }
  EVENT_OBJECT_HIDE                = $8003;  { hwnd + ID + idChild is hidden item }
  EVENT_OBJECT_REORDER             = $8004;  { hwnd + ID + idChild is parent of zordering children }
  EVENT_OBJECT_FOCUS               = $8005;  { hwnd + ID + idChild is focused item }
  EVENT_OBJECT_SELECTION           = $8006;  { hwnd + ID + idChild is selected item (if only one), or idChild is OBJID_WINDOW if complex }
  EVENT_OBJECT_SELECTIONADD        = $8007;  { hwnd + ID + idChild is item added }
  EVENT_OBJECT_SELECTIONREMOVE     = $8008;  { hwnd + ID + idChild is item removed }
  EVENT_OBJECT_SELECTIONWITHIN     = $8009;  { hwnd + ID + idChild is parent of changed selected items }
  EVENT_OBJECT_STATECHANGE         = $800A;  { hwnd + ID + idChild is item w/ state change }
  EVENT_OBJECT_LOCATIONCHANGE      = $800B;  { hwnd + ID + idChild is moved/sized item }
  EVENT_OBJECT_NAMECHANGE          = $800C;  { hwnd + ID + idChild is item w/ name change }
  EVENT_OBJECT_DESCRIPTIONCHANGE   = $800D;  { hwnd + ID + idChild is item w/ desc change }
  EVENT_OBJECT_VALUECHANGE         = $800E;  { hwnd + ID + idChild is item w/ value change }
  EVENT_OBJECT_PARENTCHANGE        = $800F;  { hwnd + ID + idChild is item w/ new parent }
  EVENT_OBJECT_HELPCHANGE          = $8010;  { hwnd + ID + idChild is item w/ help change }
  EVENT_OBJECT_DEFACTIONCHANGE     = $8011;  { hwnd + ID + idChild is item w/ def action change }
  EVENT_OBJECT_ACCELERATORCHANGE   = $8012;  { hwnd + ID + idChild is item w/ keybd accel change }
  EVENT_OBJECT_INVOKED             = $8013;  { hwnd + ID + idChild is item invoked }
  EVENT_OBJECT_TEXTSELECTIONCHANGED= $8014;  { hwnd + ID + idChild is item w? test selection change }

var
  // Clipboard format IDs used in OLE drag'n drop and clipboard transfers.
  CF_VIRTUALTREE,
  CF_VTREFERENCE,
  CF_VRTF,
  CF_VRTFNOOBJS,   // Named CF_VRTF* because CF_RTF* is already taken by the RTF
                   // registration strings.
  CF_HTML,
  CF_CSV: Word;

type
  tagSCROLLINFO = record
    cbSize: UINT;
    fMask: UINT;
    nMin: Single;
    nMax: Single;
    nPage: Single;
    nPos: Single;
    nTrackPos: Single;
  end;
  PScrollInfo = ^TScrollInfo;
  TScrollInfo = tagSCROLLINFO;
  SCROLLINFO = tagSCROLLINFO;

  TBorderWidth = Single;
  TBevelCut = (bvNone, bvLowered, bvRaised, bvSpace);
  TBevelEdge = (beLeft, beTop, beRight, beBottom);
  TBevelEdges = set of TBevelEdge;
  TBevelKind = (bkNone, bkTile, bkSoft, bkFlat);
  TBevelWidth = 1..MaxInt;

  TFormBorderStyle = (bsNone, bsSingle, bsSizeable, bsDialog, bsToolWindow, bsSizeToolWin);
  TBorderStyle = TFormBorderStyle.bsNone..TFormBorderStyle.bsSingle;



  TChangeLink = class(TImageLink)
  private
    function GetSender: TCustomImageList; inline;
    procedure SetSender(const Value: TCustomImageList); inline;
  public
    constructor Create; override;
    property Sender: TCustomImageList read GetSender write SetSender;
  end;

  // Deliberately 32 bit on every platform: these only ever carry the packed coordinates
  // and flags of the simulated messages below, and the record layouts assume that size.
  INT_PTR = Integer;
  {$EXTERNALSYM INT_PTR}
  UINT_PTR = Cardinal;

  WPARAM = UINT_PTR;
  LPARAM = INT_PTR;
  LRESULT = INT_PTR;

  TDWordFiller = record
  {$IFDEF CPU64}
    Filler: array[1..4] of Byte; // Pad DWORD to make it 8 bytes (4+4) [x64 only]
  {$ENDIF}
end;

//--------- Windows messages simulations ---------------------------------------------------------------------------------------------------

const
  WM_APP              = $8000;
  WM_MOUSEFIRST       = $0200;
  WM_MOUSEMOVE        = $0200;
  WM_LBUTTONDOWN      = $0201;
  WM_LBUTTONUP        = $0202;
  WM_LBUTTONDBLCLK    = $0203;
  WM_RBUTTONDOWN      = $0204;
  WM_RBUTTONUP        = $0205;
  WM_RBUTTONDBLCLK    = $0206;
  WM_MBUTTONDOWN      = $0207;
  WM_MBUTTONUP        = $0208;
  WM_MBUTTONDBLCLK    = $0209;
  WM_MOUSEWHEEL       = $020A;
  WM_SIZE             = $0005;
  WM_NCMBUTTONDOWN    = $00A7;
  WM_NCMBUTTONUP      = $00A8;
  WM_NCMBUTTONDBLCLK  = $00A9;
  WM_NCLBUTTONDBLCLK  = $00A3;
  WM_NCRBUTTONDOWN    = $00A4;
  WM_NCRBUTTONUP      = $00A5;
  WM_NCRBUTTONDBLCLK  = $00A6;
  WM_NCLBUTTONDOWN    = $00A1;
  WM_NCLBUTTONUP      = $00A2;
  WM_NCMOUSEMOVE      = $00A0;
  WM_KEYDOWN          = $0100;
  WM_KEYUP            = $0101;
  WM_SETFOCUS         = $0007;
  WM_KILLFOCUS        = $0008;
  WM_SETCURSOR        = $0020;
  WM_HSCROLL          = $0114;
  WM_VSCROLL          = $0115;
  WM_CHANGESTATE = WM_APP + 32;

  CM_BASE                   = $B000;
{$IF DEFINED(CLR)}
  CM_CLROFFSET              = $100;
{$ELSE}
  CM_CLROFFSET              = $0; // Only applicable in CLR
{$ENDIF}
  CM_ACTIVATE               = CM_BASE + 0;
  CM_DEACTIVATE             = CM_BASE + 1;
  CM_GOTFOCUS               = CM_BASE + 2;
  CM_LOSTFOCUS              = CM_BASE + 3;
  CM_CANCELMODE             = CM_BASE + CM_CLROFFSET + 4;
  CM_DIALOGKEY              = CM_BASE + 5;
  CM_DIALOGCHAR             = CM_BASE + 6;
{$IF NOT DEFINED(CLR)}
  CM_FOCUSCHANGED           = CM_BASE + 7;
{$ENDIF}
  CM_PARENTFONTCHANGED      = CM_BASE + CM_CLROFFSET + 8;
  CM_PARENTCOLORCHANGED     = CM_BASE + 9;
  CM_BIDIMODECHANGED        = CM_BASE + 60;
  CM_PARENTBIDIMODECHANGED  = CM_BASE + 61;
  CM_MOUSEWHEEL             = CM_BASE + 67;

  VK_ESCAPE = 27;

type
  PMessage = ^TMessage;
  TMessage = record
    Msg: Cardinal;                      //4
    tmp: Integer;                       //4
    case Integer of
      0: (
        WParam: WPARAM;                 //4
        LParam: LPARAM;                 //4
        Result: LRESULT                 //4
        );                              //= 12 + 4 = 16
      1: (
        WParamLo: Word;                 //2
        WParamHi: Word;                 //2
        //WParamFiller: TDWordFiller;
        LParamLo: Word;                 //2
        LParamHi: Word;                 //2
        //LParamFiller: TDWordFiller;
        ResultLo: Word;                 //2
        ResultHi: Word;                 //2
                                        //=12 + 8 = 20
        );
  end;

  TWMMouse = record
    Msg: Cardinal;                      //4
    Keys: Longint; //TShiftState;       //4
    //KeysFiller: TDWordFiller;
    case Integer of
      0: (
        XPos: Single;                   //4
        YPos: Single;                   //4
        Result: LRESULT;                //4
        );
      1: (
        Pos: TPoint;                    //8
        ResultLo: Word;                 //2
        ResultHi: Word;                 //2
        );                              //=12 + 8=20
  end;

  TWMMouseMove = TWMMouse;

  TWMNCHitTest = record
    Msg: Cardinal;
    //MsgFiller: TDWordFiller;
    Unused: WPARAM;
    case Integer of
      0: (
        XPos: Single;
        YPos: Single;
        //XYPosFiller: TDWordFiller
        );
      1: (
        Pos: TPoint;
        //PosFiller: TDWordFiller;
        Result: LRESULT);
  end;

  TWMNCHitMessage = record
    Msg: Cardinal;                       //4
    //MsgFiller: TDWordFiller;
    HitTest: Longint;                    //4
    //HitTestFiller: TDWordFiller;
    XCursor: Single;                     //4
    YCursor: Single;                     //4
    //XYCursorFiller: TDWordFiller;
    Result: LRESULT;                     //4
  end;                                   //=20

  TWMNCLButtonDblClk = TWMNCHitMessage;
  TWMNCLButtonDown   = TWMNCHitMessage;
  TWMNCLButtonUp     = TWMNCHitMessage;
  TWMNCMButtonDblClk = TWMNCHitMessage;
  TWMNCMButtonDown   = TWMNCHitMessage;
  TWMNCMButtonUp     = TWMNCHitMessage;
  TWMNCMouseMove     = TWMNCHitMessage;
  TWMNCRButtonDblClk = TWMNCHitMessage;
  TWMNCRButtonDown   = TWMNCHitMessage;
  TWMNCRButtonUp     = TWMNCHitMessage;

  TWMLButtonDblClk = TWMMouse;
  TWMLButtonDown   = TWMMouse;
  TWMLButtonUp     = TWMMouse;
  TWMMButtonDblClk = TWMMouse;
  TWMMButtonDown   = TWMMouse;
  TWMMButtonUp     = TWMMouse;


  TWMKey = record
    Msg: Cardinal;                       //4
    tmp: Integer;                        //4
    CharCode: Word;                      //4
    //Unused: Word;                        //2
    KeyData: Longint;                    //4
    Result: LRESULT;                     //4
  end;                                   //=20

  TWMKeyDown = TWMKey;
  TWMKeyUp = TWMKey;

  TWMSize = record
    Msg: Cardinal;                       //4
    //MsgFiller: TDWordFiller;
    SizeType: WPARAM;  { SIZE_MAXIMIZED, SIZE_MINIMIZED, SIZE_RESTORED,  //4
                         SIZE_MAXHIDE, SIZE_MAXSHOW }
    Width: Single;                       //4
    Height: Single;                      //4
    //WidthHeightFiller: TDWordFiller;
    Result: LRESULT;                     //4
  end;                                   //=20

  TWMScroll = record
    Msg: Cardinal;                      //4
    //MsgFiller: TDWordFiller;
    ScrollCode: {Smallint}Integer; { SB_xxxx }   //4
    Pos: Single;                        //4
    //ScrollCodePosFiller: TDWordFiller;
    ScrollBar: Integer;                 //4  nBar
    Result: LRESULT;                    //4
  end;                                  //=20

  TWMHScroll = TWMScroll;
  TWMVScroll = TWMScroll;

  TCMMouseWheel = record
    Msg: Cardinal;                      //4
    //MsgFiller: TDWordFiller;
    ShiftState: TShiftState;            //2
    WheelDelta: SmallInt;               //2
    //ShiftStateWheel: TDWordFiller;
    case Integer of
      0: (
        XPos: Single;                   //4
        YPos: Single;                   //4
        //XYPos: TDWordFiller
        );                              //=24!
      1: (
        Pos: TPoint;                    //8
        //PosFiller: TDWordFiller;
        Result: LRESULT                 //4
        );                              //=28!
  end;


procedure FillTWMMouse(Var MM: TWMMouse; Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single; IsNC: Boolean; IsUp: Boolean);
function TMessageToTWMMouse(const Source: TMessage): TWMMouse;
function TMessageToTWMNCHitMessage(const Source: TMessage): TWMNCHitMessage;
function TWMMouseToTMessage(const Source: TWMMouse): TMessage;

//--------- Text metrics -------------------------------------------------------------------------------------------------------------------
type
  TTextMetric = record
    tmHeight: Single;  //The height (ascent + descent) of characters.
    tmAscent: Single;  //The ascent (units above the base line) of characters.
    tmDescent: Single; //The descent (units below the base line) of characters.
    tmInternalLeading: Single; //The amount of leading (space) inside the bounds set by the tmHeight member. Accent marks and other diacritical characters may occur in this area. The designer may set this member to zero
    tmExternalLeading: Single; //The amount of extra leading (space) that the application adds between rows. Since this area is outside the font, it contains no marks and is not altered by text output calls in either OPAQUE or TRANSPARENT mode. The designer may set this member to zero.
    tmAveCharWidth: Single; //The average width of characters in the font (generally defined as the width of the letter x ). This value does not include the overhang required for bold or italic characters.
    tmMaxCharWidth: Single; //The width of the widest character in the font.
    tmWeight: Single; //The weight of the font.
    tmOverhang: Single;
    tmDigitizedAspectX: Single; //The horizontal aspect of the device for which the font was designed.
    tmDigitizedAspectY: Single; //The vertical aspect of the device for which the font was designed. The ratio of the tmDigitizedAspectX and tmDigitizedAspectY members is the aspect ratio of the device for which the font was designed.
    tmFirstChar: WideChar; //The value of the first character defined in the font.
    tmLastChar: WideChar;  //The value of the last character defined in the font.
    tmDefaultChar: WideChar; //The value of the character to be substituted for characters not in the font.
    tmBreakChar: WideChar; //The value of the character that will be used to define word breaks for text justification.
    tmItalic: Byte; //Specifies an italic font if it is nonzero.
    tmUnderlined: Byte; //Specifies an underlined font if it is nonzero.
    tmStruckOut: Byte; //A strikeout font if it is nonzero.
    tmPitchAndFamily: Byte; //Specifies information about the pitch, the technology, and the family of a physical font.  TMPF_FIXED_PITCH, TMPF_VECTOR, TMPF_TRUETYPE, TMPF_DEVICE
    tmCharSet: Byte; //The character set of the font. The character set can be one of the following values. ANSI_CHARSET, GREEK_CHARSET....
  end;
  procedure GetTextMetrics(ACanvas: TCanvas; var TM: TTextMetric);

//-------- function aliassing --------------------------------------------------------------------------------------------------------------

procedure FillMemory(Destination: Pointer; Length: NativeUInt; Fill: Byte);
procedure ZeroMemory(Destination: Pointer; Length: NativeUInt);
procedure MoveMemory(Destination: Pointer; Source: Pointer; Length: NativeUInt);
procedure CopyMemory(Destination: Pointer; Source: Pointer; Length: NativeUInt);

procedure DrawTextW(ACanvas: TCanvas; CaptionText: String; Len: Integer; Var Bounds: TRect; DrawFormat: Cardinal{this is windows format - must be converted to FMX});
procedure GetTextExtentPoint32W(ACanvas: TCanvas; CaptionText: String; Len: Integer; Var Size: TSize);
procedure DrawEdge(Canvas: TCanvas; R: TRect; edge, grfFlags: Cardinal);

type
  THighQualityBitmap = class(TBitmap)
    public
      constructor Create; override;
  end;

//fill system images
procedure FillSystemCheckImages(Parent: TFmxObject; List: TImageList);

type
  /// <summary>
  /// The ghost that follows the pointer while a dtFMX drag is running: a small bitmap built
  /// once when the drag starts and drawn half transparent over everything else at the end of
  /// the tree's paint.
  ///
  /// The VCL gets this from the operating system, which hangs a glyph on the drag cursor.
  /// FMX has no OS drag cursor to hang anything on and no cursor at all on a touch screen,
  /// so the tree draws its own - which is also why this works the same under a finger as it
  /// does under a mouse.
  ///
  /// The bitmap is held at its own pixel size and drawn at the logical size given to
  /// SetBitmap, so the caller can build it oversampled and still have it land the right size
  /// on a high density screen.
  /// </summary>
  TVTFmxDragImage = class
  private
    FBitmap: TBitmap;
    FSize: TSizeF;        // logical size the bitmap is drawn at
    FPosition: TPointF;   // where the pointer is, in the tree's own coordinates
    FOffset: TPointF;     // top left of the image relative to the pointer
    FOpacity: Single;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>
    /// Copies ABitmap and makes the image visible. ASize is the size it is drawn at and
    /// AOffset the position of its top left corner relative to the pointer.
    /// </summary>
    procedure SetBitmap(ABitmap: TBitmap; const ASize: TSizeF; const AOffset: TPointF);
    /// <summary>Hides the image and releases the bitmap.</summary>
    procedure Clear;
    function Visible: Boolean;
    /// <summary>The pointer has moved. Does not repaint - the caller owns that.</summary>
    procedure MoveTo(const APosition: TPointF);
    /// <summary>
    /// Draws the image, kept inside ABounds so it cannot be dragged off the control and
    /// disappear. Does nothing when there is no image.
    /// </summary>
    procedure PaintTo(ACanvas: TCanvas; const ABounds: TRectF);

    property Opacity: Single read FOpacity write FOpacity;
    property Position: TPointF read FPosition;
  end;

type
  TCanvasHelper = class helper for TCanvas
  private
    function GetBrush: TBrush; inline;
    function GetPen: TStrokeBrush; inline;
  public
    property Brush: TBrush read GetBrush;
    property Pen: TStrokeBrush read GetPen;
    procedure FillRect(const ARect: TRectF); overload; inline;
    procedure DrawRect(const ARect: TRectF); overload; inline;
    procedure DrawFocusRect(const AFocusRect: TRect);
    procedure FrameRect(const AFocusRect: TRect);
    procedure RoundRect(X1, Y1, X2, Y2: Single; const XRadius, YRadius: Single); overload;
    procedure RoundRect(const Rect: TRect; const XRadius, YRadius: Single); overload;
    procedure Polygon(const Points: TPolygon);
    procedure Draw(const X, Y: Single; const Bitmap: TBitmap);
  end;

  TFontHelper = class helper for TFont
  private
    function GetOnChange: TNotifyEvent;
    procedure SetOnChange(const Value: TNotifyEvent);
  public
    property OnChange: TNotifyEvent read GetOnChange write SetOnChange;
  end;

{ Draws a solid triangular arrow that can point in any TScrollDirection }

type
  TScrollDirection = (sdLeft, sdRight, sdUp, sdDown);
  TArrowType = (atSolid, atArrows);

procedure DrawArrow(ACanvas: TCanvas; Direction: TScrollDirection; Location: TPoint; Size: Single);

procedure ChangeBiDiModeAlignment(var Alignment: TAlignment);

procedure OleUninitialize();

function timeGetTime: Int64;

implementation
uses
    System.SysUtils
  , FMX.TextLayout
  , FMX.MultiResBitmap
  , FMX.Objects
  , VirtualTrees.Utils
  ;

//----------------------------------------------------------------------------------------------------------------------

procedure DrawArrow(ACanvas: TCanvas; Direction: TScrollDirection; Location: TPoint; Size: Single);
// Location is the top left corner of the glyph box, Size its side length.
const
  cArrowScale = 0.6;   // fraction of the glyph box actually used by the triangle
var
  Pts: TPolygon;
  L, T, R, B, CX, CY, Inset: Single;
  SavedColor: TAlphaColor;
  SavedKind: TBrushKind;
begin
  if Size <= 0 then
    Exit;

  Inset := Size * (1 - cArrowScale) / 2;
  L := Location.X + Inset;
  T := Location.Y + Inset;
  R := Location.X + Size - Inset;
  B := Location.Y + Size - Inset;
  CX := Location.X + Size / 2;
  CY := Location.Y + Size / 2;

  SetLength(Pts, 3);
  case Direction of
    TScrollDirection.sdUp:
      begin
        Pts[0] := PointF(CX, T);
        Pts[1] := PointF(R, B);
        Pts[2] := PointF(L, B);
      end;
    TScrollDirection.sdDown:
      begin
        Pts[0] := PointF(CX, B);
        Pts[1] := PointF(L, T);
        Pts[2] := PointF(R, T);
      end;
    TScrollDirection.sdLeft:
      begin
        Pts[0] := PointF(L, CY);
        Pts[1] := PointF(R, T);
        Pts[2] := PointF(R, B);
      end;
    TScrollDirection.sdRight:
      begin
        Pts[0] := PointF(R, CY);
        Pts[1] := PointF(L, B);
        Pts[2] := PointF(L, T);
      end;
  end;

  // Callers set Pen.Color for the arrow (see THeaderPaintInfo.DrawSortArrow), but a solid
  // triangle is filled - mirror Pen into Fill and put Fill back afterwards.
  SavedColor := ACanvas.Fill.Color;
  SavedKind := ACanvas.Fill.Kind;
  try
    ACanvas.Fill.Kind := TBrushKind.Solid;
    ACanvas.Fill.Color := ACanvas.Pen.Color;
    ACanvas.FillPolygon(Pts, 1);
  finally
    ACanvas.Fill.Color := SavedColor;
    ACanvas.Fill.Kind := SavedKind;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

{ TVTFmxDragImage }

constructor TVTFmxDragImage.Create;
begin
  inherited;
  FOpacity:= 0.6;   // enough to read the row being carried, little enough to see through it
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TVTFmxDragImage.Destroy;
begin
  FreeAndNil(FBitmap);
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTFmxDragImage.SetBitmap(ABitmap: TBitmap; const ASize: TSizeF; const AOffset: TPointF);
begin
  Clear;
  if (ABitmap = nil) or (ABitmap.Width = 0) or (ABitmap.Height = 0) then
    Exit; //!!!

  // A copy, not the caller's object: the drag outlives the routine that built the image, and
  // an owner shared with a local variable is how a double free happens.
  FBitmap:= TBitmap.Create;
  FBitmap.Assign(ABitmap);
  FSize:= ASize;
  FOffset:= AOffset;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTFmxDragImage.Clear;
begin
  FreeAndNil(FBitmap);
  FSize:= TSizeF.Create(0, 0);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTFmxDragImage.Visible: Boolean;
begin
  Result:= Assigned(FBitmap) and (FSize.cx > 0) and (FSize.cy > 0);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTFmxDragImage.MoveTo(const APosition: TPointF);
begin
  FPosition:= APosition;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTFmxDragImage.PaintTo(ACanvas: TCanvas; const ABounds: TRectF);
var
  LDest: TRectF;
begin
  if not Visible then
    Exit; //!!!
  if ACanvas = nil then
    Exit; //!!!

  LDest:= RectF(FPosition.X + FOffset.X, FPosition.Y + FOffset.Y,
                FPosition.X + FOffset.X + FSize.cx, FPosition.Y + FOffset.Y + FSize.cy);

  // Kept whole and inside the control rather than clipped away at the edges: a finger near
  // the top of the screen would otherwise be carrying an invisible image.
  if LDest.Right > ABounds.Right then
    LDest.Offset(ABounds.Right - LDest.Right, 0);
  if LDest.Left < ABounds.Left then
    LDest.Offset(ABounds.Left - LDest.Left, 0);
  if LDest.Bottom > ABounds.Bottom then
    LDest.Offset(0, ABounds.Bottom - LDest.Bottom);
  if LDest.Top < ABounds.Top then
    LDest.Offset(0, ABounds.Top - LDest.Top);

  ACanvas.DrawBitmap(FBitmap, RectF(0, 0, FBitmap.Width, FBitmap.Height), LDest, FOpacity, False);
end;

//----------------------------------------------------------------------------------------------------------------------

{ TCanvasHelper }

procedure TCanvasHelper.Draw(const X, Y: Single; const Bitmap: TBitmap);
begin
  DrawBitmap(Bitmap
          , RectF(0, 0, Bitmap.Width, Bitmap.Height)
          , RectF(X, Y, X+Bitmap.Width, Y+ Bitmap.Height)
          , 1.0
          );
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCanvasHelper.DrawFocusRect(const AFocusRect: TRect);
begin
  // Half transparent gray dashes, the closest FMX equivalent of the VCL focus rectangle.
  DrawDashRect(AFocusRect, 0, 0, AllCorners, 1.0, $A0909090);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCanvasHelper.DrawRect(const ARect: TRectF);
begin
  DrawRect(ARect, 0, 0, [], 1.0);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCanvasHelper.FillRect(const ARect: TRectF);
begin
  FillRect(ARect, 0, 0, [], 1.0);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCanvasHelper.FrameRect(const AFocusRect: TRect);
begin
  DrawRect(AFocusRect);
end;

//----------------------------------------------------------------------------------------------------------------------

function TCanvasHelper.GetBrush: TBrush;
begin
  Result:= Fill;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCanvasHelper.GetPen: TStrokeBrush;
begin
  Result:= Stroke;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCanvasHelper.Polygon(const Points: TPolygon);
begin
  DrawPolygon(Points, 1.0);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCanvasHelper.RoundRect(const Rect: TRect; const XRadius, YRadius: Single);

// Vcl.Graphics.TCanvas.RoundRect fills with the brush and outlines with the pen, and the
// shared tree code sets both and calls this expecting exactly that. FMX.Graphics.TCanvas
// has no single call that does both, so it takes two here. Stroking only - which this did
// before - left every full row selection as an outline with the background showing through.

begin
  FillRect(Rect, XRadius, YRadius, allCorners, 1.0);
  DrawRect(Rect, XRadius, YRadius, allCorners, 1.0);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCanvasHelper.RoundRect(X1, Y1, X2, Y2: Single; const XRadius, YRadius: Single);
begin
  RoundRect(RectF(X1, Y1, X2, Y2), XRadius, YRadius);
end;


//----------------------------------------------------------------------------------------------------------------------

type
  TImageListHelper = class helper for TImageList
    function Add(aBitmap: TBitmap): integer;
  end;

function TImageListHelper.Add(aBitmap: TBitmap): integer;
const
  SCALE = 1;
var
  vSource: TCustomSourceItem;
  vBitmapItem: TCustomBitmapItem;
  vDest: TCustomDestinationItem;
  vLayer: TLayer;
begin
  Result := -1;
  if (aBitmap.Width = 0) or (aBitmap.Height = 0) then exit;

  // add source bitmap
  vSource := Source.Add;
  vSource.MultiResBitmap.TransparentColor := TColorRec.Fuchsia;
  vSource.MultiResBitmap.SizeKind := TSizeKind.Source;
  vSource.MultiResBitmap.Width := Round(aBitmap.Width / SCALE);
  vSource.MultiResBitmap.Height := Round(aBitmap.Height / SCALE);
  vBitmapItem := vSource.MultiResBitmap.ItemByScale(SCALE, True, True);
  if vBitmapItem = nil then
  begin
    vBitmapItem := vSource.MultiResBitmap.Add;
    vBitmapItem.Scale := Scale;
  end;
  vBitmapItem.Bitmap.Assign(aBitmap);

  vDest := Destination.Add;
  vLayer := vDest.Layers.Add;
  vLayer.SourceRect.Rect := TRectF.Create(TPoint.Zero, vSource.MultiResBitmap.Width,
      vSource.MultiResBitmap.Height);
  vLayer.Name := vSource.Name;
  Result := vDest.Index;
end;

//----------------------------------------------------------------------------------------------------------------------
// Scanline flood fill for an FMX bitmap, after
// https://stackoverflow.com/questions/22813461/is-there-an-equivalent-to-floodfill-in-fmx-for-a-tbitmap
// Currently unused: FillSystemCheckImages draws its glyphs on the bitmap canvas instead.
procedure Bitmap_FloodFill(fBitmap: TBitmap; StartX,StartY : Integer; FillColor: TAlphaColor);
var
  fBitmapData  : TBitmapData;
  X, Y         : Integer;
  ReplaceColor : TAlphaColor;
  Stack        : Array of System.Types.TPoint;
  fHeight      : Integer;
  fWidth       : Integer;

  procedure PutInStack(X, Y: Integer);
  begin
    SetLength(Stack, Length(Stack)+1);
    Stack[Length(Stack)-1] := System.Types.Point(X, Y);
  end;

  procedure GetFromStack(var X, Y: Integer);
  begin
    X := Stack[Length(Stack)-1].X;
    Y := Stack[Length(Stack)-1].Y;
    SetLength(Stack, Length(Stack)-1);
  end;

begin
  X := StartX;
  Y := StartY;
  fHeight := fBitmap.Height;
  fWidth  := fBitmap.Width;
  if (X >= fWidth) or (Y >= fHeight) then Exit;

  if fBitmap.Map(TMapAccess.ReadWrite,fBitmapData) then
  try
    ReplaceColor := fBitmapData.GetPixel(X,Y);
    if ReplaceColor <> FillColor then
    begin
      PutInStack(X,Y);
      while Length(Stack) > 0 do
      begin
        GetFromStack(X,Y);
        while (X >      0) and (fBitmapData.GetPixel(X-1, Y) = ReplaceColor) do System.Dec(X);
        while (X < fWidth) and (fBitmapData.GetPixel(X  , Y) = ReplaceColor) do
        begin
          if Y   >       0 then If fBitmapData.GetPixel(X, Y-1) = ReplaceColor then PutInStack(X, Y-1);
          if Y+1 < fHeight then If fBitmapData.GetPixel(X, Y+1) = ReplaceColor then PutInStack(X, Y+1);
          fBitmapData.SetPixel(X,Y,FillColor);
          System.Inc(X);
        end;
      end;
    end;
  finally
    fBitmap.Canvas.Bitmap.Unmap(fBitmapData);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

// Builds the tree's check image list by drawing every glyph on a bitmap canvas.
//
// The entries are added in the order of the ck* constants in VirtualTrees.Types (0..24) and
// that order is what the tree indexes by - do not reorder or drop any of them. All 25 are
// produced, the four ckButton* ones included, so a ctButton check type has an image too.
//
// Nothing is taken from the active FMX style. The same drawing runs on every target, so a
// check box looks the same everywhere and cannot come out blank
// because a platform style paints its glyph with a bitmap the tree never receives.
//
// The interior of every box and circle is opaque white, so a check box stays readable on a
// selected row, while the area outside the glyph is left transparent, so the row colour
// shows around it. The mixed state is a horizontal bar - the tri-state "some children are
// checked" mark - and is deliberately nothing like the tick.
//
// Every image is built before the list is touched: if a canvas cannot be opened, nothing is
// added and the list stays empty, which is what makes the caller (TBaseVirtualTree.Paint)
// try again on the next paint rather than keeping a set of blank squares for good.
//
// The images are 32x32; TCustomImageList scales them to CheckImageSize when the tree draws
// them. Parent is not used - it is kept because the abstract call site in
// TVTBaseAncestorFMX.CreateSystemImageSet passes the tree.
procedure FillSystemCheckImages(Parent: TFmxObject; List: TImageList);
const
  cImageSize   = 32;    // source edge length of every entry, in pixels
  cInset       = 2.5;   // keeps the border stroke inside the bitmap
  cBorderWidth = 2.0;
  cMarkWidth   = 4.0;
  cCorner      = 4.0;   // corner radius of the check box and of the button

  cBack        = TAlphaColorRec.White;      // interior of every box and circle
  cButtonFace  = TAlphaColor($FFE8E8E8);    // interior of the drop down button
  cBorder      = TAlphaColor($FF5A5A5A);    // an empty box, at rest
  cBorderHot   = TAlphaColor($FF303030);
  cAccent      = TAlphaColor($FF1B6FD4);    // a checked box: border and mark
  cAccentHot   = TAlphaColor($FF2E86E8);
  cPressed     = TAlphaColor($FF14508F);
  cDisabled    = TAlphaColor($FF9E9E9E);
type
  TGlyphShape = (gsBox, gsCircle, gsButton);
  TGlyphMark = (gmNone, gmTick, gmBar, gmDot, gmArrow);
  TGlyphDef = record
    Shape: TGlyphShape;
    Mark: TGlyphMark;
    BorderColor: TAlphaColor;
    MarkColor: TAlphaColor;
  end;
const
  // Index 0 is ckEmpty and is not in here - it is an empty bitmap, not a drawn glyph.
  cGlyphs: array [1 .. 24] of TGlyphDef = (
    // radio buttons, unchecked then checked (ckRadioUncheckedNormal .. ckRadioCheckedDisabled)
    (Shape: TGlyphShape.gsCircle; Mark: TGlyphMark.gmNone; BorderColor: cBorder;    MarkColor: cBorder),
    (Shape: TGlyphShape.gsCircle; Mark: TGlyphMark.gmNone; BorderColor: cBorderHot; MarkColor: cBorderHot),
    (Shape: TGlyphShape.gsCircle; Mark: TGlyphMark.gmNone; BorderColor: cPressed;   MarkColor: cPressed),
    (Shape: TGlyphShape.gsCircle; Mark: TGlyphMark.gmNone; BorderColor: cDisabled;  MarkColor: cDisabled),
    (Shape: TGlyphShape.gsCircle; Mark: TGlyphMark.gmDot;  BorderColor: cAccent;    MarkColor: cAccent),
    (Shape: TGlyphShape.gsCircle; Mark: TGlyphMark.gmDot;  BorderColor: cAccentHot; MarkColor: cAccentHot),
    (Shape: TGlyphShape.gsCircle; Mark: TGlyphMark.gmDot;  BorderColor: cPressed;   MarkColor: cPressed),
    (Shape: TGlyphShape.gsCircle; Mark: TGlyphMark.gmDot;  BorderColor: cDisabled;  MarkColor: cDisabled),
    // check boxes, unchecked (ckCheckUncheckedNormal .. ckCheckUncheckedDisabled)
    (Shape: TGlyphShape.gsBox;    Mark: TGlyphMark.gmNone; BorderColor: cBorder;    MarkColor: cBorder),
    (Shape: TGlyphShape.gsBox;    Mark: TGlyphMark.gmNone; BorderColor: cBorderHot; MarkColor: cBorderHot),
    (Shape: TGlyphShape.gsBox;    Mark: TGlyphMark.gmNone; BorderColor: cPressed;   MarkColor: cPressed),
    (Shape: TGlyphShape.gsBox;    Mark: TGlyphMark.gmNone; BorderColor: cDisabled;  MarkColor: cDisabled),
    // check boxes, checked (ckCheckCheckedNormal .. ckCheckCheckedDisabled)
    (Shape: TGlyphShape.gsBox;    Mark: TGlyphMark.gmTick; BorderColor: cAccent;    MarkColor: cAccent),
    (Shape: TGlyphShape.gsBox;    Mark: TGlyphMark.gmTick; BorderColor: cAccentHot; MarkColor: cAccentHot),
    (Shape: TGlyphShape.gsBox;    Mark: TGlyphMark.gmTick; BorderColor: cPressed;   MarkColor: cPressed),
    (Shape: TGlyphShape.gsBox;    Mark: TGlyphMark.gmTick; BorderColor: cDisabled;  MarkColor: cDisabled),
    // check boxes, mixed (ckCheckMixedNormal .. ckCheckMixedDisabled)
    (Shape: TGlyphShape.gsBox;    Mark: TGlyphMark.gmBar;  BorderColor: cAccent;    MarkColor: cAccent),
    (Shape: TGlyphShape.gsBox;    Mark: TGlyphMark.gmBar;  BorderColor: cAccentHot; MarkColor: cAccentHot),
    (Shape: TGlyphShape.gsBox;    Mark: TGlyphMark.gmBar;  BorderColor: cPressed;   MarkColor: cPressed),
    (Shape: TGlyphShape.gsBox;    Mark: TGlyphMark.gmBar;  BorderColor: cDisabled;  MarkColor: cDisabled),
    // drop down button (ckButtonNormal .. ckButtonDisabled)
    (Shape: TGlyphShape.gsButton; Mark: TGlyphMark.gmArrow; BorderColor: cBorder;    MarkColor: cBorder),
    (Shape: TGlyphShape.gsButton; Mark: TGlyphMark.gmArrow; BorderColor: cBorderHot; MarkColor: cBorderHot),
    (Shape: TGlyphShape.gsButton; Mark: TGlyphMark.gmArrow; BorderColor: cPressed;   MarkColor: cPressed),
    (Shape: TGlyphShape.gsButton; Mark: TGlyphMark.gmArrow; BorderColor: cDisabled;  MarkColor: cDisabled)
  );

var
  LGlyphs: array [0 .. 24] of TBitmap;
  I: Integer;
  LComplete: Boolean;

  // One glyph, or nil when the bitmap canvas cannot be opened.
  function MakeGlyph(const ADef: TGlyphDef): TBitmap;
  var
    LBmp: TBitmap;
    LBox: TRectF;
    LPath: TPathData;
  begin
    Result:= nil;
    LBmp:= TBitmap.Create(cImageSize, cImageSize);
    try
      // Transparent everywhere the glyph does not reach, and Clear has to come before
      // BeginScene - it can reset the scene count.
      LBmp.Clear(TAlphaColorRec.Null);
      if not LBmp.Canvas.BeginScene then
        begin
          FreeAndNil(LBmp);
          Exit; //!!!
        end;
      try
        LBox:= RectF(cInset, cInset, cImageSize - cInset, cImageSize - cInset);

        LBmp.Canvas.Fill.Kind:= TBrushKind.Solid;
        LBmp.Canvas.Stroke.Kind:= TBrushKind.Solid;
        LBmp.Canvas.Stroke.Cap:= TStrokeCap.Round;
        LBmp.Canvas.Stroke.Join:= TStrokeJoin.Round;
        LBmp.Canvas.Stroke.Thickness:= cBorderWidth;
        LBmp.Canvas.Stroke.Color:= ADef.BorderColor;

        if ADef.Shape = TGlyphShape.gsCircle then
          begin
            LBmp.Canvas.Fill.Color:= cBack;
            LBmp.Canvas.FillEllipse(LBox, 1.0);
            LBmp.Canvas.DrawEllipse(LBox, 1.0);
          end else
          begin
            // A path rather than FillRect/DrawRect: the TCanvasHelper in this unit
            // redeclares both of those names, which hides the canvas versions that take a
            // corner radius.
            LPath:= TPathData.Create;
            try
              LPath.AddRectangle(LBox, cCorner, cCorner, AllCorners);
              if ADef.Shape = TGlyphShape.gsButton then
                LBmp.Canvas.Fill.Color:= cButtonFace else
                LBmp.Canvas.Fill.Color:= cBack;
              LBmp.Canvas.FillPath(LPath, 1.0);
              LBmp.Canvas.DrawPath(LPath, 1.0);
            finally
              LPath.Free;
            end;
          end;

        LBmp.Canvas.Fill.Color:= ADef.MarkColor;
        LBmp.Canvas.Stroke.Color:= ADef.MarkColor;
        LBmp.Canvas.Stroke.Thickness:= cMarkWidth;

        case ADef.Mark of
          TGlyphMark.gmTick:
            begin
              // Two strokes with round caps and a round join: the short one down to the
              // corner, the long one up to the right.
              LBmp.Canvas.DrawLine(PointF(8, 16), PointF(13.5, 22), 1.0);
              LBmp.Canvas.DrawLine(PointF(13.5, 22), PointF(24, 10), 1.0);
            end;
          TGlyphMark.gmBar:
            LBmp.Canvas.DrawLine(PointF(9, cImageSize / 2), PointF(cImageSize - 9, cImageSize / 2), 1.0);
          TGlyphMark.gmDot:
            LBmp.Canvas.FillEllipse(RectF(10, 10, cImageSize - 10, cImageSize - 10), 1.0);
          TGlyphMark.gmArrow:
            // DrawArrow fills the triangle with the pen colour, which is Stroke.Color.
            DrawArrow(LBmp.Canvas, TScrollDirection.sdDown, PointF(8, 8), 16);
        end;
      finally
        LBmp.Canvas.EndScene;
      end;
      Result:= LBmp;
    except
      LBmp.Free;
      raise;
    end;
  end;

begin
  if List = nil then
    Exit; //!!!

  for I:= Low(LGlyphs) to High(LGlyphs) do
    LGlyphs[I]:= nil;

  try
    // ckEmpty: a place holder the tree draws for a node without a check type.
    LGlyphs[0]:= TBitmap.Create(cImageSize, cImageSize);
    LGlyphs[0].Clear(TAlphaColorRec.Null);

    for I:= Low(cGlyphs) to High(cGlyphs) do
      LGlyphs[I]:= MakeGlyph(cGlyphs[I]);

    LComplete:= True;
    for I:= Low(LGlyphs) to High(LGlyphs) do
      if LGlyphs[I] = nil then
        LComplete:= False;

    if LComplete then
      begin
        List.Destination.Clear;
        List.Source.Clear;
        for I:= Low(LGlyphs) to High(LGlyphs) do
          List.Add(LGlyphs[I]);
      end;
  finally
    for I:= Low(LGlyphs) to High(LGlyphs) do
      LGlyphs[I].Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure FillTWMMouse(Var MM: TWMMouse; Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single; IsNC: Boolean; IsUp: Boolean);
begin
  MM.Msg:= 0;
  if ssDouble in Shift then
    begin
      if ssLeft in Shift then
        begin
          if IsNC then
            MM.Msg:= WM_NCLBUTTONDBLCLK else
            MM.Msg:= WM_LBUTTONDBLCLK;
        end else
      if ssRight in Shift then
        begin
          if IsNC then
            MM.Msg:= WM_NCRBUTTONDBLCLK else
            MM.Msg:= WM_RBUTTONDBLCLK;
        end else
      if ssMiddle in Shift then
        begin
          if IsNC then
            MM.Msg:= WM_NCMBUTTONDBLCLK else
            MM.Msg:= WM_MBUTTONDBLCLK;
        end;
    end else
    begin
      if (ssLeft in Shift) or (Button=TMouseButton.mbLeft) then
        begin
          if IsUp then
            begin
              if IsNC then
                MM.Msg:= WM_NCLBUTTONUP else
                MM.Msg:= WM_LBUTTONUP;
            end else
            begin
              if IsNC then
                MM.Msg:= WM_NCLBUTTONDOWN else
                MM.Msg:= WM_LBUTTONDOWN;
            end;
        end else
      if (ssRight in Shift) or (Button=TMouseButton.mbRight) then
        begin
          if IsUp then
            begin
              if IsNC then
                MM.Msg:= WM_NCRBUTTONUP else
                MM.Msg:= WM_RBUTTONUP;
            end else
            begin
              if IsNC then
                MM.Msg:= WM_NCRBUTTONDOWN else
                MM.Msg:= WM_RBUTTONDOWN;
            end;

        end else
      if (ssMiddle in Shift) or (Button=TMouseButton.mbMiddle) then
        begin
          if IsUp then
            begin
              if IsNC then
                MM.Msg:= WM_NCMBUTTONUP else
                MM.Msg:= WM_MBUTTONUP;
            end else
            begin
              if IsNC then
                MM.Msg:= WM_NCMBUTTONDOWN else
                MM.Msg:= WM_MBUTTONDOWN;
            end;
        end;
    end;

  MM.XPos:= X;
  MM.YPos:= Y;
  MM.Keys:= LongInt(Word(Shift));
  MM.Result:= 0; // MM is an uninitialized local in the callers - do not propagate garbage.
end;

//----------------------------------------------------------------------------------------------------------------------

function TMessageToTWMMouse(const Source: TMessage): TWMMouse;
begin
  // Copy the common fields
  Result.Msg := Source.Msg;

  // Copy according to the specific active variant part
  Result.Keys := Source.tmp;
  Result.XPos := Source.WParam;
  Result.YPos := Source.LParam;
  Result.Result := Source.Result;
end;

//----------------------------------------------------------------------------------------------------------------------

function TMessageToTWMNCHitMessage(const Source: TMessage): TWMNCHitMessage;
begin
  // Copy the common fields
  Result.Msg := Source.Msg;

  // Copy according to the specific active variant part
  Result.HitTest := Source.tmp;
  Result.XCursor := NativeInt(Source.WParam); // WPARAM is unsigned - restore the sign
  Result.YCursor := Source.LParam;
  Result.Result := Source.Result;
end;

//----------------------------------------------------------------------------------------------------------------------

function TWMMouseToTMessage(const Source: TWMMouse): TMessage;
begin
  // Packing convention, shared with TMessageToTWMMouse and TMessageToTWMNCHitMessage:
  //   WParam = X  (XPos / XCursor)
  //   LParam = Y  (YPos / YCursor)
  //   tmp    = Keys / Shift  (HitTest in the NC variant)
  // WPARAM is unsigned (UINT_PTR), so X is routed through NativeInt to survive going
  // negative while the mouse is captured outside the control.
  Result.Msg := Source.Msg;
  Result.tmp := Source.Keys;
  Result.WParam := WPARAM(NativeInt(Round(Source.XPos)));
  Result.LParam := LPARAM(Round(Source.YPos));
  Result.Result := Source.Result;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure DrawTextW(ACanvas: TCanvas; CaptionText: String; Len: Integer; Var Bounds: TRect; DrawFormat: Cardinal{this is windows format - must be converted to FMX});

// Win32 DrawTextW stand-in. Honoured: horizontal and vertical alignment, RTL reading,
// DT_SINGLELINE, DT_WORDBREAK and DT_CALCRECT. Not honoured: the ellipsis flags - the tree
// shortens text itself through ShortenString - and DT_EXPANDTABS.
//
// DT_CALCRECT MEASURES AND DRAWS NOTHING, which is what the Win32 flag means and what
// TCustomVirtualStringTree.ComputeNodeHeight depends on. Bounds is updated in place: Left
// and Top are kept, the incoming width is the wrapping width, and Right/Bottom come back
// as the space the text needs. Before this the flag was ignored, so ComputeNodeHeight read
// Bottom - Top off a rect nothing had touched and every multiline node measured zero high -
// while the call painted the text it was only supposed to measure.
//
// The measurement goes through TTextLayout rather than the canvas, for two reasons that both
// matter: TCanvas.TextWidth/TextHeight cannot wrap, and FillText needs the canvas to be
// inside a BeginScene, which it is not when the tree measures a node outside a paint pass -
// MeasureItemHeight is reached from GetNodeHeight and from InitChildren as well as from
// PaintTree. A layout is built per call; a node is only measured while vsHeightMeasured is
// clear, so this runs once per node and not once per frame.

const
  cMaxLayoutExtent = 65535.0;   // Ceiling for an axis that is not being constrained.
Var
  hAlign: TTextAlign;
  vAlign: TTextAlign;
  Flags: TFillTextFlags;
  WordWrap: Boolean;
  S: string;
  Layout: TTextLayout;
  MaxWidth: Single;
begin
  S:= Copy(CaptionText, 1, Len);

  hAlign:= TTextAlign.Leading;
  if DrawFormat and DT_CENTER<>0 then
    hAlign:= TTextAlign.Center;
  if DrawFormat and DT_RIGHT<>0 then
    hAlign:= TTextAlign.Trailing;

  // DT_SINGLELINE outranks DT_WORDBREAK, the same way it does in Win32.
  WordWrap:= (DrawFormat and DT_WORDBREAK<>0) and (DrawFormat and DT_SINGLELINE=0);

  // DT_TOP is zero and cannot be tested. Wrapped text is the one case where the callers
  // always mean it - ComputeNodeHeight and PaintNormalText both pass DT_TOP for a multiline
  // node, and PaintNormalText has already centred the rect itself - so wrapping implies top
  // alignment here and everything else stays centred as before.
  if WordWrap then
    vAlign:= TTextAlign.Leading
  else
    vAlign:= TTextAlign.Center;
  if DrawFormat and DT_VCENTER<>0 then
    vAlign:= TTextAlign.Center;
  if DrawFormat and DT_BOTTOM<>0 then
    vAlign:= TTextAlign.Trailing;

  Flags:= [];

  if DrawFormat and DT_RTLREADING<>0 then
    Flags:= Flags + [TFillTextFlag.RightToLeft];

  if DrawFormat and DT_CALCRECT<>0 then
    begin
      MaxWidth:= Bounds.Right - Bounds.Left;
      // A cell too narrow for any text at all - a deeply indented node in a narrow column,
      // where the label offset has already eaten the whole width. Measuring unconstrained
      // gives one line rather than an infinite stack of one character each.
      if MaxWidth<=0 then
        MaxWidth:= cMaxLayoutExtent;

      Layout:= TTextLayoutManager.DefaultTextLayout.Create(ACanvas);
      try
        Layout.BeginUpdate;
        try
          // Measuring can be reached before the control has ever painted - GetNodeHeight
          // hands over TControl.Canvas, which is not necessarily there yet - so the font is
          // only taken when there is one. The layout then measures in its own default, which
          // is wrong but finite; an unguarded ACanvas.Font is an access violation.
          if Assigned(ACanvas) then
            Layout.Font:= ACanvas.Font;
          Layout.WordWrap:= WordWrap;
          Layout.Trimming:= TTextTrimming.None;
          // Measuring only - the alignment the caller asked for moves the text inside the
          // box but does not change how much room it needs.
          Layout.HorizontalAlign:= TTextAlign.Leading;
          Layout.VerticalAlign:= TTextAlign.Leading;
          if WordWrap then
            Layout.MaxSize:= TPointF.Create(MaxWidth, cMaxLayoutExtent)
          else
            Layout.MaxSize:= TPointF.Create(cMaxLayoutExtent, cMaxLayoutExtent);
          Layout.Text:= S;
        finally
          Layout.EndUpdate;
        end;

        Bounds.Right:= Bounds.Left + Layout.TextWidth;
        Bounds.Bottom:= Bounds.Top + Layout.TextHeight;
      finally
        Layout.Free;
      end;
      Exit; //!!! measured, nothing drawn
    end;

  ACanvas.FillText(Bounds, S, WordWrap, 1.0, Flags, hAlign, vAlign);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure DrawEdge(Canvas: TCanvas; R: TRect; edge, grfFlags: Cardinal);
Var tmpR: TRect;
  IsSoft, IsFlat, IsMono: Boolean;
begin

  if grfFlags and BF_SOFT<>0 then
    IsSoft:= true else
    IsSoft:= false;

  if grfFlags and BF_FLAT<>0 then
    IsFlat:= true else
    IsFlat:= false;

  if grfFlags and BF_MONO<>0 then
    IsMono:= true else
    IsMono:= false;

  if grfFlags and BF_MIDDLE<>0 then
    begin
      Canvas.Fill.Color:= clBtnFace;
      Canvas.FillRect(R, 0, 0, [], 1.0);
    end;
  tmpR:= R;
  if grfFlags and BF_LEFT<>0 then
    begin
      tmpR:= R;

      if edge and BDR_RAISEDOUTER<>0 then
        begin
          if isSoft then
            begin
              Canvas.Stroke.Color:= TColors.White;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Left, tmpR.Bottom), 1.0);
            end else
          if IsFlat then
            begin
              Canvas.Stroke.Color:= $FFA0A0A0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Left, tmpR.Bottom), 1.0);
            end else
          if isMono then
            begin
              Canvas.Stroke.Color:= $FF646464;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Left, tmpR.Bottom), 1.0);
            end else
            begin
              Canvas.Stroke.Color:= $FFE3E3E3;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Left, tmpR.Bottom), 1.0);
            end;
          InflateRect(tmpR, -1, -1)
        end;

      if edge and BDR_SUNKENOUTER<>0 then
        begin
          if isSoft then
            begin
              Canvas.Stroke.Color:= $FF696969;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Left, tmpR.Bottom), 1.0);
            end else
          if IsFlat then
            begin
              Canvas.Stroke.Color:= $FFA0A0A0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Left, tmpR.Bottom), 1.0);
            end else
          if isMono then
            begin
              Canvas.Stroke.Color:= $FF646464;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Left, tmpR.Bottom), 1.0);
            end else
            begin
              Canvas.Stroke.Color:= $FFA0A0A0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Left, tmpR.Bottom), 1.0);
            end;
          InflateRect(tmpR, -1, -1)
        end;

      if edge and BDR_RAISEDINNER<>0 then
        begin
          if isSoft then
            begin
              Canvas.Stroke.Color:= $FFE3E3E3;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Left, tmpR.Bottom), 1.0);
            end else
          if IsFlat then
            begin
              Canvas.Stroke.Color:= $FFF0F0F0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Left, tmpR.Bottom), 1.0);
            end else
          if isMono then
            begin
              Canvas.Stroke.Color:= TAlphaColorRec.White;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Left, tmpR.Bottom), 1.0);
            end else
            begin
              Canvas.Stroke.Color:= TAlphaColorRec.White;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Left, tmpR.Bottom), 1.0);
            end;
        end;

      if edge and BDR_SUNKENINNER<>0 then
        begin
          if isSoft then
            begin
              Canvas.Stroke.Color:= $FFA0A0A0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Left, tmpR.Bottom), 1.0);
            end else
          if IsFlat then
            begin
              Canvas.Stroke.Color:= $FFF0F0F0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Left, tmpR.Bottom), 1.0);
            end else
          if isMono then
            begin
              Canvas.Stroke.Color:= TAlphaColorRec.White;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Left, tmpR.Bottom), 1.0);
            end else
            begin
              Canvas.Stroke.Color:= $FF696969;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Left, tmpR.Bottom), 1.0);
            end;
        end;
    end;

  if grfFlags and BF_TOP<>0 then
    begin
      tmpR:= R;

      if edge and BDR_RAISEDOUTER<>0 then
        begin
          if isSoft then
            begin
              Canvas.Stroke.Color:= TAlphaColorRec.White;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Top), 1.0);
            end else
          if IsFlat then
            begin
              Canvas.Stroke.Color:= $FFA0A0A0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Top), 1.0);
            end else
          if isMono then
            begin
              Canvas.Stroke.Color:= $FF646464;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Top), 1.0);
            end else
            begin
              Canvas.Stroke.Color:= $FFE3E3E3;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Top), 1.0);
            end;
          InflateRect(tmpR, -1, -1)
        end;

      if edge and BDR_SUNKENOUTER<>0 then
        begin
          if isSoft then
            begin
              Canvas.Stroke.Color:= $FF696969;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Top), 1.0);
            end else
          if IsFlat then
            begin
              Canvas.Stroke.Color:= $FFA0A0A0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Top), 1.0);
            end else
          if isMono then
            begin
              Canvas.Stroke.Color:= $FF646464;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Top), 1.0);
            end else
            begin
              Canvas.Stroke.Color:= $FFA0A0A0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Top), 1.0);
            end;
          InflateRect(tmpR, -1, -1)
        end;

      if edge and BDR_RAISEDINNER<>0 then
        begin
          if isSoft then
            begin
              Canvas.Stroke.Color:= $FFE3E3E3;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Top), 1.0);
            end else
          if IsFlat then
            begin
              Canvas.Stroke.Color:= $FFF0F0F0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Top), 1.0);
            end else
          if isMono then
            begin
              Canvas.Stroke.Color:= TAlphaColorRec.White;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Top), 1.0);
            end else
            begin
              Canvas.Stroke.Color:= TAlphaColorRec.White;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Top), 1.0);
            end;
        end;

      if edge and BDR_SUNKENINNER<>0 then
        begin
          if isSoft then
            begin
              Canvas.Stroke.Color:= $FFA0A0A0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Top), 1.0);
            end else
          if IsFlat then
            begin
              Canvas.Stroke.Color:= $FFF0F0F0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Top), 1.0);
            end else
          if isMono then
            begin
              Canvas.Stroke.Color:= TAlphaColorRec.White;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Top), 1.0);
            end else
            begin
              Canvas.Stroke.Color:= $FF696969;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Top), 1.0);
            end;
        end;


    end;

  if grfFlags and BF_RIGHT<>0 then
    begin
      tmpR:= R;
      if edge and BDR_RAISEDOUTER<>0 then
        begin
          if isSoft then
            begin
              Canvas.Stroke.Color:= $FF696969;
              Canvas.DrawLine(TPoint.Create(tmpR.Right-1, tmpR.Top), TPoint.Create(tmpR.Right-1, tmpR.Bottom), 1.0);
            end else
          if IsFlat then
            begin
              Canvas.Stroke.Color:= $FFA0A0A0;
              Canvas.DrawLine(TPoint.Create(tmpR.Right-1, tmpR.Top), TPoint.Create(tmpR.Right-1, tmpR.Bottom), 1.0);
            end else
          if isMono then
            begin
              Canvas.Stroke.Color:= $FF646464;
              Canvas.DrawLine(TPoint.Create(tmpR.Right-1, tmpR.Top), TPoint.Create(tmpR.Right-1, tmpR.Bottom), 1.0);
            end else
            begin
              Canvas.Stroke.Color:= $FF696969;
              Canvas.DrawLine(TPoint.Create(tmpR.Right-1, tmpR.Top), TPoint.Create(tmpR.Right-1, tmpR.Bottom), 1.0);
            end;
          InflateRect(tmpR, -1, -1)
        end;

      if edge and BDR_SUNKENOUTER<>0 then
        begin
          if isSoft then
            begin
              Canvas.Stroke.Color:= TAlphaColorRec.White;
              Canvas.DrawLine(TPoint.Create(tmpR.Right-1, tmpR.Top), TPoint.Create(tmpR.Right-1, tmpR.Bottom), 1.0);
            end else
          if IsFlat then
            begin
              Canvas.Stroke.Color:= $FFA0A0A0;
              Canvas.DrawLine(TPoint.Create(tmpR.Right-1, tmpR.Top), TPoint.Create(tmpR.Right-1, tmpR.Bottom), 1.0);
            end else
          if isMono then
            begin
              Canvas.Stroke.Color:= $FF646464;
              Canvas.DrawLine(TPoint.Create(tmpR.Right-1, tmpR.Top), TPoint.Create(tmpR.Right-1, tmpR.Bottom), 1.0);
            end else
            begin
              Canvas.Stroke.Color:= TAlphaColorRec.White;
              Canvas.DrawLine(TPoint.Create(tmpR.Right-1, tmpR.Top), TPoint.Create(tmpR.Right-1, tmpR.Bottom), 1.0);
            end;
          InflateRect(tmpR, -1, -1)
        end;

      tmpR.Right := tmpR.Right - 1;

      if edge and BDR_RAISEDINNER<>0 then
        begin
          if isSoft then
            begin
              Canvas.Stroke.Color:= $FFA0A0A0;
              Canvas.DrawLine(TPoint.Create(tmpR.Right, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
          if IsFlat then
            begin
              Canvas.Stroke.Color:= $FFF0F0F0;
              Canvas.DrawLine(TPoint.Create(tmpR.Right, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
          if isMono then
            begin
              Canvas.Stroke.Color:= TAlphaColorRec.White;
              Canvas.DrawLine(TPoint.Create(tmpR.Right, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
            begin
              Canvas.Stroke.Color:= $FFA0A0A0;
              Canvas.DrawLine(TPoint.Create(tmpR.Right, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end;
        end;

      if edge and BDR_SUNKENINNER<>0 then
        begin
          if isSoft then
            begin
              Canvas.Stroke.Color:= $FFE3E3E3;
              Canvas.DrawLine(TPoint.Create(tmpR.Right, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
          if IsFlat then
            begin
              Canvas.Stroke.Color:= $FFE3E3E3;
              Canvas.DrawLine(TPoint.Create(tmpR.Right, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
          if isMono then
            begin
              Canvas.Stroke.Color:= TAlphaColorRec.White;
              Canvas.DrawLine(TPoint.Create(tmpR.Right, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
            begin
              Canvas.Stroke.Color:= $FFE3E3E3;
              Canvas.DrawLine(TPoint.Create(tmpR.Right, tmpR.Top), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end;
        end;
    end;

  if grfFlags and BF_BOTTOM<>0 then
    begin
      tmpR:= R;
      tmpR.Bottom := tmpR.Bottom - 1;
      if edge and BDR_RAISEDOUTER<>0 then
        begin
          if isSoft then
            begin
              Canvas.Stroke.Color:= $FF696969;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Bottom), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
          if IsFlat then
            begin
              Canvas.Stroke.Color:= $FFA0A0A0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Bottom), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
          if isMono then
            begin
              Canvas.Stroke.Color:= $FF646464;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Bottom), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
            begin
              Canvas.Stroke.Color:= $FF696969;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Bottom), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end;
          InflateRect(tmpR, -1, -1)
        end;

      if edge and BDR_SUNKENOUTER<>0 then
        begin
          if isSoft then
            begin
              Canvas.Stroke.Color:= TAlphaColorRec.White;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Bottom), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
          if IsFlat then
            begin
              Canvas.Stroke.Color:= $FFA0A0A0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Bottom), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
          if isMono then
            begin
              Canvas.Stroke.Color:= $FF646464;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Bottom), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
            begin
              Canvas.Stroke.Color:= TAlphaColorRec.White;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Bottom), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end;
          InflateRect(tmpR, -1, -1)
        end;

      if edge and BDR_RAISEDINNER<>0 then
        begin
          if isSoft then
            begin
              Canvas.Stroke.Color:= $FFA0A0A0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Bottom), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
          if IsFlat then
            begin
              Canvas.Stroke.Color:= $FFF0F0F0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Bottom), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
          if isMono then
            begin
              Canvas.Stroke.Color:= TAlphaColorRec.White;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Bottom), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
            begin
              Canvas.Stroke.Color:= $FFA0A0A0;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Bottom), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end;
        end;

      if edge and BDR_SUNKENINNER<>0 then
        begin
          if isSoft then
            begin
              Canvas.Stroke.Color:= $FFE3E3E3;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Bottom), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
          if IsFlat then
            begin
              Canvas.Stroke.Color:= $FFE3E3E3;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Bottom), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
          if isMono then
            begin
              Canvas.Stroke.Color:= $FFE3E3E3;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Bottom), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end else
            begin
              Canvas.Stroke.Color:= $FFE3E3E3;
              Canvas.DrawLine(TPoint.Create(tmpR.Left, tmpR.Bottom), TPoint.Create(tmpR.Right, tmpR.Bottom), 1.0);
            end;
        end;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure GetTextExtentPoint32W(ACanvas: TCanvas; CaptionText: String; Len: Integer; Var Size: TSize);
begin
  Size.cx:= ACanvas.TextWidth(Copy(CaptionText, 1, Len));
  Size.cy:= ACanvas.TextHeight(Copy(CaptionText, 1, Len));
end;

//----------------------------------------------------------------------------------------------------------------------

procedure GetTextMetrics(ACanvas: TCanvas; var TM: TTextMetric);
// Fills in what the tree actually reads - height, ascent, descent and the two character
// widths - by measuring glyph outlines, since FMX exposes no font metrics. Everything else
// is zeroed rather than guessed.
// TODO: the ascent and internal leading below are differences against tmHeight and come out
// negative; only tmHeight is currently trustworthy.
Var P: TPathData;
  tx: TTextLayout;
  R: TRectF;
begin
  TM.tmExternalLeading:= 0;
  TM.tmWeight:= 0; //boldness???
  TM.tmOverhang:= 0;
  TM.tmDigitizedAspectX:= 0;
  TM.tmDigitizedAspectY:= 0;
  TM.tmFirstChar:= 'a'; //???
  TM.tmLastChar:= 'z'; //???
  TM.tmDefaultChar:= ' ';
  TM.tmBreakChar:= ' ';
  TM.tmItalic:= 0;
  TM.tmUnderlined:= 0;
  TM.tmStruckOut:= 0;
  TM.tmPitchAndFamily:= 0;
  TM.tmCharSet:= 0;

  tx:= TTextLayoutManager.DefaultTextLayout.Create(ACanvas);
  P:= TPathData.Create;
  try
    tx.Text:= 'W';
    tx.ConvertToPath(p);
    R:= P.GetBounds();

    TM.tmHeight:= R.Height;
    TM.tmMaxCharWidth:= R.Width;

    //------------------------------------
    tx.Text:= 'Ó';
    p.Clear;
    tx.ConvertToPath(p);
    R:= P.GetBounds();
    TM.tmInternalLeading:= R.Height - TM.tmHeight;

    //------------------------------------
    tx.Text:= 'x';
    p.Clear;
    tx.ConvertToPath(p);
    R:= P.GetBounds();
    TM.tmAscent:= R.Height - TM.tmHeight;
    TM.tmAveCharWidth:= R.Width;

    //------------------------------------
    tx.Text:= 'y';
    p.Clear;
    tx.ConvertToPath(p);
    TM.tmDescent:= P.GetBounds().Height - R.Height;
    TM.tmHeight:= TM.tmHeight + TM.tmDescent;
  finally
    FreeAndNil(P);
    FreeAndNil(tx);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure FillMemory(Destination: Pointer; Length: NativeUInt; Fill: Byte);
begin
  FillChar(Destination^, Length, Fill);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ZeroMemory(Destination: Pointer; Length: NativeUInt);
begin
  FillChar(Destination^, Length, 0);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure MoveMemory(Destination: Pointer; Source: Pointer; Length: NativeUInt);
begin
  Move(Source^, Destination^, Length);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure CopyMemory(Destination: Pointer; Source: Pointer; Length: NativeUInt);
begin
  Move(Source^, Destination^, Length);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ChangeBiDiModeAlignment(var Alignment: TAlignment);
begin
  case Alignment of
    taLeftJustify:  Alignment := taRightJustify;
    taRightJustify: Alignment := taLeftJustify;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure OleUninitialize();
begin
 //nothing
end;

//----------------------------------------------------------------------------------------------------------------------

function timeGetTime: Int64;
begin
  Result:= TThread.GetTickCount;
end;

{ TChangeLink }

//----------------------------------------------------------------------------------------------------------------------

constructor TChangeLink.Create;
begin
  inherited;
  IgnoreIndex := True;
  IgnoreImages := True;
end;

//----------------------------------------------------------------------------------------------------------------------

function TChangeLink.GetSender: TCustomImageList;
begin
  Result := TCustomImageList(Images);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TChangeLink.SetSender(const Value: TCustomImageList);
begin
  Images := TBaseImageList(Value);
end;

{ THighQualityBitmap }

// Placeholder: currently nothing beyond TBitmap. It exists as the single place to switch
// the tree's internal bitmaps to a higher quality setup.
constructor THighQualityBitmap.Create;
begin
  inherited;
end;

{ TFontHelper }

function TFontHelper.GetOnChange: TNotifyEvent;
begin
  Result:= OnChanged;
end;

procedure TFontHelper.SetOnChange(const Value: TNotifyEvent);
begin
  OnChanged:= Value;
end;

end.
