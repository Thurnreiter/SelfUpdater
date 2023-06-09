unit Self.Updater.Config.Factory;

interface

uses
  System.SysUtils,
  Self.Updater.Config;

type
  ISelfUpdateConfigFactory = interface(IInvokable)
    ['{41D9A02E-D49D-44F8-B01E-EB385B8AED3E}']

    function ReturnMessage(const Value: TProc<String>): ISelfUpdateConfigFactory; overload;
    function ReturnMessage(): TProc<String>; overload;

    function Load(): TSelfUpdateConfig;
  end;

  TSelfUpdateConfigFactory = class(TInterfacedObject, ISelfUpdateConfigFactory)
  strict private
    FReturnMessage: TProc<String>;

    procedure NoConfigFound(const CfgName: string);
  public
    function ReturnMessage(const Value: TProc<String>): ISelfUpdateConfigFactory; overload;
    function ReturnMessage(): TProc<String>; overload;

    function Load(): TSelfUpdateConfig;
  end;

implementation

uses
  System.Types,
  System.IOUtils;

{ TSelfUpdateConfigFactory }

function TSelfUpdateConfigFactory.ReturnMessage: TProc<String>;
begin
  Result := FReturnMessage;
end;

function TSelfUpdateConfigFactory.ReturnMessage(const Value: TProc<String>): ISelfUpdateConfigFactory;
begin
  FReturnMessage := Value;
  Result := Self;
end;

function TSelfUpdateConfigFactory.Load: TSelfUpdateConfig;
begin
  var AppParamValue: string := '.\Self.Updater.config';

  if (not FindCmdLineSwitch('c:', AppParamValue)) then
  begin
    var ListOfFromFiles: TStringDynArray := TDirectory.GetFiles(TPath.GetLibraryPath(), '*.config');
    if (Length(ListOfFromFiles) = 0) then
    begin
      NoConfigFound('under ' + TPath.GetFileName(ParamStr(0)));
      Exit;
    end;

    if TFile.Exists(ListOfFromFiles[0]) then
    begin
      Exit(TSelfUpdateConfig.Create(ListOfFromFiles[0]));
    end
    else
    begin
      NoConfigFound(ListOfFromFiles[0]);
    end;
  end
  else
  begin
    if TFile.Exists(AppParamValue) then
    begin
      Exit(TSelfUpdateConfig.Create(AppParamValue));
    end
    else
    begin
      NoConfigFound(AppParamValue);
    end;
  end;
end;

procedure TSelfUpdateConfigFactory.NoConfigFound(const CfgName: string);
var
  InnerText: string;
begin
  InnerText := sLineBreak
    + '*.config not found ' + CfgName
    + sLineBreak
    + sLineBreak
    + 'Usage: ' + TPath.GetFileName(ParamStr(0)) + ' -c:".\Self.Updater.config"'
    + ' -c: Name of the config file.'
    + sLineBreak
    + sLineBreak
    + 'Done.. press <Enter> key to quit.';

  if Assigned(FReturnMessage) then
    FReturnMessage(InnerText)
end;

end.
