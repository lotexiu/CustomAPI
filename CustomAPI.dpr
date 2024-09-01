program CustomAPI;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  Classes,
  UWindowsUtils,
  UThreadUtils,
  UThreadData;

procedure onExit;
begin
  ReportMemoryLeaksOnShutdown := True;
  IsConsole := False;
end;

//var
//  FApp: TApp;
begin
  AddExitProc(@onExit);
//  TThreadUtils.onThread('ThreadTest', 250, 0,
//  procedure
//  var
//    FThreadData: TThreadData;
//  begin
//    TWindowsUtils.cleanScreen;
//    FThreadData := TThreadUtils.getThreadData('ThreadTest');
//    Writeln(FThreadData.toString);
//    FThreadData.Loop := False;
//  end);

  sleep(120*1000);
end.
