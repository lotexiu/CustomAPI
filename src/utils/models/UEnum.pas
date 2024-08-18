unit UEnum;

interface

uses
  Rtti,
  TypInfo,
  UEnumUtils,
  UAttributesUtils,
  UGenericUtils;

type
  TEnum<T> = record
  private
    FValue: T;

    function getIndex: Integer;
  public
    constructor Create(AValue: T);

    class operator Implicit(AEnum: String): TEnum<T>;
    class operator Implicit(AEnum: T): TEnum<T>;
    class operator Implicit(AEnum: TEnum<T>): T;

    class operator Equal(AEnum1, AEnum2: TEnum<T>): Boolean;
    class operator NotEqual(AEnum1, AEnum2: TEnum<T>): Boolean;
    class operator GreaterThan(AEnum1, AEnum2: TEnum<T>): Boolean;
    class operator GreaterThanOrEqual(AEnum1, AEnum2: TEnum<T>): Boolean;
    class operator LessThan(AEnum1, AEnum2: TEnum<T>): Boolean;
    class operator LessThanOrEqual(AEnum1, AEnum2: TEnum<T>): Boolean;

    property Index: Integer read getIndex;
    function Value<R>(AField: String): R;
    function toString: String;
  end;

implementation

{ TEnum<T> }

constructor TEnum<T>.Create(AValue: T);
begin
  FValue := AValue;
end;

class operator TEnum<T>.Implicit(AEnum: String): TEnum<T>;
begin
  Result := TEnumUtils.strToValue<T>(AEnum);
end;

class operator TEnum<T>.Implicit(AEnum: T): TEnum<T>;
begin
  Result := TEnum<T>.Create(AEnum);
end;

class operator TEnum<T>.Implicit(AEnum: TEnum<T>): T;
begin
  Result := AEnum.FValue;
end;

class operator TEnum<T>.Equal(AEnum1, AEnum2: TEnum<T>): Boolean;
begin
  Result := AEnum1.getIndex = AEnum2.getIndex;
end;

class operator TEnum<T>.NotEqual(AEnum1, AEnum2: TEnum<T>): Boolean;
begin
  Result := AEnum1.getIndex <> AEnum2.getIndex;
end;

class operator TEnum<T>.GreaterThan(AEnum1, AEnum2: TEnum<T>): Boolean;
begin
  Result := AEnum1.getIndex > AEnum2.getIndex;
end;

class operator TEnum<T>.GreaterThanOrEqual(AEnum1, AEnum2: TEnum<T>): Boolean;
begin
  Result := (AEnum1 > AEnum2) or (AEnum1 = AEnum2);
end;

class operator TEnum<T>.LessThan(AEnum1, AEnum2: TEnum<T>): Boolean;
begin
  Result := AEnum1.getIndex < AEnum2.getIndex;
end;

class operator TEnum<T>.LessThanOrEqual(AEnum1, AEnum2: TEnum<T>): Boolean;
begin
  Result := (AEnum1 < AEnum2) or (AEnum1 = AEnum2);
end;

function TEnum<T>.getIndex: Integer;
begin
  Result := TEnumUtils.indexOf<T>(FValue);
end;

function TEnum<T>.Value<R>(AField: String): R;
var
  FPointerInt: PInteger;
  FEnumIndex: Integer;
  FList: TArray<TCustomAttribute>;
  FResult: R;
  FType: TRttiType;
begin
  Result := Default(R);
  FPointerInt := @Self;
  FEnumIndex := Integer(TGenericRange((FPointerInt^)));
  FList := TAttributesUtils.attributes<T>;
  if Length(FList) > 0 then
  begin
    TGenericUtils.forEach<TCustomAttribute>(FList,
    procedure(AValue: TCustomAttribute; AIndex: Integer; out ABreak: Boolean)
    var
      FField: TRttiProperty;
    begin
      FField := nil;
      FType := TGenericUtils.rttiType(AValue.ClassType);
      FField := FType.GetProperty(AField);
      if Assigned(FField) then
      begin
        if FEnumIndex = AIndex then
        begin
          FResult := FField.GetValue(AValue).AsType<R>;
          ABreak := True;
        end;
      end;
    end);
    Result := FResult;
    TGenericUtils.freeAndNil(FList);
  end
  else
    Result := Default(R);
end;

function TEnum<T>.toString: String;
begin
  Result := GetEnumName(TypeInfo(T), getIndex);
end;

end.
