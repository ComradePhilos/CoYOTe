{
 This Unit shall contain default values for strings, constant values etc.
}

unit CoyoteDefaults;

interface

uses INIFiles;

procedure CreateLanguageFile(AFilePath: String);

procedure LoadFromLanguageFile(AFilePath: String);


var

  // Programme-Information
  ProgrammeName: String = 'CoYOT(e)';     // Official Name shown to the user
  VersionNr: String = '0.0.5.6';          // Programme-Version
  VersionDate: String = '23.06.2014';     // Date of the latest changes
  LazarusVersion: String = '1.2.2';       // Version of the Lazarus IDE the programme was created with
  defLanguage: String = 'English';        // not sure what we will need in future
  defLanguageShort: String = 'en';

  // Messages / Errors
  txtDeleteAllMsg: String = 'Do you really wish to delete every entry? All data will be lost if you do not make a copy!';
  txtDeleteMsg: String = 'Are you sure you want to delete this period including all days related to it? This cannot be made undone afterwards!';
  txtRemoveMsg: String = 'Do you really want to delete the selected day? This will delete all data related to it!';
  txtClearMsg: String = 'This will clear the current week and make it empty but will NOT delete the week! Do you wish to Continue?';
  txtQuitMsg: String = 'You did not save your changes yet! Do you really want to quit?';

  txtCaptionDelete: String = 'Really delete?';
  txtQuitProgramme: String = 'Quit Programme';
  txtFileSaved: String = 'File saved...';
  txtNewFile: String = 'Created new file...';

  emDateOrder: String = 'Error: The dates are in the wrong order!';
  emHoursPerDay: String = 'Error: Enter a valid amount of time per day!';
  emInvalidFileFormat: String = 'The file could not be loaded, because it is not a valid CoYOT(e) file!';
  emFileNotFound: String = 'Error: The selected file could not be found!';
  emMergeNoWeekSelected: String = 'Cannot merge, because no week to merge with has been selected! Please select one using the combobox!' ;
  emMergeSameWeek: String = 'Cannot merge a week with itself! Please select a different week via the combobox!';

  dbDefaultFirebirdUser: String = 'SYSDBA';
  dbDefaultFirebirdPort: String = ''; // 3050

  // default long day names
  txtMonday: String = 'Monday';
  txtTuesday: String = 'Tuesday';
  txtWednesday: String = 'Wednesday';
  txtThursday: String = 'Thursday';
  txtFriday: String = 'Friday';
  txtSaturday: String = 'Saturday';
  txtSunday: String = 'Sunday';

  // menu Captions
  mcFile: String = 'File';
  mcEdit: String = 'Edit';
  mcShow: String = 'Show';
  mcDataBase: String = 'Database';
  mcOptions: String = 'Options';
  mcHelp: String = 'Help';

  mcNew: String = 'New';
  mcSaveAs: String = 'Save as';
  mcSave: String = 'Save';
  mcOpen: String = 'Open';
  mcOpenRecent: String = 'Open Recent';

  defToolbarColor: Integer= $00E0E0E0; // $00FFDBB7;

      // default short day names
  txtMon: String = 'Mon';
  txtTue: String = 'Tue';
  txtWed: String = 'Wed';
  txtThu: String = 'Thu';
  txtFri: String = 'Fri';
  txtSat: String = 'Sat';
  txtSun: String = 'Sun';

    txtWeekDays: array[1..7] of string = ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun');
    // Standard Values - will be used, if nothing was found in the ini-file
    defHoursUntilPause: double = 6;  // Amount of time before the obligatory pause is needed / added
    defPausePerDay: double = 0.75;
    defHoursPerDay: double = 8;      // Standard Value

implementation

procedure CreateLanguageFile(AFilePath: String);
begin

end;


procedure LoadFromLanguageFile(AFilePath: String);
var
  INI: TInifile;
begin
  INI := TINIFile.Create(AFilePath);

  txtMon := INI.ReadString('CoyoteDefaults', 'txtMon', '');
  txtTue := INI.ReadString('CoyoteDefaults', 'txtTue', '');
  txtWed := INI.ReadString('CoyoteDefaults', 'txtWed', '');
  txtThu := INI.ReadString('CoyoteDefaults', 'txtThu', '');
  txtFri := INI.ReadString('CoyoteDefaults', 'txtFri', '');
  txtSat := INI.ReadString('CoyoteDefaults', 'txtSat', '');
  txtSun := INI.ReadString('CoyoteDefaults', 'txtSun', '');

  txtWeekDays[1] := txtMon;
  txtWeekDays[2] := txtTue;
  txtWeekDays[3] := txtWed;
  txtWeekDays[4] := txtThu;
  txtWeekDays[5] := txtFri;
  txtWeekDays[6] := txtSat;
  txtWeekDays[7] := txtSun;

  txtQuitMsg := INI.ReadString('CoyoteDefaults', 'txtQuitMsg', txtQuitMsg);
  txtQuitProgramme := INI.ReadString('CoyoteDefaults', 'txtQuitProgramme', txtQuitProgramme);

  mcFile := INI.ReadString('MenuCaption', 'mcFile', mcFile);
  mcEdit := INI.ReadString('MenuCaption', 'mcEdit', mcEdit);
  mcShow := INI.ReadString('MenuCaption', 'mcShow', mcShow);
  mcDataBase := INI.ReadString('MenuCaption', 'mcDataBase', mcDataBase);
  mcOptions := INI.ReadString('MenuCaption', 'mcOptions', mcOptions);
  mcHelp := INI.ReadString('MenuCaption', 'mcHelp', mcHelp);
end;

//initialization
  //LRSTranslator := TPoTranslator.Create('languages/CoYOTe-win64(x86_64).de.po');



end.
