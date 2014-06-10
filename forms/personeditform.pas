unit PersonEditForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, LCLIntF, Process;

type

  { TForm5 }

  TForm5 = class(TForm)
    BitBtn1: TBitBtn;
    Image1: TImage;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    LabeledEdit4: TLabeledEdit;
    LabeledEdit5: TLabeledEdit;
    LabeledEdit6: TLabeledEdit;
    LabeledEdit7: TLabeledEdit;
    Panel1: TPanel;
    StaticText1: TStaticText;
		procedure OpenEMailClient(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form5: TForm5;

implementation

{$R *.lfm}

{ TForm5 }

procedure TForm5.OpenEMailClient(Sender: TObject);
var
  mailadress: String;
  AProcess: TProcess;
begin
  mailadress := LabeledEdit5.Text;

  AProcess:=TProcess.Create(nil);
  try
    AProcess.CommandLine:='thunderbird "'+mailadress+'"';  // Shell command
    AProcess.Execute;
  finally
    AProcess.Free;
  end;
  //OpenDocument('philip.maerksch@gmx.de');
end;


end.

