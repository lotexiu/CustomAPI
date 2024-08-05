unit UThreadUtils;

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  UWindowsUtils;

type
  TThreadUtils = class
    class procedure onThread(ALoop: Boolean; AInterval: Integer; AProc: TProc); overload;
    class procedure onThread(AInterval: Integer; AProc: TProc); overload;
    class procedure onThread(AProc: TProc); overload;
  end;

implementation

{ TThreadUtils }

class procedure TThreadUtils.onThread(ALoop: Boolean; AInterval: Integer;
  AProc: TProc);
begin
  TThread.CreateAnonymousThread(
  procedure
  begin
    AProc;
    TWindowsUtils.cleanAppMemoryLeak;
    TThread.CurrentThread.Terminate;
    if ALoop then
    begin
      sleep(AInterval);
      TThreadUtils.onThread(ALoop, AInterval, AProc);
    end;
  end).Start;
end;

class procedure TThreadUtils.onThread(AInterval: Integer; AProc: TProc);
begin
  onThread(True, AInterval, AProc)
end;

class procedure TThreadUtils.onThread(AProc: TProc);
begin
  onThread(False, 0, AProc)
end;

end.
