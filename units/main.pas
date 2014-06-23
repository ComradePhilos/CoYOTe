{
*************************************************************************
  CoYOT(e) - the simple and lightweight time tracking tool              *
  Copyright (C) 2014  Philip Märksch and the CoYOT(e)-team              *
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
sorry for any German in the code, I may have mixed it up sometimes ;) - Philos
}

// Todo:
// * Work on Personnel Management
// * database commit and download
// * functions for getEarliestBegin, getLatestLeave, getLongestDay, AverageWorkingtime etc -> funcs.pas or workdays.pas
// * save all people and lists in one file
// * use Formatsettings for the save and load function
// * save Position + Size of Settings Form to ini file

// # database support will be improved/continued when the main functionality is working and the concept is finished
//    ( e.g. ability to compare multiple people/years/files whatever.. )
// # the obligatory pause time added to your whole work time applies at least after 6 hours of work in Germany,
//  so on a 6-hour day you need to have the pause. This topic needs to be kept in mind for calculation
// # think about a new CSV-like file format that supports multiple persons/files that could be loaded/compared
//    OR think about saving in whole directory, like DataNorm
// # we might end up not using one WeekList, but a list of WeekLists for each person our system should track time for
// # we should support some kind of anonymous methods, that calculate the time etc... So the classes in workdays.pas
//  get a little more abstract and will get the methods to calculate dynamically, like dependency injection. This could
//  help to support other common practice in other countries. Right now you would have to change code in many units.

unit main;

{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, FileUtil, RTTIGrids, RTTICtrls, Forms, Controls, Dialogs,
  ComCtrls, DBCtrls, EditBtn, Grids, Menus, StdCtrls, ExtCtrls, Buttons, ActnList,
  IBConnection, DateUtils, INIFiles, TypInfo,
  { Forms }
  WeekEditForm, WeekAddForm, about, DBConnectForm, PersonEditForm, SettingsForm,
  { own Units }
  workdays, funcs, CoyoteDefaults;

type

  { TForm1 }

  TForm1 = class(TForm)
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    IBConnection1: TIBConnection;
    ImageList1: TImageList;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuDBSettings: TMenuItem;
		MenuItem10: TMenuItem;
		MenuItem12: TMenuItem;
		MenuNew: TMenuItem;
    MenuMove: TMenuItem;
    MenuMoveTop: TMenuItem;
    MenuMoveUp: TMenuItem;
    MenuMoveDown: TMenuItem;
    MenuMoveBottom: TMenuItem;
    MenuSort: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    PopupAddPeriod: TMenuItem;
    PopupEditPeriod: TMenuItem;
    PopupRemovePeriod: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem8: TMenuItem;
    MenuOpenRecent: TMenuItem;
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
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuPeople: TMenuItem;
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
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormDestroy(Sender: TObject);
    procedure MenuAboutClick(Sender: TObject);
    procedure ColorThemeClick(Sender: TObject);
    procedure MenuDatabaseClick(Sender: TObject);
		procedure MenuItem10Click(Sender: TObject);
    procedure MenuLoadClick(Sender: TObject);
		procedure MenuNewClick(Sender: TObject);
    procedure MenuPeopleClick(Sender: TObject);
    procedure MenuQuickSaveClick(Sender: TObject);
    procedure MenuSaveClick(Sender: TObject);
		procedure MenuSettingsClick(Sender: TObject);
    procedure RemoveSelected(Sender: TObject);
    procedure RemoveAll(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuQuitClick(Sender: TObject);
    procedure MoveClick(Sender: TObject);
    procedure SelectWeek(Sender: TObject; aCol, aRow: integer; var CanSelect: boolean);

  private
    { private declarations }
    FWeekList: TWeekList;         // List of Weeks shown in the StringGrid
    FSelectionIndex: integer;     // Index of the Week that was selected in the grid
    FPersonSelected: integer;     // Index of the person selected - maybe change to string?

    FOSName: string;              // The Internal Name for the used Operating System
    FLanguage: string;            // Language chosen by User - default is English

    AboutForm: TForm2;            // The Window showing information about CoYOT(e)
    EditWeekForm: TForm3;         // The window that you can edit a week with
    AddWeekForm: TForm4;          // A window to add a new week to the "data base"
    DBForm: TForm6;               // The window to connect to the firebird database
    PersonForm: TForm5;
    FormSettings: TForm7;

    //FCurrentUser: Integer;      // ID of the currently selected "User"/Person
    FCurrentFilePath: string;     // If known - Name of the currently opened File
    FOpenRecent: TStringList;     // The files that have been opened lately - will be in ini file
    FCanSave: boolean;            // True, if changes have been made to the file

    // triggered when a week is added
    procedure AddWeekToList(Sender: TObject; AWeek: TWorkWeek; EditAfterwards: boolean);

    // triggered when a week got edited
    procedure AssignWeek(Sender: TObject; AWeek: TWorkWeek; Index: integer);

    // triggered when a Form wants a specific week
    procedure GetWeek(Sender: TObject; Index: integer);

    // triggered when a certain week is deleted
    procedure RemoveWeekFromList(Sender: TObject; AIndex: integer);

    // Merges two weeks and by default deletes the second one afterwards
    procedure MergeWeeks(Sender: TObject; AIndex1, AIndex2: integer; DeleteFirst: boolean = False);

    // Checks for each button, wether it has to get enabled or disabled
    procedure EnableButtons;

    // Updates the Information shown
    procedure UpdateWindow;

    // Clears all values like filename etc..
    procedure Clear;

    // Load the values from ini file
    procedure LoadIniFile;
    procedure SaveIniFile;

    // apply a color to the theme
    procedure ApplyColor(AColor: integer);

    // adds a filename to the recent files-list and adds it to the mainmenu
    procedure AddToOpenRecent(AFilePath: string; AList: TStringList; AMenuItem: TMenuItem);
    procedure OpenRecentCLick(Sender: TObject);  // dynamic onClick-Event for Recent Files

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
  FOSName := 'Linux';    // for those poor guys, who need to compensate the huge brain and the monstrous penis ;)
  {$ENDIF}

  self.Caption := ProgrammeName + '  ' + VersionNr;
  FLanguage := 'English';

  // default values
  FSelectionIndex := -1;
  FCurrentFilePath := '';
  FCanSave := False;

  // Create Instances
  FWeekList := TWeekList.Create;
  FOpenRecent := TStringList.Create;

  // Sub-Forms
  AboutForm := TForm2.Create(nil);
  EditWeekForm := TForm3.Create(nil);
  AddWeekForm := TForm4.Create(nil);
  DBForm := TForm6.Create(nil);
  PersonForm := TForm5.Create(nil);
  FormSettings := TForm7.Create(nil);

  AboutForm.Label1.Caption := 'Version: ' + VersionNr + ' ( ' + FOSName + ' )';
  AboutForm.Label2.Caption := 'Build Date: ' + VersionDate;

  // Event Handling
  AddWeekForm.OnApplyClick := @AddWeekToList;           // assign event of the add-form
  EditWeekForm.OnRemoveClick := @RemoveWeekFromList;    // assign event for deletion
  EditWeekForm.OnApplyClick := @AssignWeek;             // assign event for applying changes to week
  EditWeekForm.OnNextWeekClick := @GetWeek;             // switch to specified week via Index
  EditWeekForm.OnMergeWeeksClick := @MergeWeeks;        // assign the merge event of the EditWeekForm to merge function

  LoadIniFile;
  updateWindow;

  // Constraints
  self.Constraints.MinWidth := Groupbox1.Width;
  self.Constraints.MinHeight := round(Groupbox1.Width / 2);

end;

procedure TForm1.Clear;
begin
  FSelectionIndex := -1;
  FCurrentFilePath := '';
  FCanSave := False;
  FWeekList.Clear;
  StringGrid1.Clear;
  updateWindow;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  AboutForm.Free;
  EditWeekForm.Free;
  AddWeekForm.Free;
  PersonForm.Free;
  FormSettings.Free;
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
end;

procedure TForm1.MergeWeeks(Sender: TObject; AIndex1, AIndex2: integer; DeleteFirst: boolean = False);
var
  I: integer;
begin
  if DeleteFirst then
  begin
    swap(AIndex1, AIndex2);
  end;
  for I := 0 to FWeekList.Items[AIndex2].Days.Count - 1 do
  begin
    // calling the copy-constructor
    FWeekList.Items[AIndex1].Days.Add(FWeekList.Items[AIndex2].Days[I]);
    FWeekList.Items[AIndex1].WeekLength := FWeekList.Items[AIndex1].WeekLength + 1;
  end;
  FWeekList.Delete(AIndex2);
  FCanSave := True;
  updateWindow;
end;

procedure TForm1.AssignWeek(Sender: TObject; AWeek: TWorkWeek; Index: integer);
begin
  FWeekList.Items[Index].Assign(AWeek);
  WeeksToComboBox(EditWeekForm.ComboBox1, FweekList);
  WeeksToComboBox(EditWeekForm.ComboBox2, FweekList);
  EditWeekForm.ComboBox1.ItemIndex := EditWeekForm.WeekIndex;
  FCanSave := True;
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
    WeeksToComboBox(EditWeekForm.ComboBox2, FweekList);
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
    EditWeekForm.ComboBox2.ItemIndex := 0;
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
      FCanSave := True;
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
      FCanSave := True;
    end;
  end;
end;

procedure TForm1.AddWeekToList(Sender: TObject; AWeek: TWorkWeek; EditAfterwards: boolean);
begin
  FWeekList.Add(AWeek);
  updateWindow;
  FCanSave := True;
  EnableButtons;
  if EditAfterwards then
  begin
    FSelectionIndex := FWeekList.Count - 1;
    EditButtonClick(self);
  end;
end;

procedure TForm1.RemoveWeekFromList(Sender: TObject; AIndex: integer);
begin
  if (AIndex >= 0) and (AIndex < FWeekList.Count) then
  begin
    FWeekList.Delete(AIndex);
    updateWindow;
    FCanSave := True;
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
      ApplyColor(colorDlg.Color);
    end;
  finally
    colorDlg.Free;
  end;
end;

procedure TForm1.MenuDatabaseClick(Sender: TObject);
begin
  DBForm.Show;
end;

procedure TForm1.MenuItem10Click(Sender: TObject);
var
  locForm: TForm;
  locEdit: TEdit;
  locButton: TButton;
begin
  locForm := TForm.Create(self);
  locForm.Position := poMainFormCenter;
  locForm.Show;
  locForm.Caption:= 'Enter Index';

  locEdit := TEdit.Create(locForm);
  locEdit.Parent := locForm;
  locEdit.Width := 100;
  locEdit.Height := 30;
  locEdit.Left := 2;
  locEdit.Top := 2;
  locEdit.Anchors := [akLeft, akTop];
  locEdit.Show;

  locForm.Width:=200;
  locForm.Height:=LocEdit.Height + 4;
  locForm.Constraints.MinWidth:=locForm.Width;
  locForm.Constraints.maxWidth:=locForm.Width;
  locForm.Constraints.MinHeight:=locForm.Height;
  locForm.Constraints.maxHeight:=locForm.Height;

  locButton := TButton.Create(locForm);
  locButton.Parent := locForm;
  locButton.Left := 102;
  locButton.Top := 2;
  locbutton.Width := locEdit.Width-4;
  locButton.Height := locEdit.Height;
  locButton.Anchors := [akLeft, akTop];
  locButton.Caption := 'insert';


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
      if loadFromFile(OpenDlg.FileName, FWeekList) then
      begin
        StatusBar1.Panels[0].Text := '"' + ExtractFileName(OpenDlg.FileName) + '" loaded!';
        FCurrentFilePath := OpenDlg.FileName;
        AddToOpenRecent(FCurrentFilePath, FOpenRecent, MenuOpenRecent);
      end
      else
      begin
        StatusBar1.Panels[0].Text := '"' + ExtractFileName(OpenDlg.FileName) + '" could not be loaded!';
        FCurrentFilePath := '';
      end;
    end;
  finally
    OpenDlg.Free;
    FCanSave := False;
    updateWindow;
  end;
end;

procedure TForm1.MenuNewClick(Sender: TObject);
begin
  Clear;
  Statusbar1.Panels[0].Text := txtNewFile;
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
    AddToOpenRecent(FCurrentFilePath, FOpenRecent, MenuOpenRecent);
    StatusBar1.Panels[0].Text := txtFileSaved;
    FCanSave := False;
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
      AddToOpenRecent(SaveDlg.FileName, FOpenRecent, MenuOpenRecent);
      StatusBar1.Panels[0].Text := txtFileSaved;
      FCurrentFilePath := SaveDlg.FileName;
    end;
  finally
    SaveDlg.Free;
    FCanSave := False;
    EnableButtons;
  end;
end;

procedure TForm1.MenuSettingsClick(Sender: TObject);
var
  fs: TFormatSettings;
begin
  //fs.DecimalSeparator := ';
  FormSettings.Visible := True;
  FormSettings.StringGrid1.Cells[1,1] := FloatToStr(defHoursPerDay);
  FormSettings.StringGrid1.Cells[1,2] := FloatToStr(defPausePerDay);
  FormSettings.StringGrid1.Cells[1,3] := FloatToStr(defHoursUntilPause);
end;

procedure TForm1.MenuQuitClick(Sender: TObject);
begin
  if FCanSave then
  begin
    if (MessageDlg(txtQuitProgramme, txtQuitMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      Application.Terminate;
      SaveIniFile;
    end;
  end
  else
  begin
    Application.Terminate;
    SaveIniFile;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if FCanSave then
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

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveIniFile;
end;

procedure TForm1.SaveIniFile;
var
  INI: TINIFile;
  I: integer;
  fs: TFormatSettings;
begin
  fs.DecimalSeparator := '.';
  // Write INI-File
  INI := TINIFile.Create('coyote.ini');
  INI.UpdateFile;
  INI.WriteString('MainForm', 'xpos', IntToStr(self.Left));
  INI.WriteString('MainForm', 'ypos', IntToStr(self.Top));
  INI.WriteString('MainForm', 'width', IntToStr(self.Width));
  INI.WriteString('MainForm', 'height', IntToStr(self.Height));
  INI.WriteString('MainForm', 'state', GetEnumName(TypeInfo(TWindowState), integer(self.WindowState)));

  INI.WriteString('EditWeekForm', 'xpos', IntToStr(EditWeekForm.Left));
  INI.WriteString('EditWeekForm', 'ypos', IntToStr(EditWeekForm.Top));
  INI.WriteString('EditWeekForm', 'width', IntToStr(EditWeekForm.Width));
  INI.WriteString('EditWeekForm', 'height', IntToStr(EditWeekForm.Height));
  INI.WriteString('EditWeekForm', 'state', GetEnumName(TypeInfo(TWindowState), integer(EditWeekForm.WindowState)));

  INI.WriteString('DBInfo', 'hostname', DBForm.LabeledEdit1.Text);
  INI.WriteString('DBInfo', 'port', DBForm.LabeledEdit2.Text);
  INI.WriteString('DBInfo', 'dbname', DBForm.LabeledEdit5.Text);
  INI.WriteString('DBInfo', 'user', DBForm.LabeledEdit3.Text);

  INI.WriteString('SettingsForm','xpos', IntToStr(FormSettings.Left));
  INI.WriteString('SettingsForm','ypos', IntToStr(FormSettings.Top));
  INI.WriteString('SettingsForm','width', IntToStr(FormSettings.Width));
  INI.WriteString('SettingsForm','height', IntToStr(FormSettings.Height));

  INI.WriteString('Defaults', 'HoursUntilPause', FloatToStr(defHoursUntilPause,fs));
  INI.WriteString('Defaults', 'HoursPerDay', FloatToStr(defHoursPerDay,fs));
  INI.WriteString('Defaults', 'PausePerDay', FloatToStr(defPausePerDay,fs));

  // Recent Files
  INI.WriteString('RecentFiles', 'count', IntToStr(FOpenRecent.Count));
  for I := 0 to FOpenRecent.Count - 1 do
  begin
    INI.WriteString('RecentFiles', IntToStr(I), FOpenRecent[I]);
  end;

  // grid column sizes
  for I := 0 to EditWeekForm.WeekGrid.ColCount - 1 do
  begin
    INI.WriteString('EditWeekForm', 'col' + IntToStr(I + 1), IntToStr(EditWeekForm.WeekGrid.Columns.Items[I].Width));
  end;
  for I := 0 to StringGrid1.ColCount - 1 do
  begin
    INI.WriteString('MainForm', 'col' + IntToStr(I + 1), IntToStr(StringGrid1.Columns.Items[I].Width));
  end;

  INI.WriteString('Theme', 'color', IntToStr(Toolbar1.Color));
end;

procedure TForm1.LoadIniFile;
var
  INI: TINIFile;
  s: string;
  I: integer;
  fs: TFormatSettings;
begin
  fs.DecimalSeparator := '.';
  INI := TINIFile.Create('coyote.ini');

  self.Left := StrToInt(INI.ReadString('MainForm', 'xpos', IntToStr(self.Left)));
  self.Top := StrToInt(INI.ReadString('MainForm', 'ypos', IntToStr(self.Top)));
  self.Width := StrToInt(INI.ReadString('MainForm', 'width', IntToStr(self.Width)));
  self.Height := StrToInt(INI.ReadString('MainForm', 'height', IntToStr(self.Height)));
  s := INI.ReadString('MainForm', 'state', GetEnumName(TypeInfo(TWindowState), integer(wsNormal)));
  self.WindowState := TWindowState(GetEnumValue(TypeInfo(TWindowState), s));

  EditWeekForm.Left := StrToInt(INI.ReadString('EditWeekForm', 'xpos', IntToStr(self.Left)));
  EditWeekForm.Top := StrToInt(INI.ReadString('EditWeekForm', 'ypos', IntToStr(self.Top)));
  EditWeekForm.Width := StrToInt(INI.ReadString('EditWeekForm', 'width', IntToStr(self.Width)));
  EditWeekForm.Height := StrToInt(INI.ReadString('EditWeekForm', 'height', IntToStr(self.Height)));
  s := INI.ReadString('EditWeekForm', 'state', GetEnumName(TypeInfo(TWindowState), integer(wsNormal)));
  EditWeekForm.WindowState := TWindowState(GetEnumValue(TypeInfo(TWindowState), s));

  DBForm.LabeledEdit1.Text := INI.ReadString('DBInfo', 'hostname', '');
  DBForm.LabeledEdit2.Text := INI.ReadString('DBInfo', 'port', dbDefaultFirebirdPort);
  DBForm.LabeledEdit5.Text := INI.ReadString('DBInfo', 'dbname', '');
  DBForm.LabeledEdit3.Text := INI.ReadString('DBInfo', 'user', dbDefaultFirebirdUser);

  defHoursUntilPause := StrToFloat(INI.ReadString('Defaults', 'HoursUntilPause', FloatToStr(defHoursUntilPause,fs)),fs);
  defHoursPerDay := StrToFloat(INI.ReadString('Defaults', 'HoursPerDay', FloatToStr(defHoursPerDay,fs)),fs);
  defPausePerDay := StrToFloat(INI.ReadString('Defaults', 'PausePerDay', FloatToStr(defPausePerDay,fs)),fs);

  INI.WriteString('Defaults', 'HoursUntilPause', FloatToStr(defHoursUntilPause,fs));
  INI.WriteString('Defaults', 'HoursPerDay', FloatToStr(defHoursPerDay,fs));
  INI.WriteString('Defaults', 'PausePerDay', FloatToStr(defPausePerDay,fs));

  for I := 0 to StrToInt(INI.ReadString('RecentFiles', 'count', '0')) - 1 do
  begin
    AddToOpenRecent(INI.ReadString('RecentFiles', IntToStr(I), ''), FOpenRecent, MenuOpenRecent);
  end;
  for I := 0 to EditWeekForm.WeekGrid.ColCount - 1 do
  begin
    EditWeekForm.WeekGrid.Columns.Items[I].Width :=
      StrToInt(INI.ReadString('EditWeekForm', 'col' + IntToStr(I + 1),
      IntToStr(EditWeekForm.WeekGrid.Columns.Items[I].Width)));
  end;
  for I := 0 to StringGrid1.ColCount - 1 do
  begin
    StringGrid1.Columns.Items[I].Width :=
      StrToInt(INI.ReadString('MainForm', 'col' + IntToStr(I + 1), IntToStr(StringGrid1.Columns.Items[I].Width)));
  end;

  ApplyColor(StrToInt(INI.ReadString('Theme', 'color', IntToStr(defToolbarColor))));

end;

procedure TForm1.ApplyColor(AColor: integer);
begin
  Toolbar1.Color := AColor;
  EditWeekForm.ToolBar1.Color := AColor;
  PersonForm.Toolbar1.Color := AColor;
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
  end
  else
  begin
    Label4.Caption := '';//'Earliest begin:';
    Label5.Caption := '';//'Latest quitting:';
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

  MenuQuickSave.Enabled := FCanSave and (FCurrentFilePath <> '');
  ToolButton1.Enabled := FCanSave and (FCurrentFilePath <> '');
  MenuOpenRecent.Enabled := (MenuOpenRecent.Count > 0);
  MenuMove.Enabled := (FWeekList.Count > 1);

end;


procedure TForm1.AddToOpenRecent(AFilePath: string; AList: TStringList; AMenuItem: TMenuItem);
var
  I: integer;
  found: integer;
begin

  found := -1;

  if (AFilePath <> '') then
  begin
    // delete earlier entries and clear menuitem
    for I := 0 to AList.Count - 1 do
    begin
      if (AList[I] = AFilePath) then
        found := I;
    end;

    if (found >= 0) then
    begin
      AList.Delete(found);
    end;
    AList.Add(AFilePath);

    if (AList.Count > 10) then
    begin
      Alist.Delete(0);
    end;

    AMenuItem.Clear;
    for I := AList.Count - 1 downto 0 do
    begin
      AMenuItem.Add(TMenuItem.Create(nil));
      AMenuItem.Items[AList.Count - 1 - I].Caption := AList[I];
      AMenuItem.Items[AList.Count - 1 - I].OnClick := @OpenRecentCLick;
    end;
  end;
  UpdateWindow;
end;

procedure TForm1.OpenRecentCLick(Sender: TObject);
var
  filename: string;
begin
  filename := TMenuItem(Sender).Caption;

  try
    loadFromFile(filename, FWeekList);
    StatusBar1.Panels[0].Text := '"' + ExtractFileName(filename) + '" loaded!';
    FCurrentFilePath := filename;
    AddToOpenRecent(FCurrentFilePath, FOpenRecent, MenuOpenRecent);
    FCanSave := False;
  except
    on e: Exception do
    begin
      Application.MessageBox(PChar(emFileNotFound), 'File not found', 0);
      FOpenRecent.Delete(FOpenRecent.Count - 1 - MenuOpenRecent.IndexOf(TMenuItem(Sender)));
      MenuOpenRecent.Delete(MenuOpenRecent.IndexOf(TMenuItem(Sender)));
    end;
  end;

  UpdateWindow;
end;

procedure TForm1.MoveClick(Sender: TObject);
var
  tempIndex: Integer;
begin
  if (FWeekList.Count > 1) then
  begin
    tempIndex := FSelectionIndex;
    // Move Item to Top
    if (Sender = MenuMoveTop) then
    begin
      FWeekList.Insert(0,TWorkWeek.Create(FWeekList.Items[FSelectionIndex]));
      FWeekList.Delete(FSelectionIndex + 1);
      tempIndex := 0;
      FCanSave := True;
    end;

    // Move Item to Bottom
    if (Sender = MenuMoveBottom) then
    begin
      FWeekList.Insert(FWeekList.Count,TWorkWeek.Create(FWeekList.Items[FSelectionIndex]));
      FWeekList.Delete(FSelectionIndex);
      tempIndex := FWeekList.Count-1;
      FCanSave := True;
    end;

    // Move Item 1 step up
    if (Sender = MenuMoveUp) then
    begin
      if (FSelectionIndex >= 1) and (FSelectionIndex < FWeekList.Count) then
      begin
        FWeekList.Insert(FSelectionIndex-1, TWorkWeek.Create(FWeekList.Items[FSelectionIndex]));
        FWeekList.Delete(FSelectionIndex + 1);
        tempIndex -= 1;
        FCanSave := True;
      end;
    end;

    // Move Item 1 step down
    if (Sender = MenuMoveDown) then
    begin
      if (FSelectionIndex >= 0) and (FSelectionIndex < FWeekList.Count - 1) then
      begin
        FWeekList.Insert(FSelectionIndex+2, TWorkWeek.Create(FWeekList.Items[FSelectionIndex]));
        FWeekList.Delete(FSelectionIndex);
        tempIndex += 1;
        FCanSave := True;
      end;
    end;
    updateWindow;
    // Updating the EditweekForm
    EditWeekForm.showWeek(FWeekList.Items[tempIndex], tempIndex);
    EditWeekForm.WeekIndex := tempIndex;
    WeeksToCombobox(EditWeekForm.ComboBox1, FWeekList);
    WeeksToCombobox(EditWeekForm.ComboBox2, FWeekList);
    EditWeekForm.ComboBox1.ItemIndex := tempIndex;
    EditWeekForm.ComboBox2.ItemIndex := tempIndex;
  end;
end;

end.
