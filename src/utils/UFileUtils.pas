unit UFileUtils;

interface

uses
  SyncObjs,
  Classes,
  Rtti,
  StrUtils,
  SysUtils,
  IniFiles,
  UGenericUtils,
  UThreadUtils;

type
  TFileUtils = class
  private
    class var critSectionLog: TCriticalSection;
  public
    class procedure buildFile(AFile: String); overload;
    class procedure buildFile(APath, AFile: String); overload;
    class procedure buildPath(APath: String);
    class procedure save(AText, AFile: String; AKeepPreviousData: Boolean); overload;
    class procedure save(AText, AFile: String); overload;
    class function readParam<T>(ASection, AParam: String; ADefaultValue: T; AFile: String):T;
    class function writeParam<T>(ASection, AParam: String; ADefaultValue: T; AFile: String):T;
    class procedure writeLog(ALog, AFile: String; AKeepTrying: Boolean = False);
  end;

implementation

{ TFileUtils }

class procedure TFileUtils.buildFile(AFile: String);
var
  FFile: TextFile;
begin
  buildPath(ExtractFilePath(AFile));
  if not FileExists(AFile) then
  begin
    AssignFile(FFile, AFile);
    Rewrite(FFile);
    CloseFile(FFile);
  end;
end;

class procedure TFileUtils.buildFile(APath, AFile: String);
begin
  buildFile(APath+AFile);
end;

class procedure TFileUtils.buildPath(APath: String);
begin
  if not DirectoryExists(APath) then
    ForceDirectories(APath);
end;

class procedure TFileUtils.save(AText, AFile: String);
begin
  save(AText, AFile, False);
end;

class procedure TFileUtils.save(AText, AFile: String; AKeepPreviousData: Boolean);
var
  Writer: TStreamWriter;
begin
  Writer := TStreamWriter.Create(AFile, AKeepPreviousData, TEncoding.UTF8);
  Writer.WriteLine(AText);
  Writer.Flush;
  Writer.Free;
end;

class function TFileUtils.readParam<T>(ASection, AParam: String; ADefaultValue: T; AFile: String): T;
var
  FIni: TIniFile;
begin
  buildPath(ExtractFilePath(AFile));
  buildFile(ExtractFilePath(AFile), ExtractFileName(AFile));
  FIni := TIniFile.Create(AFile);
  if TGenericUtils.sameType<Boolean, T> then
    Result := TValue.From(FIni.ReadBool(ASection, AParam,
      TGenericUtils.castTo<Boolean, T>(ADefaultValue))).AsType<T>

  else if TGenericUtils.sameType<Integer, T> then
    Result := TValue.From(FIni.ReadInteger(ASection, AParam,
      TGenericUtils.castTo<Integer, T>(ADefaultValue))).AsType<T>

  else if TGenericUtils.sameType<Double, T> then
    Result := TValue.From(FIni.ReadFloat(ASection, AParam,
      TGenericUtils.castTo<Double, T>(ADefaultValue))).AsType<T>

  else if TGenericUtils.sameType<TDateTime, T> then
    Result := TValue.From(FIni.ReadDateTime(ASection, AParam,
      TGenericUtils.castTo<TDateTime, T>(ADefaultValue))).AsType<T>

  else if TGenericUtils.sameType<TDate,T> then
    Result := TValue.From(FIni.ReadDate(ASection, AParam,
      TGenericUtils.castTo<TDate, T>(ADefaultValue))).AsType<T>

  else if TGenericUtils.sameType<TTime, T> then
    Result := TValue.From(FIni.ReadTime(ASection, AParam,
      TGenericUtils.castTo<TTime, T>(ADefaultValue))).AsType<T>

  else if TGenericUtils.sameType<String, T> then
    Result := TValue.From(FIni.ReadString(ASection, AParam,
      TGenericUtils.castTo<String, T>(ADefaultValue))).AsType<T>

  else if TGenericUtils.sameType<String, T> then
    Result := TValue.From(FIni.ReadBinaryStream(ASection, AParam,
      TGenericUtils.castTo<TStream, T>(ADefaultValue))).AsType<T>

  else if TGenericUtils.sameType<String, T> then
    Result := TValue.From(FIni.ReadInt64(ASection, AParam,
      TGenericUtils.castTo<Int64, T>(ADefaultValue))).AsType<T>
  else
    raise Exception.Create('Unsupported type for reading and writing Ini format.');
  FreeAndNil(FIni);
end;

class procedure TFileUtils.writeLog(ALog, AFile: String;
  AKeepTrying: Boolean);
var
  FPath: String;
  Writer: TStreamWriter;
begin
  FPath := AFile;
  if (not ContainsStr(AFile, '\')) then
    FPath := GetCurrentDir+'\'+AFile;
  TThreadUtils.onThread(
  procedure
  begin
    try
      critSectionLog.Enter;
      buildPath(ExtractFilePath(FPath));
      if FileExists(FPath) then
        Writer := TStreamWriter.Create(FPath, True, TEncoding.UTF8)
      else
        Writer := TStreamWriter.Create(FPath, False, TEncoding.UTF8);
      try
        Writer.WriteLine(ALog);
        Writer.Flush;
      finally
        Writer.Free;
        critSectionLog.Release;
      end;
    except
      sleep(1000);
      writeLog(ALog, AFile, AKeepTrying);
    end;
  end);
end;

class function TFileUtils.writeParam<T>(ASection, AParam: String;
  ADefaultValue: T; AFile: String): T;
var
  FIni: TIniFile;
begin
  FIni := TIniFile.Create(AFile);
  if TGenericUtils.sameType<Boolean, T> then
    Result := TValue.From(FIni.ReadBool(ASection, AParam,
      TGenericUtils.castTo<Boolean, T>(ADefaultValue))).AsType<T>

  else if TGenericUtils.sameType<Integer, T> then
    Result := TValue.From(FIni.ReadInteger(ASection, AParam,
      TGenericUtils.castTo<Integer, T>(ADefaultValue))).AsType<T>

  else if TGenericUtils.sameType<Double, T> then
    Result := TValue.From(FIni.ReadFloat(ASection, AParam,
      TGenericUtils.castTo<Double, T>(ADefaultValue))).AsType<T>

  else if TGenericUtils.sameType<TDateTime, T> then
    Result := TValue.From(FIni.ReadDateTime(ASection, AParam,
      TGenericUtils.castTo<TDateTime, T>(ADefaultValue))).AsType<T>

  else if TGenericUtils.sameType<TDate,T> then
    Result := TValue.From(FIni.ReadDate(ASection, AParam,
      TGenericUtils.castTo<TDate, T>(ADefaultValue))).AsType<T>

  else if TGenericUtils.sameType<TTime, T> then
    Result := TValue.From(FIni.ReadTime(ASection, AParam,
      TGenericUtils.castTo<TTime, T>(ADefaultValue))).AsType<T>

  else if TGenericUtils.sameType<String, T> then
    Result := TValue.From(FIni.ReadString(ASection, AParam,
      TGenericUtils.castTo<String, T>(ADefaultValue))).AsType<T>

  else if TGenericUtils.sameType<String, T> then
    Result := TValue.From(FIni.ReadBinaryStream(ASection, AParam,
      TGenericUtils.castTo<TStream, T>(ADefaultValue))).AsType<T>

  else if TGenericUtils.sameType<String, T> then
    Result := TValue.From(FIni.ReadInt64(ASection, AParam,
      TGenericUtils.castTo<Int64, T>(ADefaultValue))).AsType<T>
  else
    raise Exception.Create('Unsupported type for reading and writing Ini format.');
  FreeAndNil(FIni);
end;

initialization
  TFileUtils.critSectionLog := TCriticalSection.Create;

finalization
  TGenericUtils.freeAndNil(TFileUtils.critSectionLog);

end.
