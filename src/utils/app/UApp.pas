unit UApp;

interface

uses
  Horse,
  Horse.Callback,
  Horse.Core,
  Horse.Core.Group.Contract,
  Horse.CORS,
  Horse.Jhonson,
  Horse.GBSwagger,
  Generics.Collections,
  UGenericUtils,
  UGenericDictionary,
  UAppAPI;

type
  TApp = class
  private
    FAPIList: TGenericDictionary;
    FHorse: THorse;

    class procedure _Create;
    class procedure _Destroy;
    procedure initValues;
    function getHost: String;
    function getMaxConnections: Integer;
    function getPort: Integer;
    procedure setHost(const Value: String);
    procedure setMaxConnections(const Value: Integer);
    procedure setPort(const Value: Integer);
  public
    class var APPList: TList<TApp>;

    constructor Create;
    destructor Destroy; override;

    property Host: String read getHost write setHost;
    property Port: Integer read getPort write setPort;
    property MaxConnections: Integer read getMaxConnections write setMaxConnections;

    procedure Listen;
    procedure StopListen;

    function API(AName: String): TAppAPI; overload;
    
  end;

implementation

{ TApp }

function TApp.API(AName: String): TAppAPI;
begin
  if FAPIList.containsKey(AName) then
    Result := FAPIList.get<TAppAPI>(AName)
  else
  begin
    Result := TAppAPI.Create(AName);
    FAPIList.Add(AName,Result);
  end;
end;

constructor TApp.Create;
begin
  initValues;
end;

destructor TApp.Destroy;
begin
  TGenericUtils.freeAndNil(FAPIList);
  inherited;
end;

function TApp.getHost: String;
begin
  Result := FHorse.Host;
end;

function TApp.getMaxConnections: Integer;
begin
  Result := FHorse.MaxConnections;
end;

function TApp.getPort: Integer;
begin
  Result := FHorse.Port;
end;

procedure TApp.initValues;
begin
  FAPIList := TGenericDictionary.Create;
  FAPIList.FreeValuesOnDestroy := True;
  APPList.Add(Self);

  FHorse := THorse.Create;
  FHorse.Use(CORS);
  FHorse.Use(Jhonson);
  FHorse.Use(HorseSwagger);
  FHorse.Host := '127.0.0.1';
  FHorse.Port := 8000;
  FHorse.MaxConnections := 1000;
end;

procedure TApp.Listen;
begin
  FHorse.Listen;
  TGenericUtils.forEach<TAppAPI>(FAPIList.Values<TAppAPI>,
  procedure(API: TAppAPI; out ABreak: Boolean)
  begin
    API.buildSwaggerData;
  end);
end;

procedure TApp.setHost(const Value: String);
begin
  FHorse.Host := Value;
end;

procedure TApp.setMaxConnections(const Value: Integer);
begin
  FHorse.MaxConnections := Value;
end;

procedure TApp.setPort(const Value: Integer);
begin
  FHorse.Port := Value;
end;

procedure TApp.StopListen;
begin
  FHorse.StopListen;
end;

class procedure TApp._Create;
begin
  APPList := TList<TApp>.Create;
end;

class procedure TApp._Destroy;
begin
  TGenericUtils.forEach<TApp>(APPList,
  procedure(APP: TApp; out ABreak: Boolean)
  begin
    if (not TGenericUtils.isEmptyOrNull(APP)) then
      TGenericUtils.freeAndNil(APP);
  end);
  TGenericUTils.freeAndNil(APPList);
end;

initialization
  TApp._Create;

finalization
  TApp._Destroy;

end.
