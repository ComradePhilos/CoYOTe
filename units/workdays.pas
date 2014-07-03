// A Unit that provides classes and functions for using periods of times
// inluding workdays etc...
// NOTE: The periods are sometimes called "weeks" in the code, but dont have
// to be a real week. They are just a list of (random) days.
unit workdays;

interface

uses Classes, SysUtils, DateUtils, fgl, Grids, StdCtrls,
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
    FWeekDay: integer;        // Weekday 1 - 7
    FDate: TDate;             // Date of the specific Day
    FAdditionalTime: double;  // Time to add or substract additional time e.g. if you took 1 hour off
    FTag: String;             // add a tag to the specifig day e.g. "offical holiday", "ignore"...

    function calcDifference: double;    // The function that will actually calculate work time of one day

  public
    constructor Create; overload;                    // normal day constructor
    constructor Create(ADay: TWorkDay); overload;    // Creates a new day and copies the values from ADay

    procedure Clear;
    procedure setTime(hour, min: integer; mode: boolean);
    procedure Assign(ADay: TWorkDay);
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
    property Tag: String read FTag write FTag;
    property TimeWorked: double read calcDifference;

  end;

  TWorkDays = specialize TFPGObjectList<TWorkDay>;

//############################################ Period ###########################################################
  TWorkWeek = class
  private
    // Remember to also change the assign-method when adding/deleting variables
    FWeekLabel: String;                 // The "Name" of the week shown in grid
    FDays: TWorkDays;                   // The Days related to this period
    FFromDate: TDate;                   // The lowest Date of the week
    FToDate: TDate;                     // The highest Date of the week
    FWeekLength: integer;               // Workdays in that particular week
    FIntendedTimePerDay: double;        // The time you intend to work per day
    FPausePerDay: Double;               // Obligatory Pause Time, time you need to stay at work additionally
    FDescriptionText: TStringList;      // Description Text

    function calcAverageTime: double;

  public
    constructor Create;
    constructor Create(AFromDate, AToDate: TDate); overload;
    constructor Create(AWorkWeek: TWorkWeek); overload;         // Creates a week and copies the values from AWorkWeek
    destructor Destroy;
    procedure Clear;
    procedure assign(AWeek: TWorkWeek);       // Assign the values of AWeek to this instance
    function getSum: Double;                  // come here and getsum - calculate the sum of working time of the week
    function getAmountOfVacation: Double;     // Returns the number of days a person has taken off
    function getGoalHours: Double;            // Returns the number of hours that have to be achieved
    function getDayOfLatestQuitting: TWorkDay;// Returns the Date of the latest qutting
    function getDayOfEarliestBegin: TWorkDay; // Returns the Date of the earliest begin

    property WeekLength: Integer read FWeekLength write FWeekLength;
    property IntendedTimePerDay: Double read FIntendedTimePerDay write FIntendedTimePerDay;
    property PausePerDay: Double read FPausePerDay write FPausePerDay;
    property AverageTimePerDay: Double read calcAverageTime;
    property FromDate: TDate read FFromDate write FFromDate;
    property ToDate: TDate read FToDate write FToDate;
    property Days: TWorkDays read FDays write FDays;
    property WeekLabel: String read FWeekLabel write FWeekLabel;
    property DescriptionText: TStringList read FDescriptionText write FDescriptionText;

  end;

TWeekList = specialize TFPGObjectList<TWorkWeek>;

// ############################################### additional Functions ################################################

procedure ClearStringGrid(AGrid: TStringGrid);
procedure WeeksToStringGrid(AGrid: TStringGrid; AWeeklist: TWeekList; SelectionIndex: Integer);
procedure WeekDaysToStringGrid(AGrid: TStringGrid; AWeek: TWorkWeek);
procedure WeeksToComboBox(AComboBox: TComboBox; AWeekList: TWeekList);

// Inserts a day to a week at specified Index
procedure InsertDayToWeek(ADay: TWorkDay; AWeek: TWorkWeek; AIndex: Integer);


function timeToText(AHour, AMinute: integer): string;
function RealDayOfWeek(ADate: TDate): integer;  // only needed because I used a 1-based String instead of a 0 based
function getHour(time: string): integer;
function getMinute(time: string): integer;
function getDayOfEarliestBegin(AWeekList: TWeekList): TWorkDay;

function isTimeEarliest(AHour, AMinute, earliestHour, earliestMinute: Integer): Boolean;
function isTimeLatest(AHour, AMinute, latestHour, latestMinute: Integer): Boolean;


implementation


//############################################ DAY ###########################################################
constructor TWorkDay.Create;
begin
  FTag := '';
end;

constructor TWorkDay.Create(ADay: TWorkDay);
begin
  self.Assign(ADay);
end;

procedure TWorkDay.Assign(ADay: TWorkDay);
begin
  FStartHour := ADay.StartHour;
  FStartMinute := ADay.StartMinute;
  FEndHour := ADay.EndHour;
  FEndMinute := ADay.EndMinute;

  FDate := ADay.Date;
  FWeekDay := RealDayOfWeek(FDate);
  FAdditionalTime := ADay.AdditionalTime;
  FTag := ADay.Tag;
end;

procedure TWorkDay.Clear;
begin
  FStartHour := 0;
  FStartMinute := 0;
  FEndHour := 0;
  FEndMinute := 0;

  FDate := 0;
  FAdditionalTime := 0;
  FTag := '';
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
  Result := {self.TimeOff +} (EndTime - StartTime)/3600;
end;

//############################################ Week ###########################################################

constructor TWorkWeek.Create;
begin
  FDays := TWorkDays.Create(true);
  FWeekLabel := 'empty week';
  FWeekLength := 0;
  FIntendedTimePerDay := defHoursPerDay;
  FPausePerDay := defPausePerDay;
  FDescriptionText := TStringList.Create;
end;

constructor TWorkWeek.Create(AFromDate, AToDate: TDate);
var
  I: Integer;
begin
  FFromDate := AFromDate;
  FToDate := AToDate;
  FWeekLength := DaysBetween(FToDate,FFromDate)+ 1;
  FIntendedTimePerDay := defHoursPerDay;
  FPausePerDay := defPausePerDay;
  FDays := TWorkDays.Create(true);
  FWeekLabel := FormatDateTime('dd.mm.yyyy', FromDate) + '   to   ' + FormatDateTime('dd.mm.yyyy', ToDate);
  for I := 0 to FWeekLength-1 do
  begin
    FDays.Add(TWorkDay.Create);
    FDays[I].Weekday := RealDayOfWeek(AFromDate + I);
    FDays[I].Date := AFromDate + I;
  end;
  FDescriptionText := TStringList.Create;
end;

constructor TWorkWeek.Create(AWorkWeek: TWorkWeek);
begin
  FDays := TWorkDays.Create(true);
  self.assign(AWorkWeek);
end;

destructor TWorkWeek.Destroy;
begin
  FDays.Free;
  FDescriptionText.Free;
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
  FDescriptionText := AWeek.DescriptionText;
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
    FDays[I].Tag := AWeek.Days[I].Tag;
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
    if (self.Days[I].Tag = '') then
    begin
      // If e.g. 6 hours in Germany have passed, an obligatory time for pause has to be added
      if (self.Days[I].getAmountOfTime < defHoursUntilPause) then
      begin
        Result := Result + self.Days[I].getAmountOfTime
      end
      else
      begin
        Result := Result + self.Days[I].getAmountOfTime - self.FPausePerDay;
      end;
    end;
  end;

end;

function TWorkWeek.getGoalHours: Double;
var
  sum: Double;
  I: Integer;
begin
  sum := 0;
  for I := 0 to FDays.Count - 1 do
  begin
    if (Days[I].Tag = '') then
    begin
      sum := sum + FIntendedTimePerDay - FDays[I].TimeOff;
		end;
	end;
  Result := sum;
end;

procedure TWorkWeek.Clear;
begin
  FDays.Clear;
  FFromDate := 0;
  FToDate := 0;
  FWeekLength := 0;
  FIntendedTimePerDay := 8;
end;

function TWorkWeek.getAmountOfVacation: Double;
var
  I: Integer;
  sum: Double;
begin
  sum := 0;
  for I := 0 to FDays.Count - 1 do
  begin
    if (FIntendedTimePerDay > 0) then
    begin
      sum := sum + (FDays.Items[I].TimeOff/FIntendedTimePerDay);
		end;
	end;
  Result := sum;
end;

function TWorkWeek.getDayOfEarliestBegin: TWorkDay;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FDays.Count - 1 do
  begin
    if (FDays[I].TimeOff < FIntendedTimePerDay) then
    begin
      if (Result <> nil) then
      begin
        if (FDays[I].StartHour < Result.StartHour) and (FDays[I].StartMinute <= Result.StartMinute) then
        begin
          Result := FDays[I];
				end;
			end;
		end;
	end;
end;

function TWorkWeek.getDayOfLatestQuitting: TWorkDay;
var
  I: Integer;
begin
  {
  if (self.Days.Count > 0) then
  begin
    Result := self.Days.Items[0];  // initialisieren
		for I := 1 to self.Days.Count - 1 do
		begin
      if (FDays.Items[I].StartHour > Result.EndHour) then
      begin
        if (FDays.Items[I].StartMinute > Result.EndMinute) then
        begin
          Result := FDays.Items[I];
				end;
			end;
		end;
	end
  else
  begin
    Result := nil;
	end;    }
end;

// ############################################### External Functions ################################################
function isTimeEarliest(AHour, AMinute, earliestHour, earliestMinute: Integer): Boolean;
begin
  Result := False;
  if (AHour < earliestHour) then
  begin
    Result := True;
  end;
  if (AHour = earliestHour) then
  begin
    Result := (AHour < earliestMinute);
  end;
end;

function isTimeLatest(AHour, AMinute, latestHour, latestMinute: Integer): Boolean;
begin
  Result := False;
  if (AHour > latestHour) then
  begin
    Result := True;
  end;
  if (AHour = latestHour) then
  begin
    Result := (AHour > latestMinute);
  end;
end;

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
    //AGrid.Cells[4,1+I] := FormatFloat('0.00', AWeekList.Items[I].IntendedTimePerDay * AWeekList.Items[I].WeekLength);
    AGrid.Cells[4,1+I] := FormatFloat('0.00', AWeekList.Items[I].getGoalHours);
    diff :=  (AWeekList.Items[I].getSum - AWeekList.Items[I].getGoalHours);
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
      // if it is tagges as holiday or ignored, then ignore
      if (AWeek.Days[I-1].Tag = '') then
      begin
        // if working time is under 6 hours then there is no break needed
        if (AWeek.Days[I-1].getAmountOfTime < defHoursUntilPause) then
        begin
          AGrid.Cells[6,I] := FormatFloat('0.00', (AWeek.Days[I-1].getAmountOfTime));
          AGrid.Cells[7,I] := FormatFloat('0.00', (AWeek.Days[I-1].getAmountOfTime - (AWeek.IntendedTimePerDay-AWeek.Days[I-1].TimeOff)));
				end
        else
        begin
          AGrid.Cells[6,I] := FormatFloat('0.00', (AWeek.Days[I-1].getAmountOfTime-AWeek.PausePerDay));
          AGrid.Cells[7,I] := FormatFloat('0.00', (AWeek.Days[I-1].getAmountOfTime-AWeek.PausePerDay) - (AWeek.IntendedTimePerDay-AWeek.Days[I-1].TimeOff));
				end;
			end
      else
      begin
        AGrid.Cells[6,I] := '0.00';
        AGrid.Cells[7,I] := '0.00';
			end;
			AGrid.Cells[8,I] := AWeek.Days[I-1].Tag;
	  end;
	end;
end;


procedure WeeksToComboBox(AComboBox: TComboBox; AWeekList: TWeekList);
var
  I: Integer;
begin
  AComboBox.Clear;
  For I := 0 to AWeekList.Count - 1 do
  begin
    AComboBox.Items.Add('#'+ IntToStr(I+1) + ': ' + AWeekList.Items[I].WeekLabel);
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

procedure InsertDayToWeek(ADay: TWorkDay; AWeek: TWorkWeek; AIndex: Integer);
begin
  if (AWeek.Days.Count > 1) then
  begin
	  AWeek.Days.Insert(AIndex, ADay);
	end;
end;

function getDayOfEarliestBegin(AWeekList: TWeekList): TWorkDay;
var
  I,D: Integer;
  locDay: TWorkDay;
begin

  Result := nil;


end;

end.
