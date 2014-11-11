program pool_control;

uses
  Forms,
  main in 'main.pas' {FMain},
  PortUnit in '..\common\PortUnit.pas',
  PersistenceUnit in '..\common\PersistenceUnit.pas',
  TableClassUnit in '..\common\TableClassUnit.pas',
  report in 'report.pas' {FReport},
  log in 'log.pas' {FLog},
  PortStubUnit in '..\common\PortStubUnit.pas',
  TableFrameUnit in 'TableFrameUnit.pas' {Frame0: TFrame};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFReport, FReport);
  Application.CreateForm(TFLog, FLog);
  Application.Run;
end.
