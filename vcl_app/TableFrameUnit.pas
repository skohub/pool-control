unit TableFrameUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  PngBitBtn, Vcl.ExtCtrls, Vcl.Imaging.jpeg;

type
  TFrame0 = class(TFrame)
    Panel1: TPanel;
    Image1: TImage;
    LabelTime1: TLabel;
    LabelCost1: TLabel;
    Shape2: TShape;
    Label1: TLabel;
    B1On: TPngBitBtn;
    B1Off: TPngBitBtn;
    procedure FrameResize(Sender: TObject);
  private
    const
      FHeight = 330;
    var
      FSizeFactor: Double;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TFrame0.FrameResize(Sender: TObject);
begin
  FSizeFactor := Self.Height / FHeight;
  Shape2.Height := Round(65 * FSizeFactor);
  Shape2.Width := Round(65 * FSizeFactor);
  Label1.Height := Round(65 * FSizeFactor);
  Label1.Width := Round(65 * FSizeFactor);
  LabelTime1.Height := Round(60 * FSizeFactor);
  LabelTime1.Font.Size := Round(36 * FSizeFactor);
  Label1.Font.Size := Round(38 * FSizeFactor);
  LabelTime1.Margins.SetBounds(Shape2.Width + 10, 3, 10, 3);
  LabelCost1.Height := Round(115 * FSizeFactor);
  LabelCost1.Font.Size := Round(60 * FSizeFactor);
  Image1.Height := Round(91 * FSizeFactor);
  B1On.Top := Self.Height - 60;
  B1Off.Top := Self.Height - 60;
  B1On.Left := (Self.Width div 2) - 110;
  B1Off.Left := (Self.Width div 2) + 7;
end;

end.
