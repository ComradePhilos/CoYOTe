{
  This Unit shall contain all additional functions that do not fit in a specific
  Unit or Class. (e.g. Translations, String-Conversions... )
}
unit funcs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Translations, DateUtils,
  { own Units }
  workdays;

procedure SaveToFile(filename: String; AWeekList: TWeekList);
procedure LoadFromFile(filename: String; AWeekList: TWeekList);


implementation

procedure SaveToFile(filename: String; AWeekList: TWeekList);
var
  lines: TStringList;
  I: Integer;
  F: Integer;
begin
  lines := TStringList.Create;
  try
    lines.Add(IntToStr(AWeekList.Count));
    for I := 0 to AWeekList.Count - 1 do
    begin
      lines.Add(AWeekList.Items[I].WeekLabel);                         // Label of the week
      lines.Add(FormatDateTime('dd.mm.yyyy', AWeekList.Items[I].FromDate));               // From-Date
      lines.Add(FormatDateTime('dd.mm.yyyy', AWeekList.Items[I].ToDate));                 // To-Date
      lines.Add(FloatToStr(AWeekList.Items[I].IntendedTimePerDay));    // Intended time of work per day
      lines.Add(FloatToStr(AWeekList.Items[I].PausePerDay));
      lines.Add(IntToStr(AWeekList.Items[I].WeekLength));
      for F := 0 to AWeekList.Items[I].Days.Count - 1 do
      begin
        lines.Add(FormatDateTime('dd.mm.yyyy', AWeekList.Items[I].Days[F].Date));
        lines.Add(IntToStr(AWeekList.Items[I].Days[F].Weekday));
        lines.Add(IntToStr(AWeekList.Items[I].Days[F].StartHour));
        lines.Add(IntToStr(AWeekList.Items[I].Days[F].StartMinute));
        lines.Add(IntToStr(AWeekList.Items[I].Days[F].EndHour));
        lines.Add(IntToStr(AWeekList.Items[I].Days[F].EndMinute));
        lines.Add(FloatToStr(AWeekList.Items[I].Days[F].TimeOff));
      end;
    end;
    lines.SaveToFile(filename);
  finally
    lines.Free;
  end;
end;



procedure LoadFromFile(filename: String; AWeekList: TWeekList);
var
  I: Integer;        // Week-Counter
  l: Integer;        // Line-Counter
  d: Integer;        // Day-Counter
  lines: TStringList;
  count: Integer;    // Number of Days
  locInt: Integer;
  locDate: TDate;
  locDay: Integer;
  locMonth: Integer;
  locYear: Integer;
  locDouble: Double;
begin
  lines := TStringList.Create;
  AWeekList.Clear;

  try

    l := 0;
    lines.LoadFromFile(filename);

    if TryStrToInt(lines[0], locInt) then
    begin
      count := locInt;
      Inc(l);
    end;

    for I := 0 to count - 1 do
    begin
      AWeekList.Add(TWorkWeek.Create);
      AWeekList.Items[I].WeekLabel := lines[l];
      inc(l);
      // Start - Date
      if TryStrToDate(lines[l], locDate, '.') then
      begin
        AWeekList.Items[I].FromDate := locDate;
        inc(l);
      end;
      // End- Date
      if TryStrToDate(lines[l], locDate, '.') then
      begin
        AWeekList.Items[I].ToDate := locDate;
        inc(l);
      end;
      // Time per Day
      if TryStrToFloat(lines[l], locDouble) then
      begin
        AWeekList.Items[I].IntendedTimePerDay := locDouble;
        inc(l);
      end;
      // Pause per Day
      if TryStrToFloat(lines[l], locDouble) then
      begin
        AWeekList.Items[I].PausePerDay := locDouble;
        inc(l);
      end;
      // Weeklength
      if TryStrToInt(lines[l], locInt) then
      begin
        AWeekList.Items[I].WeekLength := locInt;
        inc(l);
      end;

      // Days
      for d := 0 to AWeekList.Items[I].WeekLength - 1 do
      begin
        AWeekList.Items[I].Days.Add(TWorkDay.Create);
        // Datum
        if TryStrToDate(lines[l], locDate, '.') then
        begin
          AWeekList.Items[I].Days[d].Date:= locDate;
          inc(l);
        end;
        // Wochentag
        if TryStrToInt(lines[l], locInt) then
        begin
          AWeekList.Items[I].Days[d].Weekday := locInt;
          inc(l);
        end;
        // Start-Hour
        if TryStrToInt(lines[l], locInt) then
        begin
          AWeekList.Items[I].Days[d].StartHour := locInt;
          inc(l);
        end;
        // Start-Minute
        if TryStrToInt(lines[l], locInt) then
        begin
          AWeekList.Items[I].Days[d].StartMinute := locInt;
          inc(l);
        end;
        // End-Hour
        if TryStrToInt(lines[l], locInt) then
        begin
          AWeekList.Items[I].Days[d].EndHour := locInt;
          inc(l);
        end;
        // End-Minute
        if TryStrToInt(lines[l], locInt) then
        begin
          AWeekList.Items[I].Days[d].EndMinute := locInt;
          inc(l);
        end;
        // Time off
        if TryStrToFloat(lines[l], locDouble) then
        begin
          AWeekList.Items[I].Days[d].TimeOff := locDouble;
          inc(l);
        end;
      end; { for d := .... }
    end;  { for I := ... }
  finally
    lines.Free;
  end;
end;


end.
