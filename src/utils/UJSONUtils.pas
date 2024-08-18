unit UJSONUtils;

interface

uses
  JSON, DBXJSON, DBXJSONReflect,
  Generics.Collections,
  UJSONException,
  StrUtils,
  SysUtils,
  UGenericUtils,
  UStringUtils;

type
  TJSONUtils = class
  private
    class var MConverter: TJSONMarshal;
    class var MReverter: TJSONUnMarshal;

    class procedure _Create;
    class procedure _Destroy;
//  private function FindTypeInHierarchy(ATypeValidation: TFunc1P<TClass, Boolean>): TClass;
  public
    class function toString(AObject: TObject): String;

    class procedure registerConverter<T:class; R>(
      const AConverter: TFunc1P<T,R>; const AReverter: TFunc1P<R,T>);

    {Object -> List}
    class procedure registerTListToArray<T>;
  end;

implementation

{ TJSONUtils }

class procedure TJSONUtils._Create;
begin
  MConverter := TJSONConverters.GetJSONMarshaler;
  MReverter := TJSONConverters.GetJSONUnMarshaler;
end;

class procedure TJSONUtils._Destroy;
begin
  TGenericUtils.freeAndNil(MConverter);
  TGenericUtils.freeAndNil(MReverter);
end;

class function TJSONUtils.toString(AObject: TObject): String;
begin
  Result := MConverter.Marshal(AObject).FindValue('fields').ToJSON;
  Result := TStringUtils.replace(Result, '"F', '"');
  Result := TStringUtils.unCapitalize(Result);
end;

class procedure TJSONUtils.registerConverter<T, R>(
  const AConverter: TFunc1P<T, R>; const AReverter: TFunc1P<R, T>);
begin
  if  (TGenericUtils.isObject<R>) then
  begin
    MConverter.RegisterConverter(T,
    function(AData: TObject): TObject
    begin
      if (not TGenericUtils.isEmptyOrNull(AData)) then
        Result := TGenericUtils.castTo<TObject,R>(AConverter(AData as T));
    end)
  end
  else if (TGenericUtils.sameType<R, TArray<TObject>>) or
          (TGenericUtils.sameType<R, TArray<T>>) then
  begin
    MConverter.RegisterConverter(T,
    function(AData: TObject): TListOfObjects
    begin
      if (not TGenericUtils.isEmptyOrNull(AData)) then
        Result := TGenericUtils.castTo<TListOfObjects,R>(AConverter(AData as T));
    end);
  end
  else if (TGenericUtils.sameType<R, TArray<String>>) then
  begin
    MConverter.RegisterConverter(T,
    function(AData: TObject): TListOfStrings
    begin
      if (not TGenericUtils.isEmptyOrNull(AData)) then
        Result := TGenericUtils.castTo<TListOfStrings,R>(AConverter(AData as T));
    end);
  end
  else if (TGenericUtils.sameType<R, String>) then
  begin
    MConverter.RegisterConverter(T,
    function(AData: TObject): String
    begin
      if (not TGenericUtils.isEmptyOrNull(AData)) then
        Result := TGenericUtils.castTo<String,R>(AConverter(AData as T));
    end)
  end
  else
    raise TJSONException.Create('Type '+TGenericUtils.typeName<R>+' not supported!');

  if  (TGenericUtils.isObject<R>) then
  begin
    MReverter.RegisterReverter(T,
    function(AData: TObject): TObject
    begin
      if (not TGenericUtils.isEmptyOrNull(AData)) then
        Result := AReverter(TGenericUtils.castTo<R,TObject>(AData));
    end)
  end
  else if (TGenericUtils.sameType<R, TArray<TObject>>) or
          (TGenericUtils.sameType<R, TArray<T>>) then
  begin
    MReverter.RegisterReverter(T,
    function(AData: TListOfObjects): TObject
    begin
      if (not TGenericUtils.isEmptyOrNull(AData)) then
        Result := AReverter(TGenericUtils.castTo<R,TListOfObjects>(AData));
    end);
  end
  else if (TGenericUtils.sameType<R, TArray<String>>) then
  begin
    MReverter.RegisterReverter(T,
    function(AData: TListOfStrings): TObject
    begin
      if (not TGenericUtils.isEmptyOrNull(AData)) then
        Result := AReverter(TGenericUtils.castTo<R,TListOfStrings>(AData));
    end);
  end
  else if (TGenericUtils.sameType<R, String>) then
  begin
    MReverter.RegisterReverter(T,
    function(AData: String): TObject
    begin
      if (not TGenericUtils.isEmptyOrNull(AData)) then
        Result := AReverter(TGenericUtils.castTo<R, String>(AData));
    end)
  end
  else
    raise TJSONException.Create('Type '+TGenericUtils.typeName<R>+' not supported!');
end;

class procedure TJSONUtils.registerTListToArray<T>;
begin
  registerConverter<TList<T>,TArray<T>>(
  function(Data: TList<T>): TArray<T>
  begin
    Result := Data.List;
    SetLength(Result, Data.Count);
  end,
  function(Data: TArray<T>): TList<T>
  begin
    Result := TList<T>.Create(Data);
  end);
end;

initialization
  TJSONUtils._Create;

finalization
  TJSONUtils._Destroy;

end.

