﻿unit UThreadUtils;

interface

uses
  Diagnostics,
  Generics.Collections,
  Classes,
  SysUtils,
  SyncObjs,
  UWindowsUtils,
  UGenericUtils,
  UGenericDictionary,
  UThreadData;

type
  TThreadUtils = class
  private
    class var FDictionary: TGenericDictionary;
    class var FCritSectionThread: TCriticalSection;

    class procedure _Create;
    class procedure _Destroy;
    class procedure _onThread(AThreadData: TThreadData; AProc: TProc);
  public
    class procedure addThreadData(AThreadData: TThreadData); overload;
    class function getThreadData(AKey: String): TThreadData;

    {Normal}
    class procedure onThread(AProc: TProc); overload;
    {Loop}
    class procedure onThread(AInterval: Integer; AProc: TProc); overload;
    {ThreadType}
    class procedure onThread(AThreadType: String; AProc: TProc); overload;
    {ThreadType Normal, Change MaxThread}
    class procedure onThread(AThreadType: String; AMaxThreadsRunning: Integer; AProc: TProc); overload;
    {ThreadType Loop, Change MaxThread}
    class procedure onThread(AThreadType: String; AMaxThreadsRunning, AInterval: Integer; AProc: TProc); overload;

  end;

implementation

{ TThreadUtils }

class procedure TThreadUtils._Create;
begin
  FCritSectionThread := TCriticalSection.Create;
  if TGenericUtils.isEmptyOrNull(FDictionary) Then
    FDictionary := TGenericDictionary.Create;
end;

class procedure TThreadUtils._Destroy;
var
  FList: TArray<TThreadData>;
begin
  FList := TThreadUtils.FDictionary.Values<TThreadData>;
  TGenericUtils.forEach<TThreadData>(FList,
  procedure(AValue: TThreadData; out ABreak: Boolean)
  begin
    AValue.Loop := False;
    AValue.MaxThreadsRunning := 0;
    while AValue.ThreadRunningCount > 0 do
      Sleep(50);
  end);
  TGenericUtils.freeAndNil(FCritSectionThread);
  FDictionary.FreeValuesOnDestroy := True;
  TGenericUtils.freeAndNil(FDictionary);
end;

class procedure TThreadUtils.addThreadData(AThreadData: TThreadData);
begin
  FDictionary.add<TThreadData>(AThreadData.ThreadType, AThreadData);
end;

class function TThreadUtils.getThreadData(AKey: String): TThreadData;
begin
  Result := FDictionary.get<TThreadData>(AKey);
end;

class procedure TThreadUtils._onThread(AThreadData: TThreadData; AProc: TProc);
begin
  FCritSectionThread.Enter;
  while AThreadData.WaitToOpen do
    sleep(250);

  AThreadData.addThread; {Adding Thread}
  TThread.CreateAnonymousThread(
  procedure
  var
    FWatch: TStopwatch;
  begin
    FWatch := TStopwatch.StartNew;{Watching}
    try
      AProc;
    except
      AThreadData.ExecutionFailCount := AThreadData.ExecutionFailCount + 1;
    end;    
    FWatch.Stop; {Stop Watching}
    AThreadData.removeThread; {Removing Thread}
    AThreadData.addExecutionTime(FWatch.ElapsedMilliseconds); {Add for Avarage}
    TWindowsUtils.cleanAppMemoryFromLeak; {CleanMemory}
    TThread.CurrentThread.Terminate; {Closing Thread}
    if AThreadData.Loop then
    begin
      sleep(AThreadData.Interval); {Interval}
      _onThread(AThreadData, AProc); {Open new Thread}
    end;
  end).Start;
  FCritSectionThread.Release;
end;

class procedure TThreadUtils.onThread(AProc: TProc);
var
  FThread: TThreadData;
begin
  FThread := TThreadData.Create;
  _onThread(FThread, AProc);
  TGenericUtils.freeAndNil(FThread);
end;

class procedure TThreadUtils.onThread(AInterval: Integer; AProc: TProc);
var
  FThread: TThreadData;
begin
  FThread := TThreadData.Create(AInterval);
  _onThread(FThread, AProc);
  TGenericUtils.freeAndNil(FThread);  
end;

class procedure TThreadUtils.onThread(AThreadType: String; AProc: TProc);
var
  FThread: TThreadData;
begin
  if FDictionary.containsKey(AThreadType) then
    FThread := FDictionary.get<TThreadData>(AThreadType)
  else
  begin
    FThread := TThreadData.Create(AThreadType);
    FDictionary.add<TThreadData>(AThreadType, FThread);
  end;
  _onThread(FThread, AProc);
end;

class procedure TThreadUtils.onThread(AThreadType: String; AMaxThreadsRunning,
  AInterval: Integer; AProc: TProc);
var
  FThread: TThreadData;
begin
  if FDictionary.containsKey(AThreadType) then
  begin
    FThread := FDictionary.get<TThreadData>(AThreadType);
    FThread.MaxThreadsRunning := AMaxThreadsRunning;
    FThread.Interval := AInterval;
    FThread.Loop := True;
  end
  else
  begin
    FThread := TThreadData.Create(Ainterval,AThreadType,AMaxThreadsRunning);
    FDictionary.add<TThreadData>(AThreadType, FThread);
  end;    
  _onThread(FThread, AProc);
end;

class procedure TThreadUtils.onThread(AThreadType: String;
  AMaxThreadsRunning: Integer; AProc: TProc);
var
  FThread: TThreadData;
begin
  if FDictionary.containsKey(AThreadType) then
  begin
    FThread := FDictionary.get<TThreadData>(AThreadType);
    FThread.MaxThreadsRunning := AMaxThreadsRunning;
    FThread.Loop := False;
  end
  else
  begin
    FThread := TThreadData.Create(AThreadType,AMaxThreadsRunning);
    FDictionary.add<TThreadData>(AThreadType, FThread);
  end;    
  _onThread(FThread, AProc);
end;

initialization
  TThreadUtils._Create;

finalization
  TThreadUtils._Destroy;

end.
