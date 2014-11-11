unit TableClassUnit;

interface

uses
  Classes, StdCtrls, SysUtils, DateUtils, Windows, PortUnit, PersistenceUnit;

type
  TableException = class(Exception);
  TTable = class(TObject)
    TableId  : Integer;
    BeginTime: TDateTime;
    Pin      : Integer;
    Inverted : Boolean;
    BaseCost : Double;
    CostMultiplier: Double;
    ButtonOn : TObject;
    ButtonOff: TObject;
    LabelTime: TLabel;
    LabelCost: TLabel;
  private
    FComPort : TComPortBase;
    FPersistence: TPersistence;
    FStatus  : Boolean;
    FEnabled : Boolean; // True - включен
    procedure SetStatus(const Value: Boolean);
    procedure SetEnabled(const Value: Boolean);
    procedure NoticeLabel;
  public
    ClubCardId: Integer;
    constructor Create(TableId: Integer; ButtonOn, ButtonOff: TObject;
        LabelTime, LabelCost: TLabel; ComPort: TComPortBase; Persistence: TPersistence);
    property Status: Boolean read FStatus write SetStatus;
    property Enabled: Boolean read FEnabled write SetEnabled;
    procedure PowerOn;
    procedure PowerOff;
    procedure UpdateTime;
  end;

implementation

{ TTable }

uses Graphics, report;

constructor TTable.Create(TableId: Integer; ButtonOn, ButtonOff: TObject;
    LabelTime, LabelCost: TLabel; ComPort: TComPortBase; Persistence: TPersistence);
var
  BaseCost: Double;
  Inverted: Boolean;
  Pin: Integer;
begin
  FComPort       := ComPort;
  FPersistence   := Persistence;
  Self.TableId   := TableId;
  Self.ButtonOn  := ButtonOn;
  Self.ButtonOff := ButtonOff;
  Self.LabelTime := LabelTime;
  Self.BeginTime := Date + Time;
  Self.LabelCost := LabelCost;
  FPersistence.GetTableInitData(TableId, BaseCost, Pin, Inverted);
  Self.BaseCost  := BaseCost;
  Self.Pin       := Pin;
  Self.Inverted  := Inverted;
  Self.ClubCardId := -1;
  Self.CostMultiplier := 0;
end;

procedure TTable.PowerOff;
var
  _bt: TDateTime;
begin
  if Status = True then begin
    FComPort.WriteComm(Format('D(%d,%s)', [Pin, IntToStr(Integer(Inverted))]));
    FPersistence.StopTracking(TableId, _bt);
    BeginTime := _bt;
    Status := False;
  end else
    raise TableException.Create('Стол уже выключен');
end;

procedure TTable.PowerOn;
begin
  if Status = False then begin
    FComPort.WriteComm(Format('D(%d,%s)', [Pin, IntToStr(Integer(not Inverted))]));
    FPersistence.StartTracking(TableId, ClubCardId);
    BeginTime := Date + Time;
    Status := True;
  end else
    raise TableException.Create('Стол уже включен');
end;

procedure TTable.SetEnabled(const Value: Boolean);
var
  st: Boolean;
  bt: TDateTime;
  ci: Integer;
  cm: Double;
begin
  FEnabled := Value;
  if not Value then begin
    TButton(ButtonOn).Enabled := False;
    TButton(ButtonOff).Enabled := False;
  end else begin
    FPersistence.GetTableStatus(TableId, st, bt, ci, cm);
    Status         := st;
    BeginTime      := bt;
    ClubCardId     := ci;
    CostMultiplier := cm;
    FComPort.WriteComm(Format('D(%d,%s)', [Pin, IntToStr(Integer(Status xor Inverted))]));
  end;
end;

procedure TTable.SetStatus(const Value: Boolean);
begin
  FStatus := Value;
  TButton(ButtonOn).Enabled := not Status;
  TButton(ButtonOff).Enabled := Status;
  NoticeLabel;
end;

procedure RemoveNotice(p: Pointer); stdcall;
begin
  Sleep(5000);
  if Assigned(p) then
    TLabel(p).Font.Color := clBlack;
end;

procedure TTable.NoticeLabel;
var
  tID: DWORD;
begin
  LabelTime.Font.Color := clRed;
  LabelCost.Font.Color := clRed;
  CreateThread(nil, 0, @RemoveNotice, LabelTime, 0, tID);
  CreateThread(nil, 0, @RemoveNotice, LabelCost, 0, tID);
end;

procedure TTable.UpdateTime;
var
  S: Integer;
begin
  if Status then begin
    S := SecondsBetween(Date + Time, BeginTime);
    LabelTime.Caption := Format('%.2d:%.2d:%.2d', [Trunc(S/60/60),
      (S div 60) mod 60, S mod 60]);
    LabelCost.Caption := Format('%d р', [FReport.CalcCost(S div 60, BaseCost, CostMultiplier)]);
  end;
//    LabelTime.Caption := '00:00:00';
end;

end.
