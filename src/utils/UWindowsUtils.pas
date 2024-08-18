unit UWindowsUtils;
{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Generics.Collections,
  Classes,
  SysUtils,
  StrUtils,
  Math,
  JclDebug,
  Winapi.Windows,
  Winapi.TlHelp32,
  PsAPI,
  JwaNative,
  JwaNtStatus,
  UNTDLL,
  UGenericUtils;

type

  TProcessInfo = record
    PID: DWORD;
    Name: String;
    ExePath: String;
    Params: String;

    function buildInitializationParam: PChar;
  end;

  TWindowsUtils = class
  private
  public
    class function closeProcess(APID: DWORD): Boolean; overload;
    class function closeProcess(var AProcessInfo: TProcessInfo): Boolean; overload;
    class function runProcess(var AProcessInfo: TProcessInfo): Boolean;

    class procedure cleanAppMemoryFromLeak;
    class procedure cleanMemoryEach(ASeconds: Integer=10);
    class procedure cleanScreen;

    class function getPID(AProcessName: String): DWORD;
    class function getProcessName(APID:DWORD): String;
    class function getFileName(AHandle: THandle): String;

    class function closeHandle(AHandle: THandle): Boolean; overload;
    class function closeHandle(AFileName: String): Boolean; overload;
    class function closeHandle(AHandle: SystemHandle): Boolean; overload;
    class function getHandles(APID:DWORD = 0): TList<SystemHandle>; overload;
    class function getHandles(AProcessName: String): TList<SystemHandle>; overload;
  end;

implementation

{ TWindowsUtils }

class procedure TWindowsUtils.cleanAppMemoryFromLeak;
var
  MainHandle : THandle;
begin
  try
    MainHandle := OpenProcess(PROCESS_ALL_ACCESS, false, GetCurrentProcessID);
    SetProcessWorkingSetSize(MainHandle, $FFFFFFFF, $FFFFFFFF);
    CloseHandle(MainHandle);
    MainHandle := OpenProcess(PROCESS_SET_QUOTA, false, GetCurrentProcessID);
    SetProcessWorkingSetSize(MainHandle, $FFFFFFFF, $FFFFFFFF);
    CloseHandle(MainHandle);
  except
  end;
end;

class procedure TWindowsUtils.cleanMemoryEach(ASeconds: Integer);
begin
  TThread.CreateAnonymousThread(
  procedure
  begin
    sleep(ASeconds*1000);
    cleanAppMemoryFromLeak;
  end);
end;

class procedure TWindowsUtils.cleanScreen;
const
  FMaxBlankLines = 10;  { Maximum number of blank lines to consider for cleanup }
  FMaxLines = 10;      { Maximum number of lines to process in a block }
var
  FHConsole: THandle;
  FScreenBuffer: TConsoleScreenBufferInfo;
  FSize, FDefaultSize, FDifference: Integer;
  FParts, FPart: Integer;
  FOrigin: TCoord;
  NumWritten: DWORD;
  LineBuffer: array of Char;
  FLastChar, FChar: Integer;
begin
  { Get the console handle }
  FHConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  Win32Check(FHConsole <> INVALID_HANDLE_VALUE);
  { Get information about the console screen buffer }
  Win32Check(GetConsoleScreenBufferInfo(FHConsole, FScreenBuffer));
  { Initialize variables }
  FOrigin.X := 0;
  FDifference := FScreenBuffer.dwSize.Y mod FMaxLines;  { Calculate the difference for final adjustment }
  FDefaultSize := FScreenBuffer.dwSize.X * FMaxLines;  { Default size of the read buffer }
  FParts := (FScreenBuffer.dwSize.Y - FDifference) div FMaxLines; { Number of line blocks }
  { Loop to process each block of lines }
  for FPart := 0 to FParts - 1 do
  begin
    FSize := FDefaultSize;
    { Adjust size for the last block }
    if FPart = (FParts - 1) then
      FSize := FSize + FDifference;
    { Prepare the line buffer }
    SetLength(LineBuffer, FSize);
    FOrigin.Y := FPart * FMaxLines;
    { Read the console output }
    Win32Check(ReadConsoleOutputCharacter(
      FHConsole, @LineBuffer[0], FSize, FOrigin, NumWritten));
    { Find the last non-blank character }
    FLastChar := 0;
    for FChar := 0 to FSize - 1 do
    begin
      if LineBuffer[FChar] <> ' ' then
        FLastChar := FChar;
    end;
    { Check if there are enough blank lines to stop the loop }
    if (FMaxLines - (FLastChar div FScreenBuffer.dwSize.X) >= FMaxBlankLines) then
      Break;
  end;
  { Set the origin position for cleanup }
  FOrigin.Y := 0;
  FSize := FScreenBuffer.dwSize.X * ((FPart+1) * FMaxLines);
  { Adjust size if no non-blank characters were found }
  if FLastChar = 0 then
    FSize := FScreenBuffer.dwSize.X * (FPart * FMaxLines);
  { Fill the console with spaces }
  Win32Check(FillConsoleOutputCharacter(
    FHConsole,
    ' ',
    FSize,
    FOrigin,
    NumWritten));
  { Fill the console with the current text attribute }
  Win32Check(FillConsoleOutputAttribute(
    FHConsole,
    FScreenBuffer.wAttributes,
    FSize,
    FOrigin,
    NumWritten));
  { Set the cursor position to the beginning }
  Win32Check(SetConsoleCursorPosition(FHConsole, FOrigin));
end;

class function TWindowsUtils.closeHandle(AHandle: THandle): Boolean;
begin
  Result := False;
  try
    Result := Winapi.Windows.CloseHandle(AHandle);
  finally
  end;
end;

class function TWindowsUtils.closeHandle(AFileName: String): Boolean;
var
  FList: TList<SystemHandle>;
  FResult: Boolean;
begin
  FResult := False;
  FList := getHandles;
  TGenericUtils.forEach<SystemHandle>(FList,
  procedure(ASystemHandle: SystemHandle; out ABreak: Boolean)
  var
    FFileName: String;
  begin
    FFileName := getFileName(ASystemHandle.Handle);
    if FFileName <> 'None' then
      if AFileName = AFileName then
        FResult := closeHandle(ASystemHandle.Handle);
  end);
  Result := FResult;
end;

class function TWindowsUtils.closeHandle(AHandle: SystemHandle): Boolean;
var
  FHProcess, FHObject: THandle;
begin
  FHObject := Default(THandle);
  Result := False;
  FHProcess := OpenProcess(PROCESS_DUP_HANDLE, FALSE, AHandle.uIdProcess);
  if(FHProcess <> INVALID_HANDLE_VALUE) then
  begin
    Result := DuplicateHandle(
      FHProcess,
      AHandle.Handle,
      GetCurrentProcess,
      @FHObject,
      0,
      False,
      DUPLICATE_CLOSE_SOURCE
    );
  end;
  if FHObject <> Default(THandle) then
    CloseHandle(FHObject);
  CloseHandle(FHProcess);
end;

class function TWindowsUtils.closeProcess(APID: DWORD): Boolean;
var
  FHProcess: THandle;
begin
  Result := False;
  FHProcess := OpenProcess(PROCESS_TERMINATE, False, APID);
  if FHProcess <> 0 then
  begin
    try
      Result := TerminateProcess(FHProcess, 0);
    finally
      CloseHandle(FHProcess);
    end;
  end;
end;

class function TWindowsUtils.closeProcess(
  var AProcessInfo: TProcessInfo): Boolean;
begin
  Result := closeProcess(AProcessInfo.PID);
end;

class function TWindowsUtils.getFileName(AHandle: THandle): String;
var
  FFileName: array [0..MAX_PATH - 1] of Char;
  FResult: DWORD;
begin
  Result := 'None';
  try
    FResult := GetFinalPathNameByHandle(AHandle, FFileName, MAX_PATH, FILE_NAME_NORMALIZED);
    if FResult <> 0 then
      Result := StringReplace(String(FFileName),'\\?\','',[rfReplaceAll, rfIgnoreCase]);
  finally
  end;
end;

class function TWindowsUtils.getHandles(AProcessName: String): TList<SystemHandle>;
begin
  Result := getHandles(getPID(AProcessName));
end;

class function TWindowsUtils.getHandles(APID: DWORD): TList<SystemHandle>;
var
  FPHandleInfo : PSystemHandleInformation;
  ReturnLength, SystemInformationLength: DWORD;
  FHQuery,
  FHProcess: THandle;
  FAttempt: Integer;
  FIndex: Integer;
begin
  Result := nil;
  if APID = 0 then
    APID := GetCurrentProcessId;

  {Getting list of Handles}
  FPHandleInfo := nil;
  ReturnLength := 1024;
  FPHandleInfo := AllocMem(ReturnLength);
  FHQuery      := NTQuerySystemInformation(
    SystemHandleInformation,
    FpHandleInfo,
    1024,
    @ReturnLength
  );

  FAttempt     := 0;
  {Trying again to get the list of Handles}
  While (FHQuery = STATUS_INFO_LENGTH_MISMATCH) and (FAttempt < 10) do begin
    Inc(FAttempt);
    FreeMem(FPHandleInfo);
    SystemInformationLength := ReturnLength;
    FPHandleInfo            := AllocMem(ReturnLength+1024);
    FHQuery := NTQuerySystemInformation(
      SystemHandleInformation,
      FPHandleInfo,
      SystemInformationLength,
      @ReturnLength
    );
  end;

  try
    if (FHQuery = STATUS_SUCCESS) then
    begin
      Result := TList<SystemHandle>.Create;
      for FIndex := 0 to FPHandleInfo^.uCount-1 do
      begin
        if FPHandleInfo.Handles[FIndex].uIdProcess = APID then
        begin
          Result.Add(FPHandleInfo.Handles[FIndex]);
        end;
      end;
    end;
  finally
    if FPHandleInfo <> nil then
      FreeMem(FPHandleInfo);
  end;
end;

class function TWindowsUtils.getPID(AProcessName: String): DWORD;
var
  FFindProcess: Boolean;
  FTempHandle: tHandle;
  FProcessEntry: tProcessEntry32;
begin
  FTempHandle:=CreateToolHelp32SnapShot(TH32CS_SNAPALL, 0);
  FProcessEntry.dwSize:=SizeOf(FProcessEntry);
  FFindProcess:=Process32First(FTempHandle, FProcessEntry);
  {$B-}
    if FFindProcess and not SameText(FProcessEntry.szExeFile, AProcessName) then
      repeat FFindProcess := Process32Next(FTempHandle, FProcessEntry);
      until (not FFindProcess) or SameText(FProcessEntry.szExeFile, AProcessName);
  {$B+}
  if FFindProcess then
    result := FProcessEntry.th32ProcessID
  else
    result := 0;
  CloseHandle(FTempHandle);
end;

class function TWindowsUtils.getProcessName(APID: DWORD): String;
var
  FHProcess: THandle;
  FHMod: HMODULE;
  FDWord: DWORD;
  FProcessName: array[0..MAX_PATH] of Char;
begin
  Result := '';
  FHProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, APID);
  if FHProcess > 0 then
  try
    if EnumProcessModules(FHProcess, @FHMod, SizeOf(FHMod), FDWord) then
    begin
      if GetModuleBaseName(FHProcess, FHMod, FProcessName, SizeOf(FProcessName)) > 0 then
        Result := FProcessName;
    end;
  finally
    CloseHandle(FHProcess);
  end;
end;

class function TWindowsUtils.runProcess(var AProcessInfo: TProcessInfo): Boolean;
var
  StartupInfo: TStartupInfo;
  FProcessInfo: TProcessInformation;
begin
  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  ZeroMemory(@FProcessInfo, SizeOf(FProcessInfo));
  StartupInfo.cb := SizeOf(StartupInfo);

  Result := CreateProcess(nil, AProcessInfo.buildInitializationParam, nil,
                          nil, False, 0, nil, nil, StartupInfo, FProcessInfo);
  if Result then
  begin
    CloseHandle(FProcessInfo.hThread);
    AProcessInfo.PID := FProcessInfo.dwProcessId;
    AProcessInfo.Name := ExtractFileName(AProcessInfo.ExePath);
  end;
end;

{ TProcessInfo }

function TProcessInfo.buildInitializationParam: PChar;
begin
  Result := PChar('"'+ExePath+'" '+Params)
end;

end.

