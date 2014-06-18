{
 This Unit shall contain default values for strings, constant values etc.
}

unit CoyoteDefaults;

interface

ResourceString

  // Programme-Information
  ProgrammeName = 'CoYOT(e)';     // Official Name shown to the user
  VersionNr = '0.0.5.3';          // Programme-Version
  VersionDate = '18.06.2014';     // Date of the latest changes
  LazarusVersion = '1.2.2';       // Version of the Lazarus IDE the programme was created with

  // Messages / Errors
  txtDeleteAllMsg = 'Do you really wish to delete every entry? All data will be lost if you do not make a copy!';
  txtDeleteMsg = 'Are you sure you want to delete this period including all days related to it? This cannot be made undone afterwards!';
  txtRemoveMsg = 'Do you really want to delete the selected day? This will delete all data related to it!';
  txtClearMsg = 'This will clear the current week and make it empty but will NOT delete the week! Do you wish to Continue?';
  txtQuitMsg = 'You did not save your changes yet! Do you really want to quit?';

  txtCaptionDelete = 'Really delete?';
  txtQuitProgramme = 'Quit Programme';
  txtFileSaved = 'File saved...';

  emDateOrder = 'Error: The dates are in the wrong order!';
  emHoursPerDay = 'Error: Enter a valid amount of time per day!';
  emInvalidFileFormat = 'The file could not be loaded, because it is not a valid CoYOT(e) file!';
  emFileNotFound = 'Error: The selected file could not be found!';
  emMergeNoWeekSelected = 'Cannot merge, because no week to merge with has been selected! Please select one using the combobox!' ;
  emMergeSameWeek = 'Cannot merge a week with itself! Please select a different week via the combobox!';

  dbDefaultFirebirdUser = 'SYSDBA';
  dbDefaultFirebirdPort = ''; // 3050

  // constants
  const
  txtWeekDays: array[1..7] of string = ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun');
  defToolbarColor = $00E0E0E0; // $00FFDBB7;

implementation



end.
