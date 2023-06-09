unit System.Deployment.Application.Transfer.Filesystem;

interface

uses
  System.Deployment.Application.Transfer,
  System.Deployment.Application.Transfer.Base;

type
  TTransferNewAppFileSystem = class(TTransferNewAppBase)
  public
    function NewVersionAvailable: Boolean; override;

    function Transfer(): Integer; override;
  end;

implementation

uses
  System.IOUtils;

{ TTransferNewAppFileSystem }

function TTransferNewAppFileSystem.NewVersionAvailable: Boolean;
begin
  if TFile.Exists(Source) then
  begin
    //  TProcessFactory.GetInstance.GetAppVersionStr(ParamStr(0))
    //  TProcessFactory.GetInstance.GetAppVersionStr(FSource)
    if (TFile.GetLastWriteTime(Source) > TFile.GetLastWriteTime(ParamStr(0)))
    or (TFile.GetSize(Source) <> TFile.GetSize(ParamStr(0))) then
    begin
      Result := True;
    end;
  end
  else
  begin
    Result := False;
  end;
end;

function TTransferNewAppFileSystem.Transfer: Integer;
begin
  if NewVersionAvailable then
  begin
    TFile.Copy(Source, Destination, True);

    for var ElementIF: string in IncludeFiles do
    begin
      if TFile.Exists(ElementIF) then
      begin
        TFile.Copy(ElementIF, TPath.Combine(TPath.GetLibraryPath(), TPath.GetFileName(ElementIF)), True);
      end;
    end;

    for var ElementIfNot: string in CreateFilesIfNotExists do
    begin
      if (TFile.Exists(ElementIfNot)
      and (not TFile.Exists(TPath.Combine(TPath.GetLibraryPath(), TPath.GetFileName(ElementIfNot))))) then
      begin
        TFile.Copy(ElementIfNot, TPath.Combine(TPath.GetLibraryPath(), TPath.GetFileName(ElementIfNot)), True);
      end;
    end;

    Exit(0);
  end;

  Result := -1;
end;

end.
