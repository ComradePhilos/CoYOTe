// A Unit that provides classes and functions for using periods of times
// inluding workdays etc...
// NOTE: The periods are sometimes called "weeks" in the code, but dont have
// to be a real week. They are just a list of (random) days.
unit workdays;

interface

uses Classes, SysUtils, DateUtils, fgl, Grids,
     CoyoteDefaults;

type

//############################################ DAY ###########################################################
  TWorkDay = class

  private
    FStartHour: integer;      // The hour work starts that day
    FStartMinute: integer;    // The minute work starts that day
    FEndHour: integer;        // The hour work ends that day
    FEndMinute: integer;      // The minute work ends that day
    FTimeOff: Double;         // hours that are taken off - freetime
    FWeekDay: integer;         // Weekday 1 - 7
    FDate: TDate;              // Date of the specific Day
    FAdditionalTime: double;   // Time to add or substract additional time e.g. if you took 1 hour off

    function calcDifference: double;    // The function that will actually calculate work time of one day

  public
    procedure Clear;
    procedure setTime(hour, min: integer; mode: boolean);
    function WeekDayToText: String;
    function getAmountOfTime: Double;

    property StartHour: Integer read FStartHour write FStartHour;
    property StartMinute: Integer read FStartMinute write FStartMinute;
    property EndHour: Integer read FEndHour write FEndHour;
    property EndMinute: Integer read FEndMinute write FEndMinute;
    property Date: TDate read FDate write FDate;
    property Weekday: integer read FWeekday write FWeekday;
    property TimeOff: Double read FTimeOff write FTimeOff;
    property AdditionalTime: double read FAdditionaltime write FAdditionaltime;
    property TimeWorked: double read calcDifference;

  end;

  TWorkDays = specialize TFPGObjectList<TWorkDay>;

//############################################ Period ###########################################################
  TWorkWeek = class
  private
    // Remember to also change the assign-method when adding/deleting variables
    FWeekLabel: String;                 // A Description Text shown in the list
    FDays: TWorkDays;                   // The Days related to this period
    FFromDate: TDate;                   // The lowest Date of the week
    FToDate: TDate;                     // The highest Date of the week
    FWeekLength: integer;               // Workdays in that particular week
    FIntendedTimePerDay: double;        // The time you intend to work per day
    FPausePerDay: Double;               // Obligatory Pause Time, time you need to stay at work additionally
    // FPerson: TPerson;                // The Person related to the week data

    function calcAverageTime: double;

  public
    constructor Create;
    constructor Create(AFromDate, AToDate: TDate); overload;
    destructor Destroy;
    procedure Clear;
    procedure assign(AWeek: TWorkWeek);      // Assign the values of AWeek to this instance
    function getSum: Double;                 // calculate the sum of working time of the week

    property WeekLength: Integer read FWeekLength write FWeekLength;
    property IntendedTimePerDay: Double read FIntendedTimePerDay write FIntendedTimePerDay;
    property PausePerDay: Double read FPausePerDay write FPausePerDay;
    property AverageTimePerDay: Double read calcAverageTime;
    property FromDate: TDate read FFromDate write FFromDate;
    property ToDate: TDate read FToDate write FToDate;
    property Days: TWorkDays read FDays write FDays;
    property WeekLabel: String read FWeekLabel write FWeekLabel;

  end;

TWeekList = specialize TFPGObjectList<TWorkWeek>;

// ############################################### additional Functions ################################################

procedure ClearStringGrid(AGrid: TStringGrid);
procedure WeeksToStringGrid(AGrid: TStringGrid; AWeeklist: TWeekList; SelectionIndex: Integer);
procedure WeekDaysToStringGrid(AGrid: TStringGrid; AWeek: TWorkWeek);
function timeToText(AHour, AMinute: integer): string;
function RealDayOfWeek(ADate: TDate): integer;
function getHour(time: string): integer;
function getMinute(time: string): integer;


implementation


//############################################ DAY ###########################################################

procedure TWorkDay.Clear;
begin
  FStartHour := 0;
  FStartMinute := 0;
  FEndHour := 0;
  FEndMinute := 0;

  FDate := 0;
  FAdditionalTime := 0;
end;

procedure TWorkDay.setTime(hour, min: integer; mode: boolean);
begin
  if (hour > 23) then
    hour := 23;
  if (min > 59) then
    min := 59;
  if (hour < 0) then
    hour := 0;
  if (min < 0) then
    min := 0;

  if not mode then
  begin
    FStartHour := hour;
    FStartMinute := min;
  end
  else
  begin
    FEndHour := hour;
    FEndMinute := min;
  end;
end;

function TWorkDay.calcDifference: double;
begin
  Result := (FEndHour - FStartHour + ((FEndMinute - FStartMinute) / 60));
end;

function TWorkDay.WeekDayToText(): string;
begin
  if (FWeekday > 0) then
    Result := txtWeekdays[FWeekday] + FormatDateTime('dd.mm.yyyy', FDate)
  else
    Result := FormatDateTime('dd.mm.yyyy', FDate);
end;

function TWorkDay.getAmountOfTime: Double;
var
  StartTime: TDateTime;
  EndTime: TDateTime;
begin
  StartTime := self.FDate;
  EndTime := self.FDate;

  StartTime := StartTime + (60*60*FStartHour) + (60*FStartMinute);
  EndTime := EndTime + (60*60*FEndHour) + (60*FEndMinute);
  Result := self.TimeOff + (EndTime - StartTime)/3600;
end;

//############################################ Week ###########################################################

constructor TWorkWeek.Create;
var
  I: Integer;
begin
  FDays := TWorkDays.Create(true);
  FWeekLabel := 'empty week';
  FWeekLength := 0;
  FIntendedTimePerDay := 8;
  FPausePerDay := 0.75;
end;

constructor TWorkWeek.Create(AFromDate, AToDate: TDate);
var
  I: Integer;
begin
  FFromDate := AFromDate;
  FToDate := AToDate;
  FWeekLength := DaysBetween(FToDate,FFromDate)+ 1;
  FIntendedTimePerDay := 8;
  FPausePerDay := 0.75;
  FDays := TWorkDays.Create(true);
  FWeekLabel := FormatDateTime('dd.mm.yyyy', FromDate) + '   to   ' + FormatDateTime('dd.mm.yyyy', ToDate);
  for I := 0 to FWeekLength-1 do
  begin
    FDays.Add(TWorkDay.Create);
    FDays[I].Weekday := RealDayOfWeek(AFromDate + I);
    FDays[I].Date := AFromDate + I;
  end;
end;

destructor TWorkWeek.Destroy;
begin
  FDays.Free;
end;

procedure TWorkWeek.assign(AWeek: TWorkWeek);
var
  I: Integer;
begin
  FFromDate := AWeek.FromDate;
  FToDate := AWeek.ToDate;
  FWeekLength := AWeek.WeekLength;
  FWeekLabel := AWeek.WeekLabel;
  FIntendedTimePerDay := AWeek.IntendedTimePerDay;
  FPausePerDay := AWeek.PausePerDay;
  FDays.Clear;
  for I := 0 to self.WeekLength -1 do
  begin
    FDays.Add(TWorkDay.Create);
    FDays[I].Date := AWeek.Days[I].Date;
    FDays[I].Weekday := AWeek.Days[I].Weekday;
    FDays[I].StartHour := AWeek.Days[I].StartHour;
    FDays[I].EndHour := AWeek.Days[I].EndHour;
    FDays[I].StartMinute := AWeek.Days[I].StartMinute;
    FDays[I].EndMinute := AWeek.Days[I].EndMinute;
    FDays[I].TimeOff := AWeek.Days[I].TimeOff;
  end;
end;

function TWorkWeek.calcAverageTime: double;
var
  I: integer;
begin
  if (FDays.Count > 0) then
  begin
    for I := 0 to FDays.Count - 1 do
    begin
      Result := Result + FDays.Items[I].calcDifference;
    end;
    Result := Result / FDays.Count
  end
  else
  begin
    Result := 0;
  end;
end;

function TWorkWeek.getSum: Double;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to self.Days.Count-1 do
  begin
    Result := Result + self.Days[I].getAmountOfTime - self.FPausePerDay;
	end;
end;

procedure TWorkWeek.Clear;
begin
  FDays.Clear;
  FFromDate := 0;
  FToDate := 0;
  FWeekLength := 0;
  FIntendedTimePerDay := 8;
end;



// ############################################### additional Functions ################################################

function timeToText(AHour, AMinute: integer): string;
begin
  if (AMinute >= 0) and (AMinute < 60) and (AHour >= 0) and (AHour < 24) then
  begin
    if (AMinute < 10) then
    begin
      Result := IntToStr(AHour) + ':0' + IntToStr(AMinute);
    end
    else
    begin
      Result := IntToStr(AHour) + ':' + IntToStr(AMinute);
    end;
  end
  else
  begin
    Result := 'time not convertable!';
  end;
end;

procedure WeeksToStringGrid(AGrid: TStringGrid; AWeeklist: TWeekList; SelectionIndex: Integer);
var
  I: Integer;
  diff: Double;
begin
  clearStringGrid(AGrid);
  AGrid.RowCount := 1 + AWeekList.Count;
  for I := 0 to AWeekList.Count - 1 do
  begin
		AGrid.Cells[0,1+I] := IntToStr(I+1);
    AGrid.Cells[1,1+I] := AWeekList.Items[I].WeekLabel;
    AGrid.Cells[2,1+I] := IntToStr(AWeekList.Items[I].WeekLength);
    AGrid.Cells[3,1+I] := FormatFloat('0.00', AWeekList.Items[I].getSum);
    AGrid.Cells[4,1+I] := FormatFloat('0.00', AWeekList.Items[I].IntendedTimePerDay * AWeekList.Items[I].WeekLength);
    diff :=  (AWeekList.Items[I].getSum - (AWeekList.Items[I].IntendedTimePerDay * AWeekList.Items[I].WeekLength));
    AGrid.Cells[5,1+I] := FormatFloat('0.00', diff);
  end;
end;

procedure ClearStringGrid(AGrid: TStringGrid);
begin
  while (AGrid.RowCount > 1) do
  begin
    AGrid.DeleteRow(AGrid.RowCount-1);
  end;
end;

procedure WeekDaysToStringGrid(AGrid: TStringGrid; AWeek: TWorkWeek);
var
  I: Integer;
begin
  clearStringGrid(AGrid);
  AGrid.RowCount := AWeek.WeekLength+1;

  if (AWeek.Days.Count > 0) then
  begin
    for I := 1 to AWeek.Weeklength do
    begin
      AGrid.Cells[0,I] := IntToStr(I);
      AGrid.Cells[2,I] := FormatDateTime('dd.mm.yyyy', AWeek.Days[I-1].Date);

      if (AWeek.Days[I-1].Weekday > 0) and (AWeek.Days[I-1].Weekday < 8) then
      begin
        AGrid.cells[1,I] := txtWeekdays[Aweek.Days[I-1].Weekday];
		  end;
      AGrid.cells[3,I] := TimeToText(AWeek.Days[I-1].StartHour, AWeek.Days[I-1].StartMinute);
      AGrid.cells[4,I] := TimeToText(AWeek.Days[I-1].EndHour, AWeek.Days[I-1].EndMinute);
      AGrid.Cells[5,I] := FloatToStr(AWeek.Days[I-1].TimeOff);
      AGrid.Cells[6,I] := FormatFloat('0.00', (AWeek.Days[I-1].getAmountOfTime-AWeek.PausePerDay));
      AGrid.Cells[7,I] := FormatFloat('0.00', (AWeek.Days[I-1].getAmountOfTime-AWeek.PausePerDay) - AWeek.IntendedTimePerDay);
	  end;
	end;
end;

// Get the real day of the week as 1 = Monday
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

// Extract the Hour of a '12:00' - String
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
    if (res > 23) or (res < 0) then
    begin
      res := 0;
		end;
		Result := res;
  end
  else
  begin
    Result := 0;
  end;

end;

// Extract the Minute of a '12:00' - String
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
    if (res > 59) or (res < 0) then
    begin
      res := 0;
		end;
    Result := res;
  end
  else
  begin
    Result := 0;
  end;
end;


end.