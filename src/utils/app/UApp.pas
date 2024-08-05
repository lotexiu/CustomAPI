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
    function getHost: String;
    function getMaxConnections: Integer;
    function getPort: Integer;
    procedure setHost(AValue: String);
    procedure setMaxConnections(AValue: Integer);
    procedure setPort(AValue: Integer);
  public
    property Horse: THorse read FHorse write FHorse;
    property APIList: TList<TAppAPI> read FAPIList write FAPIList;
    property HostIp: String read getHost write setHost;
    property Port: Integer read getPort write setPort;
    property MaxConnections: Integer read getMaxConnections write setMaxConnections;

//    procedure newAPI(Name: String; AProc:TGenProc<TAppAPI>);
    procedure Listen;
    constructor Create;
  end;

implementation

{ TApp }

constructor TApp.Create;
begin
  FAPIList := TList<TAppAPI>.Create;
  FHorse := THorse.Create;
  FHorse.Use(CORS);
  FHorse.Use(Jhonson);
  FHorse.Use(HorseSwagger);
  FHorse.Host := '127.0 0.1';
  FHorse.Port := 8000;
  FHorse.MaxConnections := 1000;
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

procedure TApp.Listen;
begin
  FHorse.Listen;
end;

//procedure TApp.newAPI(Name: String; AProc: TGenProc<TAppAPI>);
//var
//  FApi: TAppAPI;
//begin
//  FApi := TAppAPI.Create(Name);
//  FAPIList.Add(FApi);
//  AProc(FApi);
//end;

procedure TApp.setHost(AValue: String);
begin
  FHorse.Host := AValue;
end;

procedure TApp.setMaxConnections(AValue: Integer);
begin
  FHorse.MaxConnections := AValue;
end;

procedure TApp.setPort(AValue: Integer);
begin
  FHorse.Port := AValue;
end;

initialization

end.
