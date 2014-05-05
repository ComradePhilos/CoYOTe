{
  CoYOt(e) - Control Your OverTimes (easily)
  Find out how much leave you accumulated by working overtimes or
  how many overtime hours you need to catch up with the week goal.
}

// in future:
// possibility to add Users and Persons to make it possible for Bosses/Teamleaders to control attendance times of employees
// MAYBE: possibility to add more than one work period to a day e.g. for several jobs or alternative pause systems
unit main;

{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, FileUtil, RTTIGrids, RTTICtrls, Forms, Controls,
  Dialogs, ComCtrls, ButtonPanel, DBCtrls, DBGrids, Calendar, EditBtn, FileCtrl,
  BarChart, Grids, Menus, StdCtrls, ExtCtrls, ExtDlgs, Buttons, DateUtils,
  { Forms }
  WeekEditForm, WeekAddForm,
  { eigene Units }
  workdays, funcs, about;

type

  { TForm1 }

  TForm1 = class(TForm)
    ImageList1: TImageList;
    GroupBox1: TGroupBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    StatusBar1: TStatusBar;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;

    procedure AddWeek(Sender: TObject);
    procedure EditButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormDestroy(Sender: TObject);
    procedure MenuAbout(Sender: TObject);
    procedure RemoveSelected(Sender: TObject);
    procedure RemoveAll(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuQuit(Sender: TObject);
    procedure SelectWeek(Sender: TObject; aCol, aRow: integer; var CanSelect: boolean);

  private
    { private declarations }
    defHoursPerDay: double;       // Standard Value
    defDaysPerWeek: integer;      // Standard Value
    FWeekList: TWeekList;         // List of Weeks shown in the StringGrid
    FSelectionIndex: integer;     // Index of the Week that was selected in the grid

    FProgrammeName: string;       // Official Name shown to the user
    FVersionNr: string;           // Internal Programme-Version
    FVersionDate: string;         // Build-Date
    FLazarusVersion: string;      // Version of the Lazarus IDE the programme was built with
    FOSName: string;              // The Internal Name for the used Operating System
    FLanguage: string;            // Language chosen by User - default is English

    FSeparator: string;           // The Separator for Dates e.g. "01.02.2014" has "."

    AboutForm: TForm2;            // The Window showing information about CoYOT(e)
    EditWeekForm: TForm3;         // The window that you can edit a week with
    AddWeekForm: TForm4;          // A window to add a new week to the "data base"

    procedure AddWeekToList(Sender: TObject; AWeek: TWorkWeek; GoOnEditing: Boolean);
    procedure RemoveWeekFromList(Sender: TObject; Index: Integer);
    procedure EnableButtons;      // Checks for each button, wether it has to get
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

const
  txtDeleteMsg = 'Are you sure you want to delete the period with all data? This cannot be made undone afterwards!';

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  I: integer;
begin

  // detect OS
  FOSName := 'unknown';
  {$IFDEF mswindows}
  FOSName := 'Windows';
  {$ENDIF}
  {$IFDEF linux}
  FOSName := 'Linux';
  {$ENDIF}

  FProgrammeName := 'CoYOT(e)';
  FVersionNr := '0.0.1.2';
  FVersionDate := '05.05.2014';
  FLazarusVersion := '1.2.0';
  self.Caption := FProgrammeName + '  ' + FVersionNr;
  FLanguage := 'English';
  FSeparator := '.';

  // default values
  defHoursPerDay := 8;
  defDaysPerWeek := 5;

  FWeekList := TWeekList.Create;
  WeeksToStringGrid(StringGrid1, FWeekList);
  AboutForm := TForm2.Create(nil);
  EditWeekForm := TForm3.Create(nil);
  AddWeekForm := TForm4.Create(nil);

  AddWeekForm.OnApplyClick := @AddWeekToList;           // assign event of the add-form
  EditWeekForm.OnRemoveClick := @RemoveWeekFromList;    // assign event for deletion

  AboutForm.Label1.Caption := 'Version: ' + FVersionNr + ' ( ' + FOSName + ' )';
  AboutForm.Label2.Caption := 'Build Date: ' + FVersionDate;
  EnableButtons;

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  AboutForm.Free;
  EditWeekForm.Free;
  AddWeekForm.Free;
  FWeekList.Free;
end;

procedure TForm1.SelectWeek(Sender: TObject; aCol, aRow: integer; var CanSelect: boolean);
begin
  FSelectionIndex := aRow - 1;
end;

procedure TForm1.AddWeek(Sender: TObject);
begin
  AddWeekForm.Visible := True;
  AddWeekForm.Show;
end;

procedure TForm1.EditButtonClick(Sender: TObject);
begin
  if (FweekList.Count > 0) and (FSelectionIndex >= 0) then
  begin
    if (FWeekList.Count > 1) then
    begin
      EditWeekForm.Arrow1.Enabled := True;
      EditWeekForm.Arrow2.Enabled := True;
    end
    else
    begin
      EditWeekForm.Arrow1.Enabled := False;
      EditWeekForm.Arrow2.Enabled := False;
    end;
    EditWeekForm.showWeek(FWeekList.Items[FSelectionIndex], FSelectionIndex);
    EditWeekForm.Visible := True;
  end;
end;

procedure TForm1.RemoveSelected(Sender: TObject);
begin
  if (FSelectionIndex >= 0) then
  begin
  if (MessageDlg('Delete Data?', txtDeleteMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    FWeekList.Delete(FSelectionIndex);
    WeeksToStringGrid(StringGrid1, FWeekList);
    FSelectionIndex := -1;
  end;
  EnableButtons;
	end;
end;

procedure TForm1.RemoveAll(Sender: TObject);
begin
  if (FWeekList.Count > 0) then
  begin
    if (MessageDlg('Delete all entries', 'Do you really wish to delete all data?', mtConfirmation,
      [mbYes, mbNo], 0) = mrYes) then
    begin
      FWeekList.Clear;
      WeeksToStringGrid(StringGrid1, FWeekList);
    end;
  end;
  EnableButtons;
end;

procedure TForm1.AddWeekToList(Sender: TObject; AWeek: TWorkWeek; GoOnEditing: Boolean);
begin
  FWeekList.Add(AWeek);
  WeeksToStringGrid(StringGrid1, FWeekList);
  EnableButtons;
  if GoOnEditing then
  begin
    FSelectionIndex := FWeekList.Count-1;
    EditButtonClick(self);
	end;
end;

procedure TForm1.RemoveWeekFromList(Sender: TObject; Index: Integer);
begin
  if (Index >= 0) and (Index < FWeekList.Count) then
  begin
    FWeekList.Delete(Index);
	end;
	WeeksToStringGrid(StringGrid1, FWeekList);
  EnableButtons;
end;

procedure TForm1.EnableButtons;
begin
  if (FWeekList.Count > 0) then
  begin
    Toolbar1.Buttons[1].Enabled := True;
    Toolbar1.Buttons[2].Enabled := True;
  end
  else
  begin
    Toolbar1.Buttons[1].Enabled := False;
    Toolbar1.Buttons[2].Enabled := False;
  end;
end;

procedure TForm1.MenuAbout(Sender: TObject);
begin
  AboutForm.Visible := True;
end;

procedure TForm1.MenuQuit(Sender: TObject);
begin
  if (MessageDlg('Quit Programme', 'Do you want to quit ' + FProgrammeName + '?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes) then
  begin
    Application.Terminate;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if (MessageDlg('Quit Programme', 'Do you want to quit ' + FProgrammeName + '?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes) then
  begin
    CanClose := True;
  end
  else
  begin
    CanClose := False;
  end;
end;


end.
