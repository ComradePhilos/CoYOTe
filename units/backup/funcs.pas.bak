{
  This Unit shall contain all additional functions that do not fit in a specific
  Unit or Class. (e.g. Translations, String-Conversions, help functions... )
}
unit funcs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Translations, DateUtils, StdCtrls, Graphics, Process, LCLIntF,
  Forms, Menus,
  { own Units }
  workdays, CoyoteDefaults;

// Save WeekList to File
procedure SaveToFile(filename: string; AWeekList: TWeekList);

// Load WeekList from File
function LoadFromFile(filename: string; AWeekList: TWeekList): boolean;

// Creates a Colored Text depending on balance etc..
procedure colorText(ALabel: TLabel; value1, value2, toleranceLimit: double);
procedure colorText(ALabel: TLabel; Value, toleranceLimit: double); overload;

// Opens a URL not depending on the OS
procedure OpenURL(AURL: string);


implementation

procedure SaveToFile(filename: string; AWeekList: TWeekList);
var
  Lines: TStringList;
  I: integer;
  F: integer;
begin
  Lines := TStringList.Create;
  try
    Lines.Add('CoYOTe file');
    Lines.Add(IntToStr(AWeekList.Count));  // Number of Weeks
    Lines.Add(FloatToStr(1.2345));         // Testfloat, so that the load-function can interpret floating values
    for I := 0 to AWeekList.Count - 1 do
    begin
      Lines.Add(AWeekList.Items[I].WeekLabel);                         // Label of the week
      Lines.Add(FormatDateTime('dd.mm.yyyy', AWeekList.Items[I].FromDate)); // From-Date
      Lines.Add(FormatDateTime('dd.mm.yyyy', AWeekList.Items[I].ToDate));  // To-Date
      Lines.Add(FloatToStr(AWeekList.Items[I].IntendedTimePerDay));    // Intended time of work per day
      Lines.Add(FloatToStr(AWeekList.Items[I].PausePerDay));
      Lines.Add(IntToStr(AWeekList.Items[I].DescriptionText.Count));
      for F := 0 to AWeekList.Items[I].DescriptionText.Count - 1 do
      begin
        Lines.Add(AWeekList.Items[I].DescriptionText[F]);
      end;
      Lines.Add(IntToStr(AWeekList.Items[I].WeekLength));
      for F := 0 to AWeekList.Items[I].Days.Count - 1 do
      begin
        Lines.Add(FormatDateTime('dd.mm.yyyy', AWeekList.Items[I].Days[F].Date));
        Lines.Add(IntToStr(AWeekList.Items[I].Days[F].Weekday));
        Lines.Add(IntToStr(AWeekList.Items[I].Days[F].StartHour));
        Lines.Add(IntToStr(AWeekList.Items[I].Days[F].StartMinute));
        Lines.Add(IntToStr(AWeekList.Items[I].Days[F].EndHour));
        Lines.Add(IntToStr(AWeekList.Items[I].Days[F].EndMinute));
        Lines.Add(FloatToStr(AWeekList.Items[I].Days[F].TimeOff));
        Lines.Add(AWeekList.Items[I].Days[F].Tag);
      end;
    end;
    Lines.SaveToFile(filename);
  finally
    Lines.Free;
  end;
end;

function LoadFromFile(filename: string; AWeekList: TWeekList): boolean;
var
  I: integer;        // Week-Counter
  l: integer;        // Line-Counter
  d: integer;        // Day-Counter
  Lines: TStringList;
  Count: integer;    // Number of Days
  locInt: integer;
  locDate: TDate;
  locDouble: double;
  FormatDouble: TFormatSettings;
begin
  Lines := TStringList.Create;

  try
    l := 1;
    Lines.LoadFromFile(filename);

    if (Lines[0] = 'CoYOTe file') then
    begin
      AWeekList.Clear;
      // Number of Weeks
      if TryStrToInt(Lines[1], locInt) then
      begin
        Count := locInt;
        Inc(l);
      end;

      // load Test-Float to set the format settings
      FormatDouble.DecimalSeparator := LeftStr(Lines[l], 2)[2];
      Inc(l);

      for I := 0 to Count - 1 do
      begin
        AWeekList.Add(TWorkWeek.Create);
        AWeekList.Items[I].WeekLabel := Lines[l];
        Inc(l);
        // Start - Date
        if TryStrToDate(Lines[l], locDate, '.') then
        begin
          AWeekList.Items[I].FromDate := locDate;
          Inc(l);
        end;
        // End- Date
        if TryStrToDate(Lines[l], locDate, '.') then
        begin
          AWeekList.Items[I].ToDate := locDate;
          Inc(l);
        end;
        // Time per Day
        if TryStrToFloat(Lines[l], locDouble, FormatDouble) then
        begin
          AWeekList.Items[I].IntendedTimePerDay := locDouble;
          Inc(l);
        end;
        // Pause per Day
        if TryStrToFloat(Lines[l], locDouble, FormatDouble) then
        begin
          AWeekList.Items[I].PausePerDay := locDouble;
          Inc(l);
        end;

        if TryStrToInt(Lines[l], locInt) then
        begin
          Inc(l);
          for d := 0 to locInt - 1 do
          begin
            AWeekList.Items[I].DescriptionText.Add(Lines[l]);
            Inc(l);
          end;
        end;

        // Weeklength
        if TryStrToInt(Lines[l], locInt) then
        begin
          AWeekList.Items[I].WeekLength := locInt;
          Inc(l);
        end;

        // Days
        for d := 0 to AWeekList.Items[I].WeekLength - 1 do
        begin
          AWeekList.Items[I].Days.Add(TWorkDay.Create);
          // Datum
          if TryStrToDate(Lines[l], locDate, '.') then
          begin
            AWeekList.Items[I].Days[d].Date := locDate;
            Inc(l);
          end;
          // Wochentag
          if TryStrToInt(Lines[l], locInt) then
          begin
            AWeekList.Items[I].Days[d].Weekday := locInt;
            Inc(l);
          end;
          // Start-Hour
          if TryStrToInt(Lines[l], locInt) then
          begin
            AWeekList.Items[I].Days[d].StartHour := locInt;
            Inc(l);
          end;
          // Start-Minute
          if TryStrToInt(Lines[l], locInt) then
          begin
            AWeekList.Items[I].Days[d].StartMinute := locInt;
            Inc(l);
          end;
          // End-Hour
          if TryStrToInt(Lines[l], locInt) then
          begin
            AWeekList.Items[I].Days[d].EndHour := locInt;
            Inc(l);
          end;
          // End-Minute
          if TryStrToInt(Lines[l], locInt) then
          begin
            AWeekList.Items[I].Days[d].EndMinute := locInt;
            Inc(l);
          end;
          // Time off
          if TryStrToFloat(Lines[l], locDouble, FormatDouble) then
          begin
            AWeekList.Items[I].Days[d].TimeOff := locDouble;
            Inc(l);
          end;
          AWeekList.Items[I].Days[d].Tag := Lines[l];
          Inc(l);
        end; { for d := .... }
      end;  { for I := ... }
      Result := True;
    end
    else
    begin
      application.MessageBox(PChar(emInvalidFileFormat), 'Invalid file format!', 0);
      Result := False;
    end;
  finally
    Lines.Free;
  end;
end;


procedure colorText(ALabel: TLabel; value1, value2, toleranceLimit: double);
begin
  if (value1 - value2) >= 0 then
  begin
    ALabel.Font.Color := clGreen;
  end
  else if ((value1 - value2) >= (0 - toleranceLimit)) then
  begin
    ALabel.Font.Color := $000080FF;
  end
  else
  begin
    ALabel.Font.Color := clRed;
  end;
end;


procedure colorText(ALabel: TLabel; Value, toleranceLimit: double);
begin
  if Value >= 0 then
  begin
    ALabel.Font.Color := clGreen;
  end
  else if Value >= (0 - toleranceLimit) then
  begin
    ALabel.Font.Color := $000080FF;
  end
  else
  begin
    ALabel.Font.Color := clRed;
  end;
end;


procedure OpenURL(AURL: string);
var
  AProcess: TProcess;
begin

  {$IFDEF linux}
  AProcess := TProcess.Create(nil);
  try
    AProcess.CommandLine := 'xdg-open "' + AURL + '"';  // Shell command
    AProcess.Execute;
  finally
    AProcess.Free;
  end;
  {$ENDIF}
  {$IFDEF macos}
  AProcess := TProcess.Create(nil);
  try
    AProcess.CommandLine := 'xdg-open "' + AURL + '"';  // Shell command
    AProcess.Execute;
  finally
    AProcess.Free;
  end;
  {$ENDIF}
  {$IFDEF mswindows}
  OpenDocument(AURL);             // Uses the API
  {$ENDIF}
end;


end.
