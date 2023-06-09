program SelfUpdaterDemoConsole;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Deployment.Application.Transfer.Base in 'System.Deployment.Application.Transfer.Base.pas',
  System.Deployment.Application.Transfer.Filesystem in 'System.Deployment.Application.Transfer.Filesystem.pas',
  System.Deployment.Application.Transfer.FilesystemZip in 'System.Deployment.Application.Transfer.FilesystemZip.pas',
  System.Deployment.Application.Transfer in 'System.Deployment.Application.Transfer.pas',
  System.Deployment.Application.Updater in 'System.Deployment.Application.Updater.pas',
  System.Depolyment.Application.Provider in 'System.Depolyment.Application.Provider.pas',
  Self.Updater.Config in 'Self.Updater.Config.pas',
  System.Diagnostics.Wrapper in 'System.Diagnostics.Wrapper.pas',
  Self.Updater.Config.Factory in 'Self.Updater.Config.Factory.pas';

const
  ERROR_SUCCESS = 0;
  ERROR_INVALID_FUNCTION = 1;

var
  ClickOnceProvider: IClickOnceProvider;
  ConfigFileLoader:  ISelfUpdateConfigFactory;
  ConfigFile: TSelfUpdateConfig;
  StartingUpdate: string;
begin
  try
    ConfigFileLoader := TSelfUpdateConfigFactory.Create;
    ConfigFile := ConfigFileLoader
      .ReturnMessage(
        procedure(OutputValue: string)
        begin
          System.Write(OutputValue);
          System.ExitCode := ERROR_INVALID_FUNCTION;
          System.Readln;
          Halt;
        end)
      .Load();

    ClickOnceProvider := TClickOnceProvider.Create(TTransferNewAppFileSystem.Create);
    ClickOnceProvider
      .UpdateAddress(ConfigFile.UpdateAddress)
      .IncludeFiles(ConfigFile.UpdateAddressIncludeFiles)
      .CreateFilesIfNotExists(ConfigFile.UpdateAddressCreateIfNotExists)
      .DoBeforeUpdate(
        function(UpdateFile: string): Boolean
        begin
          Write('There is a new version available for installation. Download and install [Y/N]? ');
          Readln(StartingUpdate);
          Result := StartingUpdate.ToLower.StartsWith('y');
        end)
      .CheckForUpdate;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      Writeln('Close console. Press an key.');
      System.Readln;
    end;
  end;
end.
