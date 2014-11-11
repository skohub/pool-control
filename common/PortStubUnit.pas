unit PortStubUnit;

interface

uses PortUnit, PersistenceUnit, SysUtils;

type
  TComPortStub = class(TComPortBase)
  public
    constructor Create(PortName: String; Persistence: TPersistence);
    procedure PortInit; override;
    procedure ReadComm; override;
    procedure WriteComm(S: string); override;
    procedure KillComm; override;
    procedure CalmWatchdog; override;
  end;

implementation

{ TComPort }

procedure TComPortStub.CalmWatchdog;
begin

end;

constructor TComPortStub.Create(PortName: String; Persistence: TPersistence);
begin

end;

procedure TComPortStub.KillComm;
begin

end;

procedure TComPortStub.PortInit;
begin

end;

procedure TComPortStub.ReadComm;
begin

end;

procedure TComPortStub.WriteComm(S: string);
begin
//  raise Exception.Create('123');
end;

end.
