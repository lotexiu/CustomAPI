unit UApp;

interface

uses
  Generics.Collections,
  Horse,
  Horse.Callback,
  Horse.Core,
  Horse.Core.Group.Contract,
  Horse.CORS,
  Horse.Jhonson,
  Horse.GBSwagger,
  UGenericUtils,
  UAppAPI;

type
  TApp = class
  private
    FAPIList: TList<TAppAPI>;
    FHorse: THorse;

    procedure initValues;
    function getHost: String;
    function getMaxConnections: Integer;
    function getPort: Integer;
    procedure setHost(const Value: String);
    procedure setMaxConnections(const Value: Integer);
    procedure setPort(const Value: Integer);
  public
    constructor Create;

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
  Result := TAppAPI.Create(AName);
end;

constructor TApp.Create;
begin
  initValues;
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
  FAPIList := TList<TAppAPI>.Create;
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

initialization

end.
