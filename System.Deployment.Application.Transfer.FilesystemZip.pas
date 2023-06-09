unit System.Deployment.Application.Transfer.FilesystemZip;

interface

uses
  System.Classes,
  System.Zip,
  System.Deployment.Application.Transfer,
  System.Deployment.Application.Transfer.Base;

type
  TTransferNewAppFileSystemZip = class(TTransferNewAppBase)
  private
    function OnCreateDecompressStream(const AInStream: TStream; const AZipFile: TZipFile; const AHeader: TZipHeader; AIsEncrypted: Boolean): TStream;
  public
    function NewVersionAvailable: Boolean; override;

    function Transfer(): Integer; override;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils;

{ TTransferNewAppFileSystemZip }

function TTransferNewAppFileSystemZip.OnCreateDecompressStream(const AInStream: TStream; const AZipFile: TZipFile;
  const AHeader: TZipHeader; AIsEncrypted: Boolean): TStream;
begin
  try
    if AIsEncrypted then
    begin
      // Perform decrypt operation on AInStream. For example, you can use your own implementation of CryptZip or AES-256.
      // Result := DecryptedStream;
    end
    else
       Result := AInStream;
  except
    on E: Exception do
    begin
      Result := AInStream;
    end;
  end;
end;

function TTransferNewAppFileSystemZip.NewVersionAvailable: Boolean;
begin
  Result := TFile.Exists(Source) and TZipFile.IsValid(Source);
end;

function TTransferNewAppFileSystemZip.Transfer: Integer;
begin
//    var myZipFile := TZipFile.Create;
//    myZipFile.OnCreateDecompressStream := OnCreateDecompressStream;
//    try
//      myZipFile.ExtractAll('');
//      myZipFile.Close;
//    finally
//      myZipFile.Free;
//    end;

//  oZip := TZipFile.Create;
//  try
//    sTempPath := TPath.GetTempPath + TGUID.NewGuid.ToString + PathDelim;
//    oZip.ExtractZipFile(AFilename, sTempPath);
//    ImportFiles(sTempPath);
//    TDirectory.Delete(sTempPath, True);
//  finally
//    oZip.Free;
//  end;

//        TFile.Copy(ElementIF, TPath.Combine(TPath.GetLibraryPath(), TPath.GetFileName(ElementIF)), True);
//    Destination

  var ExtractPath := TPath.Combine(TPath.GetLibraryPath(), 'New');
  TZipFile.ExtractZipFile(Source, ExtractPath);

  ExtractPath := TPath.Combine(ExtractPath, TPath.GetFileName(ParamStr(0)));

  TFile.Move(ExtractPath, Destination);

  Exit(0);
end;

end.
