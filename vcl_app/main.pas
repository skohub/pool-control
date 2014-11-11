unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, PortUnit, Generics.Collections, Vcl.ImgList, PngImageList,
  Vcl.ComCtrls, Vcl.XPMan, Vcl.Buttons, PngBitBtn, Vcl.Imaging.jpeg,
  TableClassUnit, Vcl.Menus, Vcl.ActnList, IniFiles, Vcl.AppEvnts, PersistenceUnit,
  PngSpeedButton, TableFrameUnit;

type
  TFMain = class(TForm)
    Timer: TTimer;
    StatusBar: TStatusBar;
    Img: TPngImageList;
    TimeTimer: TTimer;
    WatchdogTimer: TTimer;
    MainMenu: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    ActionList: TActionList;
    AReport: TAction;
    AClose: TAction;
    N3: TMenuItem;
    N4: TMenuItem;
    AReboot: TAction;
    APowerOff: TAction;
    N5: TMenuItem;
    N6: TMenuItem;
    ApplicationEvents: TApplicationEvents;
    ALog: TAction;
    XPManifest: TXPManifest;
    N7: TMenuItem;
    PClubCard: TPanel;
    Image7: TImage;
    LClubCard: TLabel;
    Shape1: TShape;
    BCancelClubCard: TPngSpeedButton;
    N8: TMenuItem;
    GridPanel1: TGridPanel;
    Frame01: TFrame0;
    Frame02: TFrame0;
    Frame04: TFrame0;
    Frame05: TFrame0;
    Frame03: TFrame0;
    Frame06: TFrame0;
    sko1: TMenuItem;
    SbRight: TSpeedButton;
    SbLeft: TSpeedButton;
    GridPanel2: TGridPanel;
    Frame07: TFrame0;
    Frame08: TFrame0;
    Frame09: TFrame0;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure B1OnClick(Sender: TObject);
    procedure B1OffClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure TimeTimerTimer(Sender: TObject);
    procedure WatchdogTimerTimer(Sender: TObject);
    procedure AReportExecute(Sender: TObject);
    procedure ACloseExecute(Sender: TObject);
    procedure ARebootExecute(Sender: TObject);
    procedure APowerOffExecute(Sender: TObject);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure ALogExecute(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure BCancelClubCardClick(Sender: TObject);
    procedure GridPanel1Resize(Sender: TObject);
    procedure SbRightClick(Sender: TObject);
    procedure SbLeftClick(Sender: TObject);
  private
    FSequenceTime: Cardinal;
    FSequenceStep: Integer;
    FSequence: String;
    FScaling: Boolean;
    FCanClose: Boolean;
    FPortConnected: Boolean;
    FTables: TDictionary<Integer, TTable>;
    FClubCard: TClubCard;
    FFrames: array of TFrame0;
    FPage: Integer;
    procedure Init;
    procedure SetPortConnected(const Value: Boolean);
    procedure InputBoxSetPasswordChar(var Msg: TMessage); message WM_USER+200;
    procedure ContinueSequence(var Key: Char);
    function  WindowsExit(RebootParam: Longword): Boolean;
    procedure SetClubCard(const Value: TClubCard);
    procedure SetPage(Page: Integer);
    procedure TurnPageRight;
    procedure TurnPageLeft;
  public
    property PortConnected: Boolean read FPortConnected write SetPortConnected;
    property ClubCard: TClubCard read FClubCard write SetClubCard;
  end;

var
  FMain: TFMain;
  Persistence: TPersistence;
  ComPort: TComPortBase;

implementation

{$R *.DFM}

uses report, log, PortStubUnit;

procedure TFMain.B1OnClick(Sender: TObject);
begin
  try
    if ClubCard.club_cardid > -1 then begin
      FTables[TButton(Sender).Tag].ClubCardId := ClubCard.club_cardid;
      FTables[TButton(Sender).Tag].CostMultiplier := ClubCard.cost_multiplier;
      BCancelClubCard.Click;
    end else begin
      FTables[TButton(Sender).Tag].ClubCardId := -1;
      FTables[TButton(Sender).Tag].CostMultiplier := 1;
    end;
    FTables[TButton(Sender).Tag].PowerOn;
  except
    on TableException do
      raise
    else
      PortConnected := False;
      raise;
  end;
end;

procedure TFMain.BCancelClubCardClick(Sender: TObject);
var
  C: TClubCard;
begin
  C.club_cardid := -1;
  ClubCard := C;
end;

procedure TFMain.ContinueSequence(var Key: Char);
const
  Delta: Integer = 350;
var
  CardId: Integer;
begin
  if GetTickCount - FSequenceTime > Delta then begin
    FSequenceStep := 0;
    FSequence := '';
  end;
  Inc(FSequenceStep);
  FSequenceTime := GetTickCount;
  FSequence := FSequence + Key;
  if FSequenceStep = 6 then begin
    if TryStrToInt(FSequence, CardId) then
      ClubCard := Persistence.GetClubCard(CardId);
    FSequenceStep := 0;
    FSequence := '';
  end;
end;

procedure TFMain.ACloseExecute(Sender: TObject);
begin
  Close;
end;

function TFMain.WindowsExit(RebootParam: Longword): Boolean;
var
   TTokenHd: THandle;
   TTokenPvg: TTokenPrivileges;
   cbtpPrevious: DWORD;
   rTTokenPvg: TTokenPrivileges;
   pcbtpPreviousRequired: DWORD;
   tpResult: Boolean;
const
   SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
begin
   if Win32Platform = VER_PLATFORM_WIN32_NT then
   begin
     tpResult := OpenProcessToken(GetCurrentProcess(),
       TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,
       TTokenHd) ;
     if tpResult then
     begin
       tpResult := LookupPrivilegeValue(nil,
                                        SE_SHUTDOWN_NAME,
                                        TTokenPvg.Privileges[0].Luid) ;
       TTokenPvg.PrivilegeCount := 1;
       TTokenPvg.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
       cbtpPrevious := SizeOf(rTTokenPvg) ;
       pcbtpPreviousRequired := 0;
       if tpResult then
         Windows.AdjustTokenPrivileges(TTokenHd,
                                       False,
                                       TTokenPvg,
                                       cbtpPrevious,
                                       rTTokenPvg,
                                       pcbtpPreviousRequired) ;
     end;
   end;
   Result := ExitWindowsEx(RebootParam, 0) ;
end;

procedure TFMain.ALogExecute(Sender: TObject);
begin
  FLog.Show;
end;

procedure TFMain.APowerOffExecute(Sender: TObject);
begin
  WindowsExit(EWX_POWEROFF);
end;

procedure TFMain.ApplicationEventsException(Sender: TObject; E: Exception);
begin
  try
    WatchdogTimer.Enabled := False;
    Timer.Enabled := False;
    MessageBox(Handle, PWideChar(E.Message), 'Pool-control', mb_iconerror);
    Persistence.Log(E.Message);
  finally
    WatchdogTimer.Enabled := True;
    Timer.Enabled := True;
  end;
end;

procedure TFMain.ARebootExecute(Sender: TObject);
begin
  WindowsExit(EWX_REBOOT);
end;

procedure TFMain.AReportExecute(Sender: TObject);
begin
  FReport.Show;
end;

procedure TFMain.B1OffClick(Sender: TObject);
begin
  try
    FTables[TButton(Sender).Tag].PowerOff;
  except
    on TableException do
      raise
    else
      PortConnected := False;
      raise;
  end;
end;

procedure TFMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
//var
//  S: String;
begin
//  CanClose := FCanClose;
//  if not CanClose then begin
//    PostMessage(Handle, WM_USER+200, 0, 0);
//    if InputQuery('АРМ', 'Пароль', S) and (S = '32167') then begin
//      CanClose := True;
//    end
//  end;
  if PortConnected then
    ComPort.KillComm;
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  Init;
  PClubCard.BringToFront;
end;

procedure TFMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
  ContinueSequence(Key);
end;

procedure TFMain.GridPanel1Resize(Sender: TObject);
var
  FrameHeight,
  FrameWidth: Integer;
  i: Integer;
begin
  FrameHeight := TGridPanel(Sender).Height div 2 - 8;
  FrameWidth  := TGridPanel(Sender).Width div 3 - 8;
  if Width / Height > 1.4 then begin
    FrameHeight := FrameHeight - 10;
    FrameWidth  := FrameWidth - 10;
  end;
  for i := 0 to Length(FFrames) - 1 do begin
    FFrames[i].Height := FrameHeight;
    FFrames[i].Width  := FrameWidth;
  end;
end;

procedure TFMain.Init;
var
  Ini: TIniFile;
  PortName: string;
  i: Integer;

  procedure CreateTable(Frame: TFrame0; Index: Integer);
  begin
    FFrames[Index - 1] := Frame;
    Frame.B1On.Tag := Index;
    Frame.B1Off.Tag := Index;
    Frame.B1On.OnClick := B1OnClick;
    Frame.B1Off.OnClick := B1OffClick;
    Frame.Label1.Caption := IntToStr(Index);
    FTables.Add(Index, TTable.Create(Index, Frame.B1On, Frame.B1Off, Frame.LabelTime1, Frame.LabelCost1, ComPort, Persistence));
  end;
begin
  Ini := TIniFile.Create(ExtractFilePath(Application.ExeName) + '\conf.ini');
  try
    PortName := Ini.ReadString('Port', 'Name', 'COM');
    FTables := TDictionary<Integer, TTable>.Create;
    Persistence := TPersistence.Create(ExtractFilePath(ParamStr(0)) + 'data.sqlite');
    if Ini.ReadBool('Port', 'Stub', False) = True then
      ComPort := TComPortStub.Create(PortName, Persistence)
    else
      ComPort := TComPort.Create(PortName, Persistence);
    ComPort.DEBUG := Ini.ReadBool('Port', 'Debug', False);
    Ini.Free;
  except
    on E: Exception do begin
      MessageBox(Handle, PWideChar(E.Message), 'Бильярд', mb_iconerror);
      Application.Terminate;
      Exit;
    end;
  end;
  FPage := 0;
  FSequenceTime := 0;
  FSequenceStep := 0;
  FSequence := '';
  BCancelClubCard.Click;
  FScaling := False;
  FCanClose := False;

  SetLength(FFrames, 9);
  CreateTable(Frame01, 1);
  CreateTable(Frame02, 2);
  CreateTable(Frame03, 3);
  CreateTable(Frame04, 4);
  CreateTable(Frame05, 5);
  CreateTable(Frame06, 6);
  CreateTable(Frame07, 7);
  CreateTable(Frame08, 8);
  CreateTable(Frame09, 9);

  WatchdogTimer.Enabled := True;
  PortConnected := True;
end;

procedure TFMain.InputBoxSetPasswordChar(var Msg: TMessage);
var
  hInputForm, hEdit, hButton: HWND;
begin
  hInputForm := Screen.Forms[0].Handle;
  if (hInputForm <> 0) then
  begin
    hEdit := FindWindowEx(hInputForm, 0, 'TEdit', nil);
    {
      // Change button text:
      hButton := FindWindowEx(hInputForm, 0, 'TButton', nil);
      SendMessage(hButton, WM_SETTEXT, 0, Integer(PChar('Cancel')));
    }
    SendMessage(hEdit, EM_SETPASSWORDCHAR, Ord('*'), 0);
  end;
end;

procedure TFMain.SbLeftClick(Sender: TObject);
begin
  TurnPageLeft;
end;

procedure TFMain.SbRightClick(Sender: TObject);
begin
  TurnPageRight;
end;

procedure TFMain.SetClubCard(const Value: TClubCard);
begin
  FClubCard := Value;
  if Value.club_cardid > -1 then begin
    LClubCard.Caption := Format('Активирована клубная карта №%.6d (%d%%) %s %s.%s.',
      [Value.club_cardid, Round((1-Value.cost_multiplier)*100),
      Value.surname, Copy(Value.name, 1, 1), Copy(Value.patronymic, 1, 1)]);
    PClubCard.Show;
  end else begin
    PClubCard.Hide;
    FClubCard.cost_multiplier := 1;
  end;
end;

procedure TFMain.SetPage(Page: Integer);
var
  FrontPanel,
  BackPanel: TGridPanel;
  w, h, x: Integer;
begin
  case FPage of
    0: BackPanel := GridPanel1;
    1: BackPanel := GridPanel2;
  end;
  case Page of
    0: FrontPanel := GridPanel1;
    1: FrontPanel := GridPanel2;
  end;
  FrontPanel.BringToFront;
  SendMessage(BackPanel.Handle, WM_SETREDRAW, Integer(False), 0);
  w := FrontPanel.Width;
  h := FrontPanel.Height;
  FrontPanel.Align  := alNone;
  FrontPanel.Width  := w;
  FrontPanel.Height := h;
  if Page > FPage then begin
    for x := Self.ClientWidth div 25 downto 0 do begin
      FrontPanel.Left := x * 25;
      Application.ProcessMessages;
      Sleep(1);
    end;
  end else begin
    for x := -Self.ClientWidth div 25 to 0 do begin
      FrontPanel.Left := x  * 25;
      Application.ProcessMessages;
      Sleep(1);
    end;
  end;
  FrontPanel.Align := alClient;
  SendMessage(BackPanel.Handle, WM_SETREDRAW, Integer(True), 0);
  RedrawWindow(BackPanel.Handle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_ALLCHILDREN);
  FPage := Page;
end;

procedure TFMain.SetPortConnected(const Value: Boolean);
var
  Status: Boolean;
  Table: TTable;
begin
  FPortConnected := Value;
  StatusBar.Repaint;

  if not Value then begin // COM порт отключен
    for Table in FTables.Values do
      Table.Enabled := False;
  end else begin          // COM порт влючен
    try
      Sleep(3000);
      for Table in FTables.Values do
        Table.Enabled := True
    except
      PortConnected := False;
      raise;
    end;
  end;

  Timer.Enabled := not Value;
  case Value of
  False: StatusBar.Panels[0].Text := 'Подключение...';
  True : StatusBar.Panels[0].Text := 'Подключено';
  end;
end;

procedure TFMain.StatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
begin
  case Panel.Index of
  1: Img.Draw(StatusBar.Canvas, Rect.Left + 1, Rect.Top, Integer(PortConnected));
  end;
end;

procedure TFMain.TimerTimer(Sender: TObject);
begin
  if not PortConnected then begin
    ComPort.PortInit;
    PortConnected := True;
  end;
end;

procedure TFMain.TimeTimerTimer(Sender: TObject);
var
  Table: TTable;
begin
  for Table in FTables.Values do
    Table.UpdateTime;
end;

procedure TFMain.TurnPageLeft;
var
  Page: Integer;
begin
  Page := FPage;
  case Page of
    1: Page := Page - 1;
  end;
  if Page <> FPage then begin
    SetPage(Page);
  end;
end;

procedure TFMain.TurnPageRight;
var
  Page: Integer;
begin
  Page := FPage;
  case Page of
    0: Page := Page + 1;
  end;
  if Page <> FPage then begin
    SetPage(Page);
  end;
end;

procedure TFMain.WatchdogTimerTimer(Sender: TObject);
begin
  if PortConnected then begin
    try
      ComPort.CalmWatchdog;
    except
      PortConnected := False;
    end;
  end;
end;

end.
