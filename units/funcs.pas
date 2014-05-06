unit funcs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Translations;
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
function searchForTranslation(VariableName: string; ALanguage: string): string;


implementation


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

function searchForTranslation(VariableName: string; ALanguage: string): string;
begin

  Result := '';
end;

end.