program PatchPackagesForDelphi;

uses
  Vcl.Forms,
  uFormMain in 'uFormMain.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Patch packages for this Delphi';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
