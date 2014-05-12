unit about;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, lclintf;

type

  { TForm2 }

  TForm2 = class(TForm)
				Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
		Panel1: TPanel;
    StaticText1: TStaticText;
		procedure Image1Click(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }


procedure TForm2.Image1Click(Sender: TObject);
begin
  openDocument('https://github.com/ComradePhilos/CoYOTe');
end;

end.
