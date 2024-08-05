unit UWindowsUtils;

interface

uses
  Classes,
  Windows;

type
  TWindowsUtils = class
  private
  public
    class procedure cleanAppMemoryLeak;
    class procedure cleanAppMemoryLeakOnTick(ACooldown: Integer);
  end;

implementation

{ TWindowsUtils }

class procedure TWindowsUtils.cleanAppMemoryLeak;
var MainHandle : THandle;
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

class procedure TWindowsUtils.cleanAppMemoryLeakOnTick(ACooldown: Integer);
begin
  TThread.CreateAnonymousThread(
  procedure
  begin
    while True do
    begin
      cleanAppMemoryLeak;
      sleep(ACooldown);
    end;
  end
  ).Start;
end;

initialization
  TWindowsUtils.cleanAppMemoryLeakOnTick(1000);

end.
