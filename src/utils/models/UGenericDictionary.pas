unit UGenericDictionary;

interface

uses
  Generics.Collections,
  UGenericUtils;

type
  TGenericDictionary = class
  private
    FDictionary: TDictionary<String, TValue>;
    FFreeValues: Boolean;
    function getCount: Integer;
    function getItem(const AKey: String): TValue;
    procedure setItem(const AKey: String; const AValue: TValue);
    function getKeys: TArray<String>;
  public
    constructor Create;
    destructor Destroy; override;

    property FreeValuesOnDestroy: Boolean read FFreeValues write FFreeValues;
    property Count: Integer read getCount;
    property Items[const Key: String]: TValue read getItem write setItem; default;
    property Keys: TArray<String> read getKeys;

    function Values: TArray<TValue>; overload;
    function Values<T>: TArray<T>; overload;

    function get<T>(AKey: String): T;
    function getPair(AKey: String): TPair<string, TValue>; overload;
    function getPair<T>(AKey: String): TPair<string, T>; overload;

    procedure add<T>(AKey: String; AValue:T);
    procedure remove<T>(AKey: String);

    function containsKey(AKey: String): Boolean;
    function containsValue<T>(AValue: T): Boolean;

    procedure trimExcess;
    procedure clear;
  end;
implementation

{ TGenericDictionary }

procedure TGenericDictionary.add<T>(AKey: String; AValue: T);
begin
  FDictionary.Add(AKey, TValue.From<T>(AValue));
end;

procedure TGenericDictionary.clear;
begin
  FDictionary.Clear;
end;

function TGenericDictionary.containsKey(AKey: String): Boolean;
begin
  Result := FDictionary.ContainsKey(AKey);
end;

function TGenericDictionary.containsValue<T>(AValue: T): Boolean;
var
  FResult: Boolean;
begin
  FResult := False;
  TGenericUtils.forEach<TValue>(FDictionary.Values.ToArray,
  procedure(ATValue: TValue; out ABreak: Boolean)
  begin
    if TGenericUtils.equals<T>(ATValue.AsType<T>) then
    begin
      FResult := True;
      ABreak := True;
    end
  end);
  Result := FResult;
end;

constructor TGenericDictionary.Create;
begin
  FDictionary := TDictionary<String, TValue>.Create;
end;

destructor TGenericDictionary.Destroy;
begin
  TGenericUtils.forEach<TValue>(Values,
  procedure(AValue: TValue; out ABreak: Boolean)
  var
    FObj: TObject;
    I: Integer;
  begin
    if TGenericUtils.isObject(AValue) then
    begin
      FObj := AValue.AsObject;
      TGenericUtils.freeAndNil(FObj);
    end;
    if TGenericUtils.isArrayOfObject(AValue) then
    begin
      for I := 0 to AValue.GetArrayLength do
      begin
        if TGenericUtils.isObject(AValue.GetArrayElement(I)) then
        begin
          FObj := AValue.GetArrayElement(I).AsObject;
          TGenericUtils.freeAndNil(FObj);
        end;
      end;
    end;
  end);
  TGenericUtils.freeAndNil(FDictionary);
  inherited;
end;

function TGenericDictionary.get<T>(AKey: String): T;
begin
  Result := Default(T);
  if FDictionary.ContainsKey(AKey) then
    Result := FDictionary[AKey].AsType<T>;
end;

function TGenericDictionary.getCount: Integer;
begin
  Result := FDictionary.Count;
end;

function TGenericDictionary.getItem(const AKey: String): TValue;
begin
  Result := FDictionary.Items[AKey];
end;

function TGenericDictionary.getKeys: TArray<String>;
begin
  Result := FDictionary.Keys.ToArray;
end;

function TGenericDictionary.getPair(AKey: String): TPair<string, TValue>;
begin
  Result := FDictionary.ExtractPair(AKey);
end;

function TGenericDictionary.getPair<T>(AKey: String): TPair<string, T>;
begin
  Result := TPair<string, T>.Create(AKey, get<T>(AKey))
end;

function TGenericDictionary.Values: TArray<TValue>;
begin
  Result := FDictionary.Values.ToArray;
end;

function TGenericDictionary.Values<T>: TArray<T>;
begin
  Result := TGenericUtils.map<TValue, T>(Values,
  function(AValue: TValue): T
  begin
    Result := AValue.AsType<T>;
  end);
end;

procedure TGenericDictionary.remove<T>(AKey: String);
begin
  FDictionary.Remove(AKey);
end;

procedure TGenericDictionary.setItem(const AKey: String; const AValue: TValue);
begin
  FDictionary.AddOrSetValue(AKey,AValue);
end;

procedure TGenericDictionary.trimExcess;
begin
  FDictionary.TrimExcess;
end;

end.


