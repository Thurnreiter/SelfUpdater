unit System.Deployment.Application.Updater;

interface

uses
  System.SysUtils,
  System.Deployment.Application.Transfer;

type
  IClickOnceBaseUpdater = interface(IInvokable)
    ['{F7475555-45DA-4CF5-82ED-7853695E8E76}']

    function UpdateAddress(const Value: String): IClickOnceBaseUpdater; overload;
    function UpdateAddress(): String; overload;

    function IncludeFiles(Value: TArray<String>): IClickOnceBaseUpdater; overload;
    function IncludeFiles(): TArray<String>; overload;

    function CreateFilesIfNotExists(Value: TArray<String>): IClickOnceBaseUpdater; overload;
    function CreateFilesIfNotExists(): TArray<String>; overload;

    function MakeBackupBefore(Value: Boolean): IClickOnceBaseUpdater; overload;
    function MakeBackupBefore(): Boolean; overload;

    function DoMakeBackupBefore(Value: TFunc<String, Boolean>): IClickOnceBaseUpdater; overload;
    function DoMakeBackupBefore(): TFunc<String, Boolean>; overload;

    function TransferWorker(Value: ITransferNewApp): IClickOnceBaseUpdater; overload;
    function TransferWorker(): ITransferNewApp; overload;

    function NewVersionAvailable: Boolean;
    function WeAreUnderUpdate: Boolean;

    function Update(): Integer;
    function Replace(): Integer;
  end;

  TClickOnceBaseUpdater = class(TInterfacedObject, IClickOnceBaseUpdater)
  strict private
    FPostfixExtension: string;
    FUpdateAddress: string;
    FDestinationApp: string;
    FTransferWorker: ITransferNewApp;
    FIncludeFiles: TArray<String>;
    FCreateFilesIfNotExists: TArray<String>;
    FMakeBackupBefore: Boolean;
    FDoMakeBackupBefore: TFunc<String, Boolean>;
  private
    procedure StartNewApp(const FilenameToStart: string);
    procedure MakeBackup();
    procedure CallDoMakeBackup();

    function TerminateSelf(): Integer;
  public const
    ERROR_NO_TRANSFERER = -1;
    ERROR_INVALID_UPDATEADDRESS = 1;
    UPDATE_SUCCESS = 0;
    NO_NEWVERSIONAVAILABLE = 1000;

    UpdParam = 'update:';
    ExUpdateAddress = 'Invalid or no update address found.';
    ExNoTransferer = 'No transfer worker class found.';
  public
    constructor Create();
    destructor Destroy; override;

    function UpdateAddress(const Value: String): IClickOnceBaseUpdater; overload;
    function UpdateAddress(): String; overload;

    function IncludeFiles(Value: TArray<String>): IClickOnceBaseUpdater; overload;
    function IncludeFiles(): TArray<String>; overload;

    function CreateFilesIfNotExists(Value: TArray<String>): IClickOnceBaseUpdater; overload;
    function CreateFilesIfNotExists(): TArray<String>; overload;

    function MakeBackupBefore(Value: Boolean): IClickOnceBaseUpdater; overload;
    function MakeBackupBefore(): Boolean; overload;

    function DoMakeBackupBefore(Value: TFunc<String, Boolean>): IClickOnceBaseUpdater; overload;
    function DoMakeBackupBefore(): TFunc<String, Boolean>; overload;

    function TransferWorker(Value: ITransferNewApp): IClickOnceBaseUpdater; overload;
    function TransferWorker(): ITransferNewApp; overload;

    function NewVersionAvailable: Boolean;
    function WeAreUnderUpdate: Boolean;

    function Update(): Integer;
    function Replace(): Integer;
  end;

  TClickOnceBaseUpdaterFactory = class
  public
    class function GetInstance(): IClickOnceBaseUpdater;
  end;


implementation

uses
  {$IFNDEF CONSOLE}
  Vcl.Forms,
  {$ENDIF}
  System.IOUtils,
  System.Diagnostics.Wrapper;

{ TClickOnceBaseUpdater }

constructor TClickOnceBaseUpdater.Create;
begin
  inherited Create();
  FPostfixExtension := FormatDateTime('_yyyymmddhhmmss', Now());
  FDestinationApp := Format('%s%s.exe', [ParamStr(0), FPostfixExtension]);

  {TODO : Only for developing}
//  FDestinationApp := Format('%s%s.exe', [ParamStr(0), FormatDateTime('_yyyymmdd', Now())]);

  FMakeBackupBefore := True;
  FDoMakeBackupBefore := nil;
end;

destructor TClickOnceBaseUpdater.Destroy;
begin
  FTransferWorker := nil;
  inherited;
end;

function TClickOnceBaseUpdater.UpdateAddress: String;
begin
  Result := FUpdateAddress;
end;

function TClickOnceBaseUpdater.UpdateAddress(const Value: String): IClickOnceBaseUpdater;
begin
  FUpdateAddress := Value;
  Result := Self;
end;

procedure TClickOnceBaseUpdater.StartNewApp(const FilenameToStart: string);
begin
  if TFile.Exists(FilenameToStart) then
  begin
    //TProcessFactory.GetInstance.ShellExecute(FilenameToStart, '-update:' + TPath.GetFileNameWithoutExtension(ParamStr(0)));
    TProcessFactory.GetInstance.ShellExecute(FilenameToStart, '-' + UpdParam + TPath.GetFileName(ParamStr(0)));
  end;
end;

function TClickOnceBaseUpdater.TerminateSelf(): Integer;
begin
  {$IFDEF CONSOLE}
  Result := UPDATE_SUCCESS;
  Halt;
  {$ELSE}
  Application.Terminate;
  {$ENDIF}
end;

function TClickOnceBaseUpdater.TransferWorker: ITransferNewApp;
begin
  Result := FTransferWorker;
end;

function TClickOnceBaseUpdater.TransferWorker(Value: ITransferNewApp): IClickOnceBaseUpdater;
begin
  FTransferWorker := Value;
  Result := Self;
end;

function TClickOnceBaseUpdater.IncludeFiles: TArray<String>;
begin
  Result := FIncludeFiles;
end;

function TClickOnceBaseUpdater.IncludeFiles(Value: TArray<String>): IClickOnceBaseUpdater;
begin
  FIncludeFiles := Value;
  Result := Self;
end;

function TClickOnceBaseUpdater.CreateFilesIfNotExists: TArray<String>;
begin
  Result := FCreateFilesIfNotExists;
end;

function TClickOnceBaseUpdater.CreateFilesIfNotExists(Value: TArray<String>): IClickOnceBaseUpdater;
begin
  FCreateFilesIfNotExists := Value;
  Result := Self;
end;

function TClickOnceBaseUpdater.MakeBackupBefore: Boolean;
begin
  Result := FMakeBackupBefore;
end;

function TClickOnceBaseUpdater.MakeBackupBefore(Value: Boolean): IClickOnceBaseUpdater;
begin
  FMakeBackupBefore := Value;
  Result := Self;
end;

function TClickOnceBaseUpdater.DoMakeBackupBefore: TFunc<String, Boolean>;
begin
  Result := FDoMakeBackupBefore;
end;

function TClickOnceBaseUpdater.DoMakeBackupBefore(Value: TFunc<String, Boolean>): IClickOnceBaseUpdater;
begin
  FDoMakeBackupBefore := Value;
  Result := Self;
end;

function TClickOnceBaseUpdater.NewVersionAvailable: Boolean;
begin
  if FUpdateAddress.IsEmpty then
    raise Exception.Create(TClickOnceBaseUpdater.ExUpdateAddress);

  if (not Assigned(FTransferWorker)) then
    raise Exception.Create(TClickOnceBaseUpdater.ExNoTransferer);

  Result := FTransferWorker
    .Source(FUpdateAddress)
    .Destination(FDestinationApp)
    .NewVersionAvailable;
end;

function TClickOnceBaseUpdater.WeAreUnderUpdate: Boolean;
var
  AppParamValue: string;
begin
  Result := FindCmdLineSwitch(UpdParam, AppParamValue);
end;

procedure TClickOnceBaseUpdater.CallDoMakeBackup();
begin
  FDoMakeBackupBefore(ParamStr(0));
  for var Element: string in FIncludeFiles do
  begin
    FDoMakeBackupBefore(TPath.GetFileName(Element));
  end;
end;

procedure TClickOnceBaseUpdater.MakeBackup;
var
  FullBackupPath: string;
begin
  FullBackupPath := TPath.Combine(TPath.GetLibraryPath, Format('Backup%s', [FPostfixExtension]));
  if (not TDirectory.Exists(FullBackupPath)) then
  begin
    TDirectory.CreateDirectory(FullBackupPath);
    TFile.Copy(ParamStr(0), TPath.Combine(FullBackupPath, TPath.GetFileName(ParamStr(0))), True);
    for var Element: string in FIncludeFiles do
    begin
      TFile.Copy(Element, TPath.Combine(FullBackupPath, TPath.GetFileName(Element)), True);
    end;
  end;
end;

function TClickOnceBaseUpdater.Update(): Integer;
begin
  if FUpdateAddress.IsEmpty then
  begin
    Exit(ERROR_INVALID_UPDATEADDRESS);
  end;

  if (not Assigned(FTransferWorker)) then
  begin
    Exit(ERROR_NO_TRANSFERER);
  end;

  if FMakeBackupBefore then
  begin
    if Assigned(FDoMakeBackupBefore) then
    begin
      CallDoMakeBackup();
    end
    else
    begin
      MakeBackup;
    end;
  end;

  Result := FTransferWorker
    .Source(FUpdateAddress)
    .Destination(FDestinationApp)
    .IncludeFiles(FIncludeFiles)
    .CreateFilesIfNotExists(FCreateFilesIfNotExists)
    .Transfer;

  if (Result = UPDATE_SUCCESS) then
  begin
    StartNewApp(FDestinationApp);
    Result := TerminateSelf();
  end;
end;

function TClickOnceBaseUpdater.Replace: Integer;
var
  AppParamValueFilenameToReplace: string;
begin
  if (FindCmdLineSwitch(UpdParam, AppParamValueFilenameToReplace)) then
  begin
    var Process: IProcess := TProcessFactory.GetInstance;
    if Process.ProcessExists(AppParamValueFilenameToReplace) then
    begin
      Process.KillProcess(AppParamValueFilenameToReplace);

      if Process.ProcessExists(AppParamValueFilenameToReplace) then
      begin
        for var Idx: Integer := 0 to 10 do
        begin
          if Process.ProcessExists(AppParamValueFilenameToReplace) then
            Process.KillProcess(AppParamValueFilenameToReplace);

          Sleep(1000 * Idx);
        end;
      end;
    end;

    var FullDestinationFilename: string := TPath.Combine(TPath.GetLibraryPath, AppParamValueFilenameToReplace);
    if TFile.Exists(FullDestinationFilename) then
    begin
      TFile.Delete(FullDestinationFilename);
    end;

    TFile.Move(ParamStr(0), FullDestinationFilename);
    //  Result := TerminateSelf();
    Result := UPDATE_SUCCESS;
  end;
end;

{ TClickOnceBaseUpdaterFactory }

class function TClickOnceBaseUpdaterFactory.GetInstance: IClickOnceBaseUpdater;
begin
  Result := TClickOnceBaseUpdater.Create;
end;

end.
