unit System.Diagnostics.Wrapper;

interface

{$M+}

type
  IProcess = interface
    ['{DE616CD4-937B-49C6-AA10-E9DFB9C43860}']
    function ShellExecuteEx(const AFileName, AParams: string; ShowWindow: Word; var ExitCode: Cardinal): Boolean;

    procedure ShellExecute(const AFileName: string); overload;
    procedure ShellExecute(const AFileName, AParams: string); overload;

    procedure ShellExplorerFolder(const AFileName: string);

    procedure StartBrowser(const ABrowser: string); overload;
    procedure StartBrowser(const ABrowser, AParams: string); overload;

    function KillProcess(const AppName: string): Boolean;

    function ProcessExists(const AppFileName: string): Boolean;

    function GetAppVersionStr(const Exe: string): string;
  end;


  TProcess = class(TInterfacedObject, IProcess)
  public
    function ShellExecuteEx(const AFileName, AParams: string; ShowWindow: Word; var ExitCode: Cardinal): Boolean;

    procedure ShellExecute(const AFileName: string); overload;
    procedure ShellExecute(const AFileName, AParams: string); overload;

    procedure ShellExplorerFolder(const AFileName: string);

    procedure StartBrowser(const ABrowser: string); overload;
    procedure StartBrowser(const ABrowser, AParams: string); overload;

    function KillProcess(const AppName: string): Boolean;

    function ProcessExists(const AppFileName: string): Boolean;

    function GetAppVersionStr(const Exe: string): string;
  end;

  TProcessFactory = class
  public
    class function GetInstance(): IProcess;
  end;

{$M-}

implementation

uses
  System.SysUtils,
  System.IOUtils,

{$IFDEF MSWINDOWS}

//  {$IFDEF FMX}
//  FMX.Forms,
//  {$ENDIF}
//  {$IFDEF VCL}
//  VCL.Forms,
//  {$ENDIF}

//{$IF DECLARED(FireMonkeyVersion)}
//  FMX.Forms,
//{$ELSE}
  VCL.Forms,
//{$IFEND}
//
////{$IF FMX.Types.FireMonkeyVersion >= 0} // if FireMonkey
////{$ELSE}
////{$IFEND}


  Winapi.Windows,
  WinApi.ShellAPI,
  Winapi.TlHelp32
{$ENDIF}
  ;

{ TProcess }

function TProcess.ShellExecuteEx(const AFileName, AParams: string;
  ShowWindow: Word; var ExitCode: Cardinal): Boolean;
var
  {$IFDEF MSWINDOWS} ExecuteInfo: TShellExecuteInfo; {$ENDIF}
begin
{$IFDEF MSWINDOWS}
  ExitCode := 0;
  FillChar(ExecuteInfo, SizeOf(ExecuteInfo), #0);
  ExecuteInfo.CbSize := SizeOf(ExecuteInfo);
  ExecuteInfo.LpVerb := 'open';
  ExecuteInfo.FMask := SEE_MASK_NOCLOSEPROCESS;
  ExecuteInfo.LpFile := PChar(AFileName);
  ExecuteInfo.LpParameters := PChar(AParams);
  ExecuteInfo.LpDirectory := PChar(TPath.GetDirectoryName(AFileName));
  ExecuteInfo.NShow := ShowWindow;
  Result := WinApi.ShellAPI.ShellExecuteEx(@ExecuteInfo);
  if (Result) and (ExecuteInfo.HProcess <> 0) then
  begin
    WaitForSingleObject(ExecuteInfo.HProcess, INFINITE);
    GetExitCodeProcess(ExecuteInfo.HProcess, ExitCode);
    CloseHandle(ExecuteInfo.HProcess)
  end;
{$ELSE}
  raise ENotImplemented.Create('Wrapper IProcess ShellExecuteEx not implemented.');
{$ENDIF}
end;

procedure TProcess.ShellExecute(const AFileName: string);
begin
  ShellExecute(AFileName, '');
end;

procedure TProcess.ShellExecute(const AFileName, AParams: string);
var
  {$IFDEF MSWINDOWS} Handle: HWND; {$ENDIF}
  Result: Cardinal;
begin
{$IFDEF MSWINDOWS}
  Handle := Application.Handle;
  if Assigned(Application.MainForm) then
    Handle := Application.MainForm.Handle;

  Result := WinApi.ShellAPI.ShellExecute(Handle, 'open', PChar(AFileName), PChar(AParams), nil, SW_SHOWNORMAL);

  //  War der Aufruf erfolgreich, liefert ShellExecute einen Wert > 32
  //  http://msdn.microsoft.com/en-us/library/windows/desktop/bb762153%28v=vs.85%29.aspx
  if (Result <= 32) then
    RaiseLastOSError();
{$ELSE}
  raise ENotImplemented.Create('Wrapper IProcess ShellExecute not implemented.');
{$ENDIF}
end;

procedure TProcess.ShellExplorerFolder(const AFileName: string);
var
  {$IFDEF MSWINDOWS} Handle: HWND; {$ENDIF}
  Result: Cardinal;
begin
{$IFDEF MSWINDOWS}
  if TFile.Exists(AFileName) then
    Exit;

  Handle := Application.Handle;
  if Assigned(Application.MainForm) then
    Handle := Application.MainForm.Handle;

  Result := WinApi.ShellAPI.ShellExecute(Handle, nil, PChar('explorer'), PChar('/select,' + AFileName), nil, SW_SHOW);
  if (Result <= 32) then
    RaiseLastOSError();
{$ELSE}
  raise ENotImplemented.Create('Wrapper IProcess ShellExplorerFolder not implemented.');
{$ENDIF}
end;

procedure TProcess.StartBrowser(const ABrowser: string);
begin
  StartBrowser(ABrowser, '');
end;

procedure TProcess.StartBrowser(const ABrowser, AParams: string);
begin
  ShellExecute(ABrowser, AParams);
end;

function TProcess.KillProcess(const AppName: string): Boolean;
{$IFDEF MSWINDOWS}
var
  HProc: THandle;
  Snapshot: THandle;
  ProcEntry: TProcessEntry32;
{$ENDIF}
begin
  Result := False;
{$IFDEF MSWINDOWS}
  Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    if (Snapshot <> INVALID_HANDLE_VALUE) then
    begin
      ProcEntry.dwSize := SizeOf(ProcessEntry32);
      if (Process32First(Snapshot, ProcEntry)) then
      repeat
        if (LowerCase(ProcEntry.szExeFile) = AppName.ToLower) then
        begin
          HProc := OpenProcess(Process_Terminate, False, ProcEntry.th32ProcessID);
          //  Result := OpenProcess(Winapi.Windows.SYNCHRONIZE, False, ProcEntry.th32ProcessID);
          TerminateProcess(HProc, 0);
          CloseHandle(HProc);
          Result := True;
        end;
      until not Process32Next(Snapshot, ProcEntry);
    end;
  finally
    CloseHandle(Snapshot);
  end;
{$ENDIF}
end;

function TProcess.ProcessExists(const AppFileName: string): Boolean;
{description checks if the process is running URL: http://www.swissdelphicenter.ch/torry/showcode.php?id=2554}
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  Result := False;

  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = AppFileName.ToUpper)
    or (UpperCase(FProcessEntry32.szExeFile) = AppFileName.ToUpper)) then
    begin
      Exit(True);
    end;

    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

function TProcess.GetAppVersionStr(const Exe: string): string;
var
  Size, DummyHandle: DWORD;
  Buffer: TBytes;
  FixedPtr: PVSFixedFileInfo;
begin
  if Exe.IsEmpty then
  begin
    Exit(Exe.Empty);
  end;

  Size := GetFileVersionInfoSize(PChar(Exe), DummyHandle);
  if (Size = 0) then
  begin
    RaiseLastOSError;
  end;

  SetLength(Buffer, Size);
  if not GetFileVersionInfo(PChar(Exe), DummyHandle, Size, Buffer) then
  begin
    RaiseLastOSError;
  end;

  if not VerQueryValue(Buffer, '\', Pointer(FixedPtr), Size) then
  begin
    RaiseLastOSError;
  end;

  Result := Format('%d.%d.%d.%d',
    [LongRec(FixedPtr.dwFileVersionMS).Hi,  //  major
     LongRec(FixedPtr.dwFileVersionMS).Lo,  //  minor
     LongRec(FixedPtr.dwFileVersionLS).Hi,  //  release
     LongRec(FixedPtr.dwFileVersionLS).Lo]) //  build
end;

{ TProcessFactory }

class function TProcessFactory.GetInstance: IProcess;
begin
  Result := TProcess.Create;
end;

end.
