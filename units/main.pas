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
  Classes, SysUtils, FileUtil, RTTIGrids, RTTICtrls, Forms, Controls, Graphics,
  Dialogs, ComCtrls, ButtonPanel, DBCtrls, DBGrids, Calendar, EditBtn, FileCtrl,
  BarChart, Grids, Menus, PopupNotifier, StdCtrls, ExtCtrls, ExtDlgs, Buttons,
  MaskEdit, DateUtils, LResources, Translations,
  { Forms }
  WeekEditForm, WeekAddForm,
  { eigene Units }
  workdays, funcs, about;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    QuickMenu: TPanel;
    AddButton: TBitBtn;
    RemoveButton: TBitBtn;
    RemoveAllButton: TBitBtn;
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
    StringGrid2: TStringGrid;

    procedure ApplyChanges(Sender: TObject);
    procedure AddWeek(Sender: TObject);
    procedure ApplyValuesFromGrid(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormDestroy(Sender: TObject);
    procedure MenuSelectEnglish(Sender: TObject);
    procedure MenuAbout(Sender: TObject);
    procedure RemoveSelected(Sender: TObject);
    procedure RemoveAll(Sender: TObject);
    procedure FromDateEditChange(Sender: TObject);
    procedure FromDateEditEditingDone(Sender: TObject);
    procedure ToDateEditChange(Sender: TObject);
    procedure ToDateEditEditingDone(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure WorkdaysEditEditingDone(Sender: TObject);
    procedure MenuQuit(Sender: TObject);
    procedure SelectWeek(Sender: TObject; aCol, aRow: integer; var CanSelect: boolean);

    procedure DisableAllFields;
    procedure EnableAllFields;

  private
    { private declarations }
    defHoursPerDay: double;       // Standard Value for
    defDaysPerWeek: integer;
    FWeekList: TWeekList;         // List of Weeks shown in the StringGrid
    FSelectionIndex: integer;     // Index of the Week that was selected in the grid
    FTranslations: TStringList;

    FProgrammeName: string;       // Official Name shown to the user
    FVersionNr: string;           // Internal Programme-Version
    FVersionDate: string;         // Build-Date
    FLazarusVersion: string;      // Version of the Lazarus IDE the programme was built with
    FOSName: string;              // The Internal Name for the used Operating System
    Flanguage: string;            // Language chosen by User - default is English

    FSeparator: string;           // The Separator for Dates e.g. "01.02.2014" has "."

    AboutForm: TForm2;            // The Window showing information about CoYOT(e)
    EditWeekForm: TForm3;         // The window that you can edit a week with
    AddWeekForm: TForm4;          // A window to add a new week to the "data base"


    procedure AddWeekToList(Sender: TObject; AWeek: TWorkWeek);
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

  FOSName := 'unknown';             // Other OS
  {$IFDEF mswindows}
  FOSName := 'Windows';
  {$ENDIF}
  {$IFDEF linux}
  FOSName := 'Linux';
  {$ENDIF}
  FProgrammeName := 'CoYOT(e)';
  FVersionNr := '0.0.0.13';
  FVersionDate := '30.04.2014';
  FLazarusVersion := '1.2.0';
  self.Caption := FProgrammeName + '  ' + FVersionNr;
  FLanguage := 'English';
  FSeparator := '.';

  defHoursPerDay := 8;
  defDaysPerWeek := 5;

  FWeekList := TWeekList.Create;
  FTranslations := TStringList.Create;
  clearStringGrid(StringGrid1);
  AboutForm := TForm2.Create(nil);
  EditWeekForm := TForm3.Create(nil);
  AddWeekForm := TForm4.Create(nil);

  AboutForm.Label1.Caption := 'Version: ' + FVersionNr + ' ( ' + FOSName + ' )';
  AboutForm.Label2.Caption := 'Build Date: ' + FVersionDate;

end;


procedure TForm1.WorkdaysEditEditingDone(Sender: TObject);
begin
  FromDateEditEditingDone(nil);
end;


procedure TForm1.SelectWeek(Sender: TObject; aCol, aRow: integer;
  var CanSelect: boolean);
begin
  try
    FSelectionIndex := aRow - 1;
    //FromDateEdit.Text := DateToStr(FWeekList.Items[aRow - 1].FromDate);
    //ToDateEdit.Text := DateToStr(FWeekList.Items[aRow - 1].ToDate);
    EnableAllFields;

    WeekDaysToStringGrid(StringGrid2, FWeekList.Items[aRow - 1]);
  except
  end;
end;


procedure TForm1.FromDateEditEditingDone(Sender: TObject);
var
  Date1, Date2: TDate;
begin
  //if TryStrToDate(FromDateEdit.Text, Date1) and TryStrToDate(ToDateEdit.Text, Date2) then
  //begin
  // WorkdaysEdit.Text := IntToStr(DaysBetween(Date1, Date2) + 1);
  //ToDateEditEditingDone(nil);
  ////else
  //begin
  // Application.MessageBox('You entered an unvalid Date!', 'Error appeared!',0);
  //end;
end;

procedure TForm1.ToDateEditChange(Sender: TObject);
begin
  ToDateEditEditingDone(nil);
end;

procedure TForm1.FromDateEditChange(Sender: TObject);
begin
  FromDateEditEditingDone(nil);
end;

procedure TForm1.AddWeek(Sender: TObject);
begin
  AddWeekForm.Visible := True;
end;

procedure TForm1.ApplyValuesFromGrid(Sender: TObject);
var
  I: integer;
begin

  // The ClockTimes entered in the edit-grid now will be stored in the week
  for I := 0 to FWeeklist.Items[FSelectionIndex].IntendedWorkDayCount do
  begin
    // Begin of Work
    FWeeklist.Items[FSelectionIndex].Days.Items[I].StartHour :=
      getHour(StringGrid2.Cells[1, I]);
    FWeeklist.Items[FSelectionIndex].Days.Items[I].StartMinute :=
      getMinute(StringGrid2.Cells[1, I]);

    // End of Work
    FWeeklist.Items[FSelectionIndex].Days.Items[I].EndHour :=
      getHour(StringGrid2.Cells[2, I]);
    FWeeklist.Items[FSelectionIndex].Days.Items[I].EndMinute :=
      getMinute(StringGrid2.Cells[2, I]);

    // Additional hours
    // FWeeklist.Items[FSelectionIndex].Days.Items[I].AdditionalTime := StrToCurr(StringGrid2.Cells[3,I+1]);
  end;

end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  if (FweekList.Count > 0) and (FSelectionIndex >= 0) then
  begin
    EditWeekForm.Visible := True;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if (MessageDlg('Quit Programme', 'Do you want to quit ' + FProgrammeName +
    '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    CanClose := True;
  end
  else
  begin
    CanClose := False;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  AboutForm.Free;
  EditWeekForm.Free;
  AddWeekForm.Free;
end;

procedure TForm1.MenuSelectEnglish(Sender: TObject);
begin
  FTranslations := changeLanguage('English', FLazarusVersion, FOSName);
end;

procedure TForm1.MenuAbout(Sender: TObject);
begin
  AboutForm.Visible := True;
end;

procedure TForm1.RemoveSelected(Sender: TObject);
begin
  if (FSelectionIndex >= 0) then
  begin
    FWeekList.Delete(FSelectionIndex);
    WeeksToStringGrid(StringGrid1, FWeekList);
    FSelectionIndex := -1;
  end;
  DisableAllFields;
end;

procedure TForm1.ApplyChanges(Sender: TObject);
var
  date1, date2: TDate;
  days: integer;
begin
  //date1 := StrToDate(FromDateEdit.Text);
  //date2 := StrToDate(ToDateEdit.Text);

  //days := DaysBetween(date1, date2);
  //WorkdaysEdit.Text := IntToStr(days + 1);
  FWeekList.Items[FSelectionIndex].IntendedWorkDayCount := days;

  if (days > 6) or (date1 > date2) then
  begin
    days := 6;
    date2 := date1 + defDaysPerWeek - 1;
    //ToDateEdit.Text := DateToStr(date2);
    application.MessageBox(
      'A week cannot exceed 7 days! Please select a valid value for a week!',
      'Warning', 0);
  end;
  if (FSelectionIndex >= 0) then
  begin
    try
      //FWeekList.Items[FSelectionIndex].FromDate := StrToDate(FromDateEdit.Text);
      //FWeekList.Items[FSelectionIndex].ToDate := StrToDate(ToDateEdit.Text);
      WeeksToStringGrid(StringGrid1, FWeekList);
    except
    end;
  end;
  DisableAllFields;
end;

procedure TForm1.RemoveAll(Sender: TObject);
begin
  if (MessageDlg('Delete all entries', 'Do you really wish to delete all data?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    FWeekList.Clear;
    WeeksToStringGrid(StringGrid1, FWeekList);
    DisableAllFields;
  end;
end;


procedure TForm1.ToDateEditEditingDone(Sender: TObject);
begin
  //WorkdaysEdit.Text := IntToStr(DaysBetween(StrToDate(FromDateEdit.Text), StrToDate(ToDateEdit.Text)) + 1);
end;

procedure TForm1.EnableAllFields;
begin

end;

procedure TForm1.DisableAllFields;
begin

end;

procedure TForm1.MenuQuit(Sender: TObject);
begin
  if (MessageDlg('Quit Programme', 'Do you want to quit ' + FProgrammeName +
    '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    Application.Terminate;
  end;
end;

procedure TForm1.AddWeekToList(Sender: TObject; AWeek: TWorkWeek);
begin
  FWeekList.Add(AWeek);
  WeeksToStringGrid(StringGrid1, FWeekList);
end;

end.