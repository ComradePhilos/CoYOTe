{
  CoYOt(e) - Control Your OverTimes (easily)
  Find out how much leave you accumulated by working overtimes or
  how many overtime hours you need to catch up with the week goal.
}

// Todo:
// * each person (for each year) will be a file
// * merge weeks
// * switch day order in week
// * add switchable advanced view, which will add more colums to the grid
// !! * change the ListToGrid-function so that temporary changes won't be
//    deleted after a refresh of the grid
// * improve the close-Dialog, so that it only appears when there have been changes

// features in future:
// * Database Support for local or external database servers (e.g. Firebird)

unit main;

{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, FileUtil, RTTIGrids, RTTICtrls, Forms, Controls, Dialogs,
  ComCtrls, ButtonPanel, DBCtrls, DBGrids, Calendar, EditBtn, FileCtrl, BarChart,
  Grids, Menus, StdCtrls, ExtCtrls, ExtDlgs, Buttons, ActnList, ColorBox,
  DateUtils,
  { Forms }
  WeekEditForm, WeekAddForm, about,
  { eigene Units }
  workdays, funcs, CoyoteDefaults;

type

  { TForm1 }

  TForm1 = class(TForm)
    ImageList1: TImageList;
    GroupBox1: TGroupBox;
    ImageList2: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuLoad: TMenuItem;
    MenuSave: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    PopupMenu1: TPopupMenu;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton5: TToolButton;
    UsersList: TPopupMenu;
    StatusBar1: TStatusBar;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    AddWeekButton: TToolButton;
    RemoveWeekButton: TToolButton;
    EditWeekButton: TToolButton;
    ToolButton4: TToolButton;

    procedure AddWeek(Sender: TObject);
    procedure EditButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormDestroy(Sender: TObject);
    procedure MenuAbout(Sender: TObject);
    procedure MenuItem19Click(Sender: TObject);
    procedure MenuLoadClick(Sender: TObject);
    procedure MenuSaveClick(Sender: TObject);
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

    FOSName: string;              // The Internal Name for the used Operating System
    FLanguage: string;            // Language chosen by User - default is English

    AboutForm: TForm2;            // The Window showing information about CoYOT(e)
    EditWeekForm: TForm3;         // The window that you can edit a week with
    AddWeekForm: TForm4;          // A window to add a new week to the "data base"

    // triggered when a week is added
    procedure AddWeekToList(Sender: TObject; AWeek: TWorkWeek; EditAfterwards: boolean);

    // triggered when a week got edited
    procedure AssignWeek(Sender: TObject; AWeek: TWorkWeek; Index: integer);

    // triggered when a Form wants a specific week
    procedure GetWeek(Sender: TObject; Index: integer);

    // triggered when a certain week is deleted
    procedure RemoveWeekFromList(Sender: TObject; Index: integer);

    // Checks for each button, wether it has to get
    procedure EnableButtons;

    // Updates the Information shown
    procedure UpdateWindow;

  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation



{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  I: integer;
begin

  FOSName := 'unknown';  // for those poor guys using Minix, BSD, Solaris and such things ;)
  // detectable OS
  {$IFDEF macos}
  FOSName := 'MacOS';    // for those poor guys, who need to compensate the little penis ;)
  {$ENDIF}
  {$IFDEF mswindows}
  FOSName := 'Windows';  // for those poor guys, who need to compensate the little brain ;)
  {$ENDIF}
  {$IFDEF linux}
  FOSName := 'Linux';    // for those poor guys, who need to compensate the little budget ;)
  {$ENDIF}

  Caption := ProgrammeName + '  ' + VersionNr;
  FLanguage := 'English';

  // default values
  defHoursPerDay := 8;
  defDaysPerWeek := 5;
  FSelectionIndex := -1;

  // Create Instances
  FWeekList := TWeekList.Create;

  AboutForm := TForm2.Create(nil);
  EditWeekForm := TForm3.Create(nil);
  AddWeekForm := TForm4.Create(nil);

  // Event Handling
  AddWeekForm.OnApplyClick := @AddWeekToList;           // assign event of the add-form
  EditWeekForm.OnRemoveClick := @RemoveWeekFromList;    // assign event for deletion
  EditWeekForm.OnApplyClick := @AssignWeek;             // assign event for applying changes to week
  EditWeekForm.OnNextWeekClick := @GetWeek;             // switch to specified week via Index

  AboutForm.Label1.Caption := 'Version: ' + VersionNr + ' ( ' + FOSName + ' )';
  AboutForm.Label2.Caption := 'Build Date: ' + VersionDate;

  updateWindow;
  Toolbar1.Color := $00FFDBB7;
  EditWeekForm.ToolBar1.Color := $00FFDBB7;

  // $00FFDBB7   Standardfarbe

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  AboutForm.Free;
  EditWeekForm.Free;
  AddWeekForm.Free;
  FWeekList.Free;
end;

procedure TForm1.SelectWeek(Sender: TObject; aCol, aRow: integer; var CanSelect: boolean);
var
  locInt: integer;
begin
  if (StringGrid1.RowCount > 1) then
  begin
    if TryStrToInt(StringGrid1.Cells[0, aRow], locInt) then
    begin
      FSelectionIndex := locInt - 1;
    end
    else
    begin
      FSelectionIndex := -1;
    end;
  end;
end;

procedure TForm1.AddWeek(Sender: TObject);
begin
  AddWeekForm.Visible := True;
  AddWeekForm.Show;
end;

procedure TForm1.AssignWeek(Sender: TObject; AWeek: TWorkWeek; Index: integer);
begin
  FWeekList.Items[Index].Assign(AWeek);
  updateWindow;
end;

procedure TForm1.EditButtonClick(Sender: TObject);
begin
  if (FweekList.Count > 0) and (FSelectionIndex >= 0) then
  begin
    if (FWeekList.Count > 1) then
    begin
      EditWeekForm.ButtonLeft.Enabled := True;
      EditWeekForm.ButtonRight.Enabled := True;
    end
    else
    begin
      EditWeekForm.ButtonLeft.Enabled := False;
      EditWeekForm.ButtonRight.Enabled := False;
    end;
    EditWeekForm.showWeek(FWeekList.Items[FSelectionIndex], FSelectionIndex);
    EditWeekForm.Visible := True;
  end;
end;

procedure TForm1.getWeek(Sender: TObject; Index: integer);
begin
  if (FWeekList.Count > 0) then
  begin
    if (Index >= FWeekList.Count) then
    begin
      Index := 0;
    end;
    if (Index < 0) then
    begin
      Index := FWeekList.Count - 1;
    end;
    EditWeekForm.showWeek(FWeekList.Items[Index], Index);
  end;
end;

procedure TForm1.RemoveSelected(Sender: TObject);
begin
  if (FSelectionIndex >= 0) then
  begin
    if (MessageDlg(txtCaptionDelete, txtDeleteMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      FWeekList.Delete(FSelectionIndex);
      FSelectionIndex := -1;
    end;
    updateWindow;
  end;
end;

procedure TForm1.RemoveAll(Sender: TObject);
begin
  if (FWeekList.Count > 0) then
  begin
    if (MessageDlg(txtCaptionDelete, txtDeleteAllMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      FWeekList.Clear;
      updateWindow;
    end;
  end;
end;

procedure TForm1.AddWeekToList(Sender: TObject; AWeek: TWorkWeek; EditAfterwards: boolean);
begin
  FWeekList.Add(AWeek);
  updateWindow;
  if EditAfterwards then
  begin
    FSelectionIndex := FWeekList.Count - 1;
    EditButtonClick(self);
  end;
end;

procedure TForm1.RemoveWeekFromList(Sender: TObject; Index: integer);
begin
  if (Index >= 0) and (Index < FWeekList.Count) then
  begin
    FWeekList.Delete(Index);
  end;
  updateWindow;
end;

procedure TForm1.MenuAbout(Sender: TObject);
begin
  AboutForm.Visible := True;
end;

procedure TForm1.MenuItem19Click(Sender: TObject);
var
  colorDlg: TColorDialog;
begin
  colorDlg := TColorDialog.Create(nil);
  try
    colorDlg.Color := Toolbar1.Color;
    if colorDlg.Execute then
    begin
      Toolbar1.Color := colorDlg.Color;
      EditWeekForm.ToolBar1.Color := colorDlg.Color;
    end;
  finally
    colorDlg.Free;
  end;
end;

procedure TForm1.MenuLoadClick(Sender: TObject);
var
  OpenDlg: TOpenDialog;
begin
  OpenDlg := TOpenDialog.Create(self);
  OpenDlg.Title := 'Open file';
  try
    OpenDlg.InitialDir := '../data/';
    OpenDlg.DoFolderChange;
    if OpenDlg.Execute then
    begin
      loadFromFile(OpenDlg.FileName, FWeekList);
    end;
    StatusBar1.Panels[0].Text := '"' + ExtractFileName(OpenDlg.FileName) + '" loaded!';
  finally
    OpenDlg.Free;
    updateWindow;
  end;
end;

procedure TForm1.MenuSaveClick(Sender: TObject);
var
  SaveDlg: TSaveDialog;
begin
  SaveDlg := TSaveDialog.Create(self);
  SaveDlg.InitialDir := '../data/';         // surprisingly works on Windows too
  SaveDlg.DoFolderChange;
  SaveDlg.FileName := 'test user.sav';
  SaveDlg.Options := [ofOverwritePrompt];
  SaveDlg.Title := 'Save as';
  try
    if SaveDlg.Execute then
    begin
      SaveToFile(SaveDlg.FileName, FWeekList);
      StatusBar1.Panels[0].Text := txtFileSaved;
    end;
  finally
    SaveDlg.Free;
  end;
end;

procedure TForm1.MenuQuit(Sender: TObject);
begin
  if (MessageDlg(txtQuitProgramme, txtQuitMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    Application.Terminate;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if (MessageDlg(txtQuitProgramme, txtQuitMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    CanClose := True;
  end
  else
  begin
    CanClose := False;
  end;
end;


procedure TForm1.UpdateWindow;
var
  I: integer;
  d: integer;
  sum: double;
  goal: double;
  diff: double;
  earliestHour, earliestMin: integer;
  latestHour, latestMin: integer;
  earlyDate, lateDate: TDate;
begin
  sum := 0;
  goal := 0;
  diff := 0;

  // Statistics on the right
  for I := 0 to FWeekList.Count - 1 do
  begin
    sum := sum + FWeekList.Items[I].getSum;
    goal := goal + (FWeekList.Items[I].IntendedTimePerDay * FWeekList.Items[I].Days.Count);

    // earliest begin and latest leave
    for d := 0 to FWeekList.Items[I].Days.Count - 1 do
    begin
      if (FWeekList.Items[I].Days[d].TimeOff < FWeekList.Items[I].IntendedTimePerDay) then
      begin
        if (I > 0) then
        begin
          if (isTimeEarliest(FWeekList.Items[I].Days[d].StartHour, FWeekList.Items[I].Days[d].StartMinute,
            earliestHour, earliestMin)) then
          begin
            earliestHour := FWeekList.Items[I].Days.Items[d].StartHour;
            earliestMin := FWeekList.Items[I].Days.Items[d].StartMinute;
            earlyDate := FWeekList.Items[I].Days[d].Date;
          end;
          if (isTimeLatest(FWeekList.Items[I].Days[d].EndHour, FWeekList.Items[I].Days[d].EndMinute,
            latestHour, latestMin)) then
          begin
            latestHour := FWeekList.Items[I].Days.Items[d].EndHour;
            latestMin := FWeekList.Items[I].Days.Items[d].EndMinute;
            lateDate := FWeekList.Items[I].Days[d].Date;
          end;
        end
        else
        begin
          earliestHour := FWeekList.Items[0].Days.Items[0].StartHour;
          earliestMin := FWeekList.Items[0].Days.Items[0].StartMinute;
          latestHour := FWeekList.Items[0].Days.Items[0].StartHour;
          latestMin := FWeekList.Items[0].Days.Items[0].StartMinute;
        end;
      end;
    end;
  end;
  diff := sum - goal;
  if (FWeekList.Count > 0) then
  begin
    WeeksToStringGrid(StringGrid1, FWeekList, FSelectionIndex);
  end;

  colorText(Label3, sum, goal, 0.5);
  Label1.Caption := 'Sum: ' + FormatFloat('0.00', sum) + ' h';
  Label2.Caption := 'Goal: ' + FormatFloat('0.00', goal) + ' h';
  Label3.Caption := 'Diff.: ' + FormatFloat('0.00', diff) + ' h';

  if (earlyDate <> 0) then
  begin
    Label4.Caption := 'Earliest begin: ' + TimeToText(earliestHour, earliestMin) + '   ( on ' +
      FormatDateTime('dd.mm.yyyy', earlyDate) + ' )';
    Label5.Caption := 'Latest quitting: ' + TimeToText(latestHour, latestMin) + '   ( on ' +
      FormatDateTime('dd.mm.yyyy', lateDate) + ' )';
  end;
  EnableButtons;

end;

procedure TForm1.EnableButtons;
begin
  if (FWeekList.Count > 0) then
  begin
    Toolbar1.Buttons[1].Enabled := True;
    Toolbar1.Buttons[2].Enabled := True;
    ToolButton1.Enabled := True;
    RemoveWeekButton.Enabled := True;
    EditWeekButton.Enabled := True;
  end
  else
  begin
    Toolbar1.Buttons[1].Enabled := False;
    Toolbar1.Buttons[2].Enabled := False;
    ToolButton1.Enabled := False;
    EditWeekButton.Enabled := False;
    RemoveWeekButton.Enabled := False;
    EditWeekButton.Enabled := False;
  end;
end;

end.
