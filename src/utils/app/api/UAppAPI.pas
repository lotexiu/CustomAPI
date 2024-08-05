unit UAppAPI;

interface

uses
  Horse,
  Horse.Callback,
  Horse.Core,
  Horse.Core.Group.Contract,
  Horse.GBSwagger;

type
  TAppAPI = class
  private
    FName: String;
  public
    property Name: String read FName write FName;
    constructor Create(AName: String);
  end;

implementation

{ TAppAPI }

constructor TAppAPI.Create(AName: String);
begin
  FName := AName;
end;

end.
