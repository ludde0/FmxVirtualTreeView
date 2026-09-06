unit VirtualTrees.Debug;

interface

type
  TDebug = class
  public
    class procedure Log(AText: string);
    class procedure Clear; // Clears the log file and the in-memory log.
    class function  LogText: string;
    class function  FilePath: string;
  end;

implementation

uses
  System.Classes, System.SysUtils, System.IOUtils, System.SyncObjs;

var
  GLock: TCriticalSection;
  GLines: TStringList;

class function TDebug.FilePath: string;
begin
  Result := TPath.Combine(TPath.GetDocumentsPath, 'DebugLog.txt');
end;

class procedure TDebug.Log(AText: string);
var
  ALine: string;
begin
  ALine := FormatDateTime('hh:nn:ss.zzz', Now) + ' ' + AText;
  GLock.Enter;
  try
    GLines.Add(ALine);
    try
      TFile.AppendAllText(FilePath, ALine + sLineBreak, TEncoding.UTF8);
    except
      // Never let logging break the app.
    end;
  finally
    GLock.Leave;
  end;
end;

class procedure TDebug.Clear;
begin
  GLock.Enter;
  try
    GLines.Clear;
    try
      if TFile.Exists(FilePath) then begin
        TFile.Delete(FilePath);
      end;
    except
      // Never let logging break the app.
    end;
  finally
    GLock.Leave;
  end;
end;

class function TDebug.LogText: string;
begin
  GLock.Enter;
  try
    Result := GLines.Text;
  finally
    GLock.Leave;
  end;
end;

initialization
  GLock := TCriticalSection.Create;
  GLines := TStringList.Create;
finalization
  GLines.Free;
  GLock.Free;
end.
