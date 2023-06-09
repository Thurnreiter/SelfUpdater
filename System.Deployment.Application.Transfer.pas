unit System.Deployment.Application.Transfer;

interface

type
  ITransferNewApp = interface(IInvokable)
    ['{3B8F6DC4-DCCE-4FAA-BF0F-430258FEFF90}']

    function Source(const Value: String): ITransferNewApp; overload;
    function Source(): String; overload;

    function Destination(const Value: String): ITransferNewApp; overload;
    function Destination(): String; overload;

    function IncludeFiles(Value: TArray<String>): ITransferNewApp; overload;
    function IncludeFiles(): TArray<String>; overload;

    function CreateFilesIfNotExists(Value: TArray<String>): ITransferNewApp; overload;
    function CreateFilesIfNotExists(): TArray<String>; overload;

    function NewVersionAvailable: Boolean;

    function Transfer(): Integer;
  end;

implementation

end.
