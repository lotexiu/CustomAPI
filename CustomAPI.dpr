program CustomAPI;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  Classes,
  UGenericUtils in 'src\utils\UGenericUtils.pas',
  UWindowsUtils in 'src\utils\UWindowsUtils.pas',
  UApp in 'src\utils\app\UApp.pas',
  UAppAPIRequest in 'src\utils\app\api\UAppAPIRequest.pas',
  UAppAPI in 'src\utils\app\api\UAppAPI.pas',
  UFileUtils in 'src\utils\UFileUtils.pas',
  UArrayUtils in 'src\utils\UArrayUtils.pas',
  UArrayHelper in 'src\utils\models\UArrayHelper.pas',
  UGenericException in 'src\utils\models\UGenericException.pas',
  UThreadUtils in 'src\utils\UThreadUtils.pas',
  UJSONUtils in 'src\utils\UJSONUtils.pas',
  UJSONException in 'src\utils\models\UJSONException.pas',
  UStringUtils in 'src\utils\UStringUtils.pas',
  UDebugUtils in 'src\utils\UDebugUtils.pas',
  UGenericDictionary in 'src\utils\models\UGenericDictionary.pas',
  UThreadData in 'src\utils\models\UThreadData.pas',
  UNTDLL in 'src\utils\UNTDLL.pas',
  UEnum in 'src\utils\models\UEnum.pas',
  UEnumUtils in 'src\utils\UEnumUtils.pas',
  UEnumException in 'src\utils\models\UEnumException.pas',
  UAttributesUtils in 'src\utils\UAttributesUtils.pas',
  UEnd in 'src\utils\models\UEnd.pas';

procedure onExit;
begin
  ReportMemoryLeaksOnShutdown := True;
  IsConsole := False;
end;

var
  FApp: TApp;

begin
  AddExitProc(@onExit);

//  TThreadUtils.onThread('ThreadTest', 250, 0,
//  procedure
//  var
//    FThreadData: TThreadData;
//  begin
//    TWindowsUtils.cleanScreen;
//    FThreadData := TThreadUtils.getThreadData('ThreadTest');
//    Writeln(FThreadData.toString);
//  end);

  FApp := TApp.Create;
  FApp.API('test').&End.API('');
//    .GET<String>('path-1',
//    function(AReq: THorseRequest; ARes: THorseResponse): String
//    begin
//    end);

  sleep(120*1000);
end.
