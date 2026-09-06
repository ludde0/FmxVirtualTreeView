program TestTreeViewVcl;

uses
  Vcl.Forms,
  VirtualTrees in '..\..\Source\VirtualTrees.pas',
  VirtualTrees.AccessibilityFactory in '..\..\Source\VirtualTrees.AccessibilityFactory.pas',
  VirtualTrees.AncestorVcl in '..\..\Source\VirtualTrees.AncestorVcl.pas',
  VirtualTrees.BaseAncestorVcl in '..\..\Source\VirtualTrees.BaseAncestorVcl.pas',
  VirtualTrees.BaseTree in '..\..\Source\VirtualTrees.BaseTree.pas',
  VirtualTrees.Classes in '..\..\Source\VirtualTrees.Classes.pas',
  VirtualTrees.ClipBoard in '..\..\Source\VirtualTrees.ClipBoard.pas',
  VirtualTrees.Colors in '..\..\Source\VirtualTrees.Colors.pas',
  VirtualTrees.DataObject in '..\..\Source\VirtualTrees.DataObject.pas',
  VirtualTrees.DragImage in '..\..\Source\VirtualTrees.DragImage.pas',
  VirtualTrees.DragnDrop in '..\..\Source\VirtualTrees.DragnDrop.pas',
  VirtualTrees.DrawTree in '..\..\Source\VirtualTrees.DrawTree.pas',
  VirtualTrees.EditLink in '..\..\Source\VirtualTrees.EditLink.pas',
  VirtualTrees.Export in '..\..\Source\VirtualTrees.Export.pas',
  VirtualTrees.Header in '..\..\Source\VirtualTrees.Header.pas',
  VirtualTrees.StyleHooks in '..\..\Source\VirtualTrees.StyleHooks.pas',
  VirtualTrees.Types in '..\..\Source\VirtualTrees.Types.pas',
  VirtualTrees.Utils in '..\..\Source\VirtualTrees.Utils.pas',
  VirtualTrees.WorkerThread in '..\..\Source\VirtualTrees.WorkerThread.pas',
  uFormVcl in 'uFormVcl.pas' {FormVcl};

{$R *.res}

begin
{$WARN SYMBOL_PLATFORM OFF}
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
{$WARN SYMBOL_PLATFORM ON}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormVcl, FormVcl);
  Application.Run;
end.
