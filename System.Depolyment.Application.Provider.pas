unit System.Depolyment.Application.Provider;

interface

uses
  System.SysUtils,
  System.Deployment.Application.Updater,
  System.Deployment.Application.Transfer,
  System.Deployment.Application.Transfer.Filesystem;

type
  IClickOnceProvider = interface(IInvokable)
    ['{10C11690-96C3-441C-AB72-05640BF60389}']

    function UpdateAddress(const Value: String): IClickOnceProvider; overload;
    function UpdateAddress(): String; overload;

    function IncludeFiles(Value: TArray<String>): IClickOnceProvider; overload;
    function IncludeFiles(): TArray<String>; overload;

    function CreateFilesIfNotExists(Value: TArray<String>): IClickOnceProvider; overload;
    function CreateFilesIfNotExists(): TArray<String>; overload;

    function DoBeforeUpdate(Value: TFunc<String, Boolean>): IClickOnceProvider; overload;
    function DoBeforeUpdate(): TFunc<String, Boolean>; overload;

    function DoMakeBackupBefore(Value: TFunc<String, Boolean>): IClickOnceProvider; overload;
    function DoMakeBackupBefore(): TFunc<String, Boolean>; overload;

    procedure CheckForUpdate();
  end;

  TClickOnceProvider = class(TInterfacedObject, IClickOnceProvider)
  strict private
    FTransferWorker: ITransferNewApp;
    FAppUpdater: IClickOnceBaseUpdater;

    FUpdateAddress: string;
    FIncludeFiles: TArray<String>;
    FCreateFilesIfNotExists: TArray<String>;

    FDoBeforeUpdate: TFunc<String, Boolean>;
    FDoMakeBackupBefore: TFunc<String, Boolean>;
  public
    constructor Create(); overload;
    constructor Create(TransferWorker: ITransferNewApp); overload;
    constructor Create(AppUpdater: IClickOnceBaseUpdater; TransferWorker: ITransferNewApp); overload;

    destructor Destroy; override;

    function UpdateAddress(const Value: String): IClickOnceProvider; overload;
    function UpdateAddress(): String; overload;

    function IncludeFiles(Value: TArray<String>): IClickOnceProvider; overload;
    function IncludeFiles(): TArray<String>; overload;

    function CreateFilesIfNotExists(Value: TArray<String>): IClickOnceProvider; overload;
    function CreateFilesIfNotExists(): TArray<String>; overload;

    function DoBeforeUpdate(Value: TFunc<String, Boolean>): IClickOnceProvider; overload;
    function DoBeforeUpdate(): TFunc<String, Boolean>; overload;

    function DoMakeBackupBefore(Value: TFunc<String, Boolean>): IClickOnceProvider; overload;
    function DoMakeBackupBefore(): TFunc<String, Boolean>; overload;

    procedure CheckForUpdate();
  end;

implementation

{ TClickOnceProvider }

constructor TClickOnceProvider.Create();
begin
  Create(TClickOnceBaseUpdaterFactory.GetInstance, TTransferNewAppFileSystem.Create);
end;

constructor TClickOnceProvider.Create(TransferWorker: ITransferNewApp);
begin
  Create(TClickOnceBaseUpdaterFactory.GetInstance, TransferWorker);
end;

constructor TClickOnceProvider.Create(AppUpdater: IClickOnceBaseUpdater; TransferWorker: ITransferNewApp);
begin
  inherited Create();

  FTransferWorker := TransferWorker;
  FAppUpdater := AppUpdater;
  FDoMakeBackupBefore := nil;
end;

destructor TClickOnceProvider.Destroy;
begin
  FAppUpdater := nil;
  inherited;
end;

function TClickOnceProvider.DoBeforeUpdate: TFunc<String, Boolean>;
begin
  Result := FDoBeforeUpdate;
end;

function TClickOnceProvider.DoBeforeUpdate(Value: TFunc<String, Boolean>): IClickOnceProvider;
begin
  FDoBeforeUpdate := Value;
  Result := Self;
end;

function TClickOnceProvider.DoMakeBackupBefore: TFunc<String, Boolean>;
begin
  Result := FDoMakeBackupBefore;
end;

function TClickOnceProvider.DoMakeBackupBefore(Value: TFunc<String, Boolean>): IClickOnceProvider;
begin
  FDoMakeBackupBefore := Value;
  Result := Self;
end;

function TClickOnceProvider.IncludeFiles(Value: TArray<String>): IClickOnceProvider;
begin
  FIncludeFiles := Value;
  Result := Self;
end;

function TClickOnceProvider.IncludeFiles: TArray<String>;
begin
  Result := FIncludeFiles;
end;

function TClickOnceProvider.CreateFilesIfNotExists: TArray<String>;
begin
  Result := FCreateFilesIfNotExists;
end;

function TClickOnceProvider.CreateFilesIfNotExists(Value: TArray<String>): IClickOnceProvider;
begin
  FCreateFilesIfNotExists := Value;
  Result := Self;
end;

function TClickOnceProvider.UpdateAddress(const Value: String): IClickOnceProvider;
begin
  FUpdateAddress := Value;
  Result := Self;
end;

function TClickOnceProvider.UpdateAddress: String;
begin
  Result := FUpdateAddress;
end;

procedure TClickOnceProvider.CheckForUpdate;
begin
  FAppUpdater
    .UpdateAddress(FUpdateAddress)
    .IncludeFiles(FIncludeFiles)
    .CreateFilesIfNotExists(FCreateFilesIfNotExists)
    .MakeBackupBefore(True)
    .DoMakeBackupBefore(FDoMakeBackupBefore)
    .TransferWorker(FTransferWorker);

  if (FAppUpdater.NewVersionAvailable and (not FAppUpdater.WeAreUnderUpdate)) then
  begin
    if Assigned(FDoBeforeUpdate) and FDoBeforeUpdate(FUpdateAddress) then
    begin
      FAppUpdater.Update();
    end;
  end
  else
  if FAppUpdater.WeAreUnderUpdate then
  begin
    FAppUpdater.Replace();
  end;
end;

end.
