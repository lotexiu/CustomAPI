unit UGenericUtils;

interface

uses
  { Reflexao }
  Rtti,
  TypInfo,
  { Reflexao }
  Generics.Collections,
  { UImports }
  UGenericException;

type

  TFunc<T> = reference to function: T;
  TFunc1P<T> = reference to function(AValue: T): T;
  TFunc1P<T,R> = reference to function(AValue: T): R;

  TForEach<T> = reference to procedure(AValue: T; out ABreak: Boolean);
  TForEachIndex<T> = reference to procedure(AValue: T; AIndex: Integer; out ABreak: Boolean);

  TGenericRange = 0 .. 255;

  TGenericUtils = class
  private
  public

    class function castTo<R,T>(AValue: T): R;

    class function callFunc<T>(AObject: T; AFunctionName: String): TValue; overload;
    class function callFunc<T>(AObject: T; AFunctionName: String; const Args: Array of TValue): TValue; overload;

    class procedure freeAndNil<T>(out AValue: T);

    class function isEmptyOrNull(AValue: TValue): Boolean; overload;
    class function isEmptyOrNull<T>(out AValue: T): Boolean; overload;

    class function isObject<T>: Boolean; overload;
    class function isObject<T>(out AValue: T): Boolean; overload;

    class function isSubClass<T1,T2>: Boolean; overload;
    class function isSubClass(AClass, AFromClass: TClass): Boolean; overload;

    class function newInstance<T: class>: T; overload;
    class function newInstance(AClass: TClass): TObject; overload;

    class function pointerEqualsNil<T>(AValue: T): Boolean;

    class function rttiType<T>: TRttiType; overload;
    class function rttiType(AClass: TClass): TRttiType; overload;
    class function rttiType(APointer: Pointer): TRttiType; overload;

    class function sameType<T1,T2>: Boolean; overload;
    class function sameType<T1,T2>(out AValue1: T1; out AValue2:T2): Boolean; overload;

    class procedure setNil<T>(out AValue: T);

    class function tclassOf<T>: TClass;
    class function typeName<T>: String; overload;
    class function typeName<T>(out AValue: T): String; overload;

    class function ifThen<T>(AResult: Boolean; ATrue: T; AFalse: T): T; overload;
    class function ifThen<T>(AResult: Boolean; ATrue: TFunc<T>; AFalse: TFunc<T>): T; overload;

    class procedure forEach<T>(AList: TList<T>; AProc: TForEach<T>); overload;
    class procedure forEach<T>(AList: TArray<T>; AProc: TForEach<T>); overload;
    class procedure forEach<T>(AList: TList<T>; AProc: TForEachIndex<T>); overload;
    class procedure forEach<T>(AList: TArray<T>; AProc: TForEachIndex<T>); overload;

    class function map<T>(AList: TList<T>; AFunc: TFunc1P<T, T>): TList<T>; overload;
    class function map<T>(AList: TArray<T>; AFunc: TFunc1P<T, T>): TArray<T>; overload;
    class function map<T,R>(AList: TList<T>; AFunc: TFunc1P<T, R>): TList<R>; overload;
    class function map<T,R>(AList: TArray<T>; AFunc: TFunc1P<T, R>): TArray<R>; overload;
  end;

implementation

{ TGenericUtils }

class function TGenericUtils.castTo<R,T>(AValue: T): R;
begin
  Result := R(TValue.From<T>(AValue).GetReferenceToRawData^);
end;

class function TGenericUtils.callFunc<T>(AObject: T; AFunctionName: String): TValue;
begin
  Result := callFunc<T>(AObject, AFunctionName, []);
end;

class function TGenericUtils.callFunc<T>(AObject: T; AFunctionName: String; const Args: Array of TValue): TValue;
var
  FRType: TRttiType;
  FMethod: TRttiMethod;
  FLog: String;
begin
  FLog := 'The function '+AFunctionName+' ';
  FRType := rttiType<T>;
  FMethod := FRType.GetMethod(AFunctionName);
  if Assigned(FMethod) then
  begin
    if FMethod.ReturnType <> nil then
    begin
      Result := FMethod.Invoke(TValue.From(AObject), Args);
    end
    else
      raise TGenericException.Create(FLog+'doesnt has a return!');
  end
  else
    raise TGenericException.Create(FLog+'was not being found!');
end;

class procedure TGenericUtils.freeAndNil<T>(out AValue: T);
var
  FObject: TObject;
begin
  if isObject(AValue) and (not isEmptyOrNull(AValue)) then
  begin
    try
      FObject := TValue.From<T>(AValue).AsObject;
      FObject.Free;
    except
      writeln('The value already has been free from the memory!');
    end;
  end;
  setNil(AValue);
  AValue := Default (T);
end;

class function TGenericUtils.isEmptyOrNull(AValue: TValue): Boolean;
begin
  try
    Result := PointerEqualsNil(AValue.GetReferenceToRawData);
    if (not Result) then
      AValue.ToString;
  except
    setNil(AValue);
    Result := True;
  end;
end;

class function TGenericUtils.isEmptyOrNull<T>(out AValue: T): Boolean;
begin
  try
    Result := PointerEqualsNil(AValue);
    if (not Result) then
      TValue.From<T>(AValue).ToString;
  except
    setNil(AValue);
    Result := True;
  end;
end;

class function TGenericUtils.isObject<T>: Boolean;
var
  FType: PTypeInfo;
  FTypeData: PTypeData;
begin
  FType := TValue.From<T>(Default (T)).TypeInfo;
  if (FType.Kind = tkDynArray) or (FType.Kind = tkArray) then
  begin
    FTypeData := GetTypeData(FType);
    if FTypeData.elType <> nil then
      Result := rttiType(FTypeData.elType^).TypeKind = tkClass
    else
      Result := rttiType(FTypeData.elType2^).TypeKind = tkClass;
  end
  else
    Result := TValue.From<T>(Default (T)).IsObject;
end;

class function TGenericUtils.isObject<T>(out AValue: T): Boolean;
begin
  Result := TValue.From<T>(AValue).isObject;
end;

class function TGenericUtils.isSubClass<T1,T2>: Boolean;
begin
  Result := tclassOf<T1>.InheritsFrom(tclassOf<T2>);
end;

class function TGenericUtils.isSubClass(AClass, AFromClass: TClass): Boolean;
begin
  Result := AClass.InheritsFrom(AFromClass);
end;

class function TGenericUtils.newInstance<T>: T;
begin
  Result := newInstance(T) as T;
end;

class function TGenericUtils.newInstance(AClass: TClass): TObject;
var
  FRTypeInfo: TRttiType;
  FRConstructorMethod: TRttiMethod;
  FLog: String;
begin
  FLog := 'The type '+AClass.ClassName+' ';
  FRTypeInfo := rttiType(AClass);

  if (isEmptyOrNull(FRTypeInfo)) then
    raise TGenericException.Create(FLog+'was not being found!');

  FRConstructorMethod := FRTypeInfo.GetMethod('Create');
  if (isEmptyOrNull(FRConstructorMethod)) then
    raise TGenericException.Create(FLog+'doesnt have a constructor!');

  if (Length(FRConstructorMethod.GetParameters) > 0) then
  begin
    try
      Result := FRConstructorMethod.Invoke(FRTypeInfo.AsInstance.MetaclassType, [nil]).AsObject
    except
      raise TGenericException.Create('Fail to make a new instance of '+AClass.ClassName);
    end;
  end
  else
  try
    Result := FRConstructorMethod.Invoke(FRTypeInfo.AsInstance.MetaclassType, []).AsObject;
  except
    raise TGenericException.Create('Fail to make a new instance of '+AClass.ClassName);
  end;
end;

class function TGenericUtils.pointerEqualsNil<T>(AValue: T): Boolean;
var
  FPPointer: PPointer;
begin
  try
    if (sameType<T, Pointer>) then
      FPPointer := PPointer(castTo<Pointer,T>(AValue))
    else if (sameType<T, PPointer>) then
      FPPointer := castTo<PPointer,T>(AValue)
    else
      FPPointer := PPointer(@AValue);
    Result := (FPPointer^ = nil);
  except
    raise TGenericException.Create('Type not supported!');
  end;
end;

class function TGenericUtils.rttiType<T>: TRttiType;
var
  FRContext: TRttiContext;
begin
  try
    FRContext := TRttiContext.Create;
    Result := FRContext.GetType(TypeInfo(T));
  except
    FRContext.Free;
    if (not isEmptyOrNull(Result)) then
      freeAndNil(Result);
    raise TGenericException.Create('Fail to obtain RttiType from '+typeName<T>);
  end;
end;

class function TGenericUtils.rttiType(AClass: TClass): TRttiType;
var
  FRContext: TRttiContext;
begin
  FRContext := TRttiContext.Create;
  try
    Result := FRContext.GetType(AClass);
  finally
    FRContext.Free;
  end;
end;

class function TGenericUtils.rttiType(APointer: Pointer): TRttiType;
var
  FRContext: TRttiContext;
begin
  FRContext := TRttiContext.Create;
  try
    Result := FRContext.GetType(APointer);
  finally
    FRContext.Free;
  end;
end;

class function TGenericUtils.sameType<T1,T2>: Boolean;
begin
  Result := TypeInfo(T1) = TypeInfo(T2);
end;

class function TGenericUtils.sameType<T1,T2>(out AValue1: T1; out AValue2:T2): Boolean;
begin
  Result := sameType<T1, T2>;
end;

class procedure TGenericUtils.setNil<T>(out AValue: T);
begin
  PPointer(@AValue)^ := nil;
end;

class function TGenericUtils.tclassOf<T>: TClass;
var
  FRContext: TRttiContext;
  FRType: TRttiType;
begin
  FRContext := TRttiContext.Create;
  FRType := FRContext.GetType(TypeInfo(T));
  Result := FRType.AsInstance.MetaclassType;
  FRContext.Free;
end;

class function TGenericUtils.typeName<T>: String;
begin
  Result := PTypeInfo(TypeInfo(T))^.Name;
end;

class function TGenericUtils.typeName<T>(out AValue: T): String;
begin
  if isObject<T> then
    Result := TValue.From(AValue).AsObject.ClassName
  else
    Result := typeName<T>;
end;

class function TGenericUtils.ifThen<T>(AResult: Boolean; ATrue: T; AFalse: T): T;
begin
  if AResult then
    Result := ATrue
  else
    Result := AFalse;
end;

class function TGenericUtils.ifThen<T>(AResult: Boolean; ATrue: TFunc<T>; AFalse: TFunc<T>): T;
begin
  if AResult then
    Result := ATrue
  else
    Result := AFalse;
end;

class procedure TGenericUtils.forEach<T>(AList: TList<T>; AProc: TForEach<T>);
begin
  forEach<T>(AList,
  procedure(AValue: T; AIndex: Integer; out ABreak: Boolean)
  begin
    AProc(AValue, ABreak);
  end);
end;

class procedure TGenericUtils.forEach<T>(AList: TArray<T>; AProc: TForEach<T>);
begin
  forEach<T>(AList,
  procedure(AValue: T; AIndex: Integer; out ABreak: Boolean)
  begin
    AProc(AValue, ABreak);
  end);
end;

class procedure TGenericUtils.forEach<T>(AList: TList<T>; AProc: TForEachIndex<T>);
begin
  forEach<T>(AList.ToArray, AProc);
end;

class procedure TGenericUtils.forEach<T>(AList: TArray<T>; AProc: TForEachIndex<T>);
var
  I: Integer;
  FBreak: Boolean;
begin
  FBreak := False;
  if Length(AList) > 0 then
  begin
    for I := 0 to Length(AList) - 1 do
    begin
      AProc(AList[I], I, FBreak);
      if FBreak then
        Break;
    end;
  end;
end;

class function TGenericUtils.map<T>(AList: TList<T>; AFunc: TFunc1P<T, T>): TList<T>;
begin
  Result := map<T,T>(AList, AFunc);
end;

class function TGenericUtils.map<T>(AList: TArray<T>; AFunc: TFunc1P<T, T>): TArray<T>;
begin
  Result := map<T, T>(AList, AFunc);
end;

class function TGenericUtils.map<T,R>(AList: TList<T>; AFunc: TFunc1P<T, R>): TList<R>;
var
  FValue: R;
begin
  Result := TList<R>.Create;
  for FValue in map<T, R>(AList.ToArray, AFunc) do
    Result.Add(FValue);
end;

class function TGenericUtils.map<T,R>(AList: TArray<T>; AFunc: TFunc1P<T, R>): TArray<R>;
var
  FValue: T;
  FResult: R;
  FResultList: TList<R>;
begin
  FResultList := TList<R>.Create;
  if Length(AList) > 0 then
    for FValue in AList do
    begin
      FResult := Default (R);
      FResult := AFunc(FValue);
      if not isEmptyOrNull<R>(FResult) then
        FResultList.Add(FResult);
    end;
  Result := FResultList.ToArray;
  freeAndNil(FResultList)
end;


end.

