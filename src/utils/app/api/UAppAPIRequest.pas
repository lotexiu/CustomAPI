unit UAppAPIRequest;

interface

uses
  Horse,
  Horse.Callback,
  Horse.GBSwagger,
  Horse.Core,
  Horse.Core.Group.Contract,
  Generics.Collections,
  UGenericUtils;

type
  TRequestFunctionRR<Receive, Return> =
    reference to function(AReq: THorseRequest; ARes: THorseResponse): Return;
  TRequestFunctionR<Return> =
    reference to function(AReq: THorseRequest; ARes: THorseResponse): Return;
  TRequestFunction =
    reference to procedure(AReq: THorseRequest; ARes: THorseResponse);

  TRequestType = (GET_, PUT_, POST_, PATCH_, DELETE_);
  TFunctionType = (TFunction, TFunctionR, TFunctionRR);

  TAppAPIRequest = class
  private
    FHideOnSwagger: Boolean;
    FType: TRequestType;
    FFunctionPointer: Pointer;
    FFunctionType: TFunctionType;

  public
    class var APIRequestList: TList<TAppAPIRequest>;

    constructor Create; overload;

    class function Create<Receive, Return>
      (AType: TRequestType; APath: String; AFunction: TRequestFunctionRR<Receive, Return>): TAppAPIRequest; overload;
    class function Create<Return>
      (AType: TRequestType; APath: String; AFunction: TRequestFunctionR<Return>): TAppAPIRequest; overload;
    class function Create
      (AType: TRequestType; APath: String; AFunction: TRequestFunction): TAppAPIRequest; overload;

    property HideOnSwagger: Boolean read FHideOnSwagger write FHideOnSwagger;
  end;

implementation

{ TAppAPIRequest }

constructor TAppAPIRequest.Create;
begin
  APIRequestList.Add(Self);
end;

class function TAppAPIRequest.Create<Receive, Return>(
  AType: TRequestType; APath: String; AFunction: TRequestFunctionRR<Receive, Return>): TAppAPIRequest;
begin
  Result := TAppAPIRequest.Create;
  Result.FType := AType;
  Result.FFunctionPointer := @AFunction;
  Result.FFunctionType := TFunctionRR;
end;

class function TAppAPIRequest.Create<Return>(
  AType: TRequestType; APath: String; AFunction: TRequestFunctionR<Return>): TAppAPIRequest;
begin
  Result := TAppAPIRequest.Create;
  Result.FType := AType;
  Result.FFunctionPointer := @AFunction;
  Result.FFunctionType := TFunctionR;
end;

class function TAppAPIRequest.Create(
  AType: TRequestType; APath: String; AFunction: TRequestFunction): TAppAPIRequest;
begin
  Result := TAppAPIRequest.Create;
  Result.FType := AType;
  Result.FFunctionPointer := @AFunction;
  Result.FFunctionType := TFunction;
end;

initialization
  TAppAPIRequest.APIRequestList := TList<TAppAPIRequest>.Create;

finalization
  TGenericUtils.forEach<TAppAPIRequest>(TAppAPIRequest.APIRequestList,
  procedure(Request: TAppAPIRequest; out ABreak: Boolean)
  begin
    if (not TGenericUtils.isEmptyOrNull(Request)) then
      TGenericUtils.freeAndNil(Request);
  end);
  TGenericUtils.freeAndNil(TAppAPIRequest.APIRequestList);

end.
