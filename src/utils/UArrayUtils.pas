unit UArrayUtils;

interface

uses
  Rtti,
  TypInfo,
  Classes,
  Variants,
  Json,
  Rest.Json,
  Generics.Collections,
  Generics.Defaults,
  SysUtils;

type
  TArrayUtils = class
    class function TArrayToTList<T>(AArray: TArray<T>): TList<T>;
    class function TArrayCast<T,R>(AArray: TArray<T>): TArray<R>;
  end;

implementation

class function TArrayUtils.TArrayCast<T, R>(AArray: TArray<T>): TArray<R>;
var
  FList: TList<R>;
  I: Integer;
begin
  try
    FList := TList<R>.Create;
    for I := 0 to High(AArray) do
      FList.Add(TValue.From<T>(AArray[I]).AsType<R>);
    Result := FList.ToArray;
    FreeAndNil(FList);
  except
    if Assigned(FList) then
      FreeAndNil(FList);
    raise Exception.Create('Impossible cast.');
  end;
end;

class function TArrayUtils.TArrayToTList<T>(AArray: TArray<T>): TList<T>;
var
  I: Integer;
begin
  Result := TList<T>.Create;
  for I := 0 to High(AArray) do
    Result.Add(AArray[I]);
end;

end.
