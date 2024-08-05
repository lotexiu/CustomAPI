unit UArrayHelper;

interface

uses
  SysUtils,
  Classes,
  JSON.Serializers,
  REST.Json.Types,
  REST.JsonReflect,
  Generics.Collections,
  Generics.Defaults,
  Rtti,
  UGenericUtils;

/// <summary>
///
/// </summary>
type
  /// <summary>
  ///  Utility class for manipulating arrays.
  /// </summary>
  /// <remarks>
  ///  It's similar to record helper for TArray
  /// </remarks>
  TArrayHelper<T> = class
  private
    [JSONMarshalled(False)]
    FArrayList: ^TArray<T>;
    [JSONMarshalled(False)]
    FFreeValue: Boolean;
    [JSONMarshalled(False)]
    FNonNullIndex: Boolean;

    procedure freeValueIfPossible(AValue:T);
    procedure setItem(AIndex: Integer; const AValue: T);
    function getSize: Integer;
    function getItem(AIndex: Integer): T;
    function getLast: T;
    function getFirst: T;
    function newList: TArray<T>;
  public
    property Items[Index: Integer]: T read getItem write setItem; default;
    property Count: Integer read getSize;
    property Length: Integer read getSize;
    property First: T read getFirst;
    property Last: T read getLast;

    /// <summary>
    ///  On True: Free the value when he loses the reference in the list
    /// </summary>
    property AutoFreeUnusedValues: Boolean read FFreeValue write FFreeValue;
    /// <summary>
    ///  On True: Removes all index that contains a null value
    /// </summary>
    property AutoRemoveNullIndexes: Boolean read FNonNullIndex write FNonNullIndex;

    procedure add(AValue:T; Aindex:Integer; AForceIndex: Boolean=False); overload;
    procedure add(AValue:T); overload;

    /// <summary>
    ///  Remove Value but keep the index
    /// </summary>
    procedure removeValue(AIndex:Integer);
    /// <summary>
    ///  Remove Value and index from list
    /// </summary>
    procedure removeIndex(AIndex:Integer);
    /// <summary>
    ///  Removes all indexes with null values
    /// </summary>
    procedure removeNullIndexes;
    /// <summary>
    ///  Removes all values and make a new List
    /// </summary>
    procedure clear;

    function map<TReturn>(AFunc: TFunc<T,Integer,TReturn>): TArrayHelper<TReturn>; overload;
    function map(AFunc: TFunc<T,Integer,T>): TArrayHelper<T>; overload;
    procedure forEach(AProc: TProc<T,Integer,Boolean>); overload;
    procedure forEach(AProc: TProc<T,Boolean>); overload;

    function contains(AFunc: TFunc<T,Integer,T>):Boolean; overload;
    function contains(AValue: T): Boolean; overload;

    {
    TODO
      Sort        IMPORTANT by Value or Func
      Reverse     none
      IndexOf     IMPORTANT by Value or Func
      LastIndexOf IMPORTANT by Value or Func
    }

    /// <summary>
    ///  Receives the variable that will be updated and changed by the helper
    /// </summary>
    constructor Create(var AArray: TArray<T>);
  end;

implementation

{ TArrayList<T> }

procedure TArrayHelper<T>.add(AValue: T);
begin
  add(AValue,getSize,True);
end;

procedure TArrayHelper<T>.clear;
begin
  if FFreeValue then
  begin
    forEach(procedure(AValue:T; ABreak:Boolean)
    begin
      TGenericUtils.freeAndNil<T>(AValue);
    end);
  end
  else
    FArrayList^ := newList;
end;

function TArrayHelper<T>.contains(AValue: T): Boolean;
var
  FResult: Boolean;
begin
//  forEach(procedure(AForValue: T; AIndex:Integer; ABreak: Boolean)
//  begin
//    FResult := AForValue = AValue;
////    if FResult then
////      ABreak := True;
//  end);
//  TGenericUtils.forEach<T>(FArrayList^,
//  procedure(AForValue: T; AIndex:Integer; ABreak: Boolean)
//  begin
//      FResult := AForValue = AValue;
//      writeln('x'+TValue.from<T>(AForValue).ToString +'-'+ TValue.from<T>(AValue).ToString+'x');
//  end);
//  Result := FResult;
end;

function TArrayHelper<T>.contains(AFunc: TFunc<T, Integer, T>): Boolean;
var
  FResult: Boolean;
begin
//  forEach(procedure(AValue: T; AIndex:Integer; ABreak: Boolean)
//  begin
//    FResult := not TGenericUtils.isEmptyOrNull<T>(AFunc(AValue, AIndex));
//    if FResult then
//      ABreak := True;
//  end);
//  Result := FResult;
end;

procedure TArrayHelper<T>.add(AValue: T; Aindex: Integer; AForceIndex: Boolean);
begin
  if (Aindex > getSize-1) and (not AForceIndex) then
    raise Exception.Create('Out of Range')
  else
  begin
    if AIndex > getSize-1 then
      SetLength(FArrayList^, AIndex+1);
    FArrayList^[AIndex] := AValue;
  end;
end;

constructor TArrayHelper<T>.Create(var AArray: TArray<T>);
begin
  FArrayList := @AArray;

end;

procedure TArrayHelper<T>.forEach(AProc: TProc<T, Integer, Boolean>);
begin
//  TGenericUtils.forEach<T>(FArrayList^,
//  procedure(AValue: T; AIndex: Integer; ABreak: Boolean)
//  begin
//    AProc(AValue,AIndex,ABreak);
//  end);
end;

procedure TArrayHelper<T>.forEach(AProc: TProc<T, Boolean>);
begin
//  TGenericUtils.forEach<T>(FArrayList^,
//  procedure(AValue: T; ABreak: Boolean)
//  begin
//    AProc(AValue,ABreak);
//  end);
end;

procedure TArrayHelper<T>.freeValueIfPossible(AValue: T);
begin
  if not TGenericUtils.isEmptyOrNull<T>(AValue) and FFreeValue then
  begin
    if not contains(AValue) then
      TGenericUtils.freeAndNil<T>(AValue);
  end;
end;

function TArrayHelper<T>.getFirst: T;
begin
  Result := FArrayList^[0];
end;

function TArrayHelper<T>.getItem(AIndex: Integer): T;
begin
  Result := FArrayList^[AIndex];
end;

function TArrayHelper<T>.getLast: T;
begin
  Result := FArrayList^[getSize-1];
end;

function TArrayHelper<T>.getSize: Integer;
begin
  Result := System.Length(FArrayList^);
end;

function TArrayHelper<T>.map(AFunc: TFunc<T, Integer, T>): TArrayHelper<T>;
var
  FMapList: TArray<T>;
begin
//  FMapList := TGenericUtils.map<T,T>(FArrayList^, AFunc);
//  Result := TArrayHelper<T>.Create(FMapList);
end;

function TArrayHelper<T>.map<TReturn>(
  AFunc: TFunc<T, Integer, TReturn>): TArrayHelper<TReturn>;
var
  FMapList: TArray<TReturn>;
begin
//  FMapList := TGenericUtils.map<T,TReturn>(FArrayList^, AFunc);
//  Result := TArrayHelper<TReturn>.Create(FMapList);
end;

function TArrayHelper<T>.newList: TArray<T>;
begin
  SetLength(Result,0);
end;

procedure TArrayHelper<T>.removeIndex(AIndex: Integer);
var
  FRemovedValue: T;
begin
//  FArrayList^ := TGenericUtils.map<T,T>(FArrayList^,
//  function(AValue: T; AMapIndex: Integer):T
//  begin
//    if AIndex <> AMapIndex then
//      Result := AValue
//    else
//    begin
//      Result := Default(T);
//      FRemovedValue := AValue;
//    end;
//  end);
//  freeValueIfPossible(FRemovedValue);
end;

procedure TArrayHelper<T>.removeNullIndexes;
begin
//  FArrayList^ := TGenericUtils.map<T,T>(FArrayList^,
//  function(AValue:T):T
//  begin
//    Result := AValue;
//  end);
end;

procedure TArrayHelper<T>.removeValue(AIndex: Integer);
var
  FRemovedValue: T;
begin
//  TGenericUtils.forEach<T>(FArrayList^,
//  procedure(AValue: T; AForIndex: Integer; ABreak: Boolean)
//  begin
//    if AForIndex = AIndex then
//    begin
//      AValue := Default(T);
//      FRemovedValue := AValue;
//      ABreak := True;
//    end;
//  end);
//  freeValueIfPossible(FRemovedValue);
end;

procedure TArrayHelper<T>.setItem(AIndex: Integer; const AValue: T);
begin
  FArrayList^[AIndex] := AValue;
end;
end.

