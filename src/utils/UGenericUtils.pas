unit UGenericUtils;

interface

uses
  { System }
  SysUtils,
  StrUtils,
  RegularExpressions,
  { Reflexao }
  Rtti,
  TypInfo,
  { Reflexao }
  Generics.Collections,
  Generics.Defaults,
  { UImports }
  UDebugUtils,
  UGenericException,
  UArrayUtils;
type
  TFunc<T> = reference to function: T;
  TFunc1P<T> = reference to function(AValue: T): T;
  TFunc1P<T,R> = reference to function(AValue: T): R;
  TForEach<T> = reference to procedure(AValue: T; out ABreak: Boolean);
  TForEachIndex<T> = reference to procedure(AValue: T; AIndex: Integer; out ABreak: Boolean);

  TProcObj = procedure of object;

  TValue = Rtti.TValue;
  TGenericRange = 0 .. 255;

  TGenericUtils = class
  private
//    class procedure getAllObjectTypesInTheTypeRecursive(AClass: TClass; out AList:TList<TClass>);
  public
    class function castTo<R,T>(AValue: T): R; overload;
    class function castTo<R>(Avalue: Pointer): R; overload;

    class function callFunc<T>(AObject: T; AFunctionName: String): TValue; overload;
    class function callFunc<T>(AObject: T; AFunctionName: String; const Args: Array of TValue): TValue; overload;

    class function defaultFunc<T>: TFunc<T>;
    class function defaultProc: TProc;

    class function equals<T>(AValue, AValue2: T): Boolean; overload;
    class function equals<T>(AValue: T): Boolean; overload;

    class procedure freeAndNil<T>(out AValue: T);

    class function isEmptyOrNull(AValue: TValue): Boolean; overload;
    class function isEmptyOrNull<T>(AValue: T): Boolean; overload;

    class function isObject(AValue: TValue): Boolean; overload;
    class function isObject<T>: Boolean; overload;
    class function isObject<T>(AValue: T): Boolean; overload;
    class function isArrayOfObject(AValue: TValue): Boolean; overload;
    class function isArrayOfObject<T>: Boolean; overload;

    class function isSubClass<T1,T2>: Boolean; overload;
    class function isSubClass(AClass, AFromClass: TClass): Boolean; overload;

    class function newInstance<T: class>: T; overload;
    class function newInstance(AClass: TClass): TObject; overload;

    class function rttiType<T>: TRttiType; overload;
    class function rttiType(AClass: TClass): TRttiType; overload;
    class function rttiType(APointer: Pointer): TRttiType; overload;

    class function sameType<T1,T2>: Boolean; overload;
    class function sameType<T1,T2>(AValue1: T1; AValue2:T2): Boolean; overload;

    class procedure setNil<T>(out AValue: T);

    class function tclassOf<T>: TClass; overload;
    class function tclassOf(AQualifiedName: String): TClass; overload;
    class function tclassOf<T:class>(AObject: T): TClass; overload;
    class function tclassOf(APointer: Pointer): TClass; overload;

    class function typeName<T>: String; overload;
    class function typeName<T>(AValue: T): String; overload;

    class function ifThen<T>(AResult: Boolean; ATrue: T; AFalse: T): T; overload;
    class function ifThen<T>(AResult: Boolean; ATrue: TFunc<T>; AFalse: TFunc<T>): T; overload;

    class procedure forEach<T>(AList: TList<T>; AProc: TForEach<T>); overload;
    class procedure forEach<T>(AList: TArray<T>; AProc: TForEach<T>); overload;
    class procedure forEach<T>(AList: TList<T>; AProc: TForEachIndex<T>); overload;
    class procedure forEach<T>(AList: TArray<T>; AProc: TForEachIndex<T>); overload;

    class function map<T>(AList: TArray<T>; AFunc: TFunc1P<T, T>): TArray<T>; overload;
    class function map<T,R>(AList: TArray<T>; AFunc: TFunc1P<T, R>): TArray<R>; overload;
    class function map<T>(AList: TList<T>; AFunc: TFunc1P<T, T>; ADestroyOldList: Boolean = True): TList<T>; overload;
    class function map<T,R>(AList: TList<T>; AFunc: TFunc1P<T, R>; ADestroyOldList: Boolean = True): TList<R>; overload;
//    class function getAttributes(ARType: TRttiType; AAttributeType: TClass = nil; AFrom: TClass = nil;
//      AName: String = ''; AParamsTypeList: TArray<String> = []): TArray<TCustomAttribute>; overload;
//    class function getAttributes<R: class; T>(ARType: TRttiType = nil): TArray<R>; overload;
//    class function getAttributesFromAMethod(ARType: TRttiType; AFrom: TClass; AName: String = '';
//      AType: String = ''): TArray<TCustomAttribute>;
//    class function getAllObjectTypesInTheType(AClass: TClass):TList<TClass>;
//    class function getGenericTypes(AQualifiedName: String):TList<TClass>;
//    class function copyParentDataToChildren<T,R:class>(AParent:T; AChildren:R):R;
  end;
implementation

{ TGenericUtils }

class function TGenericUtils.castTo<R,T>(AValue: T): R;
begin
  Result := R(TValue.From<T>(AValue).GetReferenceToRawData^);
end;

class function TGenericUtils.castTo<R>(Avalue: Pointer): R;
begin
  Result := R(AValue^);
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

class function TGenericUtils.defaultFunc<T>: TFunc<T>;
begin
  Result := function: T
  begin
    Result := Default(T)
  end;
end;

class function TGenericUtils.defaultProc: TProc;
begin
  Result := procedure
  begin
  end;
end;

class function TGenericUtils.equals<T>(AValue, AValue2: T): Boolean;
var
  FCompare: IEqualityComparer<T>;
begin
  Result := False;
  try
    FCompare := TEqualityComparer<T>.Default;
    Result := FCompare.Equals(AValue, AValue2);
  except
    raise TGenericException.Create('Fail on generic compare '+typeName<T>+'.');
  end;
end;

class function TGenericUtils.equals<T>(AValue: T): Boolean;
begin
  Result := equals<T>(AValue, Default(T));
end;

class procedure TGenericUtils.freeAndNil<T>(out AValue: T);
var
  FObject: TObject;
  FDataInfo: TDataInfo;
  FValue: TClass;
begin
  if (not isEmptyOrNull(AValue)) and isObject(AValue) then
  begin
    try
      FValue := tclassOf(castTo<TObject, T>(AValue));
      FObject := TValue.From<T>(AValue).AsObject;
      FObject.Free;
    except    
      FDataInfo := TDebugUtils.getCurrentDataInfo(2);
      writeln('The value from '+typeName<T>+' has already been free from the memory!');
      writeln('File: '+FDataInfo.FileName+' Function: '+FDataInfo.CallBy);
    end;
  end;
  setNil(AValue);
  AValue := Default (T);
end;

class function TGenericUtils.isEmptyOrNull(AValue: TValue): Boolean;
begin
  try
    if (not Result) then
      Result := AValue.IsEmpty;
    if (not Result) then
      Result := AValue.TypeInfo = nil;
    if (not Result) then
      AValue.ToString;
  except
    Result := True;
  end;
end;

class function TGenericUtils.isEmptyOrNull<T>(AValue: T): Boolean;
var
  FValue: TValue;
  FClass: TClass;
begin
  Result := False;
  try
    FValue := TValue.From<T>(AValue);
    {Empty}
    if (not Result) then
      Result := FValue.IsEmpty;
    {Null Type}
    if (not Result) then
      Result := FValue.TypeInfo = nil;
    {T, Value is both Object or not}
    if (not Result) and (FValue.Kind <> tkInterface) then
      Result := not (isObject<T> = FValue.IsObject);
    {not Valid Class}
    if (not Result) then
    begin
      if FValue.IsObject then
      begin
        FClass := FValue.AsObject.ClassType;
        {Not T or SubClass of T}
        Result := not ((FClass = tclassOf<T>) or (FClass.InheritsFrom(tclassOf<T>)));
      end;
    end;
    {Equals Default}
    if (not Result) and (not sameType<T, Boolean>) then
      Result := equals<T>(AValue);
    {Try it to use}
    if (not Result) then
      FValue.ToString;
  except
    setNil(AValue);
    Result := True;
  end;
end;

class function TGenericUtils.isObject(AValue: TValue): Boolean;
var
  FType: PTypeInfo;
  FTypeData: PTypeData;
begin
  FType := AValue.TypeInfo;
  {Not Array}
  Result := not ((FType.Kind = tkDynArray) or (FType.Kind = tkArray));
  if Result then
    Result := AValue.IsObject;
end;

class function TGenericUtils.isObject<T>: Boolean;
begin
  Result := isObject(TValue.From<T>(Default(T)));
end;

class function TGenericUtils.isObject<T>(AValue: T): Boolean;
begin
  Result := isObject<T>;
end;

class function TGenericUtils.isArrayOfObject(AValue: TValue): Boolean;
var
  FType: PTypeInfo;
  FTypeData: PTypeData;
begin
  Result := False;
  FType := AValue.TypeInfo;
  if (FType.Kind = tkDynArray) or (FType.Kind = tkArray) then
  begin
    FTypeData := GetTypeData(FType);
    if FTypeData.elType <> nil then
      Result := rttiType(FTypeData.elType^).TypeKind = tkClass
    else
      Result := rttiType(FTypeData.elType2^).TypeKind = tkClass;
  end
end;

class function TGenericUtils.isArrayOfObject<T>: Boolean;
begin
  isArrayOfObject(TValue.From<T>(Default(T)));
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
  FArray: TArray<TValue>;
  FLog: String;
begin
  FLog := 'The type '+AClass.ClassName+' ';
  FRTypeInfo := rttiType(AClass);
  if (isEmptyOrNull(FRTypeInfo)) then
    raise TGenericException.Create(FLog+'was not being found!');
  FRConstructorMethod := FRTypeInfo.GetMethod('Create');
  if (isEmptyOrNull(FRConstructorMethod)) then
    raise TGenericException.Create(FLog+'doesnt have a constructor!');
  FArray := [];
  if (Length(FRConstructorMethod.GetParameters) > 0) then
    FArray := [nil];
  try
    Result := FRConstructorMethod.Invoke(FRTypeInfo.AsInstance.MetaclassType, []).AsObject;
  except
    raise TGenericException.Create('Fail to make a new instance of '+AClass.ClassName);
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

class function TGenericUtils.sameType<T1,T2>(AValue1: T1; AValue2:T2): Boolean;
begin
  Result := sameType<T1, T2>;
end;

class procedure TGenericUtils.setNil<T>(out AValue: T);
begin
  PPointer(@AValue)^ := nil;
end;

class function TGenericUtils.tclassOf<T>: TClass;
begin
  Result := tclassOf(TypeInfo(T));
end;

class function TGenericUtils.tclassOf(AQualifiedName: String): TClass;
var
  FRContext: TRttiContext;
  FRType: TRttiType;
begin
  FRContext := TRttiContext.Create;
  FRType := FRContext.FindType(AQualifiedName);
  if FRType.IsInstance then  
    Result := FRType.AsInstance.MetaclassType;
  FRContext.Free;
end;

class function TGenericUtils.tclassOf(APointer: Pointer): TClass;
var
  FRContext: TRttiContext;
  FRType: TRttiType;
begin
  FRContext := TRttiContext.Create;
  FRType := FRContext.GetType(APointer);
  Result := FRType.AsInstance.MetaclassType;
  FRContext.Free;
end;

class function TGenericUtils.tclassOf<T>(AObject: T): TClass;
begin
  Result := TValue.From<T>(AObject).AsObject.ClassType;
end;

class function TGenericUtils.typeName<T>: String;
begin
  Result := PTypeInfo(TypeInfo(T))^.Name;
end;

class function TGenericUtils.typeName<T>(AValue: T): String;
begin
  Result := typeName<T>;
  if isObject<T> then
    Result := TValue.From(AValue).AsObject.ClassName;
end;

class function TGenericUtils.ifThen<T>(AResult: Boolean; ATrue: T; AFalse: T): T;
begin
  Result := AFalse;
  if AResult then
    Result := ATrue;
end;

class function TGenericUtils.ifThen<T>(AResult: Boolean; ATrue: TFunc<T>; AFalse: TFunc<T>): T;
begin
  Result := AFalse;
  if AResult then
    Result := ATrue;
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
  if (not TGenericUtils.isEmptyOrNull(AList)) then
    forEach<T>(AList.ToArray, AProc);
end;

class procedure TGenericUtils.forEach<T>(AList: TArray<T>; AProc: TForEachIndex<T>);
var
  I: Integer;
  FBreak: Boolean;
begin
  FBreak := False;
  if (not TGenericUtils.isEmptyOrNull(AList)) then
  begin
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
end;

class function TGenericUtils.map<T>(AList: TList<T>; AFunc: TFunc1P<T, T>; ADestroyOldList: Boolean): TList<T>;
begin
  Result := map<T,T>(AList, AFunc, ADestroyOldList);
end;

class function TGenericUtils.map<T>(AList: TArray<T>; AFunc: TFunc1P<T, T>): TArray<T>;
begin
  Result := map<T,T>(AList, AFunc);
end;

class function TGenericUtils.map<T,R>(AList: TList<T>; AFunc: TFunc1P<T, R>; ADestroyOldList: Boolean): TList<R>;
var
  FValue: R;
begin
  Result := TList<R>.Create;
  for FValue in map<T, R>(AList.ToArray, AFunc) do
    Result.Add(FValue);
  if (ADestroyOldList = True) then
  begin
    TGenericUtils.freeAndNil(AList);
  end;
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

//class function TGenericUtils.copyParentDataToChildren<T, R>(AParent:T; AChildren:R): R;
//var
//  FParentType, FChildrenType: TRttiType;
//  FChildrenProp: TRttiProperty;
//  FChildrenField: TRttiField;
//begin
//  FParentType := rttiType<T>;
//  FChildrenType := rttiType<R>;
//  TGenericUtils.forEach<TRttiProperty>(FParentType.GetProperties,
//  procedure(AParentProperty: TRttiProperty; out ABreak: Boolean)
//  begin
//    FChildrenProp := FChildrenType.GetProperty(AParentProperty.Name);
//    if (FChildrenProp <> nil) and (FChildrenProp.IsWritable) then
//      FChildrenProp.SetValue(Pointer(AChildren), AParentProperty.GetValue(@AParent));
//  end);
//  TGenericUtils.forEach<TRttiField>(FParentType.GetFields,
//  procedure(AParentField: TRttiField; out ABreak: Boolean)
//  begin
//    FChildrenField := FChildrenType.GetField(AParentField.Name);
//    if (FChildrenField <> nil) and (FChildrenField.Visibility in [mvPublic, mvPublished, mvProtected]) then
//      FChildrenProp.SetValue(Pointer(AChildren),AParentField.GetValue(@AParent));
//  end);
//  Result := AChildren;
//end;
//class function TGenericUtils.getAllObjectTypesInTheType(AClass: TClass): TList<TClass>;
//begin
//  Result := TList<TClass>.Create;
//  getAllObjectTypesInTheTypeRecursive(AClass, Result);
//end;
//class procedure TGenericUtils.getAllObjectTypesInTheTypeRecursive(AClass: TClass; out AList:TList<TClass>);
//var
//  FRttiType: TRttiType;
//  FList: TList<TClass>;
//  FListFromQualifiedName: TList<TClass>;
//begin
//  FList := AList;
//  FRttiType := rttiType(AClass);
//  if (not isEmptyOrNull(FRttiType)) then
//  begin
//    forEach<TRttiProperty>(FRttiType.GetProperties,
//    procedure(AValue: TRttiProperty; out ABreak: Boolean)
//    var
//      FProp: TRttiType;
//    begin
//      FProp := AValue.PropertyType;
//      FListFromQualifiedName := getGenericTypes(FProp.QualifiedName);
//      forEach<TClass>(FListFromQualifiedName,
//      procedure(AClass: TClass; out ABreak2: Boolean)
//      begin
//        if FList.IndexOf(AClass) = -1 then
//          FList.Add(AClass);
//      end);
//      freeAndNil(FListFromQualifiedName);
//      if FProp.IsInstance then
//      begin
//        if FList.IndexOf(FProp.AsInstance.MetaclassType) = -1 then
//        begin
//          FList.Add(FProp.AsInstance.MetaclassType);
//          getAllObjectTypesInTheTypeRecursive(FProp.AsInstance.MetaclassType, FList);
//        end;
//      end;
//    end);
//  end;
//end;
//class function TGenericUtils.getGenericTypes(AQualifiedName: String):TList<TClass>;
//var
//  FRegex: TRegEx;
//  FMatch: TMatch;
//  FResult: String;
//  FList: TList<TClass>;
//begin
//  FList := TList<TClass>.Create;
//  FRegex := TRegEx.Create('<([^<>]+)>');
//  FMatch := FRegex.Match(AQualifiedName);
//  if (FMatch.Length > 0) then
//  begin
//    FResult := StringReplace(StringReplace(FMatch.Value,'<','',[]),'>','',[]);
//    forEach<String>(SplitString(FResult,','),
//    procedure(AValue: String; out ABreak: Boolean)
//    begin
//      if not isEmptyOrNull(tclassOf(AValue)) then
//        FList.Add(tclassOf(AValue));
//    end);
//  end;
//  freeAndNil(FMatch);
//  freeAndNil(FRegex);
//  Result := FList;
//end;
//class function TGenericUtils.getAttributes(ARType: TRttiType; AAttributeType: TClass = nil; AFrom: TClass = nil;
//  AName: String = ''; AParamsTypeList: TArray<String> = []): TArray<TCustomAttribute>;
//var
//  FRMethod: TRttiMethod;
//  FRParameter: TRttiParameter;
//  FStringList: TArray<String>;
//  FResultList: TArray<TCustomAttribute>;
//begin
//  if (not Assigned(AFrom)) then
//    FResultList := ARType.getAttributes
//  else if AFrom = TRttiMethod then
//  begin
//    if (Length(ARType.GetMethods(AName)) > 1) then
//      for FRMethod in ARType.GetMethods(AName) do
//      begin
//        if Length(FRMethod.GetParameters) = Length(AParamsTypeList) then
//        begin
//          FStringList := map<TRttiParameter, String>(FRMethod.GetParameters,
//            function(AValue: TRttiParameter): String
//            begin
//              Result := AValue.ParamType.Name;
//            end);
//          if String.Join(',', FStringList) = String.Join(',', AParamsTypeList)
//          then
//          begin
//            FResultList := FRMethod.getAttributes;
//            Break;
//          end;
//        end;
//      end
//    else
//      FResultList := ARType.GetMethod(AName).getAttributes;
//  end
//  else if AFrom = TRttiField then
//    FResultList := ARType.GetField(AName).getAttributes
//  else if AFrom = TRttiProperty then
//    FResultList := ARType.GetProperty(AName).getAttributes
//  else if AFrom = TRttiIndexedProperty then
//    FResultList := ARType.GetIndexedProperty(AName).getAttributes
//  else if AFrom = TRttiParameter then
//    raise TGenericException.Create
//      ('Utilze getAttributesFromAMethod para obter os atributos de um parâmetro.')
//  else
//    raise TGenericException.Create(AFrom.ClassName + ' não suportado.');
//
//  if Assigned(AAttributeType) then
//  begin
//    Result := map<TCustomAttribute>(FResultList,
//      function(AValue: TCustomAttribute): TCustomAttribute
//      begin
//        if AValue is AAttributeType then
//          Result := AValue
//        else
//          Result := nil;
//      end);
//  end
//  else
//    Result := FResultList;
//end;
//class function TGenericUtils.getAttributes<R,T>(ARType: TRttiType = nil): TArray<R>;
//var
//  FRContext: TRttiContext;
//  FRType: TRttiType;
//begin
//  if Assigned(ARType) then
//    Result := TArrayUtils.TArrayCast<TCustomAttribute, R>
//      (getAttributes(ARType, R))
//  else
//  begin
//    FRContext := TRttiContext.Create;
//    FRType := FRContext.GetType(TypeInfo(T));
//    Result := TArrayUtils.TArrayCast<TCustomAttribute, R>
//      (getAttributes(FRType, R))
//  end;
//  FRContext.Free;
//end;
//class function TGenericUtils.getAttributesFromAMethod(ARType: TRttiType; AFrom: TClass; AName: String = '';
//  AType: String = ''): TArray<TCustomAttribute>;
//var
//  FRMethod: TRttiMethod;
//  FRParameter: TRttiParameter;
//begin
//  for FRMethod in ARType.GetMethods(AName) do
//  begin
//    if AFrom = TRttiMethod then
//      Result := FRMethod.getAttributes
//    else if AFrom = TRttiParameter then
//    begin
//      if (AName = '') or (AType = '') then
//        raise TGenericException.Create
//          ('Campo AName e AType é necessário para buscar attributos de parâmetro.')
//      else
//        for FRParameter in FRMethod.GetParameters do
//        begin
//          if (FRParameter.Name = AName) and (FRParameter.ParamType.Name = AType)
//          then
//            Result := FRParameter.getAttributes;
//        end;
//    end;
//  end;
//end;
end.
