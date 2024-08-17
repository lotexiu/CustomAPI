unit UGenericException;

interface

uses
  SysUtils;

type
  TGenericException = class(Exception)
  public
    constructor Create(const Msg: string); overload;
    constructor CreateFmt(const Msg: string; const Args: array of const); overload;
  end;

implementation

constructor TGenericException.Create(const Msg: string);
begin
  inherited Create(Msg);
end;

constructor TGenericException.CreateFmt(const Msg: string; const Args: array of const);
begin
  inherited CreateFmt(Msg, Args);
end;

end.
