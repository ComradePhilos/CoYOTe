{
 This Unit shall contain default values for strings etc.
}

unit CoyoteDefaults;

interface

ResourceString
  txtDeleteAllMsg = 'Do you really wish to delete every entry? All data will be lost if you do not make a copy!';
  txtDeleteMsg = 'Are you sure you want to delete this period including all days related to it? This cannot be made undone afterwards!';
  txtRemoveMsg = 'Do you really want to delete the selected day? This will delete all data related to it!';
  txtClearMsg = 'This will clear the current week and make it empty but will NOT delete the week! Do you wish to Continue?';
  txtQuitMsg = 'Do you really want to quit? (Be sure you saved your changes!)';

  txtCaptionDelete = 'Really delete?';
  txtQuitProgramme = 'Quit Programme';

  emDateOrder = 'Error: The dates are in the wrong order!';
  emHoursPerDay = 'Error: Enter a valid amount of time per day!';

  const
  txtWeekDays: array[1..7] of string = ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun');

implementation



end.
