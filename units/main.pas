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
  MaskEdit, DateUtils,
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
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;

    procedure ApplyChanges(Sender: TObject);
    procedure AddWeek(Sender: TObject);
    procedure ApplyValuesFromGrid(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure RemoveSelected(Sender: TObject);
    procedure RemoveAll(Sender: TObject);
    procedure DateEdit1Change(Sender: TObject);
    procedure DateEdit1EditingDone(Sender: TObject);
    procedure DateEdit2Change(Sender: TObject);
    procedure DateEdit2EditingDone(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LabeledEdit1EditingDone(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
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

    FVersionNr: String;           // Internal Programme-Version
    FVersionDate: String;         // Build-Date
    FOSName: String;              // The Internal Name for the used Operating System
    Flanguage: String;            // Language chosen by User - default is English

    FSeparator: String;           // The Separator for Dates e.g. "01.02.2014" has "."

    AboutForm: TForm2;
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
  FOSName := 'unknown';
  {$IFDEF mswindows}
    FOSName := 'Windows';
    //FVersionDate := FormatDateTime('dd.mm.yyyy', now);         // wird leider nicht nur zur Kompilierzeit ausgeführt
  {$ENDIF}
  {$IFDEF linux}
    {$IFDEF x32}
    FOSName := 'Linux';
    // := FormatDateTime('dd.mm.yyyy', now);
  {$ENDIF}
  FVersionNr := '0.0.0.7';
  FVersionDate := '22.04.2014';
  self.Caption := 'CoYOT(e) vers. ' + FVersionNr;
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
  //DateEdit2.
end;


procedure TForm1.LabeledEdit1EditingDone(Sender: TObject);
begin
  DateEdit1EditingDone(nil);
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.SelectWeek(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  try
    FSelectionIndex := aRow-1;
    DateEdit1.Text := FormatDateTime('dd.mm.yyyy', FWeekList.Items[aRow-1].FromDate);
    DateEdit2.Text := FormatDateTime('dd.mm.yyyy', FWeekList.Items[aRow-1].ToDate);
    EnableAllFields;

    WeekDaysToStringGrid(StringGrid2, FWeekList.Items[aRow-1]);
  except
  end;
end;


procedure TForm1.DateEdit1EditingDone(Sender: TObject);
var Date1, Date2: TDate;
begin
  try
    //if (FLanguage = 'English') then
    Date1 := StrToDate(DateEdit1.Text, 'dd.mm.yyyy', '.');
    Date2 := StrToDate(DateEdit2.Text, 'dd.mm.yyyy', '.');
    LabeledEdit1.Text := IntToStr(DaysBetween( Date1, Date2 )+1);
    DateEdit2EditingDone(nil);
  except
  end;
end;

procedure TForm1.DateEdit2Change(Sender: TObject);
begin
  DateEdit2EditingDone(nil);
  DateEdit2.Text := FormatDateTime('dd.mm.yyyy', StrToDate(DateEdit2.Text));
end;

procedure TForm1.DateEdit1Change(Sender: TObject);
begin
  DateEdit1EditingDone(nil);
  DateEdit1.Text := FormatDateTime('dd.mm.yyyy', StrToDate(DateEdit1.Text));
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

  for I := 0 to FWeeklist.Items[FSelectionIndex].Days.Count - 1 do
  begin
   // FWeeklist.Items[FSelectionIndex].Days.Items[I].StartHour := StringGrid2.Cells[2,I+1];
  end;

end;

procedure TForm1.MenuItem12Click(Sender: TObject);
begin
  FTranslations := changeLanguage('eng');
end;

procedure TForm1.MenuItem8Click(Sender: TObject);
begin
  AboutForm.Visible := True;
end;

procedure TForm1.RemoveSelected(Sender: TObject);
begin
  if (FSelectionIndex >= 0) then                                       // <<<<<<<<<<<<< -----------------------------
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
    date1 := StrToDate(DateEdit1.Text, 'dd.mm.yyyy','.');
    date2 := StrToDate(DateEdit2.Text, 'dd.mm.yyyy','.');

    days := DaysBetween( date1, date2 );
    FWeekList.Items[FSelectionIndex].IntendedWorkDayCount := days;

  if (days > 6) or (date1 > date2) then
  begin
    days := 6;
    date2 := date1 + defDaysPerWeek-1;
    dateedit2.Text := FormatDateTime('dd.mm.yyyy', date2);
    application.MessageBox('A week can not extend 7 days! Please select a valid value for a week!','Warning',0);
  end;
  if (FSelectionIndex >= 0) then
  begin
    try
      FWeekList.Items[FSelectionIndex].FromDate := StrToDate(DateEdit1.Text, 'dd.mm.yyyy', '.');
      FWeekList.Items[FSelectionIndex].ToDate := StrToDate(DateEdit2.Text, 'dd.mm.yyyy', '.');
      WeeksToStringGrid(StringGrid1, FWeekList);
    except
    end;
  end;
  DisableAllFields;
end;

procedure TForm1.RemoveAll(Sender: TObject);
begin
  FWeekList.Clear;
  WeeksToStringGrid(StringGrid1, FWeekList);
  DisableAllFields;
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

end.

