unit UStringUtils;

interface

uses
  SysUtils,
  StrUtils,
  Classes,
  RegularExpressions;

type
  TStringUtils = class
  private
    class function UnCapitalizeMatch(const Match: TMatch): string;
    class function CapitalizeMatch(const Match: TMatch): string; static;
  public
    class function replace(const AText, AReplace, AValue: string; AOptions: TRegExOptions = [roIgnoreCase]): string; overload;
    class function capitalize(const AText: String): String;
    class function unCapitalize(const AText: String): String;
    class function startWith(AText, AContains: String): Boolean; static;
    class function noAccent(AText: String): String; static;
  end;

implementation

{ TStringUtils }

class function TStringUtils.CapitalizeMatch(const Match: TMatch): string;
begin
  Result := UpperCase(Match.Value);
end;

class function TStringUtils.capitalize(const AText: String): String;
var
  Regex: TRegEx;
begin
  {First Letter}
  Regex := TRegEx.Create('^([a-z])');
  {Replace by lower one}
  Result := Regex.Replace(AText, '\U$1');
end;

class function TStringUtils.UnCapitalizeMatch(const Match: TMatch): string;
begin
  Result := LowerCase(Match.Value);
end;

class function TStringUtils.unCapitalize(const AText: String): String;
var
  Regex: TRegEx;
  myEval: TMatchEvaluator;
begin
  {First Letter}
  Regex := TRegEx.Create('([A-Z])');
  {Replace by lower one}
  myEval := UnCapitalizeMatch;
  Result := Regex.Replace(AText,myEval)
end;

class function TStringUtils.replace(const AText, AReplace, AValue: string;
  AOptions: TRegExOptions): string;
var
  FRegex: TRegEx;
begin
  FRegex := TRegEx.Create(AReplace, AOptions);
  Result := FRegex.Replace(AText, AValue);
end;

class function TStringUtils.startWith(AText, AContains: String): Boolean;
begin
  Result := Pos(AContains, AText) = 1;
end;

class function TStringUtils.noAccent(AText: String): String;
var
  FByteList: TBytes;
begin
  FByteList := TEncoding.Convert(TEncoding.Unicode, TEncoding.ASCII, TEncoding.Unicode.GetBytes(AText));
  Result := StringOf(FByteList);
end;

//class function TStringUtils.putQuotes(AText: String; ADoubleQuotes: Boolean): String;
//begin
//  if ADoubleQuotes then
//    Result := '"'+AText+ '"'
//  else
//    Result := ''''+AText+ '''';
//end;
end.
