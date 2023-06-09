unit Self.Updater.Config;

interface

{$M+}

uses
  Winapi.Windows,
  System.SysUtils,
  System.JSON.Serializers,
  System.JSON.Converters;

type
  [JsonSerialize(TJsonMemberSerialization.&In)]
  TSelfUpdateConfig = record
  public
    [JsonIn]
    [JsonName('UpdateAddress')]
    UpdateAddress: string;

    [JsonIn]
    [JsonName('UpdateAddressIncludeFiles')]
    UpdateAddressIncludeFiles: TArray<String>;

    [JsonIn]
    [JsonName('UpdateAddressCreateIfNotExists')]
    UpdateAddressCreateIfNotExists: TArray<String>;

    function ToJson(): string;

    constructor Create(const AConfigFilename: string); overload;

    //  https://stackoverflow.com/questions/39392920/how-can-delphi-records-be-initialized-automatically
    //  https://docwiki.embarcadero.com/RADStudio/Sydney/en/Custom_Managed_Records
    class operator Initialize(out Dest: TSelfUpdateConfig);
  end;

{$M-}

implementation

uses
  System.IOUtils,
  System.JSON.Types;

{ TSelfUpdateConfig }

constructor TSelfUpdateConfig.Create(const AConfigFilename: string);
var
  JsonValue: string;
  Serializer: TJsonSerializer;
begin
  if TFile.Exists(AConfigFilename) then
  begin
    Serializer := TJsonSerializer.Create;
    try
      JsonValue := TFile.ReadAllText(AConfigFilename);
      Self := Serializer.Deserialize<TSelfUpdateConfig>(JsonValue);
    finally
      Serializer.Free;
    end;
  end;
end;

function TSelfUpdateConfig.ToJson: string;
var
  Serializer: TJsonSerializer;
begin
  Serializer := TJsonSerializer.Create;
  try
    Serializer.Formatting := TJsonFormatting.Indented;  //  Line Breaks...
    Result := Serializer.Serialize<TSelfUpdateConfig>(Self);
  finally
    Serializer.Free;
  end;
end;


class operator TSelfUpdateConfig.Initialize(out Dest: TSelfUpdateConfig);
begin
  Dest.UpdateAddress := 'C:\temp\github\Win64\Debug\SelfUpdaterDemoConsole.exe';
  Dest.UpdateAddressIncludeFiles := ['C:\temp\github\Self.Updater.config'];
  Dest.UpdateAddressCreateIfNotExists := ['C:\temp\README.md'];
end;

end.
