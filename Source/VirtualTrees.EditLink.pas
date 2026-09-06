unit VirtualTrees.EditLink;

// Base class for inplace node editors implementing IVTEditLink interface
// and default node editor.

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
  , System.UITypes         // vkReturn / vkEscape / TShiftState
  , FMX.Controls
  , FMX.StdCtrls
  , FMX.Edit
  , FMX.Types
  , VirtualTrees
  , VirtualTrees.Types
  , VirtualTrees.BaseTree
  , VirtualTrees.FMX
  ;
{$ELSE}
uses
    WinApi.Messages
  , System.Types
  , System.Classes
  , Vcl.Controls
  , Vcl.StdCtrls
  , VirtualTrees
  , VirtualTrees.Types
  , VirtualTrees.BaseTree
  ;
{$ENDIF}

type
  // Edit support Classes.
  TStringEditLink = class;

  TBaseEditLink = class;

  TVTEdit = class(TCustomEdit)
  private
{$IFDEF VT_VCL}
    procedure CMAutoAdjust(var Message: TMessage); message CM_AUTOADJUST;
    procedure CMExit(var Message: TMessage); message CM_EXIT;
    procedure CMRelease(var Message: TMessage); message CM_RELEASE;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure WMDestroy(var Message: TWMDestroy); message WM_DESTROY;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
{$ENDIF}
  protected
    FRefLink: IVTEditLink;
    FLink: TBaseEditLink;
    procedure AutoAdjustSize; virtual;
{$IFDEF VT_VCL}
    function CalcMinHeight: Integer; virtual;
    procedure CreateParams(var Params: TCreateParams); override;
    function GetTextSize: TSize; virtual;
    procedure KeyPress(var Key : Char); override;
{$ENDIF}
{$IFDEF VT_FMX}
    // FMX has no CM_EXIT / WM_KEYDOWN, so the behaviour those carried in the VCL
    // has to be hung on the corresponding FMX virtual methods instead.
    procedure DoExit; override;
    procedure KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState); override;
    procedure Paint; override;
{$ENDIF}
  public
    constructor Create(Link: TBaseEditLink); reintroduce;
    procedure ClearLink;
    procedure ClearRefLink;
{$IFDEF VT_VCL}
    procedure Release; virtual;

    property AutoSelect;
    property AutoSize;
    property BorderStyle;
{$ENDIF}
    property CharCase;
{$IFDEF VT_VCL}
    property HideSelection;
    property MaxLength;
    property OEMConvert;
    property PasswordChar;
{$ENDIF}
{$IFDEF VT_FMX}
    property Password;
{$ENDIF}
  end;

  TEditLinkEditEvent = procedure (Sender: TBaseEditLink; var Result: Boolean) of object;
  TEditLinkPrepareEditEvent = procedure (Sender: TBaseEditLink; var Edit: TControl; var Result: Boolean) of object;

  // Most abstract base class for implementing IVTEditLink.
  // Knows almost nothing about associated Edit control and doesn't perform any
  // actions on it. Contains some properties that are not used directly but could
  // be useful in descendant classes. Follows general extension approach - all
  // IVTEditLink methods are virtual and most of them call DoXXX virtual methods
  // which in turn call event handlers so these extension options possible:
  //   - overriding main API methods to run additional actions before, after or
  //     instead of basic class code.
  //     (+) Lesser modification of existing classes
  //     (-) Event handlers are already launched after calling parent method
  //     (-) It's critical to check Result of parent method and exit immediately
  //       on False - this value means no action is done.
  //     (-) Returning Result is necessary
  //   - overriding DoXXX methods to run additional actions inside basic class code
  //     (+) No need in returning - lesser boilerplate code
  //     (-) Should call inherited to launch event handlers (OK if not using them)
  //   - assign event handlers in end-user code
  //     (+) Access to external classes with data to copy to EditLink editor.
  //     (-) Lesser encapsulation
  TBaseEditLink = class(TInterfacedObject, IVTEditLink)
  strict protected
    FEdit: TControl;                          // One of the property editor classes.
    FTree : TCustomVirtualStringTree;         //A back reference to the tree calling.
    FNode : PVirtualNode;                     //The node to be edited.
    FColumn : TColumnIndex;                   //The column of the node.
    FStopping : Boolean;                      //Set to True when the edit link requests stopping the edit action.
    FAlignment : TAlignment;
    FBiDiMode: TBiDiMode;
    FMultiline : Boolean;                     //See the Multiline property.
								
    // custom event handlers
    FOnPrepareEdit: TEditLinkPrepareEditEvent;
    FOnBeginEdit,
    FOnEndEdit,
    FOnCancelEdit: TEditLinkEditEvent;

    procedure SetEdit(const Value : TControl); //Setter for the FEdit member;
  public
    // IVTEditLink API
    function BeginEdit : Boolean; virtual; stdcall;
    function CancelEdit : Boolean; virtual; stdcall;
    function EndEdit : Boolean; virtual; stdcall;
    function GetBounds : TRect; virtual; stdcall; abstract;
    function PrepareEdit(Tree : TBaseVirtualTree; Node : PVirtualNode; Column : TColumnIndex) : Boolean; virtual; stdcall;	
{$IFDEF VT_VCL}															
    procedure ProcessMessage(var Message: TMessage); virtual; stdcall; abstract;
{$ENDIF}
    procedure SetBounds(R : TRect); virtual; stdcall; abstract;

    // Methods to plug custom actions into main ones. In base class only call event handlers.
    // Descendants may modify Result to cancel further flow.
    procedure DoBeginEdit(var Result: Boolean); virtual;
    procedure DoCancelEdit(var Result: Boolean); virtual;
    procedure DoEndEdit(var Result: Boolean); virtual;
    procedure DoPrepareEdit(var Result: Boolean); virtual;

    property Alignment : TAlignment read FAlignment;
    property BiDiMode: TBiDiMode read FBiDiMode;
    /// <summary>
    /// False, the default - the editor is one line: Return ends the edit, Escape cancels it,
    /// and Up and Down move the caret within the line.
    ///
    /// True - the editor takes as many lines as the row is tall: Return inserts a line break
    /// and Ctrl+Return ends the edit.
    ///
    /// Deliberately not tied to vsMultiline. A caption that WRAPS when it is displayed is
    /// still one line of text to type, and a Return that does not finish the edit is the
    /// surprise. The default also makes the two frameworks behave alike, because an FMX
    /// TEdit has one line and nothing else to offer.
    ///
    /// In effect on VCL only - the FMX editor is a single line control. An application that
    /// wants a multi line editor creates the link itself in OnCreateEditor:
    ///
    ///   var L: TStringEditLink;
    ///   begin
    ///     L := TStringEditLink.Create;
    ///     L.Multiline := True;
    ///     EditLink := L;
    ///   end;
    /// </summary>
    property Multiline : Boolean read FMultiline write FMultiline;
    property Column : TColumnIndex read FColumn; // The column being edited.
    property Node : PVirtualNode read FNode;     // The node being edited.
    property Tree : TCustomVirtualStringTree read FTree;
    property Stopping : Boolean read FStopping;

    property OnBeginEdit: TEditLinkEditEvent read FOnBeginEdit write FOnBeginEdit;
    property OnCancelEdit: TEditLinkEditEvent read FOnCancelEdit write FOnCancelEdit;
    property OnEndEdit: TEditLinkEditEvent read FOnEndEdit write FOnEndEdit;
    property OnPrepareEdit: TEditLinkPrepareEditEvent read FOnPrepareEdit write FOnPrepareEdit;
  end;
  
  // Edit link that has TWinControl-based Edit. Performs visibility and focus actions,
  // transfers window messages to Edit control.
{$IFDEF VT_VCL}
  TWinControlEditLink = class(TBaseEditLink)
  protected
    function GetEdit: TWinControl;                //Getter for the FEdit member;
    procedure SetEdit(const Value : TWinControl); //Setter for the FEdit member;
  public
    destructor Destroy; override;

    function BeginEdit : Boolean; override; stdcall;
    function CancelEdit : Boolean; override; stdcall;
    function EndEdit : Boolean; override; stdcall;
    function GetBounds : TRect; override; stdcall;

    procedure ProcessMessage(var Message : TMessage); override; stdcall;

    property Edit : TWinControl read GetEdit write SetEdit;
  end;
{$ENDIF}

{$IFDEF VT_VCL}
  // Edit link that implements default node text editor.
  TStringEditLink = class(TWinControlEditLink)
  protected
    FTextBounds : TRect;                      //Smallest rectangle around the text.
    function GetEdit: TVTEdit;                //Getter for the FEdit member;
    procedure SetEdit(const Value : TVTEdit); //Setter for the FEdit member;
  public
    constructor Create;

    function BeginEdit : Boolean; override; stdcall;
    function CancelEdit : Boolean; override; stdcall;
    function EndEdit : Boolean; override; stdcall;
    function PrepareEdit(Tree : TBaseVirtualTree; Node : PVirtualNode; Column : TColumnIndex) : Boolean; override; stdcall;
    procedure SetBounds(R : TRect); override; stdcall;

    property Edit : TVTEdit read GetEdit write SetEdit;
  end;
{$ENDIF}

{$IFDEF VT_FMX}
  // Default node text editor for FMX. TBaseEditLink already carries Tree/Node/Column,
  // the alignment and bidi mode, the FStopping flag and the DoXXX hooks, so only the two
  // abstract bounds methods plus the edit lifecycle are added here. There is deliberately
  // no TWinControlEditLink equivalent: that split exists in the VCL only because a
  // TWinControl can be focused and a TControl cannot, which is not a distinction FMX makes.
  TStringEditLink = class(TBaseEditLink)
  strict protected
    function GetEdit: TVTEdit;
  public
    destructor Destroy; override;

    function BeginEdit : Boolean; override; stdcall;
    function CancelEdit : Boolean; override; stdcall;
    function EndEdit : Boolean; override; stdcall;
    function GetBounds : TRect; override; stdcall;
    function PrepareEdit(Tree : TBaseVirtualTree; Node : PVirtualNode; Column : TColumnIndex) : Boolean; override; stdcall;
    procedure SetBounds(R : TRect); override; stdcall;

    property Edit : TVTEdit read GetEdit;
  end;
{$ENDIF}

implementation
{$IFDEF VT_FMX}
uses
    System.SysUtils
  , System.Math
  , FMX.Graphics
  , FMX.Forms;
{$ELSE}
uses
    WinApi.Windows
  , System.SysUtils
  , System.Math
  , Vcl.Graphics
  , Vcl.Forms;
{$ENDIF}
  
const
  cMinEditWidth = 30;   // Narrowest usable editor, in logical pixels.
  // Stretch the FMX editor across the whole column rather than sitting on the text rect.
  // Set to False to get the VCL's text-width behaviour back.
  cEditFillsColumn = True;
  // Select the existing text when the editor opens, so typing replaces it - the VCL's
  // AutoSelect. FMX moves the caret to the end of the selection and scrolls the view to
  // the caret, so with text wider than the editor the START of the string ends up
  // off-screen. Set to False to open with the caret at position 0 and no selection.
  cSelectAllOnEdit = True;

{$IFDEF VT_FMX}
const
  // A TCustomEdit paints nothing of its own - everything visible comes from the style,
  // and on Android the styled edit's background rectangle is frequently absent, so the
  // row underneath shows straight through the editor. TVTEdit.Paint lays these down
  // instead. The text colour has to be pinned along with the background: left to the
  // style, a dark theme writes light text, which on a light background is invisible.
  cEditBackColor   = TAlphaColors.White;
  cEditTextColor   = TAlphaColors.Black;
  cEditBorderColor = TAlphaColors.Gray;
{$ENDIF}

type
  TCustomVirtualStringTreeCracker = class(TCustomVirtualStringTree);

//----------------- TVTEdit --------------------------------------------------------------------------------------------

// Implementation of a generic node caption editor.

constructor TVTEdit.Create(Link : TBaseEditLink);

begin
  inherited Create(nil);
  if not Assigned(Link) then
    raise EArgumentException.Create('Parameter Link must not be nil.');
  ShowHint := False;
  ParentShowHint := False;
  // This assignment increases the reference count for the interface.
  FRefLink := Link;
  // This reference is used to access the link.
  FLink := Link;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.ClearLink;
begin
  FLink := nil
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.ClearRefLink;

// Drops the interface reference the constructor took. TStringEditLink holds the edit and
// the edit holds the link, so without this the pair keeps each other alive and the link
// destructor never runs. The VCL broke the cycle from WMDestroy / Release; on FMX the
// link calls this itself when it stops.

begin
  FRefLink := nil
end;

//----------------------------------------------------------------------------------------------------------------------
{$IFDEF VT_VCL}
function TVTEdit.CalcMinHeight : Integer;
var
  textHeight : Integer;
begin
  // Get the actual text height.
  textHeight := GetTextSize.cy;
  // The minimal height is the actual text height in pixels plus the the non client area.
  Result := textHeight + (Height - ClientHeight);
  // Also, proportionally to the text size, additional pixel(s) needs to be added for the caret.
  Result := Result + Trunc(textHeight * 0.05);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.CMAutoAdjust(var Message: TMessage);
begin
  AutoAdjustSize;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.CMExit(var Message: TMessage);
begin
  if Assigned(FLink) and not FLink.Stopping then
    with TCustomVirtualStringTreeCracker(FLink.Tree) do
    begin
      if (toAutoAcceptEditChange in TreeOptions.StringOptions) then
        DoEndEdit
      else
        DoCancelEdit;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.CMRelease(var Message: TMessage);
begin
  Free;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.CNCommand(var Message: TWMCommand);
begin
  if Assigned(FLink) and Assigned(FLink.Tree) and (Message.NotifyCode = EN_UPDATE) and not FLink.Multiline then
    // Instead directly calling AutoAdjustSize it is necessary on Win9x/Me to decouple this notification message
    // and eventual resizing. Hence we use a message to accomplish that.
    AutoAdjustSize()
  else
    inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.WMChar(var Message: TWMChar);
begin
  if not (Message.CharCode in [VK_ESCAPE, VK_TAB]) then
    inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.WMDestroy(var Message: TWMDestroy);
begin
  // Editing stopped by other means than accept or cancel: drop both references to the link, so
  // that nothing can call back into an edit control that is on its way out.
  if Assigned(FLink) and not FLink.Stopping and not (csRecreating in Self.ControlState) then
  begin
    FLink := nil;
    FRefLink := nil;
  end;

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;

  Message.Result := Message.Result or DLGC_WANTALLKEYS or DLGC_WANTTAB or DLGC_WANTARROWS;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.WMKeyDown(var Message: TWMKeyDown);
// Handles some control keys.

var
  Shift: TShiftState;
  EndEdit: Boolean;
  Tree: TBaseVirtualTree;
  NextNode: PVirtualNode;
  ColumnCandidate: Integer;
  EditOptions: TVTEditOptions;
  Column: TVirtualTreeColumn;
begin
  Tree := FLink.Tree;
  case Message.CharCode of
    VK_ESCAPE:
      begin
        TCustomVirtualStringTreeCracker(Tree).DoCancelEdit;
      end;
    VK_RETURN:
      begin
        EndEdit := not FLink.Multiline;
        if not EndEdit then
        begin
          //In a multiline editor finish editing only if Ctrl+Enter was pressed,
          //otherwise allow to insert line breaks into the text.
          Shift := KeyDataToShiftState(Message.KeyData);
          EndEdit := ssCtrl in Shift;
        end;
        if EndEdit then
        begin
          Tree := FLink.Tree;
          FLink.Tree.InvalidateNode(FLink.Node);
          NextNode := Tree.GetNextVisible(FLink.Node, True);
          TCustomVirtualStringTreeCracker(FLink.Tree).DoEndEdit;

          //get edit options for column as priority. If column has toDefaultEdit
          //use global edit options for tree
          EditOptions := TCustomVirtualStringTreeCracker(Tree).TreeOptions.EditOptions; //default
          ColumnCandidate := - 1;
          if Tree.Header.Columns.Count > 0 then  // are there any columns?
          begin
            Column := Tree.Header.Columns[Tree.FocusedColumn];
            if Column.EditOptions <> toDefaultEdit then
              EditOptions := Column.EditOptions;

            //next column candidate for toVerticalEdit and toHorizontalEdit
            if Column.EditNextColumn <> -1 then
              ColumnCandidate := Column.EditNextColumn;
          end;

          case EditOptions of
            toDefaultEdit :
              TCustomVirtualStringTreeCracker(Tree).TrySetFocus;
            toVerticalEdit :
              if NextNode <> nil then
              begin
                Tree.FocusedNode := NextNode;

                //for toVerticalEdit ColumnCandidate is also proper,
                //select ColumnCandidate column in row below
                if ColumnCandidate <> - 1 then
                begin
                  Tree.FocusedColumn := ColumnCandidate;
                  TCustomVirtualStringTreeCracker(Tree).EditColumn := ColumnCandidate;
                end;

                if Tree.CanEdit(Tree.FocusedNode, Tree.FocusedColumn) then
                  TCustomVirtualStringTreeCracker(Tree).DoEdit;
              end;
            toHorizontalEdit :
              begin
                if ColumnCandidate = - 1 then
                begin
                  //for toHorizontalEdit if property EditNextColumn is not used
                  //try to use just next column
                  ColumnCandidate := Tree.FocusedColumn + 1;
                  while (ColumnCandidate < Tree.Header.Columns.Count) and not Tree.CanEdit(Tree.FocusedNode, ColumnCandidate) do
                    Inc(ColumnCandidate);
                end
                else if not Tree.CanEdit(Tree.FocusedNode, ColumnCandidate) then
                  ColumnCandidate := Tree.Header.Columns.Count; //omit "focus/edit column" (see below)

                if ColumnCandidate < Tree.Header.Columns.Count then
                begin
                  Tree.FocusedColumn := ColumnCandidate;
                  TCustomVirtualStringTreeCracker(Tree).EditColumn := ColumnCandidate;
                  TCustomVirtualStringTreeCracker(Tree).DoEdit;
                end;
              end;
          end;
        end;
      end;
    VK_UP :
      begin
        if not FLink.Multiline then
          Message.CharCode := VK_LEFT;
        inherited;
      end;
    VK_DOWN :
      begin
        if not FLink.Multiline then
          Message.CharCode := VK_RIGHT;
        inherited;
      end;
    VK_TAB :
      begin
        if Tree.IsEditing then
        begin
          Tree.InvalidateNode(FLink.Node);
          if ssShift in KeyDataToShiftState(Message.KeyData) then
            NextNode := Tree.GetPreviousVisible(FLink.Node, True)//Shift+Tab goes to previous mode
          else
            NextNode := Tree.GetNextVisible(FLink.Node, True);
          Tree.EndEditNode;
          //check NextNode, otherwise we got AV
          if NextNode <> nil then
          begin
            //Continue editing next node
            Tree.ClearSelection();
            Tree.Selected[NextNode] := True;
            if Tree.CanEdit(Tree.FocusedNode, Tree.FocusedColumn) then
              TCustomVirtualStringTreeCracker(Tree).DoEdit;
          end;
        end;
      end;
    Ord('A') :
      begin
        if Tree.IsEditing and ([ssCtrl] = KeyboardStateToShiftState) then
        begin
          Self.SelectAll();
          Message.CharCode := 0;
        end;
      end;
    else
      inherited;
  end;
end;
{$ENDIF}
//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.AutoAdjustSize;
// Changes the size of the edit to accomodate as much as possible of its text within its container window.
// NewChar describes the next character which will be added to the edit's text.
{$IFDEF VT_VCL}
var
  Size: TSize;
{$ENDIF}
begin
{$IFDEF VT_VCL}
  if not FLink.Multiline and not (toGridExtensions in TCustomVirtualStringTreeCracker(FLink.Tree).TreeOptions.MiscOptions { see issue #252 } ) then
  begin
    // avoid flicker
    SendMessage(Handle, WM_SETREDRAW, 0, 0);
    try
      Size := GetTextSize;
      Inc(Size.cx, 2 * TCustomVirtualStringTreeCracker(FLink.Tree).TextMargin);
      // Repaint associated node if the edit becomes smaller.
      if Size.cx < Width then
        FLink.Tree.Invalidate();

      if FLink.Alignment = taRightJustify then
        FLink.SetBounds(Rect(Left + Width - Size.cx, Top, Left + Width, Top + Max(Size.cy, Height)))
      else
        FLink.SetBounds(Rect(Left, Top, Left + Size.cx, Top + Max(Size.cy, Height)));
    finally
      SendMessage(Handle, WM_SETREDRAW, 1, 0);
    end;
  end;
{$ENDIF}
end;

{$IFDEF VT_FMX}
//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.DoExit;

// FMX equivalent of the VCL's CMExit. Losing focus commits or discards, depending on
// toAutoAcceptEditChange, exactly as in the VCL.
//
// The work is queued rather than done inline: ending the edit destroys this control, and
// destroying a control from inside its own focus notification is a crash. The VCL used
// CM_RELEASE for the same reason.
//
// Note for touch targets: raising the virtual keyboard can itself move focus. If commits start
// happening at unexpected moments there, this handler is the first place to look.

var
  LTree: TCustomVirtualStringTree;
  LAccept: Boolean;
begin
  inherited;

  if not Assigned(FLink) or FLink.Stopping or not Assigned(FLink.Tree) then
    Exit; //!!!

  LTree := FLink.Tree;
  LAccept := toAutoAcceptEditChange in TCustomVirtualStringTreeCracker(LTree).TreeOptions.StringOptions;

  TThread.ForceQueue(nil,
    procedure
    begin
      if LAccept then
        LTree.EndEditNode
      else
        LTree.CancelEditNode;
    end);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState);

// FMX equivalent of the VCL's WMKeyDown / WMChar pair. Return commits, Escape discards,
// and both are swallowed so the tree does not also act on them.
//
// Queued for the same reason as DoExit - the tree frees this control as part of ending
// the edit, and we are inside one of its own methods.

var
  LTree: TCustomVirtualStringTree;
  LEnd: Boolean;
begin
  if Assigned(FLink) and not FLink.Stopping and Assigned(FLink.Tree) and
     ((Key = vkReturn) or (Key = vkEscape)) then
  begin
    LTree := FLink.Tree;
    LEnd := Key = vkReturn;

    Key := 0;
    KeyChar := #0;

    TThread.ForceQueue(nil,
      procedure
      begin
        if LEnd then
          LTree.EndEditNode
        else
          LTree.CancelEditNode;
      end);
    Exit; //!!!
  end;

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.Paint;

// Gives the editor an opaque background, which is what the VCL got for free from the
// edit control's own window. PaintTree does skip the cell being edited, so what shows
// through an unpainted editor is the row background and the grid line - see the note on
// the colour constants.
//
// Painting rather than dropping a TRectangle behind the edit: Paint runs before the style
// objects and before the child controls, so the fill lands underneath the text, the selection
// and the caret without hiding any of them, and nothing has to be kept in sync with the bounds.
// Done on every FMX target rather than on the touch ones alone, so that a desktop build shows
// what the device will show.

var
  LRect: TRectF;
begin
  Canvas.Fill.Kind  := TBrushKind.Solid;
  Canvas.Fill.Color := cEditBackColor;
  Canvas.FillRect(LocalRect, 0, 0, [], AbsoluteOpacity);

  // Inset by half the line width, or the stroke straddles the control's edge and its
  // outer half is clipped away - the right and bottom borders then look thinner.
  LRect := LocalRect;
  LRect.Inflate(-0.5, -0.5);

  Canvas.Stroke.Kind      := TBrushKind.Solid;
  Canvas.Stroke.Color     := cEditBorderColor;
  Canvas.Stroke.Thickness := 1;
  Canvas.DrawRect(LRect, 0, 0, [], AbsoluteOpacity);

  inherited;
end;
{$ENDIF}

//----------------------------------------------------------------------------------------------------------------------
{$IFDEF VT_VCL}
procedure TVTEdit.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if not Assigned(FLink.Node) then
    exit; //Prevent AV exceptions occasionally seen in code below

  //Only with multiline style we can use the text formatting rectangle.
  // This does not harm formatting as single line control, if we don't use word wrapping.
  // The word wrapping and the vertical scrollbar are what make it a memo, and those follow
  // the link's Multiline property - NOT the node's vsMultiline state, which says how the
  // caption is DISPLAYED and nothing about how it is typed.
  with Params do
  begin
    Style := Style or ES_MULTILINE;
    if FLink.Multiline then
      Style := Style and not (ES_AUTOHSCROLL or WS_HSCROLL) or WS_VSCROLL or ES_AUTOVSCROLL;
    if tsUseThemes in FLink.Tree.TreeStates then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end
    else
    begin
      Style := Style or WS_BORDER;
      ExStyle := ExStyle and not WS_EX_CLIENTEDGE;
    end;
  end;
end;
{$ENDIF}
//----------------------------------------------------------------------------------------------------------------------
{$IFDEF VT_VCL}
function TVTEdit.GetTextSize: TSize;
var
  DC: HDC;
  LastFont: THandle;
begin
  DC := GetDC(Handle);
  LastFont := SelectObject(DC, Font.Handle);
  try
    // Read needed space for the current text.
    GetTextExtentPoint32(DC, PChar(Text+'yG'), Length(Text)+2, Result);
  finally
    SelectObject(DC, LastFont);
    ReleaseDC(Handle, DC);
  end;
end;
{$ENDIF}
//----------------------------------------------------------------------------------------------------------------------
{$IFDEF VT_VCL}
procedure TVTEdit.KeyPress(var Key : Char);
begin
  if (Key = #13) and Assigned(FLink) and not FLink.Multiline then
    Key := #0; //Filter out return keys as they will be added to the text, avoids #895
  inherited;
end;
{$ENDIF}
//----------------------------------------------------------------------------------------------------------------------
{$IFDEF VT_VCL}
procedure TVTEdit.Release;
begin
  if HandleAllocated then
    PostMessage(Handle, CM_RELEASE, 0, 0);
end;
{$ENDIF}
//----------------- TBaseEditLink --------------------------------------------------------------------------------------

procedure TBaseEditLink.SetEdit(const Value : TControl);
begin
  if Assigned(FEdit) then
    FEdit.Free;
  FEdit := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseEditLink.BeginEdit : Boolean;
//Notifies the edit link that editing can start now. descendants may cancel node edit
//by returning False.

begin
  Result := not FStopping;
  if Result then
    DoBeginEdit(Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseEditLink.CancelEdit : Boolean;

// Performs edit cancelling.

begin
  Result := not FStopping;
  if Result then
  begin
    // Let descendants cancel the cancel
    DoCancelEdit(Result);
    if not Result then
      Exit;
    FStopping := True;
    FTree.CancelEditNode;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseEditLink.EndEdit : Boolean;

// Performs edit ending.

begin
  Result := not FStopping;
  if Result then
  begin
    // Let descendants cancel the end
    DoEndEdit(Result);
    if not Result then
      Exit;
    FStopping := True;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseEditLink.PrepareEdit(Tree : TBaseVirtualTree; Node : PVirtualNode; Column : TColumnIndex) : Boolean;

// Performs general init: assign Tree, Node, Column, other properties; destroys previous
// edit instance.

begin
  Result := Tree is TCustomVirtualStringTree;
  if not Result then Exit; // should not happen

  FTree := Tree as TCustomVirtualStringTree;
  FNode := Node;
  FColumn := Column;
  if Column <= NoColumn then
  begin
    FBidiMode := FTree.BidiMode;
    FAlignment := TCustomVirtualStringTreeCracker(FTree).Alignment;
  end
  else
  begin
    FBidiMode := FTree.Header.Columns[Column].BidiMode;
    FAlignment := FTree.Header.Columns[Column].Alignment;
  end;
  SetEdit(nil); // always dispose edit

  DoPrepareEdit(Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseEditLink.DoBeginEdit(var Result: Boolean);
begin
  if Assigned(OnBeginEdit) then
    OnBeginEdit(Self, Result);
end;

//----------------------------------------------------------------------------------------------------------------------
					  
procedure TBaseEditLink.DoCancelEdit(var Result: Boolean);
begin
  if Assigned(OnCancelEdit) then
    OnCancelEdit(Self, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseEditLink.DoEndEdit(var Result: Boolean);
begin
  if Assigned(OnEndEdit) then
    OnEndEdit(Self, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseEditLink.DoPrepareEdit(var Result: Boolean);
begin
  if Assigned(OnPrepareEdit) then
    OnPrepareEdit(Self, FEdit, Result);
end;

//----------------- TWinControlEditLink ------------------------------------------------------------------------------------
{$IFDEF VT_VCL}
destructor TWinControlEditLink.Destroy;
begin
  //FEdit.Free; casues issue #357. Fix:
  if Assigned(FEdit) and Edit.HandleAllocated then
    PostMessage(Edit.Handle, CM_RELEASE, 0, 0);
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

function TWinControlEditLink.GetEdit: TWinControl;
begin
  Result := TWinControl(FEdit);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TWinControlEditLink.SetEdit(const Value: TWinControl);
begin
  inherited SetEdit(Value);
end;

//----------------------------------------------------------------------------------------------------------------------

function TWinControlEditLink.BeginEdit: Boolean;
begin
  Result := inherited;
  if Result then
  begin
    Edit.Show;
    Edit.SetFocus;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TWinControlEditLink.CancelEdit: Boolean;
begin
  Result := inherited;
  if Result then
  begin
    Edit.Hide;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TWinControlEditLink.GetBounds : TRect;
begin
  Result := FEdit.BoundsRect;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TWinControlEditLink.ProcessMessage(var Message : TMessage);
begin
  FEdit.WindowProc(Message);
end;

//----------------------------------------------------------------------------------------------------------------------
					  
function TWinControlEditLink.EndEdit: Boolean;
begin
  Result := inherited;
  if Result then
  begin
    Edit.Hide;
  end;
end;

//----------------- TStringEditLink ------------------------------------------------------------------------------------

constructor TStringEditLink.Create;
begin
  inherited;
  FEdit := TVTEdit.Create(Self);
  with Edit do
  begin
    Visible := False;
    BorderStyle := bsSingle;
    AutoSize := False;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TStringEditLink.GetEdit: TVTEdit;
begin
  Result := TVTEdit(FEdit);			 
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TStringEditLink.SetEdit(const Value: TVTEdit);
begin
  inherited SetEdit(Value);			   
end;

//----------------------------------------------------------------------------------------------------------------------

function TStringEditLink.BeginEdit : Boolean;
begin
  Result := inherited;
  if Result then
  begin
    Edit.SelectAll;
    Edit.AutoAdjustSize;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TStringEditLink.CancelEdit : Boolean;
begin
  Result := inherited;
  if Result then
  begin
    Edit.ClearLink;
    Edit.ClearRefLink;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TStringEditLink.EndEdit: Boolean;
begin
  Result := inherited;
  if Result then
  try
    if Edit.Modified then
      FTree.Text[FNode, FColumn] := Edit.Text;
    Edit.ClearLink;
    Edit.ClearRefLink;
  except
    FStopping := False;
    raise;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TStringEditLink.PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean;
var
  Text: string;
begin
  Result := inherited;
  if Result then
  begin 
    Edit := TVTEdit.Create(Self);
    Edit.Visible := False;
    Edit.BorderStyle := bsSingle;
    Edit.AutoSize := True;
    Edit.Parent := Tree;
    // Initial size, font and text of the node.
    FTree.GetTextInfo(Node, Column, Edit.Font, FTextBounds, Text);
    Edit.Font.Color := clWindowText;
    Edit.RecreateWnd;
    Edit.AutoSize := False;
    Edit.Text := Text;
      Edit.BidiMode := FBidiMode;
    if Edit.BidiMode <> bdLeftToRight then
      ChangeBidiModeAlignment(FAlignment);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TStringEditLink.SetBounds(R: TRect);
// Sets the outer bounds of the edit control and the actual edit area in the control.

var
  lOffset, tOffset, Height: TDimension;
  offsets : TVTOffsets;
begin
  if not FStopping then
  begin
    // Check if the provided rect height is smaller than the edit control height.
    Height := R.Bottom - R.Top;
    if Height < Edit.ClientHeight then
    begin
      // If the height is smaller than the minimal height we must correct it, otherwise the caret will be invisible.
      tOffset := Edit.CalcMinHeight - Height;
      if tOffset > 0 then
        Inc(R.Bottom, tOffset);
    end;

    // Set the edit's bounds but make sure there's a minimum width and the right border does not
    // extend beyond the parent's left/right border.
    if R.Left < 0 then
      R.Left := 0;
    if R.Right - R.Left < 30 then
    begin
      if FAlignment = taRightJustify then
        R.Left := R.Right - 30
      else
        R.Right := R.Left + 30;
    end;
    if R.Right > FTree.ClientWidth then
      R.Right := FTree.ClientWidth;
    Edit.BoundsRect := R;

    // The selected text shall exclude the text margins and be centered vertically.
    // We have to take out the two pixel border of the edit control as well as a one pixel "edit border" the
    // control leaves around the (selected) text.
    R := Edit.ClientRect;

    // If toGridExtensions are turned on, we can fine tune the left margin (or the right margin if RTL is on)
    // of the text to exactly match the text in the tree cell.
    if (toGridExtensions in TCustomVirtualStringTreeCracker(FTree).TreeOptions.MiscOptions) and
       ((FAlignment = taLeftJustify) and (Edit.BidiMode = bdLeftToRight) or (FAlignment = taRightJustify) and (Edit.BidiMode <> bdLeftToRight)) then
    begin
      // Calculate needed text area offset.
      FTree.GetOffsets(FNode, offsets, ofsText, FColumn);
      if FColumn = FTree.Header.MainColumn then
      begin
        if offsets[ofsToggleButton] < 0 then
          lOffset := -(offsets[ofsToggleButton] + 2)
        else
          lOffset := 0;
      end
      else
        lOffset := offsets[ofsText] - offsets[ofsMargin] + 1;
      // Apply the offset.
      if Edit.BidiMode = bdLeftToRight then
        Inc(R.Left, lOffset)
      else
        Dec(R.Right, lOffset);
    end;

    lOffset := IfThen(FMultiline, 0, 2);
    if tsUseThemes in FTree.TreeStates then
      Inc(lOffset);
    InflateRect(R, - TCustomVirtualStringTreeCracker(FTree).TextMargin + lOffset, lOffset);
    if not FMultiline then
    begin
      tOffset := FTextBounds.Top - Edit.Top;
      // Do not apply a negative offset, the cursor will disappear.
      if tOffset > 0 then
        OffsetRect(R, 0, tOffset);
    end;
    R.Top := Max(-1, R.Top); // A value smaller than -1 will prevent the edit cursor from being shown by Windows, see issue #159
    R.Left := Max(-1, R.Left);
    SendMessage(Edit.Handle, EM_SETRECTNP, 0, LPARAM(@R));
  end;
end;
{$ENDIF}

{$IFDEF VT_FMX}
//----------------- TStringEditLink (FMX) ------------------------------------------------------------------------------

destructor TStringEditLink.Destroy;

// TBaseEditLink does not own its edit - only TWinControlEditLink freed it, and that class
// is VCL only. Without this the tree leaks one TVTEdit per edited cell.

begin
  inherited SetEdit(nil);   // TBaseEditLink.SetEdit frees the previous instance
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

function TStringEditLink.GetEdit: TVTEdit;
begin
  Result := TVTEdit(FEdit);
end;

//----------------------------------------------------------------------------------------------------------------------

function TStringEditLink.PrepareEdit(Tree : TBaseVirtualTree; Node : PVirtualNode; Column : TColumnIndex) : Boolean;

// The inherited call fills in Tree, Node, Column, Alignment and BiDiMode and disposes of
// any previous editor, so all that is left is to build this one. It stays hidden until
// BeginEdit, because the tree calls UpdateEditBounds (and so SetBounds) in between, and an
// editor that first appears in the wrong place is visibly ugly.

var
  LEdit: TVTEdit;
begin
  Result := inherited PrepareEdit(Tree, Node, Column);
  if not Result then
    Exit; //!!!

  LEdit := TVTEdit.Create(Self);
  inherited SetEdit(LEdit);         // link takes ownership

  LEdit.Parent := FTree;
  LEdit.Visible := False;

  // Paint puts down a fixed light background, so the text colour cannot be left to the
  // style - a dark theme would write light text on it. Taking FontColor out of
  // StyledSettings is what stops the style from putting its own colour back.
  LEdit.StyledSettings := LEdit.StyledSettings - [TStyledSetting.FontColor];
  LEdit.FontColor := cEditTextColor;

  // The text is deliberately NOT assigned here. At this point the editor is still hidden
  // and has its default size, and an FMX TEdit lays its text out - including the horizontal
  // scroll offset - when Text is assigned. Doing it now leaves the view scrolled to the end
  // of the string, so the start of the text is invisible until the user presses Home. The
  // assignment happens in BeginEdit instead, once the bounds are final and the control is
  // visible. (The Text setter short-circuits on an unchanged value, so it cannot be
  // assigned in both places and re-laid-out later.)

  case FAlignment of
    taRightJustify: LEdit.TextAlign := TTextAlign.Trailing;
    taCenter:       LEdit.TextAlign := TTextAlign.Center;
  else
    LEdit.TextAlign := TTextAlign.Leading;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TStringEditLink.BeginEdit : Boolean;

// Shows the editor and hands it the keyboard. On a touch target this is also what raises the
// virtual keyboard, which may cover the cell being edited - see the note in TVTEdit.DoExit.

begin
  Result := inherited BeginEdit;
  if Result and Assigned(FEdit) then
  begin
    FEdit.Visible := True;
    FEdit.BringToFront;

    // Only now, with the bounds already applied by UpdateEditBounds and the control
    // visible - see the note in PrepareEdit about the horizontal scroll offset.
    Edit.Text := FTree.Text[FNode, FColumn];

    FEdit.SetFocus;

    if cSelectAllOnEdit then
      Edit.SelectAll
    else
    begin
      Edit.SelLength := 0;
      Edit.SelStart := 0;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TStringEditLink.CancelEdit : Boolean;
begin
  Result := not FStopping;
  if not Result then
    Exit; //!!!

  // Break the edit -> link reference before the tree drops its own, otherwise the two keep
  // each other alive. Safe here: the tree still holds FEditLink at this point.
  if Assigned(FEdit) then
    Edit.ClearRefLink;

  Result := inherited CancelEdit;
end;

//----------------------------------------------------------------------------------------------------------------------

function TStringEditLink.EndEdit : Boolean;

// Writes the edited text back through Text[], which routes to DoNewText and so to the
// application's OnNewText handler. The text is read before the inherited call, because
// that sets FStopping and the editor may be gone by the time it returns.

var
  S: string;
begin
  Result := not FStopping;
  if not Result then
    Exit; //!!!

  S := '';
  if Assigned(FEdit) then
  begin
    S := Edit.Text;
    Edit.ClearRefLink;   // see CancelEdit
  end;

  Result := inherited EndEdit;
  if not Result then
    Exit; //!!!

  if Assigned(FTree) and Assigned(FNode) then
    FTree.Text[FNode, FColumn] := S;
end;

//----------------------------------------------------------------------------------------------------------------------

function TStringEditLink.GetBounds : TRect;

// Built field by field rather than from BoundsRect, so this does not depend on whether
// VirtualTrees.FMX.TRect is an alias of TRectF or a record of its own.

begin
  Result := Default(TRect);
  if not Assigned(FEdit) then
    Exit; //!!!

  Result.Left   := FEdit.Position.X;
  Result.Top    := FEdit.Position.Y;
  Result.Right  := Result.Left + FEdit.Width;
  Result.Bottom := Result.Top + FEdit.Height;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TStringEditLink.SetBounds(R : TRect);

// The VCL version finishes by sending EM_SETRECTNP to inset the edit control's inner text
// rectangle, so that the text lines up with the cell it replaced. FMX has no equivalent, so that
// fine alignment is not attempted here; the difference is cosmetic.

var
  LClient: TRect;
  LColLeft, LColRight: TDimension;
  LHeight, LMinHeight: Single;
begin
  if FStopping or not Assigned(FEdit) then
    Exit; //!!!

  // R arrives from GetDisplayRect, whose origin is the top left of the CLIENT area. In the
  // VCL the header sits in the non-client area, so client coordinates already start below
  // it and the rect can be used as is. On FMX the header is painted inside the control and
  // TControl.Position is measured from the control's own top edge, so the header height has
  // to be added back - without it the editor lands one row too high. ClientRect carries
  // exactly that offset and already respects hoVisible, so no Header.Height test is needed.
  // R is the text rectangle, not the cell, unless toGridExtensions is on - so by default
  // the editor is only as wide as the string it holds. Widen it to the column instead:
  // more room to type, and short values then fit without the view scrolling at all.
  if cEditFillsColumn and (FColumn > NoColumn) then
  begin
    FTree.Header.Columns.GetColumnBounds(FColumn, LColLeft, LColRight);
    R.Left := LColLeft;
    R.Right := LColRight - 1;   // the right column border is not part of the cell
  end;

  LClient := FTree.ClientRect;
  R.Left   := R.Left   + LClient.Left;
  R.Right  := R.Right  + LClient.Left;
  R.Top    := R.Top    + LClient.Top;
  R.Bottom := R.Bottom + LClient.Top;

  // A minimum width, or a narrow column leaves nothing to type into.
  if R.Left < LClient.Left then
    R.Left := LClient.Left;
  if R.Right - R.Left < cMinEditWidth then
  begin
    if FAlignment = taRightJustify then
      R.Left := R.Right - cMinEditWidth
    else
      R.Right := R.Left + cMinEditWidth;
  end;
  if R.Right > LClient.Right then
    R.Right := LClient.Right;

  // Keep the editor out of the header when the edited row is scrolled partly under it.
  if R.Top < LClient.Top then
    R.Top := LClient.Top;

  // DefaultNodeHeight is already density scaled by the application, so it makes a better
  // minimum than any constant - on a phone a 20px editor is unusable. It is protected on
  // TBaseVirtualTree and only republished further down the hierarchy, hence the cracker.
  LMinHeight := TCustomVirtualStringTreeCracker(FTree).DefaultNodeHeight;
  LHeight := R.Bottom - R.Top;
  if LHeight < LMinHeight then
    R.Bottom := R.Top + LMinHeight;

  // SetBounds rather than BoundsRect, again to stay independent of the TRect alias.
  FEdit.SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
end;
{$ENDIF}

end.
