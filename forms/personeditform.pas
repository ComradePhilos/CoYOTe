unit PersonEditForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, LCLIntF, ComCtrls, Process;

type

  { TForm5 }

  TForm5 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    ComboBox1: TComboBox;
    Image1: TImage;
    ImageList1: TImageList;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    LabeledEdit4: TLabeledEdit;
    LabeledEdit5: TLabeledEdit;
    LabeledEdit6: TLabeledEdit;
    LabeledEdit7: TLabeledEdit;
    Panel1: TPanel;
    StaticText1: TStaticText;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LabeledEdit5Change(Sender: TObject);
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
  mailadress: string;
  AProcess: TProcess;
begin
  mailadress := LabeledEdit5.Text;

  if (mailadress <> '') then
  begin
    OpenURL('mailto:' + mailadress);
  end;
end;


procedure TForm5.BitBtn3Click(Sender: TObject);
begin
  self.Visible := False;
end;

procedure TForm5.FormCreate(Sender: TObject);
begin
  self.Constraints.MinHeight := self.Height;
  self.Constraints.MinWidth := self.Width;
end;

procedure TForm5.LabeledEdit5Change(Sender: TObject);
begin
  BitBtn1.Enabled := (LabeledEdit5.Text <> '');
end;

procedure TForm5.BitBtn2Click(Sender: TObject);
begin
  StaticText1.Caption := LabeledEdit2.Text + ', ' + LabeledEdit1.Text;
end;


end.

