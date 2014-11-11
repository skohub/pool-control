unit log;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ActnList, Vcl.ComCtrls, Vcl.ToolWin,
  VirtualTrees, PersistenceUnit;

type
  TLogRecord = record
    created_at: TDateTime;
    msg: String;
  end;
  PLogRecord = ^TLogRecord;
  TFLog = class(TForm)
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    ActionList: TActionList;
    ARefresh: TAction;
    ARefreshAll: TAction;
    AClearLog: TAction;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    Vst: TVirtualStringTree;
    procedure FormCreate(Sender: TObject);
    procedure VstFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VstGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure ARefreshExecute(Sender: TObject);
    procedure ARefreshAllExecute(Sender: TObject);
    procedure AClearLogExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure Refresh(Limit: Integer = 1000);
  public
    { Public declarations }
  end;

var
  FLog: TFLog;

implementation

{$R *.dfm}

uses main, SQLiteTable3;

procedure TFLog.AClearLogExecute(Sender: TObject);
begin
  if MessageBox(handle, 'Очистить журнал событий?', 'АРМ', mb_iconquestion or mb_yesno) = idYes then begin
    Persistence.ClearLog;
    Vst.Clear;
  end;
end;

procedure TFLog.ARefreshAllExecute(Sender: TObject);
begin
  Refresh(0);
end;

procedure TFLog.ARefreshExecute(Sender: TObject);
begin
  Refresh;
end;

procedure TFLog.FormCreate(Sender: TObject);
begin
  Vst.NodeDataSize := SizeOf(TLogRecord);
end;

procedure TFLog.FormShow(Sender: TObject);
begin
  Refresh;
end;

procedure TFLog.Refresh(Limit: Integer);
var
  Table: TSQLiteUniTable;
  Node: PVirtualNode;
  Data: PLogRecord;
begin
  Vst.Clear;
  Table := Persistence.GetLog(Limit);
  try
    while not Table.EOF do begin
      Node := Vst.AddChild(Nil);
      Data := Vst.GetNodeData(Node);
      Vst.ValidateNode(Node, False);
      Data.created_at := Table.FieldByName['created_at'].AsDateTime;
      Data.msg := Table.FieldByName['msg'].AsString;
      Table.Next;
    end;
  finally
    Table.Free;
  end;
end;

procedure TFLog.VstFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PLogRecord;
begin
  Data := Sender.GetNodeData(Node);
  Data.msg := '';
end;

procedure TFLog.VstGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  Data: PLogRecord;
begin
  Data := Sender.GetNodeData(Node);
  case Column of
  0: CellText := FormatDateTime('dd.mm.yyyy hh:mm', Data.created_at);
  1: CellText := Data.msg;
  end;
end;

end.
