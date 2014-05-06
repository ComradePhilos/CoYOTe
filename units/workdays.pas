// CoYOT(e) - Control Your Overtimes (easily)
unit workdays;

interface

uses Classes, SysUtils, DateUtils, fgl, Grids,
      funcs;

type

//############################################ DAY ###########################################################
  TWorkDay = class

  private
    FStartHour: integer;      // The hour work starts that day
    FStartMinute: integer;    // The minute work starts that day
    FEndHour: integer;        // The hour work ends that day
    FEndMinute: integer;      // The minute work ends that day

    FWeekDay: integer;         // Weekday 1 - 7
    FDate: TDate;              // Date of the specific Day
    FAdditionalTime: double;   // Time to add or substract additional time e.g. if you took 1 hour off

    function calcDifference: double;    // The function that will actually calculate work time of one day

  public
    procedure Clear;
    procedure setTime(hour, min: integer; mode: boolean);
    function WeekDayToText: String;

    property StartHour: Integer read FStartHour write FStartHour;
    property StartMinute: Integer read FStartMinute write FStartMinute;
    property EndHour: Integer read FEndHour write FEndHour;
    property EndMinute: Integer read FEndMinute write FEndMinute;
    property Date: TDate read FDate write FDate;
    property Weekday: integer read FWeekday write FWeekday;
    property AdditionalTime: double read FAdditionaltime write FAdditionaltime;
    property TimeWorked: double read calcDifference;

  end;

  TWorkDays = specialize TFPGObjectList<TWorkDay>;

//############################################ Period ###########################################################
  TWorkWeek = class
  private
    FDays: TWorkDays;
    FFromDate: TDate;
    FToDate: TDate;
    FWeekLength: integer;     // Workdays in that particular week
    FIntendedTimePerDay: double;        // The time you intend to work per day
    //FAverageTime: Double;             // Durchschnittsarbeitszeit pro Tag (Zur Kontrolle)

    function calcAverageTime: double;

  public
    constructor Create;
    constructor Create(AFromDate, AToDate: TDate); overload;
    destructor Destroy;
    procedure Clear;

    property WeekLength: Integer read FWeekLength write FWeekLength;
    property IntendedTimePerDay: Double read FIntendedTimePerDay write FIntendedTimePerDay;
    property AverageTimePerDay: Double read calcAverageTime;
    property FromDate: TDate read FFromDate write FFromDate;
    property ToDate: TDate read FToDate write FToDate;
    property Days: TWorkDays read FDays write FDays;

  end;

TWeekList = specialize TFPGObjectList<TWorkWeek>;

// ############################################### additional Functions ################################################

procedure ClearStringGrid(AGrid: TStringGrid);
procedure WeeksToStringGrid(AGrid: TStringGrid; AWeeklist: TWeekList);
function TimeToText(hour,min: Integer):String;
procedure WeekDaysToStringGrid(AGrid: TStringGrid; AWeek: TWorkWeek);


const
  txtWeekDays: array[1..7] of string = ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun');

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
    Result := txtWeekdays[FWeekday] + DateToStr(FDate)
  else
    Result := DateToStr(FDate);
end;


//############################################ Week ###########################################################

constructor TWorkWeek.Create;
var
  I: Integer;
begin
  FDays := TWorkDays.Create(true);
  for I := 1 to 7 do
  begin
    FDays.Add(TWorkDay.Create);
    FDays.Items[I-1].Weekday := I;
  end;
  FFromDate := now();
  FToDate := now();
end;

constructor TWorkWeek.Create(AFromDate, AToDate: TDate);
var
  I: Integer;
begin
  self.FromDate := AFromDate;
  self.ToDate := AToDate;
  self.WeekLength := DaysBetween(FToDate,FFromDate)+ 1;
  FDays := TWorkDays.Create(true);
  for I := 0 to FWeekLength do
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


procedure TWorkWeek.Clear;
begin
  FDays.Clear;
  FFromDate := 0;
  FToDate := 0;
  FWeekLength := 5;
  FIntendedTimePerDay := 8;
end;



// ############################################### additional Functions ################################################
function TimeToText(hour,min: Integer):String;
var
  txtHour, txtMin: String;
begin
  if (hour < 10) then
    txtHour := '0' + IntToStr(hour);
  if (min < 10) then
    txtMin := '0' + IntToStr(min)
  else
    txtMin := IntToStr(min);

  Result := txtHour + ':' + txtMin;
end;


procedure WeeksToStringGrid(AGrid: TStringGrid; AWeeklist: TWeekList);
var
  I: Integer;
begin
  clearStringGrid(AGrid);
  AGrid.RowCount := 1 + AWeekList.Count;
  for I := 0 to AWeekList.Count - 1 do
  begin
    AGrid.Cells[0,1+I] := IntToStr(I+1);
    if (AWeekList.Items[I].FromDate <> AWeekList.Items[I].ToDate) then
    begin
         AGrid.Cells[1,1+I] := DateToStr(AWeekList.Items[I].Days[0].Date) + ' - ' + DateToStr(AWeekList.Items[I].Days[AWeekList.Items[I].WeekLength-1].Date);
    end
    else
    begin
       AGrid.Cells[1,1+I] := DateToStr(AWeekList.Items[I].FromDate);
    end;
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
  day1: Integer;
begin
  clearStringGrid(AGrid);
  AGrid.RowCount := AWeek.WeekLength+1;
  day1 := RealDayOfWeek(AWeek.FromDate);

  // write contents to right grid
  for I := 1 to AWeek.WeekLength do
  begin

    AGrid.Cells[0,I] := IntToStr(I);
    AGrid.Cells[2,I] := DateToStr(AWeek.Days[I-1].Date);

    if (AWeek.Days[I-1].Weekday > 0) and (AWeek.Days[I-1].Weekday < 8) then
    begin
      AGrid.cells[1,I] := txtWeekdays[Aweek.Days[I-1].Weekday-1];
		end;

    if (AWeek.Days[I].StartMinute < 10) then
    begin
      AGrid.cells[3,I] := IntToStr(AWeek.Days[I-1].StartHour) + ':0' + IntToStr(AWeek.Days[I].StartMinute);
    end
    else
    begin
      AGrid.cells[3,I] := IntToStr(AWeek.Days[I-1].StartHour) + ':' + IntToStr(AWeek.Days[I].StartMinute);
    end;

    if (AWeek.Days[I].EndMinute < 10) then
    begin
      AGrid.cells[4,I] := IntToStr(AWeek.Days[I-1].EndHour) + ':0' + IntToStr(AWeek.Days[I].EndMinute);
    end
    else
    begin
      AGrid.cells[4,I] := IntToStr(AWeek.Days[I-1].EndHour) + ':' + IntToStr(AWeek.Days[I].EndMinute);
    end;
  end;

end;

end.
