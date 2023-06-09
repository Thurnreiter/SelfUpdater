unit System.Deployment.Application.Transfer.Base;

interface

uses
  System.Deployment.Application.Transfer;

type
  TTransferNewAppBase = class(TInterfacedObject, ITransferNewApp)
  strict private
    FSource: string;
    FDestination: string;
    FIncludeFiles: TArray<String>;
    FCreateFilesIfNotExists: TArray<String>;
  public
    constructor Create();
    destructor Destroy; override;

    function Source(const Value: String): ITransferNewApp; overload;
    function Source(): String; overload;

    function Destination(const Value: String): ITransferNewApp; overload;
    function Destination(): String; overload;

    function IncludeFiles(Value: TArray<String>): ITransferNewApp; overload;
    function IncludeFiles(): TArray<String>; overload;

    function CreateFilesIfNotExists(Value: TArray<String>): ITransferNewApp; overload;
    function CreateFilesIfNotExists(): TArray<String>; overload;

    function NewVersionAvailable: Boolean; virtual; abstract;

    function Transfer(): Integer; virtual; abstract;
  end;

implementation

uses
  System.IOUtils;

{ TTransferNewAppBase }

constructor TTransferNewAppBase.Create;
begin
  inherited Create();
  //...
end;

destructor TTransferNewAppBase.Destroy;
begin
  //...
  inherited;
end;

function TTransferNewAppBase.IncludeFiles: TArray<String>;
begin
  Result := FIncludeFiles;
end;

function TTransferNewAppBase.IncludeFiles(Value: TArray<String>): ITransferNewApp;
begin
  FIncludeFiles := Value;
  Result := Self;
end;

function TTransferNewAppBase.CreateFilesIfNotExists: TArray<String>;
begin
  Result := FCreateFilesIfNotExists;
end;

function TTransferNewAppBase.CreateFilesIfNotExists(Value: TArray<String>): ITransferNewApp;
begin
  FCreateFilesIfNotExists := Value;
  Result := Self;
end;

function TTransferNewAppBase.Destination(const Value: String): ITransferNewApp;
begin
  FDestination := Value;
  Result := Self;
end;

function TTransferNewAppBase.Destination: String;
begin
  Result := FDestination;
end;

function TTransferNewAppBase.Source(const Value: String): ITransferNewApp;
begin
  FSource := Value;
  Result := Self;
end;

function TTransferNewAppBase.Source: String;
begin
  Result := FSource;
end;

end.
