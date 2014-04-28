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
  Dialogs, ComCtrls, ButtonPanel, DbCtrls, DBGrids, Calendar, EditBtn, FileCtrl,
  BarChart, Grids, Menus, PopupNotifier, StdCtrls, ExtCtrls, ExtDlgs, Buttons,
  MaskEdit, DateUtils, LResources, Translations,
  { eigene Units }
  workdays, funcs, about;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    DateEdit1: TDateEdit;
    DateEdit2: TDateEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
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
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure MenuSelectEnglish(Sender: TObject);
    procedure MenuAbout(Sender: TObject);
    procedure RemoveSelected(Sender: TObject);
    procedure RemoveAll(Sender: TObject);
    procedure DateEdit1Change(Sender: TObject);
    procedure DateEdit1EditingDone(Sender: TObject);
    procedure DateEdit2Change(Sender: TObject);
    procedure DateEdit2EditingDone(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LabeledEdit1EditingDone(Sender: TObject);
    procedure MenuQuit(Sender: TObject);
    procedure SelectWeek(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);

    procedure DisableAllFields;
    procedure EnableAllFields;
  private
    { private declarations }
    defHoursPerDay: Double;
    defDaysPerWeek: Integer;
    FWeekList: TWeekList;         // List of Weeks shown in the StringGrid
    FSelectionIndex: Integer;     // Index of the Week that was selected in the grid
    FTranslations: TStringList;

    FProgrammeName: String;       // Official Name shown to the user
    FVersionNr: String;           // Internal Programme-Version
    FVersionDate: String;         // Build-Date
    FLazarusVersion: String;      // Version of the Lazarus IDE the programme was built with
    FOSName: String;              // The Internal Name for the used Operating System
    Flanguage: String;            // Language chosen by User - default is English

    FSeparator: String;           // The Separator for Dates e.g. "01.02.2014" has "."

    AboutForm: TForm2;            // The Window showing information about CoYOT(e)
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
  FVersionNr := '0.0.0.9';
  FVersionDate := '28.04.2014';
  FLazarusVersion := '1.2.0';
  self.Caption := FProgrammeName + '  ' +  FVersionNr;
  FLanguage := 'English';
  FSeparator := '.';

  defHoursPerDay := 8;
  defDaysPerWeek := 5;

  FWeekList := TWeekList.Create;
  FTranslations := TStringList.Create;
  clearStringGrid(StringGrid1);
  AboutForm := TForm2.Create(nil);

  AboutForm.Label1.Caption := 'Version: ' + FVersionNr + ' ( ' + FOSName + ' )';
  AboutForm.Label2.Caption := 'Build Date: ' + FVersionDate;

end;


procedure TForm1.LabeledEdit1EditingDone(Sender: TObject);
begin
  DateEdit1EditingDone(nil);
end;


procedure TForm1.SelectWeek(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  try
    FSelectionIndex := aRow-1;
    DateEdit1.Text := DateToStr(FWeekList.Items[aRow-1].FromDate);
    DateEdit2.Text := DateToStr(FWeekList.Items[aRow-1].ToDate);
    EnableAllFields;

    WeekDaysToStringGrid(StringGrid2, FWeekList.Items[aRow-1]);
  except
  end;
end;


procedure TForm1.DateEdit1EditingDone(Sender: TObject);
var
  Date1, Date2: TDate;
begin
    if TryStrToDate(DateEdit1.Text, Date1) and TryStrToDate(DateEdit2.Text, Date2) then
    begin
      LabeledEdit1.Text := IntToStr(DaysBetween( Date1, Date2 )+1);
      DateEdit2EditingDone(nil);
		end
    else
    begin
     // Application.MessageBox('You entered an unvalid Date!', 'Error appeared!',0);
		end;
end;

procedure TForm1.DateEdit2Change(Sender: TObject);
begin
  DateEdit2EditingDone(nil);
end;

procedure TForm1.DateEdit1Change(Sender: TObject);
begin
  DateEdit1EditingDone(nil);
end;

procedure TForm1.AddWeek(Sender: TObject);
begin
  FWeekList.Add(TWorkWeek.Create);
  WeeksToStringGrid(StringGrid1, FWeekList);
end;

procedure TForm1.ApplyValuesFromGrid(Sender: TObject);
var
  I: Integer;
begin

  // The ClockTimes entered in the edit-grid now will be stored in the week
  for I := 0 to FWeeklist.Items[FSelectionIndex].IntendedWorkDayCount do
  begin
    // Begin of Work
    FWeeklist.Items[FSelectionIndex].Days.Items[I].StartHour := getHour(StringGrid2.Cells[1,I+1]);
    FWeeklist.Items[FSelectionIndex].Days.Items[I].StartMinute := getMinute(StringGrid2.Cells[1,I+1]);

    // End of Work
    FWeeklist.Items[FSelectionIndex].Days.Items[I].EndHour := getHour(StringGrid2.Cells[2,I+1]);
    FWeeklist.Items[FSelectionIndex].Days.Items[I].EndMinute := getMinute(StringGrid2.Cells[2,I+1]);

    // Additional hours
    FWeeklist.Items[FSelectionIndex].Days.Items[I].AdditionalTime := StrToCurr(StringGrid2.Cells[3,I+1]);
  end;

end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if (MessageDlg('Quit Programme', 'Do you want to quit ' + FProgrammeName + '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    CanClose := True;
  end
  else
  begin
    CanClose := False;
  end;
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
    FSelectionIndex := - 1;
  end;
  DisableAllFields;
end;

procedure TForm1.ApplyChanges(Sender: TObject);
var
  date1, date2: TDate;
  days: Integer;
begin
    date1 := StrToDate(DateEdit1.Text);
    date2 := StrToDate(DateEdit2.Text);

    days := DaysBetween( date1, date2 );
    labeledEdit1.Text := IntToStr(days+1);
    FWeekList.Items[FSelectionIndex].IntendedWorkDayCount := days;

  if (days > 6) or (date1 > date2) then
  begin
    days := 6;
    date2 := date1 + defDaysPerWeek-1;
    dateedit2.Text := DateToStr(date2);
    application.MessageBox('A week can not exceed 7 days! Please select a valid value for a week!','Warning',0);
  end;
  if (FSelectionIndex >= 0) then
  begin
    try
      FWeekList.Items[FSelectionIndex].FromDate := StrToDate(DateEdit1.Text);
      FWeekList.Items[FSelectionIndex].ToDate := StrToDate(DateEdit2.Text);
      WeeksToStringGrid(StringGrid1, FWeekList);
    except
    end;
  end;
  DisableAllFields;
end;

procedure TForm1.RemoveAll(Sender: TObject);
begin
  if (MessageDlg('Delete all entries', 'Do you really wish to delete all data?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    FWeekList.Clear;
    WeeksToStringGrid(StringGrid1, FWeekList);
    DisableAllFields;
  end;
end;


procedure TForm1.DateEdit2EditingDone(Sender: TObject);
begin
  try
    LabeledEdit1.Text := IntToStr(DaysBetween( StrToDate(DateEdit1.Text), StrToDate(DateEdit2.Text))+1);
  except
  end;
end;

procedure TForm1.EnableAllFields;
begin
  DateEdit1.Enabled := True;
  DateEdit2.Enabled := True;
  labeledEdit1.Enabled := True;
  labeledEdit2.Enabled := True;

  bitBtn1.Enabled := True;
  bitBtn2.Enabled := True;
  label1.Enabled := True;
  label2.Enabled := True;
  label3.Caption := 'Week #' + IntToStr(FSelectionIndex+1);
end;

procedure TForm1.DisableAllFields;
begin
  DateEdit1.Enabled := False;
  DateEdit2.Enabled := False;
  labeledEdit1.Enabled := False;
  labeledEdit2.Enabled := False;

  bitBtn1.Enabled := False;
  bitBtn2.Enabled := False;
  label1.Enabled := False;
  label2.Enabled := False;
  label3.Caption := '';
end;

procedure TForm1.MenuQuit(Sender: TObject);
begin
  if (MessageDlg('Quit Programme', 'Do you want to quit ' + FProgrammeName + '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    Application.Terminate;
  end;
end;


end.

