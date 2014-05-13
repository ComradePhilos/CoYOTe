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

//property TimeOff: Double read FTimeOff write FTimeOff;
//property AdditionalTime: double read FAdditionaltime write FAdditionaltime;


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
        lines.Add(DateToStr(AWeekList.Items[I].Days[F].Date));
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



end.