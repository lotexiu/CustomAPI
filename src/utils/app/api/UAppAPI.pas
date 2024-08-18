unit UAppAPI;

interface

uses
  Generics.Collections,
  UAppAPIRequest,
  UGenericUtils,
  UGenericDictionary;

type
  TAppAPI = class
  private
    FName: String;
    FHideOnSwagger: Boolean;
    FDefaultHideRequestOnSwagger: Boolean;
    FModel: Pointer;
    FRequestList: TGenericDictionary;

    function REQUEST(AType: TRequestType; APath: String;
                    AFunction: TRequestFunction): TAppAPIRequest; overload;
    function REQUEST<Return>(AType: TRequestType; APath: String;
                    AFunction: TRequestFunctionR<Return>): TAppAPIRequest; overload;
    function REQUEST<Receive,Return>(AType: TRequestType; APath: String;
                    AFunction: TRequestFunctionRR<Receive,Return>): TAppAPIRequest; overload;
  public
    class var APIList: TList<TAppAPI>;

    constructor Create(AName: String);
    destructor Destroy; override;

    property Name: String read FName write FName;
    property HideOnSwagger: Boolean read FHideOnSwagger write FHideOnSwagger;
    property DefaultHideRequestOnSwagger: Boolean read FDefaultHideRequestOnSwagger write FDefaultHideRequestOnSwagger;
    property RequestList: TGenericDictionary read FRequestList;

    function ModelTypeInfo: Pointer;
    procedure Model<T>;

    function GET<Return>(APath: String; AFunction: TRequestFunctionR<Return>): TAppAPIRequest; overload;
    function PUT<Return>(APath: String; AFunction: TRequestFunctionR<Return>): TAppAPIRequest; overload;
    function POST<Return>(APath: String; AFunction: TRequestFunctionR<Return>): TAppAPIRequest; overload;
    function PATCH<Return>(APath: String; AFunction: TRequestFunctionR<Return>): TAppAPIRequest; overload;
    function DELETE<Return>(APath: String; AFunction: TRequestFunctionR<Return>): TAppAPIRequest; overload;

    function GET<Receive,Return>(APath: String; AFunction: TRequestFunctionRR<Receive,Return>): TAppAPIRequest; overload;
    function PUT<Receive,Return>(APath: String; AFunction: TRequestFunctionRR<Receive,Return>): TAppAPIRequest; overload;
    function POST<Receive,Return>(APath: String; AFunction: TRequestFunctionRR<Receive,Return>): TAppAPIRequest; overload;
    function PATCH<Receive,Return>(APath: String; AFunction: TRequestFunctionRR<Receive,Return>): TAppAPIRequest; overload;
    function DELETE<Receive,Return>(APath: String; AFunction: TRequestFunctionRR<Receive,Return>): TAppAPIRequest; overload;

    function GET(APath: String; AFunction: TRequestFunction): TAppAPIRequest; overload;
    function PUT(APath: String; AFunction: TRequestFunction): TAppAPIRequest; overload;
    function POST(APath: String; AFunction: TRequestFunction): TAppAPIRequest; overload;
    function PATCH(APath: String; AFunction: TRequestFunction): TAppAPIRequest; overload;
    function DELETE(APath: String; AFunction: TRequestFunction): TAppAPIRequest; overload;

    procedure buildSwaggerData;
  end;

implementation

{ TAppAPI }

procedure TAppAPI.buildSwaggerData;
begin

end;

constructor TAppAPI.Create(AName: String);
begin
  APIList.Add(Self);
  FName := AName;
  FRequestList := TGenericDictionary.Create;
  FRequestList.FreeValuesOnDestroy := True;
end;

destructor TAppAPI.Destroy;
begin
  TGenericUtils.freeAndNil(FRequestList);
  inherited;
end;

function TAppAPI.ModelTypeInfo: Pointer;
begin
  Result := FModel;
end;

procedure TAppAPI.Model<T>;
begin
  FModel := TypeInfo(T);
end;

function TAppAPI.REQUEST(AType: TRequestType; APath: String;
                        AFunction: TRequestFunction): TAppAPIRequest;
begin
  Result := TAppAPIRequest.Create(AType, APath, AFunction);
  Result.HideOnSwagger := FDefaultHideRequestOnSwagger;
  FRequestList.add(APath,Result);
end;
function TAppAPI.REQUEST<Return>(AType: TRequestType; APath: String;
                        AFunction: TRequestFunctionR<Return>): TAppAPIRequest;
begin
  Result := TAppAPIRequest.Create<Return>(AType, APath, AFunction);
  Result.HideOnSwagger := FDefaultHideRequestOnSwagger;
  FRequestList.add(APath,Result);
end;
function TAppAPI.REQUEST<Receive,Return>(AType: TRequestType; APath: String;
                        AFunction: TRequestFunctionRR<Receive,Return>): TAppAPIRequest;
begin
  Result := TAppAPIRequest.Create<Receive,Return>(AType, APath, AFunction);
  Result.HideOnSwagger := FDefaultHideRequestOnSwagger;
  FRequestList.add(APath,Result);
end;

function TAppAPI.GET<Return>(APath: String; AFunction: TRequestFunctionR<Return>): TAppAPIRequest;
begin
  Result := REQUEST<Return>(GET_, APath, AFunction);
end;
function TAppAPI.PUT<Return>(APath: String; AFunction: TRequestFunctionR<Return>): TAppAPIRequest;
begin
  Result := REQUEST<Return>(PUT_, APath, AFunction);
end;
function TAppAPI.POST<Return>(APath: String; AFunction: TRequestFunctionR<Return>): TAppAPIRequest;
begin
  Result := REQUEST<Return>(POST_, APath, AFunction);
end;
function TAppAPI.PATCH<Return>(APath: String; AFunction: TRequestFunctionR<Return>): TAppAPIRequest;
begin
  Result := REQUEST<Return>(PATCH_, APath, AFunction);
end;
function TAppAPI.DELETE<Return>(APath: String; AFunction: TRequestFunctionR<Return>): TAppAPIRequest;
begin
  Result := REQUEST<Return>(DELETE_, APath, AFunction);
end;

function TAppAPI.GET<Receive,Return>(APath: String; AFunction: TRequestFunctionRR<Receive,Return>): TAppAPIRequest;
begin
  Result := REQUEST<Receive,Return>(GET_, APath, AFunction);
end;
function TAppAPI.PUT<Receive,Return>(APath: String; AFunction: TRequestFunctionRR<Receive,Return>): TAppAPIRequest;
begin
  Result := REQUEST<Receive,Return>(PUT_, APath, AFunction);
end;
function TAppAPI.POST<Receive,Return>(APath: String; AFunction: TRequestFunctionRR<Receive,Return>): TAppAPIRequest;
begin
  Result := REQUEST<Receive,Return>(POST_, APath, AFunction);
end;
function TAppAPI.PATCH<Receive,Return>(APath: String; AFunction: TRequestFunctionRR<Receive,Return>): TAppAPIRequest;
begin
  Result := REQUEST<Receive,Return>(PATCH_, APath, AFunction);
end;
function TAppAPI.DELETE<Receive,Return>(APath: String; AFunction: TRequestFunctionRR<Receive,Return>): TAppAPIRequest;
begin
  Result := REQUEST<Receive,Return>(DELETE_, APath, AFunction);
end;

function TAppAPI.GET(APath: String; AFunction: TRequestFunction): TAppAPIRequest;
begin
  Result := REQUEST(GET_, APath, AFunction);
end;
function TAppAPI.PUT(APath: String; AFunction: TRequestFunction): TAppAPIRequest;
begin
  Result := REQUEST(PUT_, APath, AFunction);
end;
function TAppAPI.POST(APath: String; AFunction: TRequestFunction): TAppAPIRequest;
begin
  Result := REQUEST(POST_, APath, AFunction);
end;
function TAppAPI.PATCH(APath: String; AFunction: TRequestFunction): TAppAPIRequest;
begin
  Result := REQUEST(PATCH_, APath, AFunction);
end;
function TAppAPI.DELETE(APath: String; AFunction: TRequestFunction): TAppAPIRequest;
begin
  Result := REQUEST(DELETE_, APath, AFunction);
end;

initialization
  TAppAPI.APIList := TList<TAppAPI>.Create;

finalization
  TGenericUtils.forEach<TAppAPI>(TAppAPI.APIList,
  procedure(API: TAppAPI; out ABreak: Boolean)
  begin
    if (not TGenericUtils.isEmptyOrNull(API)) then
      TGenericUtils.freeAndNil(API);
  end);
  TGenericUtils.freeAndNil(TAppAPI.APIList);

end.
