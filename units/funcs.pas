unit funcs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Translations;

{
  This will Replace all Texts of one language with Text of the choosen Language
  -> Needs more work on that!!!
}
function changeLanguage(ALanguage: String; ALazarusVersion: String; AOSName: String): TStringList;
{
  The Real Day of the Week. Starting with 1 for Monday instead of Sunday
  I had to do this, because the original "DayOfWeek" returns a "1" for "Sunday"
  and "2" for Monday etc....
}
function RealDayOfWeek(ADate: TDate): Integer;


implementation

function changeLanguage(ALanguage: String; ALazarusVersion: String; AOSName: String): TStringList;
var
  words: TStringList;
begin

  // There is a better way- look at the file in folder "language"
  words := TStringList.Create;
  //words.loadFromFile('data\languages\'+ ALanguage +'.txt');
  Result := words;
  words.Free;

  // translate also Buttons on Dialog-Forms
  if (ALanguage = 'German') then
  begin
    if (AOSName = 'Linux') then
      TranslateUnitResourceStrings('LCLStrConsts', '/usr/share/lazarus/'+ALazarusVersion+'/lcl/languages/lclstrconsts.de.po');
    if (AOSName = 'Windows') then
      TranslateUnitResourceStrings('LCLStrConsts', 'C:\lazarus\lcl\languages\lclstrconsts.de.po');
	end;

end;

function RealDayOfWeek(ADate: TDate): Integer;
var
  day: Integer;
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

end.

