unit PortUnit;

interface

uses windows, sysutils, PersistenceUnit;

type
  CommException = class(Exception)
  end;

  TComPortBase = class(TObject)
    DEBUG : Boolean;
    constructor Create(PortName: String; Persistence: TPersistence);
    procedure PortInit; virtual; abstract;
    procedure ReadComm; virtual; abstract;
    procedure WriteComm(S: string); virtual; abstract;
    procedure KillComm; virtual; abstract;
    procedure CalmWatchdog; virtual; abstract;
  end;

  TComPort = class(TComPortBase)
  private
    FPersistence: TPersistence;
    FPortName: string;
    CommHandle : integer;
    DCB : TDCB;
    Ovr : TOverlapped;
    Stat : TComStat;
    CommThread : THandle;
    hEvent : THandle;
    Flag,StopResive : boolean;
    KolByte,Kols,Mask,TransMask,Errs : DWord;
  public
    constructor Create(PortName: String; Persistence: TPersistence);
    procedure PortInit; override;
    procedure ReadComm; override;
    procedure WriteComm(S: string); override;
    procedure KillComm; override;
    procedure CalmWatchdog; override;
  end;

implementation

constructor TComPort.Create(PortName: String; Persistence: TPersistence);
begin
  inherited Create(PortName, Persistence);
  FPersistence := Persistence;
  FPortName := PortName;
  PortInit;
end;

procedure TComPort.KillComm;
begin
  //TerminateThread(CommThread,0);
  FPersistence.Log('Closing port');
  CloseHandle(CommHandle);
end;

procedure TComPort.PortInit;
var
  ThreadID:dword;
  fDtrControl: Integer;
  ErrorMsg: string;
begin
  //создание и иницализация порта
  KolByte:=0;
  //создание порта и получение его хэндла
  CommHandle := CreateFile(PWideChar(FPortName), GENERIC_READ or GENERIC_WRITE,
    0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if CommHandle=-1 then begin
    ErrorMsg := SysErrorMessage(GetLastError);
    FPersistence.Log(Format('Create file (%s) failed: %s', [FPortName, ErrorMsg]));
    raise Exception.Create(Format('Create file (%s) failed: %s', [FPortName, ErrorMsg]));
  end;
  //ставим маску - "по пришествии определенного символа"
  SetCommMask(CommHandle,EV_RXFLAG);

  //построение DCB
  if not GetCommState(CommHandle,DCB) then begin
    CloseHandle(CommHandle);
    FPersistence.Log('GetCommState failed');
    raise Exception.Create('GetCommState failed');
  end;
  DCB.BaudRate:=CBR_9600;
  DCB.Parity:=NOPARITY;
  DCB.ByteSize:=8;
  DCB.StopBits:=OneStopBit;
  DCB.EvtChar:=chr(13);//задание символа для флага
//    fDtrControl := 0; //DTR_CONTROL_ENABLE
//    DCB.Flags := (DCB.Flags and (not $0030)) or ((fDtrControl) shl 4);
  //устанавливаем DCB
  SetCommState(CommHandle,DCB);
  //создаем паралельный поток
  //там будет вертеться процедура приема строки
  //с порта - ReadComm
  //   CommThread := CreateThread(nil,0,@ReadComm,nil,0,ThreadID);
  FPersistence.Log('Connected to ' + FPortName);
end;

procedure TComPort.WriteComm(S: string);
var
  Transmit: array [0..255] of byte;
  i: Integer;
  ErrorMsg: String;
begin
  KolByte:=Length(S);
  for i := 1 to Length(S) do begin
    Transmit[i-1]:=Ord(S[i]);
  end;
  if not WriteFile(CommHandle,Transmit,KolByte,KolByte,nil) then begin
    ErrorMsg := SysErrorMessage(GetLastError);
    FPersistence.Log(Format('Can`t write %s, bytes written: %d. Error: %s',
      [S, KolByte, ErrorMsg]));
    KillComm;
    raise CommException.Create(ErrorMsg);
  end;
  if DEBUG then begin
    FPersistence.Log(Format('Written %d bytes: %s', [KolByte, S]));
  end;
end;

procedure TComPort.ReadComm;
//var
//  Resive:array [0..255] of byte;
//  s: string;
//  i: integer;
begin
//
//  TransMask:=0;
//  WaitCommEvent(CommHandle,TransMask,@Ovr); //ждем
//  if (TransMask and EV_RXFLAG)=EV_RXFLAG then //проверяем нужное событие
//  begin
//    ClearCommError(CommHandle,Errs,@Stat);//сбрасываем флаг
//    Kols := Stat.cbInQue;
//    ReadFile(CommHandle,Resive,Kols,Kols,@Ovr);//читаем
//    for i := 0 to Kols - 1 do
//      s := s + Chr(Resive[i]);
//  end;//mask
end;

procedure TComPort.CalmWatchdog;
begin
  WriteComm('W');
end;

{ TComPortBase }

constructor TComPortBase.Create(PortName: String; Persistence: TPersistence);
begin
  inherited Create;
end;

end.
