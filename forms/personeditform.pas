unit PersonEditForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, RTTIGrids, Forms, Controls, Graphics, Dialogs,
	ExtCtrls, StdCtrls, Buttons, LCLIntF, ComCtrls, Grids, ValEdit, DbCtrls,
	Process,
  {own units}
  people, workdays;

type

  TRemoveEvent = procedure(Sender: TObject; Index: integer) of object;
  TApplyEvent = procedure(Sender: TObject; APerson: TPerson; Index: integer) of object;
  TNextPersonEvent = procedure(Sender: TObject; Index: integer) of object;

	{ TForm5 }

  TForm5 = class(TForm)
		RevertButton: TBitBtn;
    BitBtn1: TBitBtn;
    ApplyButton: TBitBtn;
    BackButton: TBitBtn;
		BitBtn3: TBitBtn;
		BitBtn4: TBitBtn;
		BitBtn5: TBitBtn;
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
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    DeleteUserButton: TToolButton;
    ToolButton5: TToolButton;
    ClearButton: TToolButton;
    ToolButton7: TToolButton;
		ApplyButton2: TToolButton;
    procedure ApplyButtonClick(Sender: TObject);
		procedure RevertButtonClick(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
		procedure ComboBox1Select(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EMailEditChange(Sender: TObject);
    procedure OpenEMailClient(Sender: TObject);
		procedure ToolButton1Click(Sender: TObject);
		procedure ToolButton2Click(Sender: TObject);
		procedure DeleteUserButtonClick(Sender: TObject);
		procedure ToolButton5Click(Sender: TObject);
		procedure ToolButton8Click(Sender: TObject);

  private
    { private declarations }
    FPersonList: TPersonList;
    FPersonIndex: Integer;

    procedure UpdateWindow;
    procedure Clear;
    procedure EnableFields;

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

uses CoyoteDefaults;

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
  if (FPersonList.Count > 0) then
  begin
    Dec(FPersonIndex);
    if (FPersonIndex < 0) then
    begin
      FPersonIndex := ComboBox1.Items.Count - 1;
	  end;
    updateWindow;
	end;
end;

procedure TForm5.ToolButton2Click(Sender: TObject);
begin
if (FPersonList.Count > 0) then
  begin
    Inc(FPersonIndex);
    if (FPersonIndex >= ComboBox1.Items.Count) then
    begin
      FPersonIndex := 0;
	  end;
    updateWindow;
	end;
end;

procedure TForm5.DeleteUserButtonClick(Sender: TObject);
begin
  if (FPersonList.Count > 0) then
  begin
    if (MessageDlg('Delete selected user?', txtRemoveUserMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      FPersonList.Delete(FPersonIndex);
      FPersonIndex := 0;
		end;
	end
  else
  begin
    FPersonIndex := -1;
    Combobox1.ItemIndex := -1;
	end;
	updateWindow;
end;

procedure TForm5.ToolButton5Click(Sender: TObject);
begin
  FPersonList.Add(TPerson.Create);
  FPersonList.Items[FPersonList.Count-1].FirstName := 'New';
  FPersonList.Items[FPersonList.Count-1].FamilyName := 'User';
  FPersonList.Items[FPersonList.Count-1].TimeData.Add(TWeekList.Create);
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
end;

procedure TForm5.EMailEditChange(Sender: TObject);
begin
  BitBtn1.Enabled := (EMailEdit.Text <> '');
end;

procedure TForm5.ApplyButtonClick(Sender: TObject);
begin
  if (FPersonList.Count > 0) then
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
end;

procedure TForm5.RevertButtonClick(Sender: TObject);
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

  if (FPersonList.Count > 0) then
  begin
    FirstNameEdit.Text := FPersonList.Items[FPersonIndex].FirstName;
    FamilyNameEdit.Text := FPersonList.Items[FPersonIndex].FamilyName;
    StreetEdit.Text := FPersonList.Items[FPersonIndex].Street;
    StreetNREdit.Text := FPersonList.Items[FPersonIndex].StreetNR;
    ResidenceEdit.Text := FPersonList.Items[FPersonIndex].Residence;
    PhoneEdit1.Text := FPersonList.Items[FPersonIndex].PhoneNumber1;
    PhoneEdit2.Text := FPersonList.Items[FPersonIndex].PhoneNumber2;
    EmailEdit.Text := FPersonList.Items[FPersonIndex].EMail;
    StaticText1.Caption := FirstNameEdit.Text + ' ' + FamilyNameEdit.Text;
	end
  else
  begin
    Clear;
	end;
end;

procedure TForm5.Clear;
begin
  FirstNameEdit.Text := '';
  FamilyNameEdit.Text := '';
  StreetEdit.Text := '';
  StreetNREdit.Text := '';
  ResidenceEdit.Text := '';
  PhoneEdit1.Text := '';
  PhoneEdit2.Text := '';
  EmailEdit.Text := '';
  StaticText1.Caption := '';
  ComboBox1.Clear;
end;

procedure TForm5.EnableFields;
begin
  ApplyButton.Enabled := (FPersonList.Count > 0);
  ApplyButton2.Enabled := (FPersonList.Count > 0);
  RevertButton.Enabled := (FPersonList.Count > 0);
  DeleteUserButton.Enabled := (FPersonList.Count > 0);
  ClearButton.Enabled := (FPersonList.Count > 0);
end;

end.

