unit WeekEditForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  Buttons, StdCtrls, Arrow, ExtCtrls, Menus, ExtDlgs, ComCtrls, DateUtils,
  { own Units }
  workdays, funcs, CoyoteDefaults;

type

  TRemoveEvent = procedure(Sender: TObject; Index: integer) of object;
  TApplyEvent = procedure(Sender: TObject; AWeek: TWorkWeek; Index: integer) of object;
  TNextWeekEvent = procedure(Sender: TObject; Index: integer) of object;

  { TForm3 }

  TForm3 = class(TForm)
    ApplyButton: TBitBtn;
    BackButton: TBitBtn;
    ComboBox1: TComboBox;
    CreateLabelButton: TBitBtn;
    GroupBox1: TGroupBox;
    HoursPerDayEdit: TLabeledEdit;
    DescriptionEdit: TLabeledEdit;
    Label4: TLabel;
    Memo1: TMemo;
    MenuHalfDayOff: TMenuItem;
    PausePerDayEdit: TLabeledEdit;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MenuOneDayOff: TMenuItem;
    MenuDelete: TMenuItem;
    MenuEdit: TMenuItem;
    MenuAdd: TMenuItem;
    PopupMenu1: TPopupMenu;
    SaveDialog1: TSaveDialog;
    ToolBar1: TToolBar;
    ButtonLeft: TToolButton;
    ButtonRight: TToolButton;
    ToolButton1: TToolButton;
    ButtonAdd: TToolButton;
    ButtonEmpty: TToolButton;
    ButtonApply: TToolButton;
    ToolButton2: TToolButton;
    ToolButton5: TToolButton;
    ButtonUndo: TToolButton;
    ButtonDelete: TToolButton;
    WeekGrid: TStringGrid;

    procedure ApplyButtonClick(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);
    procedure CreateLabelButtonClick(Sender: TObject);
    procedure ButtonEmptyClick(Sender: TObject);
    procedure ButtonLeftClick(Sender: TObject);
    procedure ButtonRightClick(Sender: TObject);
    procedure ButtonUndoClick(Sender: TObject);
    procedure DeleteWeek(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuAddClick(Sender: TObject);
    procedure MenuDeleteClick(Sender: TObject);
    procedure MenuEditClick(Sender: TObject);
    procedure MenuOneDayOffClick(Sender: TObject);
    procedure AddNumberOfDays(Sender: TObject);
    procedure WeekGridEditingDone(Sender: TObject);
    procedure WeekGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);

  private
    { private declarations }
    FWeek: TWorkWeek;                     // The Week as it will be saved when "applying"
    FweekCopy: TWorkWeek;                 // local Copy of the week edited, needed for the "undo"-function
    FWeekIndex: integer;                  // Index of the current week referring to the weeklist in main
    FSelectionIndex: integer;             // Index of the row in the grid that is selected

    FOnRemoveClick: TRemoveEvent;
    FOnApplyClick: TApplyEvent;
    FOnNextWeekClick: TNextWeekEvent;

    procedure UpdateTitel;
    procedure UpdateWindow;

  public
    { public declarations }
    procedure showWeek(AWeek: TWorkWeek; ANumber: integer);

    property OnRemoveClick: TRemoveEvent read FOnRemoveClick write FOnRemoveClick;
    property OnApplyClick: TApplyEvent read FOnApplyClick write FOnApplyClick;
    property OnNextWeekClick: TNextWeekEvent read FOnNextWeekClick write FOnNextWeekClick;
    property WeekIndex: integer read FWeekIndex write FWeekIndex;
  end;

var
  Form3: TForm3;

implementation


{$R *.lfm}

{ TForm3 }

procedure TForm3.FormCreate(Sender: TObject);
begin
  FWeek := TWorkWeek.Create;
  FWeekCopy := TWorkWeek.Create;

  //self.Constraints.MinWidth := Groupbox1.Width;
  self.Constraints.MinWidth := BackButton.Width + ApplyButton.Width+20;
  self.Constraints.MinHeight := Memo1.Height + Label3.Top + 80;//Label3.Top+20;
end;

procedure TForm3.FormDestroy(Sender: TObject);
begin
  FWeek.Free;
  FWeekCopy.Free;
end;

procedure TForm3.MenuAddClick(Sender: TObject);
var
  calDialog: TCalendarDialog;
begin
  calDialog := TCalendarDialog.Create(nil);
  try
    if calDialog.Execute then
    begin
      FWeek.Days.Add(TWorkDay.Create);
      FWeek.WeekLength := FWeek.WeekLength + 1;
      FWeek.Days[FWeek.WeekLength - 1].Date := calDialog.Date;
      FWeek.Days[FWeek.WeekLength - 1].Weekday := RealDayOfWeek(calDialog.Date);
      UpdateWindow;
    end;
  finally
    calDialog.Free;
  end;
end;

procedure TForm3.MenuDeleteClick(Sender: TObject);
begin
  if (MessageDlg('Delete selected day?', txtRemoveMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    if (FSelectionIndex >= 0) and (FSelectionIndex < FWeek.Days.Count) then
    begin
      FWeek.Days.Delete(FSelectionIndex);
      FWeek.WeekLength := FWeek.WeekLength - 1;
      UpdateWindow;
    end;
  end;
end;

procedure TForm3.MenuEditClick(Sender: TObject);
var
  calDialog: TCalendarDialog;
begin
  calDialog := TCalendarDialog.Create(nil);
  calDialog.Date := FWeek.Days[FSelectionIndex].Date;
  try
    if calDialog.Execute then
    begin
      FWeek.Days[FSelectionIndex].Date := calDialog.Date;
      FWeek.Days[FSelectionIndex].Weekday := RealDayOfWeek(calDialog.Date);
      WeekDaysToStringGrid(WeekGrid, FWeek);
    end;
  finally
    calDialog.Free;
  end;
end;

procedure TForm3.MenuOneDayOffClick(Sender: TObject);
begin
  if (FWeek.Days.Count > 0) then
  begin
    if (Sender = MenuOneDayOff) then
    begin
      WeekGrid.Cells[5, FSelectionIndex + 1] := HoursPerDayEdit.Text;
    end;
    if (Sender = MenuHalfDayOff) then
    begin
      WeekGrid.Cells[5, FSelectionIndex + 1] := FloatToStr(StrToFloat(HoursPerDayEdit.Text) / 2);
    end;
  end;
end;

procedure TForm3.AddNumberOfDays(Sender: TObject);
var
  locFrom, locTo: TDate;
  DateDlg: TCalendarDialog;
  I: integer;
begin
  DateDlg := TCalendarDialog.Create(self);
  DateDlg.Title := 'Select first day';
  try
    if DateDlg.Execute then
    begin
      locFrom := DateDlg.Date;

      DateDlg.Title := 'Select last day';
      if DateDlg.Execute then
      begin
        locTo := DateDlg.Date;

        Fweek.WeekLength := FWeek.WeekLength + DaysBetween(locFrom, locTo) + 1;
        for I := 0 to DaysBetween(locFrom, locTo) do
        begin
          FWeek.Days.Add(TWorkDay.Create);
          FWeek.Days[FWeek.Days.Count - 1].Date := locFrom + I;
          FWeek.Days[FWeek.Days.Count - 1].Weekday := RealDayofWeek(locFrom + I);
        end;
      end;
    end;
  finally
    DateDlg.Free;
    updateWindow;
  end;
end;

procedure TForm3.WeekGridEditingDone(Sender: TObject);
var
  I: integer;
begin
  try
    // apply values from grid
    for I := 0 to FWeek.Days.Count - 1 do
    begin
      FWeek.Days[I].StartHour := GetHour(WeekGrid.Cells[3, I + 1]);
      FWeek.Days[I].EndHour := GetHour(WeekGrid.Cells[4, I + 1]);
      FWeek.Days[I].StartMinute := GetMinute(WeekGrid.Cells[3, I + 1]);
      FWeek.Days[I].EndMinute := GetMinute(WeekGrid.Cells[4, I + 1]);
      FWeek.Days[I].TimeOff := StrToFloat(WeekGrid.Cells[5, I + 1]);
    end;
  except
  end;
end;

procedure TForm3.WeekGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  locInt: integer;
begin
  if (Button = mbRight) then
  begin
    if TryStrToInt(WeekGrid.Cells[0, WeekGrid.Row], locInt) then
    begin
      FSelectionIndex := locInt - 1;
      PopUpMenu1.PopUp;
    end
    else
    begin
      FSelectionIndex := -1;
    end;
  end
  else
  begin
    FSelectionIndex := -1;
  end;
end;

procedure TForm3.BackButtonClick(Sender: TObject);
begin
  self.Visible := False;
end;

procedure TForm3.CreateLabelButtonClick(Sender: TObject);
var
  lowest: TDate;
  highest: TDate;
  I: integer;
begin
  lowest := FWeek.Days[0].Date;
  highest := FWeek.Days[0].Date;
  for I := 1 to FWeek.Days.Count - 1 do
  begin
    if (FWeek.Days[I].Date < lowest) then
    begin
      lowest := FWeek.Days[I].Date;
    end;
    if (FWeek.Days[I].Date > highest) then
    begin
      highest := FWeek.Days[I].Date;
    end;
  end;
  if (lowest <> highest) then
  begin
    DescriptionEdit.Text := FormatDateTime('dd.mm.yyyy', lowest) + '   to   ' + FormatDateTime('dd.mm.yyyy', highest);
  end
  else
  begin
    DescriptionEdit.Text := FormatDateTime('dd.mm.yyyy', lowest);
  end;
  UpdateTitel;
end;

procedure TForm3.ApplyButtonClick(Sender: TObject);
var
  locDouble: double;
  I: integer;
begin
  if assigned(FOnApplyClick) then
  begin

    FWeek.WeekLabel := DescriptionEdit.Text;
    if TryStrToFloat(HoursPerDayEdit.Text, locDouble) then
    begin
      FWeek.IntendedTimePerDay := locDouble;
    end;
    if TryStrToFloat(PausePerDayEdit.Text, locDouble) then
    begin
      FWeek.PausePerDay := locDouble;
    end;

    FWeek.DescriptionText.Clear;
    for I := 0 to Memo1.Lines.Count - 1 do
    begin
      FWeek.DescriptionText.Add(Memo1.Lines.Strings[I]);
    end;

    // apply values from grid
    for I := 0 to FWeek.Days.Count - 1 do
    begin
      FWeek.Days[I].StartHour := GetHour(WeekGrid.Cells[3, I + 1]);
      FWeek.Days[I].EndHour := GetHour(WeekGrid.Cells[4, I + 1]);
      FWeek.Days[I].StartMinute := GetMinute(WeekGrid.Cells[3, I + 1]);
      FWeek.Days[I].EndMinute := GetMinute(WeekGrid.Cells[4, I + 1]);
      FWeek.Days[I].TimeOff := StrToFloat(WeekGrid.Cells[5, I + 1]);
    end;

    UpdateTitel;
    FWeekCopy.Assign(FWeek);
    FOnApplyClick(self, FWeek, FWeekIndex);

    // option to close window too
    if (Sender = ApplyButton) then
    begin
      self.Visible := False;
    end;
  end;
  UpdateWindow;
end;

procedure TForm3.ButtonEmptyClick(Sender: TObject);
begin
  FWeek.Clear;
  ClearStringGrid(WeekGrid);
  UpdateWindow;
end;

procedure TForm3.ComboBox1Select(Sender: TObject);
begin
  if assigned(FOnNextWeekClick) then
  begin
    FOnNextWeekClick(self, ComboBox1.ItemIndex);
    UpdateTitel;
    UpdateWindow;
  end;
end;

procedure TForm3.ButtonLeftClick(Sender: TObject);
begin
  // Get previous week
  if assigned(FOnNextWeekClick) then
  begin
    FOnNextWeekClick(self, FWeekIndex - 1);
    UpdateTitel;
    UpdateWindow;
  end;
end;

procedure TForm3.ButtonRightClick(Sender: TObject);
begin
  // Get Next week
  if assigned(FOnNextWeekClick) then
  begin
    FOnNextWeekClick(self, FWeekIndex + 1);
    UpdateTitel;
    UpdateWindow;
  end;
end;

procedure TForm3.ButtonUndoClick(Sender: TObject);
begin
  // Undo all changes and revert to FWeekCopy
  FWeek.Assign(FWeekCopy);
  DescriptionEdit.Text := FWeekCopy.WeekLabel;
  HoursPerDayEdit.Text := FloatToStr(FWeekCopy.IntendedTimePerDay);
  PausePerDayEdit.Text := FloatToStr(FWeekCopy.PausePerDay);
  UpdateTitel;
  UpdateWindow;
end;

procedure TForm3.DeleteWeek(Sender: TObject);
begin
  if (MessageDlg('Delete Data?', txtDeleteMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    if assigned(FOnRemoveClick) then
    begin
      FOnRemoveClick(self, FWeekIndex);
      self.Visible := False;
    end;
  end;
end;


procedure TForm3.showWeek(AWeek: TWorkWeek; ANumber: integer);
var
  I: integer;
begin
  FWeek.Clear;
  FWeek.Assign(AWeek);
  FWeekCopy.Assign(AWeek);
  DescriptionEdit.Text := AWeek.WeekLabel;
  HoursPerDayEdit.Text := FloatToStr(AWeek.IntendedTimePerDay);
  PausePerDayEdit.Text := FloatToStr(AWeek.PausePerDay);
  Memo1.Lines := AWeek.DescriptionText;

  FWeekIndex := ANumber;
  UpdateTitel;
  UpdateWindow;
end;

procedure TForm3.UpdateTitel;
begin
  self.Caption := 'Period #' + IntToStr(FWeekIndex + 1) + ' (' + FWeek.WeekLabel + ')';
end;

procedure TForm3.UpdateWindow;
var
  diff: double;
  I: integer;
begin
  ButtonEmpty.Enabled := (FWeek.Days.Count > 0);
  PopUpMenu1.Items[1].Enabled := (FWeek.Days.Count > 0);
  PopUpMenu1.Items[2].Enabled := (FWeek.Days.Count > 0);

  diff := FWeek.getSum - (FWeek.Days.Count * FWeek.IntendedTimePerDay);

  ColorText(Label3, diff, 0.5);

  WeekDaysToStringGrid(WeekGrid, FWeek);

  Label1.Caption := 'Goal:   ' + FormatFloat('0.00', FWeek.Days.Count * FWeek.IntendedTimePerDay) + ' h';
  Label2.Caption := 'Sum:   ' + FormatFloat('0.00', FWeek.getSum) + ' h';
  Label3.Caption := 'Diff.:  ' + FormatFloat('0.00', diff) + ' h';
end;

end.



