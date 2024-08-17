unit UThreadData;

interface

uses
  SysUtils,
  Math;

type
  TThreadData = class
  private
    {Settings}
    FLoop: Boolean;
    FInterval: Integer;
    {Time}
    FExecutionCount: Integer;
    FExecutionFailCount: Integer;
    FAvarage: Extended;
    {Thread Type Settings}
    FThreadType: String;
    FMaxThreadsRunning: Integer;
    FThreadRunningCount: Integer;

    function getAvarage: Extended;
    procedure setThreadCount(const Value: Integer);
    procedure setThreadMax(const Value: Integer);

    procedure initValues;
    function getWait: Boolean;
  public
    constructor Create; overload;
    constructor Create(AThreadType: String); overload;
    constructor Create(AInterval: Integer); overload;
    constructor Create(AThreadType: String; AMaxThreadsRunning: Integer); overload;
    constructor Create(AInterval: Integer; AThreadType: String; AMaxThreadsRunning: Integer); overload;

    property Loop: Boolean read FLoop write FLoop;
    property Interval: Integer read FInterval write FInterval;
    property ExecutionCount: Integer read FExecutionCount;
    property ExecutionFailCount: Integer read FExecutionFailCount write FExecutionFailCount;
    property Avarage: Extended read getAvarage;
    property ThreadType: String read FThreadType write FThreadType;
    property MaxThreadsRunning: Integer read FMaxThreadsRunning write setThreadMax;
    property ThreadRunningCount: Integer read FThreadRunningCount write setThreadCount;
    property WaitToOpen: Boolean read getWait;

    procedure addExecutionTime(ATime: Integer);
    procedure addThread;
    procedure removeThread;
  end;

implementation

{ TThreadData }

constructor TThreadData.Create;
begin
  initValues;
end;

constructor TThreadData.Create(AThreadType: String);
begin
  initValues;
  FThreadType := AThreadType;
end;

constructor TThreadData.Create(AInterval: Integer);
begin
  initValues;
  FInterval := AInterval;
  FLoop := True;
end;

constructor TThreadData.Create(AThreadType: String; AMaxThreadsRunning: Integer);
begin
  initValues;
  FThreadType := AThreadType;
  FMaxThreadsRunning := AMaxThreadsRunning;
end;

constructor TThreadData.Create(AInterval: Integer; AThreadType: String; AMaxThreadsRunning: Integer);
begin
  initValues;
  FInterval := AInterval;
  FLoop := True;
  FThreadType := AThreadType;
  FMaxThreadsRunning := AMaxThreadsRunning;
end;

procedure TThreadData.addExecutionTime(ATime: Integer);
begin
  Inc(FExecutionCount);
  FAvarage := ((FAvarage * (FExecutionCount-1)) + ATime) / FExecutionCount;
end;

procedure TThreadData.addThread;
begin
  ThreadRunningCount := ThreadRunningCount + 1;
end;

function TThreadData.getAvarage: Extended;
begin
  Result := Math.Max(Math.RoundTo(FAvarage/1000, -2),0);
end;

function TThreadData.getWait: Boolean;
begin
  Result :=
    (FMaxThreadsRunning > 0) and
    (ThreadRunningCount >= MaxThreadsRunning);
end;

procedure TThreadData.setThreadCount(const Value: Integer);
begin
  FThreadRunningCount := Value;
end;

procedure TThreadData.setThreadMax(const Value: Integer);
begin
  FMaxThreadsRunning := Value;
end;

procedure TThreadData.initValues;
begin
  {Settings}
  FLoop := False;
  FInterval := 0;
  {Time}
  FExecutionCount := 0;
  FExecutionFailCount := 0;
  FAvarage := 0;
  {Thread Type Settings}
  FThreadType := 'global';
  FMaxThreadsRunning := 0;
  FThreadRunningCount := 0;
end;

procedure TThreadData.removeThread;
begin
  ThreadRunningCount := ThreadRunningCount - 1;
end;

end.
