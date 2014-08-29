unit PersonEditForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, RTTIGrids, Forms, Controls, Graphics, Dialogs,
	ExtCtrls, StdCtrls, Buttons, LCLIntF, ComCtrls, Grids, ValEdit, DbCtrls,
	Process,
  {own units}
  people;

type

  TRemoveEvent = procedure(Sender: TObject; Index: integer) of object;
  TApplyEvent = procedure(Sender: TObject; APerson: TPerson; Index: integer) of object;
  TNextPersonEvent = procedure(Sender: TObject; Index: integer) of object;

	{ TForm5 }

  TForm5 = class(TForm)
	  ApplyButton1: TBitBtn;
		BackButton1: TBitBtn;
    BitBtn1: TBitBtn;
    ApplyButton: TBitBtn;
    BackButton: TBitBtn;
		BitBtn2: TBitBtn;
    ComboBox1: TComboBox;
    ImageList1: TImageList;
    FirstNameEdit: TLabeledEdit;
    FamilyNameEdit: TLabeledEdit;
    PhoneEdit1: TLabeledEdit;
    PhoneEdit2: TLabeledEdit;
    EMailEdit: TLabeledEdit;
    ResidenceEdit: TLabeledEdit;
    StreetEdit: TLabeledEdit;
		StreetNREdit: TLabeledEdit;
		ListBox1: TListBox;
    StaticText1: TStaticText;
		StaticText2: TStaticText;
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
    procedure ApplyButtonClick(Sender: TObject);
		procedure BackButton1Click(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
		procedure ComboBox1Select(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EMailEditChange(Sender: TObject);
    procedure OpenEMailClient(Sender: TObject);
		procedure ToolButton1Click(Sender: TObject);
		procedure ToolButton2Click(Sender: TObject);
		procedure ToolButton4Click(Sender: TObject);
		procedure ToolButton5Click(Sender: TObject);
		procedure ToolButton8Click(Sender: TObject);
  private
    { private declarations }
    FPersonList: TPersonList;
    FPersonIndex: Integer;

    procedure UpdateWindow;

  public
    { public declarations }
    FRemoveEvent: TRemoveEvent;
    FApplyEvent: TApplyEvent;
    FNextPersonEvent: TNextPersonEvent;

    procedure ShowPersonList(APersonList: TPersonList; AIndex: Integer);
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
  mailadress := EMailEdit.Text;

  if (mailadress <> '') then
  begin
    OpenURL('mailto:' + mailadress);
  end;
end;

procedure TForm5.ToolButton1Click(Sender: TObject);
begin
  Dec(FPersonIndex);
  if (FPersonIndex < 0) then
  begin
    FPersonIndex := ComboBox1.Items.Count - 1;
	end;
  updateWindow;
end;

procedure TForm5.ToolButton2Click(Sender: TObject);
begin
  Inc(FPersonIndex);
  if (FPersonIndex >= ComboBox1.Items.Count) then
  begin
    FPersonIndex := 0;
	end;
  updateWindow;
end;

procedure TForm5.ToolButton4Click(Sender: TObject);
begin
  if (FPersonList.Count > 0) then
  begin
    FPersonList.Delete(FPersonIndex);

    if (FPersonIndex >= ComboBox1.Items.Count-1) then
    begin
      FPersonIndex := 0;
	  end;
	end
  else
  begin
    FPersonIndex := -1;
	end;
	updateWindow;
end;

procedure TForm5.ToolButton5Click(Sender: TObject);
begin
  FPersonList.Add(TPerson.Create);
  FPersonList.Items[FPersonList.Count-1].FirstName := 'New';
  FPersonList.Items[FPersonList.Count-1].FamilyName := 'User';
  updateWindow;
end;

procedure TForm5.ToolButton8Click(Sender: TObject);
begin
  ApplyButtonClick(nil);
end;

procedure TForm5.BackButtonClick(Sender: TObject);
begin
  self.Visible := False;
end;

procedure TForm5.ComboBox1Select(Sender: TObject);
begin
  FPersonIndex := ComboBox1.ItemIndex;
  updateWindow;
end;

procedure TForm5.FormCreate(Sender: TObject);
begin
  self.Constraints.MinHeight := self.Height;
  self.Constraints.MinWidth := self.Width;
  //FPersonList := TPersonList.Create;
end;

procedure TForm5.EMailEditChange(Sender: TObject);
begin
  BitBtn1.Enabled := (EMailEdit.Text <> '');
end;

procedure TForm5.ApplyButtonClick(Sender: TObject);
begin

  FPersonList.Items[FPersonIndex].FirstName := FirstNameEdit.Text;
  FPersonList.Items[FPersonIndex].FamilyName := FamilyNameEdit.Text;
  FPersonList.Items[FPersonIndex].Street := StreetEdit.Text;
  FPersonList.Items[FPersonIndex].StreetNR := StreetNrEdit.Text;
  FPersonList.Items[FPersonIndex].Residence := ResidenceEdit.Text;
  FPersonList.Items[FPersonIndex].PhoneNumber1 := PhoneEdit1.Text;
  FPersonList.Items[FPersonIndex].PhoneNumber2 := PhoneEdit2.Text;
  FPersonList.Items[FPersonIndex].EMail := EMailEdit.Text;

  updateWindow;
end;

procedure TForm5.BackButton1Click(Sender: TObject);
begin
  UpdateWindow;
end;

procedure TForm5.ShowPersonList(APersonList: TPersonList; AIndex: Integer);
begin
  FPersonList := APersonList;
  FPersonIndex := AIndex;
  UpdateWindow;
end;

procedure TForm5.UpdateWindow;
begin
  NamesToCombobox(ComboBox1, FPersonList);
  ComboBox1.ItemIndex := FPersonIndex;

  FirstNameEdit.Text := FPersonList.Items[FPersonIndex].FirstName;
  FamilyNameEdit.Text := FPersonList.Items[FPersonIndex].FamilyName;
  StreetEdit.Text := FPersonList.Items[FPersonIndex].Street;
  StreetNREdit.Text := FPersonList.Items[FPersonIndex].StreetNR;
  ResidenceEdit.Text := FPersonList.Items[FPersonIndex].Residence;
  PhoneEdit1.Text := FPersonList.Items[FPersonIndex].PhoneNumber1;
  PhoneEdit2.Text := FPersonList.Items[FPersonIndex].PhoneNumber2;
  EmailEdit.Text := FPersonList.Items[FPersonIndex].EMail;

  StaticText1.Caption := FirstNameEdit.Text + ' ' + FamilyNameEdit.Text;
end;

end.

