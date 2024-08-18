unit UEnumException;

interface
uses
  SysUtils;
type
  TEnumException = class(Exception)
  public
    constructor Create(const Msg: string); overload;
    constructor CreateFmt(const Msg: string; const Args: array of const); overload;
  end;
implementation
constructor TEnumException.Create(const Msg: string);
begin
  inherited Create(Msg);
end;
constructor TEnumException.CreateFmt(const Msg: string; const Args: array of const);
begin
  inherited CreateFmt(Msg, Args);
end;
end.
