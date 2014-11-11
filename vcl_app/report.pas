unit report;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ToolWin, Vcl.ActnList,
  VirtualTrees, Vcl.StdCtrls, SQLiteTable3, DateUtils, Vcl.Menus;

type
  TTimetable = record
    timetableid,
    tableid,
    minutes: Integer;
    begin_time,
    end_time: TDateTime;
    base_cost: Double;
    cost_multiplier: Double;
    cost: Double;
    discount: Double;
    club_cardid: Integer;
    card_owner: String;
  end;
  PTimetable = ^TTimetable;
  TFReport = class(TForm)
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    ActionList: TActionList;
    ARefresh: TAction;
    AClose: TAction;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    Vst: TVirtualStringTree;
    DEnd: TDateTimePicker;
    Label1: TLabel;
    Label2: TLabel;
    DStart: TDateTimePicker;
    StatusBar: TStatusBar;
    BInterval: TButton;
    IntervalMenu: TPopupMenu;
    N1Day: TMenuItem;
    N7Days: TMenuItem;
    NCurMonth: TMenuItem;
    NLastMonth: TMenuItem;
    AExport: TAction;
    ToolButton3: TToolButton;
    SaveDialog: TSaveDialog;
    procedure ARefreshExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure VstGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure DStartChange(Sender: TObject);
    procedure VstBeforeItemErase(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
      var ItemColor: TColor; var EraseAction: TItemEraseAction);
    procedure ACloseExecute(Sender: TObject);
    procedure N1DayClick(Sender: TObject);
    procedure N7DaysClick(Sender: TObject);
    procedure NCurMonthClick(Sender: TObject);
    procedure BIntervalClick(Sender: TObject);
    procedure VstFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure NLastMonthClick(Sender: TObject);
    procedure AExportExecute(Sender: TObject);
  private
    { Private declarations }
  public
    function CalcCost(Minutes: Integer; BaseCost,
      CostMultiplier: Double): Integer;
    function CalcBaseCost(Minutes: Integer; BaseCost: Double): Double;
  end;

var
  FReport: TFReport;

implementation

{$R *.dfm}

uses main, PersistenceUnit;

procedure TFReport.ACloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TFReport.AExportExecute(Sender: TObject);
var
  NewFile: textfile;
  Node: PVirtualNode;
  Data: PTimetable;
begin
  Node := Vst.GetFirst;
  if Assigned(Node) and SaveDialog.Execute then begin
    AssignFile(NewFile, SaveDialog.FileName);
    try
      Rewrite(NewFile);
      while Assigned(Node) do begin
        Data := Vst.GetNodeData(Node);
        Writeln(
          NewFile,
          Format(
            '%s;%f ч;%f р.', [
              FormatDateTime(
                'dd.mm.yyyy',
                Data.begin_time
              ),
              (Data.minutes / 60),
              Data.cost
            ]
          )
        );
        Node := Vst.GetNextSibling(Node);
      end;
    finally
      CloseFile(NewFile);
    end;
  end;
end;

procedure TFReport.ARefreshExecute(Sender: TObject);
var
  Table: TSQLiteUniTable;
  CurrentDate, NewDate: String;
  CurrentNode, NewNode: PVirtualNode;
  CurrentData, NewData: PTimetable;
  SummaryTime: Integer;
  SummaryCost, SummaryT1, SummaryT2, SummaryT3, SummaryT4: Double;
  SummaryDiscount: Double;
begin
  SummaryTime := 0; SummaryCost := 0;
  SummaryT1 := 0; SummaryT2 := 0; SummaryT3 := 0; SummaryT4 := 0;
  SummaryDiscount := 0;
  CurrentDate := '';
  Vst.Clear;
  if DEnd.Checked then
    Table := Persistence.GetReport(IncHour(Trunc(DStart.Date), 8), IncHour(Trunc(DEnd.Date), 32))
  else
    Table := Persistence.GetReport(IncHour(Trunc(DStart.Date), 8));
  try
    while not Table.EOF do begin
      NewDate := FormatDateTime('dd.mm.yyyy', IncHour(Table.FieldByName['begin_time'].AsDateTime, -8));
      if CurrentDate <> NewDate then begin
        CurrentDate := NewDate;
        CurrentNode := Vst.AddChild(nil);
        CurrentData := Vst.GetNodeData(CurrentNode);
        CurrentData.begin_time := IncHour(Table.FieldByName['begin_time'].AsDateTime, -8);
        CurrentData.minutes := 0;
        CurrentData.cost := 0;
        Vst.ValidateNode(CurrentNode, False);
      end;
      NewNode := Vst.AddChild(CurrentNode);
      NewData := Vst.GetNodeData(NewNode);
      Vst.ValidateNode(NewNode, False);
      NewData.timetableid     := Table.FieldByName['timetableid'].AsInteger;
      NewData.tableid         := Table.FieldByName['tableid'].AsInteger;
      NewData.minutes         := Table.FieldByName['minutes'].AsInteger;
      NewData.begin_time      := Table.FieldByName['begin_time'].AsDateTime;
      NewData.end_time        := Table.FieldByName['end_time'].AsDateTime;
      NewData.base_cost       := Table.FieldByName['base_cost'].AsDouble;
      NewData.cost_multiplier := Table.FieldByName['cost_multiplier'].AsDouble;
      if Table.FieldByName['club_cardid'].IsNull then
        NewData.club_cardid := -1
      else
        NewData.club_cardid := Table.FieldByName['club_cardid'].AsInteger;
      NewData.card_owner      := Format('%s %s.%s.', [
        Table.FieldByName['surname'].AsString,
        Copy(Table.FieldByName['name'].AsString, 1, 1),
        Copy(Table.FieldByName['patronymic'].AsString, 1, 1)]);
      NewData.cost            := CalcCost(NewData.minutes, NewData.base_cost, NewData.cost_multiplier);
      NewData.discount        := CalcBaseCost(NewData.minutes, NewData.base_cost) - NewData.cost;
      CurrentData.minutes     := CurrentData.minutes + NewData.minutes;
      CurrentData.cost        := CurrentData.cost + NewData.cost;
      CurrentData.discount    := CurrentData.discount + NewData.discount;
      SummaryTime             := SummaryTime + NewData.minutes;
      SummaryCost             := SummaryCost + NewData.cost;
      SummaryDiscount         := SummaryDiscount + NewData.discount;
      case NewData.tableid of
      1: SummaryT1 := SummaryT1 + NewData.cost;
      2: SummaryT2 := SummaryT2 + NewData.cost;
      4: SummaryT3 := SummaryT3 + NewData.cost;
      5: SummaryT4 := SummaryT4 + NewData.cost;
      end;
      Table.Next;
    end;
  finally
    Table.Free;
  end;
  StatusBar.Panels[0].Text := 'Всего часов: ' + Format('%.2f ч', [SummaryTime / 60]);
  StatusBar.Panels[1].Text := 'Общая сумма: ' + Format('%.0n р.', [SummaryCost]);
  StatusBar.Panels[2].Text := 'Общая скидка: ' + Format('%.0n р.', [SummaryDiscount]);
  StatusBar.Panels[3].Text := 'Стол1: ' + Format('%.0n р.', [SummaryT1]);
  StatusBar.Panels[4].Text := 'Стол2: ' + Format('%.0n р.', [SummaryT2]);
  StatusBar.Panels[5].Text := 'Стол3: ' + Format('%.0n р.', [SummaryT3]);
  StatusBar.Panels[6].Text := 'Стол4: ' + Format('%.0n р..', [SummaryT4]);
end;

procedure TFReport.BIntervalClick(Sender: TObject);
var
  Pt: TPoint;
begin
  Pt.X := BInterval.Left;
  Pt.Y := BInterval.Top + BInterval.Height;
  Pt := ToolBar1.ClientToScreen(Pt);
  BInterval.DropDownMenu.Popup(Pt.X, Pt.Y);
end;

procedure TFReport.DStartChange(Sender: TObject);
begin
  ARefreshExecute(Sender);
end;

procedure TFReport.FormCreate(Sender: TObject);
begin
  Vst.NodeDataSize := SizeOf(TTimetable);
  NCurMonthClick(Sender);
end;

procedure TFReport.FormShow(Sender: TObject);
begin
  ARefreshExecute(Sender);
end;

function TFReport.CalcBaseCost(Minutes: Integer; BaseCost: Double): Double;
const
  RoundTo: Integer = 10;
begin
  Result := Round(((BaseCost / 60 * Minutes) / RoundTo + 0.5)) * RoundTo;
end;

function TFReport.CalcCost(Minutes: Integer; BaseCost,
  CostMultiplier: Double): Integer;
const
  RoundTo: Integer = 10;
begin
  Result := Round(((BaseCost * CostMultiplier / 60 * Minutes) / RoundTo + 0.5)) * RoundTo;
end;

procedure TFReport.N7DaysClick(Sender: TObject);
begin
  DStart.Date := IncDay(Date, -7);
  DEnd.Date := Date;
  ARefreshExecute(Sender);
end;

procedure TFReport.N1DayClick(Sender: TObject);
begin
  DStart.Date := IncDay(Date, -1);
  DEnd.Date := Date;
  ARefreshExecute(Sender);
end;

procedure TFReport.NCurMonthClick(Sender: TObject);
begin
  DStart.Date := StartOfTheMonth(Date);
  DEnd.Date := EndOfTheMonth(Date);
  ARefreshExecute(Sender);
end;

procedure TFReport.NLastMonthClick(Sender: TObject);
begin
  DStart.Date := StartOfTheMonth(IncMonth(Date, -1));
  DEnd.Date := EndOfTheMonth(IncMonth(Date, -1));
  ARefreshExecute(Sender);
end;

procedure TFReport.VstBeforeItemErase(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
  var ItemColor: TColor; var EraseAction: TItemEraseAction);
begin
  if Sender.GetNodeLevel(Node) = 0 then begin
    ItemColor := $E6FFE6;
    EraseAction := eaColor;
  end;
end;

procedure TFReport.VstFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PTimetable;
begin
  Data := Sender.GetNodeData(Node);
  Data.card_owner := '';
end;

procedure TFReport.VstGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  Data: PTimetable;
begin
  Data := Sender.GetNodeData(Node);
  if Vst.GetNodeLevel(Node) = 0 then begin
     case Column of
     0: CellText := FormatDateTime('dd.mm.yyyy', Data.begin_time);
     1: CellText := '';
     2: CellText := Format('%.2f ч', [Data.minutes / 60]);
     3: CellText := Format('%.0n р.', [Data.cost]);
     4: CellText := Format('%.0n р.', [Data.discount]);
     5: CellText := '';
     end;
  end else begin
     case Column of
     0: CellText := FormatDateTime('hh:mm:ss', Data.begin_time);
     1: CellText := IntToStr(Data.tableid);
     2: CellText := Format('%d мин', [Data.minutes]);
     3: CellText := Format('%.0n р.', [Data.cost]);
     4: CellText := Format('%.0n р.', [Data.discount]);
     5: if Data.club_cardid > -1 then
          CellText := Format('%s (%d%%)', [Data.card_owner, Round((1-Data.cost_multiplier)*100)])
        else
          CellText := '';
     end;
  end;
end;

end.
