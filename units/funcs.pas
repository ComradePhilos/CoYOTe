unit funcs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Translations;

{
  This will Replace all Texts of one language with Text of the choosen Language
  -> Needs more work on that!!!
}
function changeLanguage(ALanguage: string; ALazarusVersion: string;
  AOSName: string): TStringList;

{
  The Real Day of the Week. Starting with 1 for Monday instead of Sunday
  I had to do this, because the original "DayOfWeek" returns a "1" for "Sunday"
  and "2" for Monday etc....
}
function RealDayOfWeek(ADate: TDate): integer;

// Gets You the hour part of a clock time like 19:00 as an Integer -> 19
function getHour(time: string): integer;
// Gets You the minute part of a clock time like 19:15 as an Integer -> 15
function getMinute(time: string): integer;

// Searches in a language-file for the translation by looking for the name in the file
function searchForTranslation(VariableName: String; ALanguage: String): String;


implementation

function changeLanguage(ALanguage: string; ALazarusVersion: string;
  AOSName: string): TStringList;
var
  words: TStringList;
begin

  // There is a better way - look at the file in folder "language"
  words := TStringList.Create;
  //words.loadFromFile('data\languages\'+ ALanguage +'.txt');
  Result := words;
  words.Free;

  // translate also Buttons on Dialog-Forms
  if (ALanguage = 'German') then
  begin
    if (AOSName = 'Linux') then
      TranslateUnitResourceStrings('LCLStrConsts',
        '/usr/share/lazarus/' + ALazarusVersion + '/lcl/languages/lclstrconsts.de.po');
    if (AOSName = 'Windows') then
      TranslateUnitResourceStrings('LCLStrConsts',
        'C:\lazarus\lcl\languages\lclstrconsts.de.po');
  end;

end;

function RealDayOfWeek(ADate: TDate): integer;
var
  day: integer;
begin
  day := DayOfWeek(ADate);

  if (day = 1) then
  begin
    day := 7;
  end
  else
  begin
    day := day - 1;
  end;

  Result := day;
end;

function getHour(time: string): integer;
var
  I: integer;
  pos: integer;
  res: integer;
begin
  time := trim(time);

  for I := 1 to length(time) do
  begin
    if (time[I] = ':') then
    begin
      pos := I;
    end;
  end;

  time := trim(LeftStr(time, pos - 1));

  if TryStrToInt(time, res) then
  begin
    Result := res;
  end
  else
  begin
    Result := 0;
  end;

end;

function getMinute(time: string): integer;
var
  I: integer;
  pos: integer;
  res: integer;
begin
  time := trim(time);

  for I := 1 to length(time) do
  begin
    if (time[I] = ':') then
    begin
      pos := I;
    end;
  end;

  time := trim(RightStr(time, length(time) - pos));

  if TryStrToInt(time, res) then
  begin
    Result := res;
  end
  else
  begin
    Result := 0;
  end;
end;

function searchForTranslation(VariableName: String; ALanguage: String): String;
begin

  Result := '';
end;

end.
