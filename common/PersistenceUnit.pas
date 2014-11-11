unit PersistenceUnit;

interface

uses
  SQLiteTable3, SysUtils, Dialogs, DateUtils;

type
  TClubCard = record
    club_cardid: Integer;
    surname,
    name,
    patronymic: String;
    cost_multiplier: Double;
  end;
  TPersistence = class(TObject)
  private
    FDbPath: string;
  public
    Base: TSQLiteDatabase;
    Table: TSQLiteUniTable;
    Stmt: TSQLitePreparedStatement;
    constructor Create(DbPath: string);
    destructor Destroy; override;
    procedure StartTracking(TableId: Integer; CardId: Integer);
    procedure StopTracking(TableId: Integer; var BeginTime: TDateTime);
    // True - если включен, иначе False
    procedure GetTableStatus(TableId: Integer; var Status: Boolean;
      var BeginTime: TDateTime; var CardId: Integer; var CostMultiplier: Double);
    procedure GetTableInitData(TableId: Integer; var BaseCost: Double;
      var Pin: Integer; var Inverted: Boolean);
    function  GetClubCard(CardId: Integer): TClubCard;
    function  GetReport(BeginDate: TDateTime; EndDate: TDateTime = 0): TSQLiteUniTable;
    function  GetLog(Limit: Integer): TSQLiteUniTable;
    procedure ClearLog;
    procedure Log(msg: String);
  end;

implementation

constructor TPersistence.Create(DbPath: string);
begin
  inherited Create;
  Base := TSQLiteDatabase.Create(DbPath);
  Stmt := TSQLitePreparedStatement.Create(Base);
end;

destructor TPersistence.Destroy;
begin
  inherited;
  if Assigned(Stmt) then
    Stmt.Free;
  if Assigned(Table) then
    Table.Free;
  if Assigned(Base) then
    Base.Free;
end;

procedure TPersistence.StartTracking(TableId: Integer; CardId: Integer);
begin
  if CardId > -1 then begin
    Base.ExecSQL('INSERT INTO timetable ([club_cardid], [tableid]) VALUES(:c, :t)', [CardId, TableId]);
  end else
    Base.ExecSQL('INSERT INTO timetable ([tableid]) VALUES(:t)', [TableId]);
end;

procedure TPersistence.StopTracking(TableId: Integer; var BeginTime: TDateTime);
var
  id: Integer;
begin
  Stmt.ClearParams;
  Stmt.SQL := 'SELECT timetableid, begin_time FROM timetable WHERE [tableid]=:t '+
  'ORDER BY timetableid DESC LIMIT 1';
  Stmt.SetParamInt(':t', TableId);
  Stmt.PrepareStatement;
  if Assigned(Table) then
    FreeAndNil(Table);
  Table := Stmt.ExecQuery;
  id := Table.FieldByName['timetableid'].AsInteger;
  BeginTime := Table.FieldByName['begin_time'].AsDateTime;

  Base.ExecSQL('UPDATE timetable SET end_time=datetime("now", "localtime") WHERE timetableid=:t', [Id]);
end;

procedure TPersistence.GetTableStatus(TableId: Integer; var Status: Boolean;
  var BeginTime: TDateTime; var CardId: Integer; var CostMultiplier: Double);
begin
  Stmt.ClearParams;
  Stmt.SQL := 'SELECT COALESCE(club_card.cost_multiplier, 1) AS '+
    'cost_multiplier, begin_time, end_time, COALESCE(timetable.'+
    'club_cardid, -1) AS club_cardid '+
    'FROM timetable LEFT JOIN club_card USING(club_cardid) '+
    'WHERE [tableid]=:t '+
    'ORDER BY timetableid DESC LIMIT 1';
  Stmt.SetParamInt(':t', TableId);
  Stmt.PrepareStatement;
  if Assigned(Table) then
    FreeAndNil(Table);
  Table := Stmt.ExecQuery;
  if Table.EOF then begin
    Status := False;
    BeginTime := 0;
    CardId := -1;
    CostMultiplier := 1;
  end else begin
    Status := Table.FieldByName['end_time'].IsNull;
    BeginTime := Table.FieldByName['begin_time'].AsDateTime;
    CardId := Table.FieldByName['club_cardid'].AsInteger;
    CostMultiplier := Table.FieldByName['cost_multiplier'].AsDouble;
  end;
end;

procedure TPersistence.GetTableInitData(TableId: Integer; var BaseCost: Double;
  var Pin: Integer; var Inverted: Boolean);
begin
  Stmt.ClearParams;
  Stmt.SQL := 'SELECT * FROM [table] WHERE tableid=:t';
  Stmt.SetParamInt(':t', TableId);
  Stmt.PrepareStatement;
  if Assigned(Table) then
    FreeAndNil(Table);
  Table := Stmt.ExecQuery;
  if Table.EOF then begin
    BaseCost := 200;
  end else begin
    BaseCost := Table.FieldByName['base_cost'].AsDouble;
    Pin      := Table.FieldByName['pin'].AsInteger;
    Inverted := Table.FieldByName['inverted'].AsInteger = 1;
  end;
end;

function  TPersistence.GetClubCard(CardId: Integer): TClubCard;
var
  Table: TSQLiteUniTable;
  Stmt: TSQLitePreparedStatement;
begin
  Stmt := TSQLitePreparedStatement.Create(Base);
  Stmt.ClearParams;
  Stmt.SQL := 'SELECT * FROM club_card WHERE club_cardid=:t';
  Stmt.SetParamInt(':t', CardId);
  Stmt.PrepareStatement;
  Table := Stmt.ExecQuery;
  if Table.EOF then begin
    Result.club_cardid := -1;
  end else begin
    Result.club_cardid     := Table.FieldByName['club_cardid'].AsInteger;
    Result.surname         := Table.FieldByName['surname'].AsString;
    Result.name            := Table.FieldByName['name'].AsString;
    Result.patronymic      := Table.FieldByName['patronymic'].AsString;
    Result.cost_multiplier := Table.FieldByName['cost_multiplier'].AsDouble;
  end;
  Table.Free;
  Stmt.Free;
end;

function TPersistence.GetReport(BeginDate: TDateTime; EndDate: TDateTime = 0): TSQLiteUniTable;
var
  Sql: string;
begin
  Sql :=
    'SELECT base_cost, COALESCE(club_card.cost_multiplier, 1) AS cost_multiplier, '+
    'club_card.surname, club_card.name, club_card.patronymic, timetable.* ' +
    'FROM timetable JOIN [table] USING(tableid) LEFT JOIN club_card USING(club_cardid) '+
    'WHERE [begin_time] > :bt AND [minutes] > 0 ';
  if EndDate > 0 then
    Sql := Sql + 'AND [begin_time] < :et ';
  Sql := Sql + 'ORDER BY begin_time';

  Stmt.ClearParams;
  Stmt.SQL := Sql;
  Stmt.SetParamText(':bt', FormatDateTime('yyyy-mm-dd hh:mm:ss', BeginDate));
  if EndDate > 0 then
    Stmt.SetParamText(':et', FormatDateTime('yyyy-mm-dd hh:mm:ss', EndDate));
  Stmt.PrepareStatement;
  Result := Stmt.ExecQuery;
end;

function TPersistence.GetLog(Limit: Integer): TSQLiteUniTable;
begin
  Stmt.ClearParams;
  Stmt.SQL := 'SELECT * FROM [log] ORDER BY logid DESC';
  if Limit > 0 then begin
    Stmt.SQL := Stmt.SQL + ' LIMIT :i';
    Stmt.SetParamInt(':i', Limit);
  end;
  Stmt.PrepareStatement;
  Result := Stmt.ExecQuery;
end;

procedure TPersistence.ClearLog;
begin
  Base.ExecSQL('DELETE FROM [log]');
end;

procedure TPersistence.Log(msg: String);
begin
  Base.ExecSQL('INSERT INTO [log] ([msg]) VALUES (:m)', [msg]);
end;

end.
