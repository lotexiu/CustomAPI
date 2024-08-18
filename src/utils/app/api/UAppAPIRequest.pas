unit UAppAPIRequest;

interface

uses
  Horse, Horse.Callback, Horse.GBSwagger,
  Horse.Core, Horse.Core.Group.Contract;

type
  TRequestFunctionRR<Receive, Return> =
    reference to function(AReq: THorseRequest; ARes: THorseResponse): Return;
  TRequestFunctionR<Return> =
    reference to function(AReq: THorseRequest; ARes: THorseResponse): Return;
  TRequestFunction =
    reference to procedure(AReq: THorseRequest; ARes: THorseResponse);

  TRequestType = (GET_, PUT_, POST_, PATCH_, DELETE_);

  TAppAPIRequest = class
  private
    FHideOnSwagger: Boolean;
  public
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

class function TAppAPIRequest.Create<Receive, Return>(
  AType: TRequestType; APath: String; AFunction: TRequestFunctionRR<Receive, Return>): TAppAPIRequest;
begin

end;

class function TAppAPIRequest.Create<Return>(
  AType: TRequestType; APath: String; AFunction: TRequestFunctionR<Return>): TAppAPIRequest;
begin

end;

class function TAppAPIRequest.Create(
  AType: TRequestType; APath: String; AFunction: TRequestFunction): TAppAPIRequest;
begin

end;

end.
