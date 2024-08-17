program CustomAPI;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  TypInfo,
  Classes,
  Generics.Collections,
  NetEncoding,
  Rtti,
  Rest.Json,
  JSON,
  DBXJSON,
  DBXJSONReflect,
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
  UNTDLL in 'src\utils\UNTDLL.pas';

begin
  sleep(100000);
end.
