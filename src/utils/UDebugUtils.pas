unit UDebugUtils;

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  Winapi.Windows,
  Winapi.TlHelp32;

type
  TDataInfo = record
    PID: DWORD;
    ProcessName: String;
    Thread: DWORD;
    FileName: String;
    Line: Integer;
    CallBy: String
  end;

  TDebugUtils = class
    class function getMethodName(ALevel: Integer): String;
    class function getCurrentDataInfo(ALevel: Integer): TDataInfo;
  end;

implementation

uses
  JclDebug;

class function TDebugUtils.getCurrentDataInfo(ALevel: Integer): TDataInfo;
begin
  Result.PID := GetCurrentProcessId;
  Result.ProcessName := extractfilename(paramstr(0));
  Result.Thread := TThread.CurrentThread.ThreadID;
  Result.FileName := FileByLevel(ALevel);
  Result.Line := LineByLevel(ALevel);
  Result.CallBy := getMethodName(ALevel)
end;

class function TDebugUtils.getMethodName(ALevel: Integer): String;
var
  FRawName: String;
  FInitialPos, FEndPos: Integer;
begin
  FRawName := ProcByLevel(ALevel + 1);
  Result := FRawName;
  FInitialPos := Pos('%', FRawName) + 1;
  FEndPos := Pos('$', FRawName, FInitialPos) - 1;
  if (FInitialPos > 1) or (FEndPos > 0) then
  begin
    if FInitialPos = 1 then
      FEndPos := FEndPos + 1;

    Result := Copy(FRawName, FInitialPos, FEndPos - FInitialPos);
  end
end;

end.
