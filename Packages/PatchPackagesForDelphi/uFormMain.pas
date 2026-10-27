unit uFormMain;

// Sets the library suffix of the Virtual TreeView package projects.
//
// Two places carry it and they have to agree: {$LIBSUFFIX 'nnn'} in each .dpk, which is what
// the compiler reads, and <DllSuffix>nnn</DllSuffix> in each .dproj, which is what MSBuild
// reads. A mismatch between them, or the {$LIBSUFFIX AUTO} form, makes a design package record
// its dependency on the runtime package under a name that was never built, and the IDE then
// refuses to install it with "Can't load package ...".
//
// The files are edited as raw bytes: only the span between the markers is replaced, so byte
// order marks, line endings and everything else survive untouched whatever the IDE last wrote.

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Types, System.Math,
  System.Win.Registry, Winapi.Windows,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Dialogs,
  Vcl.FileCtrl;

type
  TFormMain = class(TForm)
    pnlTop: TPanel;
    lblFolder: TLabel;
    edFolder: TEdit;
    btnBrowse: TButton;
    lblSuffix: TLabel;
    edSuffix: TEdit;
    btnDetect: TButton;
    chkBackup: TCheckBox;
    btnScan: TButton;
    btnPatch: TButton;
    lvFiles: TListView;
    memLog: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure btnDetectClick(Sender: TObject);
    procedure btnScanClick(Sender: TObject);
    procedure btnPatchClick(Sender: TObject);
  private
    procedure Log(const AText: string);
    procedure Scan;
    procedure UpdateVersionList(const ASuffix: string);
    function PackageFiles: TArray<string>;
    function BackupFile(const AFileName: string): Boolean;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

const
  cDpkOpen   = '{$LIBSUFFIX ';
  cDpkClose  = '}';
  cPrjOpen   = '<DllSuffix>';
  cPrjClose  = '</DllSuffix>';

//----------------------------------------------------------------------------------------------

function IsPackageProject(const AFileName: string): Boolean;
begin
  Result := SameText(TPath.GetExtension(AFileName), '.dproj');
end;

//----------------------------------------------------------------------------------------------

function Markers(const AFileName: string; out AOpen, AClose: string): Boolean;

// Which pair of markers surrounds the suffix in this kind of file. False for anything else,
// which is how a stray file in the folder is skipped rather than mangled.

begin
  Result := True;
  if SameText(TPath.GetExtension(AFileName), '.dpk') then begin
    AOpen  := cDpkOpen;
    AClose := cDpkClose;
  end else if IsPackageProject(AFileName) then begin
    AOpen  := cPrjOpen;
    AClose := cPrjClose;
  end else begin
    AOpen  := '';
    AClose := '';
    Result := False;
  end;
end;

//----------------------------------------------------------------------------------------------

function FindBytes(const AHaystack, ANeedle: TBytes; AStart: Integer): Integer;

// Plain byte search. Returns the index of the first match at or after AStart, or -1.

var
  I, J: Integer;
  LLast: Integer;
begin
  Result := -1;
  if (Length(ANeedle) = 0) or (Length(AHaystack) < Length(ANeedle)) then
    Exit;

  LLast := Length(AHaystack) - Length(ANeedle);
  for I := Max(AStart, 0) to LLast do begin
    J := 0;
    while (J < Length(ANeedle)) and (AHaystack[I + J] = ANeedle[J]) do
      System.Inc(J);
    if J = Length(ANeedle) then
      Exit(I);
  end;
end;

//----------------------------------------------------------------------------------------------

function LocateValue(const ABytes: TBytes; const AOpen, AClose: string;
  out AStart, ALength: Integer): Boolean;

// Finds the span BETWEEN the two markers - the text that holds the suffix and nothing else.
// The markers themselves are left in place, so the surrounding syntax is never rewritten.

var
  LOpen, LClose: TBytes;
  LFrom, LTo: Integer;
begin
  Result  := False;
  AStart  := -1;
  ALength := 0;

  LOpen  := TEncoding.ANSI.GetBytes(AOpen);
  LClose := TEncoding.ANSI.GetBytes(AClose);

  LFrom := FindBytes(ABytes, LOpen, 0);
  if LFrom < 0 then
    Exit;
  System.Inc(LFrom, Length(LOpen));

  LTo := FindBytes(ABytes, LClose, LFrom);
  if LTo < 0 then
    Exit;

  AStart  := LFrom;
  ALength := LTo - LFrom;
  Result  := True;
end;

//----------------------------------------------------------------------------------------------

function ReadValue(const AFileName: string; out AValue: string): Boolean;

// The suffix as it currently stands, quotes and surrounding spaces removed. AUTO comes back
// as the word AUTO, which is what makes it visible in the list rather than silently equal to
// nothing.

var
  LBytes: TBytes;
  LOpen, LClose: string;
  LStart, LLen: Integer;
begin
  Result := False;
  AValue := '';
  if not Markers(AFileName, LOpen, LClose) then
    Exit;

  LBytes := TFile.ReadAllBytes(AFileName);
  if not LocateValue(LBytes, LOpen, LClose, LStart, LLen) then
    Exit;

  AValue := TEncoding.ANSI.GetString(LBytes, LStart, LLen).Trim([' ', #9, '''']);
  Result := True;
end;

//----------------------------------------------------------------------------------------------

function WriteValue(const AFileName, ASuffix: string): Boolean;

// Splices the new suffix into place. A .dpk wants it quoted, a .dproj bare.

var
  LBytes, LNew, LInsert: TBytes;
  LOpen, LClose, LText: string;
  LStart, LLen, I: Integer;
begin
  Result := False;
  if not Markers(AFileName, LOpen, LClose) then
    Exit;

  LBytes := TFile.ReadAllBytes(AFileName);
  if not LocateValue(LBytes, LOpen, LClose, LStart, LLen) then
    Exit;

  if IsPackageProject(AFileName) then
    LText := ASuffix
  else
    LText := '''' + ASuffix + '''';

  LInsert := TEncoding.ANSI.GetBytes(LText);

  SetLength(LNew, Length(LBytes) - LLen + Length(LInsert));
  if LStart > 0 then
    Move(LBytes[0], LNew[0], LStart);
  if Length(LInsert) > 0 then
    Move(LInsert[0], LNew[LStart], Length(LInsert));
  I := Length(LBytes) - LStart - LLen;
  if I > 0 then
    Move(LBytes[LStart + LLen], LNew[LStart + Length(LInsert)], I);

  TFile.WriteAllBytes(AFileName, LNew);
  Result := True;
end;

//----------------------------------------------------------------------------------------------

function DigitsIn(const AText: string): string;

// The number out of a name like rtl290.bpl.

var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(AText) do
    if CharInSet(AText[I], ['0'..'9']) then
      Result := Result + AText[I];
end;

//----------------------------------------------------------------------------------------------

procedure CollectSuffixesFrom(const AFolder: string; AFound, ATried: TStrings);

// Every rtl*.bpl in one folder contributes its number. The folder is recorded either way, so a
// search that finds nothing can still say where it looked.

var
  LName: string;
  LDigits: string;
begin
  ATried.Add(AFolder);
  if not TDirectory.Exists(AFolder) then
    Exit;

  for LName in TDirectory.GetFiles(AFolder, 'rtl*.bpl') do begin
    LDigits := DigitsIn(TPath.GetFileNameWithoutExtension(LName));
    if LDigits <> '' then
      AFound.Add(LDigits);
  end;
end;

//----------------------------------------------------------------------------------------------

procedure CollectFromRegistry(AFound, ATried: TStrings);

// The installed RAD Studio versions as the registry lists them. RootDir points at the product
// folder, and its bin holds the redistributable packages - rtl290.bpl among them - so the number
// comes from the installation itself rather than from a folder that may have been moved.

const
  // Both hives: a per-user install registers under the first, a machine-wide one under the
  // second. An array rather than a set - these values are far too large for a Delphi set.
  cHives: array [0 .. 1] of HKEY = (HKEY_CURRENT_USER, HKEY_LOCAL_MACHINE);
var
  LReg: TRegistry;
  LVersions: TStringList;
  LVersion, LRoot: string;
  I: Integer;
begin
  for I := Low(cHives) to High(cHives) do begin
    LReg := TRegistry.Create(KEY_READ);
    try
      LReg.RootKey := cHives[I];
      LReg.Access := KEY_READ or KEY_WOW64_32KEY;
      if not LReg.OpenKeyReadOnly('\Software\Embarcadero\BDS') then
        Continue;

      LVersions := TStringList.Create;
      try
        LReg.GetKeyNames(LVersions);
        LReg.CloseKey;

        for LVersion in LVersions do begin
          if not LReg.OpenKeyReadOnly('\Software\Embarcadero\BDS\' + LVersion) then
            Continue;
          LRoot := LReg.ReadString('RootDir');
          LReg.CloseKey;
          if LRoot <> '' then
            CollectSuffixesFrom(TPath.Combine(LRoot, 'bin'), AFound, ATried);
        end;
      finally
        LVersions.Free;
      end;
    finally
      LReg.Free;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------

function DetectInstalled(ATried: TStrings): TArray<string>;

// Every RAD Studio on this machine, by the suffix its own RTL package carries. rtl290.bpl says
// 290 is the right answer for that installation, which beats assuming the number went up by ten
// again. The registry is asked first; the shared BPL folders are searched as well, because a
// package built here is written to one of those.

var
  LFound: TStringList;
  LRoot, LStudio: string;
  LRoots: TArray<string>;
begin
  LFound := TStringList.Create;
  try
    LFound.Sorted := True;
    LFound.Duplicates := dupIgnore;

    CollectFromRegistry(LFound, ATried);

    LRoots := [TPath.Combine(GetEnvironmentVariable('PUBLIC'), 'Documents\Embarcadero\Studio'),
               'C:\Users\Public\Documents\Embarcadero\Studio',
               TPath.Combine(TPath.GetPublicPath, 'Embarcadero\Studio')];

    for LRoot in LRoots do begin
      if (LRoot = '') or not TDirectory.Exists(LRoot) then begin
        ATried.Add(LRoot + '   (not there)');
        Continue;
      end;
      for LStudio in TDirectory.GetDirectories(LRoot) do
        CollectSuffixesFrom(TPath.Combine(LStudio, 'Bpl'), LFound, ATried);
    end;

    Result := LFound.ToStringArray;
  finally
    LFound.Free;
  end;
end;

//----------------------------------------------------------------------------------------------

function LastIndexOfBytes(const AHaystack, ANeedle: TBytes): Integer;

// The last match rather than the first, so a line is added after the whole list and the list
// stays in one piece.

var
  LNext, LFrom: Integer;
begin
  Result := -1;
  LFrom := 0;
  repeat
    LNext := FindBytes(AHaystack, ANeedle, LFrom);
    if LNext < 0 then
      Break;
    Result := LNext;
    LFrom := LNext + 1;
  until False;
end;

//----------------------------------------------------------------------------------------------

function VersionSymbolFor(const ASuffix: string): string;

// Up to RAD Studio 12 the library suffix ran seven behind the compiler version: suffix 290
// belongs to CompilerVersion 36, which defines VER360; 280 belongs to 35 and VER350. RAD Studio
// 13 closed that gap - its suffix is 370 and its symbol VER370 - so from 370 on the suffix and
// the symbol carry the same number.
//
// If a future RAD Studio breaks the pattern again, the symbol worked out here is wrong and
// DelphiVersion.inc still refuses the build - which is the safe way round, and the file says
// how to add the line by hand.

var
  LSuffix: Integer;
begin
  Result := '';
  if not TryStrToInt(ASuffix, LSuffix) then
    Exit;
  if LSuffix >= 370 then begin
    Result := 'VER' + IntToStr(LSuffix);
  end else begin
    Result := 'VER' + IntToStr(((LSuffix div 10) + 7) * 10);
  end;
end;

//----------------------------------------------------------------------------------------------

function IsPlausibleSuffix(const AValue: string): Boolean;

// Digits only. A suffix is appended to a file name, so anything else produces a package that
// cannot be found rather than an error at the point the mistake was made.

var
  I: Integer;
begin
  Result := (Length(AValue) >= 2) and (Length(AValue) <= 6);
  if not Result then
    Exit;
  for I := 1 to Length(AValue) do
    if not CharInSet(AValue[I], ['0'..'9']) then
      Exit(False);
end;

//----------------------------------------------------------------------------------------------
//----------------- TFormMain ------------------------------------------------------------------
//----------------------------------------------------------------------------------------------

procedure TFormMain.FormCreate(Sender: TObject);

// The tool is meant to sit in the Packages folder it patches, so that is the starting guess.

begin
  edFolder.Text := TPath.GetDirectoryName(ParamStr(0));
  Log('Ready. Scan lists the package files and the suffix each one currently carries.');
  Scan;
end;

//----------------------------------------------------------------------------------------------

procedure TFormMain.Log(const AText: string);
begin
  memLog.Lines.Add(FormatDateTime('hh:nn:ss  ', Now) + AText);
end;

//----------------------------------------------------------------------------------------------

function TFormMain.PackageFiles: TArray<string>;

// The .dpk and .dproj files in the chosen folder, in name order. Nothing recurses: the flat
// Packages folder is the whole of it.

var
  LList: TStringList;
  LName: string;
  LOpen, LClose: string;
begin
  LList := TStringList.Create;
  try
    LList.Sorted := True;
    if TDirectory.Exists(edFolder.Text) then
      for LName in TDirectory.GetFiles(edFolder.Text, '*.*') do
        if Markers(LName, LOpen, LClose) then
          LList.Add(LName);
    Result := LList.ToStringArray;
  finally
    LList.Free;
  end;
end;

//----------------------------------------------------------------------------------------------

function TFormMain.BackupFile(const AFileName: string): Boolean;

// A dated copy in a _Backup folder beside the original, so a patch can always be compared with
// what it replaced.

var
  LDir, LTarget: string;
begin
  Result := False;
  try
    LDir := TPath.Combine(TPath.GetDirectoryName(AFileName), '_Backup');
    if not TDirectory.Exists(LDir) then
      TDirectory.CreateDirectory(LDir);

    LTarget := TPath.Combine(LDir,
      TPath.GetFileNameWithoutExtension(AFileName) + '.' +
      FormatDateTime('yyyymmdd-hhnn', Now) + TPath.GetExtension(AFileName));

    TFile.Copy(AFileName, LTarget, True);
    Result := True;
  except
    on E: Exception do
      Log('Backup failed for ' + TPath.GetFileName(AFileName) + ': ' + E.Message);
  end;
end;

//----------------------------------------------------------------------------------------------

procedure TFormMain.Scan;
var
  LName, LValue: string;
  LItem: TListItem;
begin
  lvFiles.Items.BeginUpdate;
  try
    lvFiles.Items.Clear;
    for LName in PackageFiles do begin
      LItem := lvFiles.Items.Add;
      LItem.Caption := TPath.GetFileName(LName);
      if ReadValue(LName, LValue) then begin
        LItem.SubItems.Add(LValue);
        LItem.SubItems.Add('');
      end else begin
        LItem.SubItems.Add('-');
        LItem.SubItems.Add('No suffix found - this file will be left alone');
      end;
    end;
  finally
    lvFiles.Items.EndUpdate;
  end;
  Log(Format('%d package file(s) in %s', [lvFiles.Items.Count, edFolder.Text]));
end;

//----------------------------------------------------------------------------------------------

procedure TFormMain.btnBrowseClick(Sender: TObject);
var
  LDir: string;
begin
  LDir := edFolder.Text;
  if SelectDirectory('Packages folder', '', LDir) then begin
    edFolder.Text := LDir;
    Scan;
  end;
end;

//----------------------------------------------------------------------------------------------

procedure TFormMain.btnScanClick(Sender: TObject);
begin
  Scan;
end;

//----------------------------------------------------------------------------------------------

procedure TFormMain.btnDetectClick(Sender: TObject);

// Every folder searched is logged whether or not it held anything, so a detection that comes
// back empty says where to look by hand instead of only that it failed.

var
  LFound: TArray<string>;
  LValue: string;
  LTried: TStringList;
begin
  LTried := TStringList.Create;
  try
    LFound := DetectInstalled(LTried);

    if Length(LFound) = 0 then begin
      Log('No rtl*.bpl found. Searched:');
      for LValue in LTried do
        Log('    ' + LValue);
      Log('Enter the suffix by hand: it is the number in rtl<nnn>.bpl, in the bin folder of ' +
          'the RAD Studio installation.');
      Exit;
    end;

    for LValue in LFound do
      Log('Installed RTL package suffix found: ' + LValue);

    edSuffix.Text := LFound[High(LFound)];
    Log('Suffix set to ' + edSuffix.Text +
        '. Check it is the RAD Studio you mean to build with.');
  finally
    LTried.Free;
  end;
end;

//----------------------------------------------------------------------------------------------

procedure TFormMain.UpdateVersionList(const ASuffix: string);

// Brings DelphiVersion.inc in step with the suffix just written. Two things live there: the
// suffix, repeated as a symbol so the compiler can compare it, and one line per RAD Studio
// pairing that version with the suffix belonging to it.
//
// The suffix symbol is rewritten every time. Version lines are added and never replaced, so a
// folder that has been built with several RAD Studios goes on accepting all of them.
//
// Doing this alongside the .dpk and .dproj is the point. The packages refuse to compile when
// the two disagree, so writing the suffix on its own would leave the build stopped - correctly,
// but for a reason that looks like a different fault.

var
  LFile, LSymbol, LLine: string;
  LBytes, LInsert, LResult: TBytes;
  LAt, LEol, LTail, LStart, LLen: Integer;
begin
  LFile := TPath.Combine(edFolder.Text, 'DelphiVersion.inc');
  if not TFile.Exists(LFile) then begin
    Log('No DelphiVersion.inc in this folder - nothing to bring in step.');
    Exit;
  end;

  LSymbol := VersionSymbolFor(ASuffix);
  if LSymbol = '' then
    Exit;

  if chkBackup.Checked and not BackupFile(LFile) then begin
    Log('DelphiVersion.inc not updated: it could not be backed up.');
    Exit;
  end;

  // The suffix symbol, which is what makes a suffix meant for another RAD Studio visible to the
  // compiler rather than only to the IDE at install time.
  LBytes := TFile.ReadAllBytes(LFile);
  if LocateValue(LBytes, '{$DEFINE VT_SUFFIX_', '}', LStart, LLen) then begin
    if TEncoding.ANSI.GetString(LBytes, LStart, LLen) <> ASuffix then begin
      LInsert := TEncoding.ANSI.GetBytes(ASuffix);
      SetLength(LResult, Length(LBytes) - LLen + Length(LInsert));
      Move(LBytes[0], LResult[0], LStart);
      Move(LInsert[0], LResult[LStart], Length(LInsert));
      LTail := Length(LBytes) - LStart - LLen;
      if LTail > 0 then
        Move(LBytes[LStart + LLen], LResult[LStart + Length(LInsert)], LTail);
      TFile.WriteAllBytes(LFile, LResult);
      Log('DelphiVersion.inc now names suffix ' + ASuffix + '.');
    end;
  end else
    Log('No VT_SUFFIX_ line in DelphiVersion.inc - add {$DEFINE VT_SUFFIX_' + ASuffix +
        '} by hand.');

  LBytes := TFile.ReadAllBytes(LFile);

  if FindBytes(LBytes, TEncoding.ANSI.GetBytes('{$IFDEF ' + LSymbol + '}'), 0) >= 0 then begin
    Log('DelphiVersion.inc already accepts ' + LSymbol + '.');
    Exit;
  end;

  LLine := '{$IFDEF ' + LSymbol + '}{$IFDEF VT_SUFFIX_' + ASuffix +
           '}{$UNDEF VT_WRONG_DELPHI}{$ENDIF}{$ENDIF}   // library suffix ' + ASuffix;

  LAt := LastIndexOfBytes(LBytes, TEncoding.ANSI.GetBytes('{$UNDEF VT_WRONG_DELPHI}{$ENDIF}'));
  if LAt < 0 then begin
    Log('The version list in DelphiVersion.inc was not recognised. Add this line by hand:');
    Log('    ' + LLine);
    Exit;
  end;

  // Just past the end of that line, so the new one lands underneath it.
  LEol := LAt;
  while (LEol < Length(LBytes)) and (LBytes[LEol] <> 10) do
    System.Inc(LEol);
  if LEol < Length(LBytes) then
    System.Inc(LEol);

  LInsert := TEncoding.ANSI.GetBytes(LLine + sLineBreak);

  SetLength(LResult, Length(LBytes) + Length(LInsert));
  Move(LBytes[0], LResult[0], LEol);
  Move(LInsert[0], LResult[LEol], Length(LInsert));
  LTail := Length(LBytes) - LEol;
  if LTail > 0 then
    Move(LBytes[LEol], LResult[LEol + Length(LInsert)], LTail);

  TFile.WriteAllBytes(LFile, LResult);
  Log('DelphiVersion.inc now accepts ' + LSymbol + ' as well.');
end;

//----------------------------------------------------------------------------------------------

procedure TFormMain.btnPatchClick(Sender: TObject);
var
  LSuffix, LName, LBefore: string;
  LChanged, LSkipped: Integer;
begin
  LSuffix := Trim(edSuffix.Text);
  if not IsPlausibleSuffix(LSuffix) then begin
    Log('"' + LSuffix + '" is not a suffix. Two to six digits, for example 290.');
    Exit;
  end;

  LChanged := 0;
  LSkipped := 0;
  for LName in PackageFiles do begin
    if not ReadValue(LName, LBefore) then begin
      Log('Skipped ' + TPath.GetFileName(LName) + ': no suffix in it');
      System.Inc(LSkipped);
      Continue;
    end;

    if LBefore = LSuffix then begin
      Log('Unchanged ' + TPath.GetFileName(LName) + ': already ' + LSuffix);
      System.Inc(LSkipped);
      Continue;
    end;

    if chkBackup.Checked and not BackupFile(LName) then begin
      Log('Stopped: ' + TPath.GetFileName(LName) + ' could not be backed up');
      Break;
    end;

    if WriteValue(LName, LSuffix) then begin
      Log(Format('%s: %s -> %s', [TPath.GetFileName(LName), LBefore, LSuffix]));
      System.Inc(LChanged);
    end else begin
      Log('Failed to write ' + TPath.GetFileName(LName));
    end;
  end;

  UpdateVersionList(LSuffix);

  Scan;
  Log(Format('Done. %d changed, %d left as they were.', [LChanged, LSkipped]));
  if LChanged > 0 then
    Log('Close the package projects in the IDE before building, or it will save the old ' +
        'suffix back over this.');
end;

end.
