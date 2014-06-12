{
*************************************************************************
  CoYOT(e) - the simple and lightweight time tracking tool              *
  Copyright (C) <2014>  <Philip Märksch>                                *
                                                                        *
  This program is free software: you can redistribute it and/or modify  *
  it under the terms of the GNU General Public License as published by  *
  the Free Software Foundation, either version 3 of the License, or     *
  (at your option) any later version.                                   *
                                                                        *
  This program is distributed in the hope that it will be useful,       *
  but WITHOUT ANY WARRANTY; without even the implied warranty of        *
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
  GNU General Public License for more details.                          *
                                                                        *
  You should have received a copy of the GNU General Public License     *
  along with this program.  If not, see http://www.gnu.org/licenses/    *
                                                                        *
*************************************************************************
}

// Todo:
// * mergable weeks
// * switchable day order in weeks
// * Work on Personnel Management
// * Functionality to instantly open Thunderbird or other mail clients to write E-Mails to Persons
// * function to mark days as e.g. offical holidays
// * it might be that the firebird database support will be dropped in future. Or at least the whole
//    concept needs some more thinking 


unit main;

{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, FileUtil, RTTIGrids, RTTICtrls, Forms, Controls, Dialogs,
  ComCtrls, DBCtrls, EditBtn, Grids, Menus, StdCtrls, ExtCtrls, Buttons, ActnList,
  IBConnection, DateUtils,
  { Forms }
  WeekEditForm, WeekAddForm, about, DBConnectForm, PersonEditForm,
  { eigene Units }
  workdays, funcs, CoyoteDefaults;

type

  { TForm1 }

  TForm1 = class(TForm)
    ComboBox1: TComboBox;
    IBConnection1: TIBConnection;
    ImageList1: TImageList;
    GroupBox1: TGroupBox;
    ImageList2: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem5: TMenuItem;
		MenuItem6: TMenuItem;
		MenuItem7: TMenuItem;
    MenuSettings: TMenuItem;
    MenuItem11: TMenuItem;
    MenuEnglish: TMenuItem;
    MenuGerman: TMenuItem;
    MenuManual: TMenuItem;
    MenuSaveAs: TMenuItem;
    MenuLoad: TMenuItem;
    MenuQuickSave: TMenuItem;
    MenuColorTheme: TMenuItem;
    MenuItem2: TMenuItem;
    PopupAddPeriod: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuPeople: TMenuItem;
    PopupEditPeriod: TMenuItem;
    PopupRemovePeriod: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuQuit: TMenuItem;
    MenuAbout: TMenuItem;
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
    EditWeekButton: TToolButton;
    ToolButton4: TToolButton;

    procedure AddWeek(Sender: TObject);
    procedure EditButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormDestroy(Sender: TObject);
    procedure MenuAboutClick(Sender: TObject);
    procedure ColorThemeClick(Sender: TObject);
    procedure MenuDatabaseClick(Sender: TObject);
    procedure MenuLoadClick(Sender: TObject);
    procedure MenuPeopleClick(Sender: TObject);
    procedure MenuQuickSaveClick(Sender: TObject);
    procedure MenuSaveClick(Sender: TObject);
    procedure RemoveSelected(Sender: TObject);
    procedure RemoveAll(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuQuitClick(Sender: TObject);
    procedure SelectWeek(Sender: TObject; aCol, aRow: integer; var CanSelect: boolean);

  private
    { private declarations }
    defHoursPerDay: double;       // Standard Value
    defDaysPerWeek: integer;      // Standard Value
    FWeekList: TWeekList;         // List of Weeks shown in the StringGrid
    FSelectionIndex: integer;     // Index of the Week that was selected in the grid
    FChangesMade: boolean;

    FOSName: string;              // The Internal Name for the used Operating System
    FLanguage: string;            // Language chosen by User - default is English

    AboutForm: TForm2;            // The Window showing information about CoYOT(e)
    EditWeekForm: TForm3;         // The window that you can edit a week with
    AddWeekForm: TForm4;          // A window to add a new week to the "data base"
    DBForm: TForm6;               // The window to connect to the firebird database
    PersonForm: TForm5;

    // may become obsolete with the newest changes
    //FCurrentUser: Integer;        // ID of the currently selected "User"/Person
    FCurrentFilePath: string;     // If known - Name of the currently opened File

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

  self.Caption := ProgrammeName + '  ' + VersionNr;
  FLanguage := 'English';

  // default values
  defHoursPerDay := 8;
  defDaysPerWeek := 5;
  FSelectionIndex := -1;
  FCurrentFilePath := '';

  // Create Instances
  FWeekList := TWeekList.Create;

  AboutForm := TForm2.Create(nil);
  EditWeekForm := TForm3.Create(nil);
  AddWeekForm := TForm4.Create(nil);
  DBForm := TForm6.Create(nil);
  PersonForm := TForm5.Create(nil);

  // Event Handling
  AddWeekForm.OnApplyClick := @AddWeekToList;           // assign event of the add-form
  EditWeekForm.OnRemoveClick := @RemoveWeekFromList;    // assign event for deletion
  EditWeekForm.OnApplyClick := @AssignWeek;             // assign event for applying changes to week
  EditWeekForm.OnNextWeekClick := @GetWeek;             // switch to specified week via Index

  AboutForm.Label1.Caption := 'Version: ' + VersionNr + ' ( ' + FOSName + ' )';
  AboutForm.Label2.Caption := 'Build Date: ' + VersionDate;

  updateWindow;

  Toolbar1.Color := defToolbarColor;
  EditWeekForm.ToolBar1.Color := defToolbarColor;
  PersonForm.Toolbar1.Color := defToolbarColor;

  // Constraints
  self.Constraints.MinWidth := Groupbox1.Width;
  self.Constraints.MinHeight := round(Groupbox1.Width / 2);

  FChangesMade := False;

end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  AboutForm.Free;
  EditWeekForm.Free;
  AddWeekForm.Free;
  PersonForm.Free;
  DBForm.Free;
  FWeekList.Free;
end;

procedure TForm1.SelectWeek(Sender: TObject; aCol, aRow: integer; var CanSelect: boolean);
begin
  if (StringGrid1.RowCount > 1) and canSelect then
  begin
    FSelectionIndex := aRow - 1;
  end;
end;

procedure TForm1.AddWeek(Sender: TObject);
begin
  AddWeekForm.Visible := True;
  AddWeekForm.Show;
  FChangesMade := True;
end;

procedure TForm1.AssignWeek(Sender: TObject; AWeek: TWorkWeek; Index: integer);
begin
  FWeekList.Items[Index].Assign(AWeek);
  WeeksToComboBox(EditWeekForm.ComboBox1, FweekList);
  EditWeekForm.ComboBox1.ItemIndex := EditWeekForm.WeekIndex;
  FChangesMade := True;
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
    WeeksToComboBox(EditWeekForm.ComboBox1, FweekList);
    EditWeekForm.ComboBox1.ItemIndex := FSelectionIndex;
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
    EditWeekForm.ComboBox1.ItemIndex := EditWeekForm.WeekIndex;
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
      FChangesMade := True;
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
      FChangesMade := True;
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
    FChangesMade := True;
  end;
end;

procedure TForm1.RemoveWeekFromList(Sender: TObject; Index: integer);
begin
  if (Index >= 0) and (Index < FWeekList.Count) then
  begin
    FWeekList.Delete(Index);
    updateWindow;
    FChangesMade := True;
  end;

end;

procedure TForm1.MenuAboutClick(Sender: TObject);
begin
  AboutForm.Visible := True;
end;

procedure TForm1.ColorThemeClick(Sender: TObject);
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

procedure TForm1.MenuDatabaseClick(Sender: TObject);
begin
  DBForm.Show;
end;

procedure TForm1.MenuLoadClick(Sender: TObject);
var
  OpenDlg: TOpenDialog;
  //localCopy: TWeekList;
begin
  OpenDlg := TOpenDialog.Create(self);
  //localCopy := TWeekList.Create;
  //localCopy.Assign(FWeekList);
  OpenDlg.Title := 'Open file';
  try
    OpenDlg.InitialDir := '../data/';
    OpenDlg.DoFolderChange;
    if OpenDlg.Execute then
    begin
      if loadFromFile(OpenDlg.FileName, FWeekList) then
      begin
        StatusBar1.Panels[0].Text := '"' + ExtractFileName(OpenDlg.FileName) + '" loaded!';
        FCurrentFilePath := OpenDlg.FileName;
      end
      else
      begin
        StatusBar1.Panels[0].Text := '"' + ExtractFileName(OpenDlg.FileName) + '" could not be loaded!';
        FCurrentFilePath := '';
        //FWeekList.Assign(localCopy);
      end;
    end;
  finally
    OpenDlg.Free;
    //localCopy.Free;
    FChangesMade := False;
    updateWindow;
  end;
end;

procedure TForm1.MenuPeopleClick(Sender: TObject);
begin
  PersonForm.Show;
end;

procedure TForm1.MenuQuickSaveClick(Sender: TObject);
begin
  if (FCurrentFilePath <> '') then
  begin
    SaveToFile(FCurrentFilePath, FWeekList);
    StatusBar1.Panels[0].Text := txtFileSaved;
    FChangesMade := False;
    EnableButtons;
  end
  else
  begin
    MenuSaveClick(nil);
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
      FCurrentFilePath := SaveDlg.FileName;
    end;
  finally
    SaveDlg.Free;
    FChangesMade := False;
    EnableButtons;
  end;
end;

procedure TForm1.MenuQuitClick(Sender: TObject);
begin
  if FChangesMade then
  begin
    if (MessageDlg(txtQuitProgramme, txtQuitMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      Application.Terminate;
    end;
  end
  else
  begin
    Application.Terminate;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if FChangesMade then
  begin
    if (MessageDlg(txtQuitProgramme, txtQuitMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      CanClose := True;
    end
    else
    begin
      CanClose := False;
    end;
  end
  else
  begin
    CanClose := True;
  end;

end;

procedure TForm1.UpdateWindow;
var
  I: integer;
  d: integer;
  sum: double;
  goal: double;
  diff: double;
  vacationdays: double;
  earliestHour, earliestMin: integer;
  latestHour, latestMin: integer;
  earlyDate, lateDate: TDate;
begin
  sum := 0;
  goal := 0;
  diff := 0;
  vacationdays := 0;

  earliestMin := 0;
  earliestHour := 0;
  latestMin := 0;
  latestHour := 0;

  // Statistics on the right
  for I := 0 to FWeekList.Count - 1 do
  begin
    sum := sum + FWeekList.Items[I].getSum;
    //goal := goal + (FWeekList.Items[I].IntendedTimePerDay * FWeekList.Items[I].Days.Count);
    goal := goal + FWeekList.Items[I].getGoalHours;
    vacationdays := vacationdays + FWeekList.Items[I].getAmountOfVacation;

    // earliest begin and latest leave
    for d := 0 to FWeekList.Items[I].Days.Count - 1 do
    begin
      if (FWeekList.Items[I].Days[d].Tag = '') then
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
  Label6.Caption := 'Vacation taken: ' + FormatFloat('0.0', vacationdays) + ' days';

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
    EditWeekButton.Enabled := True;
    PopupEditPeriod.Enabled := True;
    PopupRemovePeriod.Enabled := True;
    MenuSaveAs.Enabled := True;
  end
  else
  begin
    Toolbar1.Buttons[1].Enabled := False;
    Toolbar1.Buttons[2].Enabled := False;
    ToolButton1.Enabled := False;
    EditWeekButton.Enabled := False;
    EditWeekButton.Enabled := False;
    PopupEditPeriod.Enabled := False;
    PopupRemovePeriod.Enabled := False;
    MenuSaveAs.Enabled := False;
  end;

  MenuQuickSave.Enabled := FChangesMade and (FCurrentFilePath <> '');
  ToolButton1.Enabled := FChangesMade and (FCurrentFilePath <> '');

end;

end.
