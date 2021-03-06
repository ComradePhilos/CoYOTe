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
  workdays, CoyoteDefaults, people;

// Save WeekList to File
procedure SaveToFile(filename: string; AWeekList: TWeekList);
procedure NEWSaveToFile(filename: string; APersonList: TPersonList);

// Load WeekList from File
function LoadFromFile(filename: string; AWeekList: TWeekList): boolean;

// Creates a Colored Text depending on balance etc..
procedure colorText(ALabel: TLabel; value1, value2, toleranceLimit: double);
procedure colorText(ALabel: TLabel; Value, toleranceLimit: double); overload;

// swaps two Indices
procedure swap(var AIndex1, AIndex2: Integer);

function CreateOffset(AOffset: Integer): String;


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
        Lines.Add(IntToStr(AWeekList.Items[I].Days[F].StartTime.getHours));
        Lines.Add(IntToStr(AWeekList.Items[I].Days[F].StartTime.getMinutes));
        Lines.Add(IntToStr(AWeekList.Items[I].Days[F].EndTime.getHours));
        Lines.Add(IntToStr(AWeekList.Items[I].Days[F].EndTime.getMinutes));
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
  locInt, locInt2: integer;   // local values for conversion
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
          // Start-Time
          if TryStrToInt(Lines[l], locInt) then
          begin
            //AWeekList.Items[I].Days[d].StartTime.Assign(int);
            if TryStrToInt(Lines[l+1], locInt2) then
            begin
              AWeekList.Items[I].Days[d].StartTime.Assign(locInt, locInt2);
              Inc(l);
              Inc(l);
            end;
          end;

          // End-Hour
          if TryStrToInt(Lines[l], locInt) then
          begin

            if TryStrToInt(Lines[l+1], locInt2) then
            begin
              AWeekList.Items[I].Days[d].EndTime.Assign(locInt, locInt2);
              Inc(l);
              Inc(l);
            end;
          end;
          // End-Minute

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
  if (Value >= 0) then
  begin
    ALabel.Font.Color := clGreen;
  end
  else if (Value >= (0 - toleranceLimit)) then
  begin
    ALabel.Font.Color := $000080FF;
  end
  else
  begin
    ALabel.Font.Color := clRed;
  end;
end;

procedure swap(var AIndex1, AIndex2: Integer);
var
  temp: Integer;
begin
  temp := AIndex1;
  AIndex1 := AIndex2;
  AIndex2 := temp;
end;

procedure NEWSaveToFile(filename: string; APersonList: TPersonList);
var
  Lines: TStringList;
  u: Integer;   // users
  l: Integer;   // lists
  w: Integer;   // weeks
  d: Integer;   // days
  offset: Integer;  // alignment
begin
  Lines := TStringList.Create;
  try
    Lines.Add('CoYOTe file');
    for u := 0 to APersonList.Count - 1 do
    begin
      Lines.Add('<'+ APersonList.Items[u].FirstName + ',' + APersonList.Items[u].FirstName + '>');
      offset := 2;
      Lines.Add(CreateOffset(offset) + APersonList.Items[u].Residence);
      Lines.Add(CreateOffset(offset) + APersonList.Items[u].Street);
      Lines.Add(CreateOffset(offset) + APersonList.Items[u].StreetNR);
      Lines.Add(CreateOffset(offset) + APersonList.Items[u].PhoneNumber1);
      Lines.Add(CreateOffset(offset) + APersonList.Items[u].PhoneNumber2);
      Lines.Add(CreateOffset(offset) + APersonList.Items[u].EMail);

      Lines.Add('</'+ APersonList.Items[u].FirstName + ',' + APersonList.Items[u].FirstName + '>');
      Lines.Add('');
    end;
    Lines.SaveToFile(filename);
  finally
    Lines.Free;
  end;
end;

function CreateOffset(AOffset: Integer): String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to AOffset - 1 do
  begin
    Result += ' ';
	end;
end;

end.