unit UJSONException;

interface

uses
  SysUtils;

type
  TJSONException = class(Exception)
  public
    constructor Create(const Msg: string); overload;
    constructor CreateFmt(const Msg: string; const Args: array of const); overload;
  end;

implementation

constructor TJSONException.Create(const Msg: string);
begin
  inherited Create(Msg);
end;

constructor TJSONException.CreateFmt(const Msg: string; const Args: array of const);
begin
  inherited CreateFmt(Msg, Args);
end;

end.
