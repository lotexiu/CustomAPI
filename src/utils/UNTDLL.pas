unit UNTDLL;

interface


uses
  Winapi.Windows;

type
  SystemHandle=packed record
    uIdProcess:ULONG;
    ObjectType:UCHAR;
    Flags     :UCHAR;
    Handle    :WORD;
    pObject   :Pointer;
    GrantedAccess:ACCESS_MASK;
  end;
  PSYSTEM_HANDLE = ^SystemHandle;
  SYSTEM_HANDLE_ARRAY = Array[0..0] of SystemHandle;
  PSYSTEM_HANDLE_ARRAY = ^SYSTEM_HANDLE_ARRAY;
  SYSTEM_HANDLE_INFORMATION = packed record
    uCount:ULONG;
    Handles:SYSTEM_HANDLE_ARRAY;
  end;
  PSystemHandleInformation=^SYSTEM_HANDLE_INFORMATION;

implementation



end.
