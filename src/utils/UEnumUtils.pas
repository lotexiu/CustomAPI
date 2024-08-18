unit UEnumUtils;

interface

uses
  Rtti,
  TypInfo,
  UEnumException,
  UGenericUtils;

type
  TEnumUtils = class
  private
  public
    class function toList<T>: TArray<Variant>;
    class function length<T>: Integer; static;
    class function indexOf<T>(AEnum: T): Integer;
    class function strToValue<T>(AEnum: String): T;
  end;

implementation

{ TEnumUtils }

class function TEnumUtils.indexOf<T>(AEnum: T): Integer;
var
  I: Integer;
  FEnumVariant, FEnumVariant2: Variant;
begin
  for I := 0 to TEnumUtils.length<T> -1  do
  begin
    FEnumVariant := TValue.FromOrdinal(TypeInfo(T), I).AsVariant;
    FEnumVariant2 := TValue.From<T>(AEnum).AsVariant;
    if (FEnumVariant = FEnumVariant2) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

class function TEnumUtils.length<T>: Integer;
var
  FRType: TRttiType;
  FROrdinalType: TRttiOrdinalType;
begin
  FRType := TGenericUtils.rttiType<T>;
  if FRType.TypeKind = tkEnumeration then
  begin
    FROrdinalType := FRType.AsOrdinal;
    Result := FROrdinalType.MaxValue - FROrdinalType.MinValue + 1;
  end
  else
  begin
    raise TEnumException.Create(TGenericUtils.typeName<T>+' isn''t an Enum.');
  end;
end;

class function TEnumUtils.strToValue<T>(AEnum: String): T;
var
  I: Integer;
  FEnum: T;
begin
  Result := Default(T);
  for I := 0 to length<T> -1  do
  begin
    FEnum := TValue.FromOrdinal(TypeInfo(T), I).AsType<T>;
    if GetEnumName(TypeInfo(T), I) = AEnum then
      Result := FEnum;
  end;
end;

class function TEnumUtils.toList<T>: TArray<Variant>;
var
  I: Integer;
begin
  SetLength(Result, length<T>);
  for I := 0 to length<T> -1  do
    Result[I] := (GetEnumName(TypeInfo(T), I));
end;

end.
