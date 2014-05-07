unit WeekEditForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  Buttons, StdCtrls, Arrow, ExtCtrls, Menus, ExtDlgs, ComCtrls,
  { eigene Units }
  workdays, funcs;

type

  TRemoveEvent = procedure(Sender: TObject; Index: integer) of object;
  TApplyEvent = procedure(Sender: TObject; AWeek: TWorkWeek; Index: Integer) of Object;
  TNextWeekEvent = procedure(Sender: TObject; var AWeek: TWorkWeek; Index: Integer) of Object;

  { TForm3 }

  TForm3 = class(TForm)
    ApplyButton: TBitBtn;
    BackButton: TBitBtn;
		BitBtn1: TBitBtn;
    HoursPerDayEdit: TLabeledEdit;
		DescriptionEdit: TLabeledEdit;
    ImageList1: TImageList;
    MenuIgnore: TMenuItem;
    MenuDelete: TMenuItem;
    MenuEdit: TMenuItem;
    MenuAdd: TMenuItem;
    PopupMenu1: TPopupMenu;
    ToolBar1: TToolBar;
    ButtonLeft: TToolButton;
    ButtonRight: TToolButton;
    ToolButton1: TToolButton;
    ButtonAdd: TToolButton;
    ButtonRemove: TToolButton;
    ButtonEmpty: TToolButton;
    ButtonApply: TToolButton;
    ToolButton5: TToolButton;
    ButtonUndo: TToolButton;
    ButtonDelete: TToolButton;
    WeekGrid: TStringGrid;

    procedure ApplyButtonClick(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
		procedure BitBtn1Click(Sender: TObject);
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
    procedure WeekGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
  private
    { private declarations }
    FWeek: TWorkWeek;
    FweekCopy: TWorkWeek;
    FWeekIndex: integer;
    FSelectionIndex: integer;
    FOnRemoveClick: TRemoveEvent;
    FOnApplyClick: TApplyEvent;
    FOnNextWeekClick: TNextWeekEvent;

    procedure UpdateTitel;
  public
    { public declarations }
    procedure showWeek(AWeek: TWorkWeek; ANumber: integer);

    property OnRemoveClick: TRemoveEvent read FOnRemoveClick write FOnRemoveClick;
    property OnApplyClick: TApplyEvent read FOnApplyClick write FOnApplyClick;
    property OnNextWeekClick: TNextWeekEvent read FOnNextWeekClick write FOnNextWeekClick;
    property WeekIndex: Integer read FWeekIndex write FWeekIndex;
  end;

var
  Form3: TForm3;

implementation

const
  txtDeleteMsg = 'Are you sure you want to delete this period including all days related to it? This cannot be made undone afterwards!';
  txtRemoveMsg = 'Do you really want to delete the selected day? This will delete all data related to it!';
  txtClearMsg = 'This will clear the current week and make it empty but will NOT delete the week! Do you wish to Continue?';

{$R *.lfm}

{ TForm3 }

procedure TForm3.FormCreate(Sender: TObject);
begin
  FWeek := TWorkWeek.Create;
  FWeekCopy := TWorkWeek.Create;
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
      WeekDaysToStringGrid(WeekGrid, FWeek);
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
      WeekDaysToStringGrid(WeekGrid, FWeek);
    end;
  end;
end;

procedure TForm3.MenuEditClick(Sender: TObject);
var
  calDialog: TCalendarDialog;
begin
  calDialog := TCalendarDialog.Create(nil);
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

procedure TForm3.WeekGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  if (Button = mbRight) then
  begin
    FSelectionIndex := Weekgrid.Row - 1;
    PopUpMenu1.PopUp;
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

procedure TForm3.BitBtn1Click(Sender: TObject);
var
  lowest: TDate;
  highest: TDate;
  I: Integer;
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
  DescriptionEdit.Text := DateToStr(lowest) + ' - ' + DateToStr(highest);
  UpdateTitel;
end;

procedure TForm3.ApplyButtonClick(Sender: TObject);
begin
  if assigned(FOnApplyClick) then
  begin
    FWeek.WeekLabel := DescriptionEdit.Text;
    FOnApplyClick(self, FWeek, FWeekIndex);
    self.Visible := False;
	end;
end;

procedure TForm3.ButtonEmptyClick(Sender: TObject);
begin
  if (MessageDlg('Delete selected day?', txtRemoveMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    FWeek.Clear;
    ClearStringGrid(WeekGrid);
  end;
end;

procedure TForm3.ButtonLeftClick(Sender: TObject);
begin
  if assigned(FOnNextWeekClick) then
  begin
    FOnNextWeekClick(self, FWeek, FWeekIndex-1);
    UpdateTitel;
  end;
end;

procedure TForm3.ButtonRightClick(Sender: TObject);
begin
  if assigned(FOnNextWeekClick) then
  begin
    FOnNextWeekClick(self, FWeek, FWeekIndex+1);
    UpdateTitel;
  end;
end;

procedure TForm3.ButtonUndoClick(Sender: TObject);
begin
  FWeek.assign(FWeekCopy);
  WeekDaysToStringGrid(WeekGrid, FWeek);
  DescriptionEdit.Text := FWeekCopy.WeekLabel;
  UpdateTitel;
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
begin
  FWeek.assign(AWeek);
  FWeekCopy.assign(AWeek);
  DescriptionEdit.Text := AWeek.WeekLabel;
  FWeekIndex := ANumber;
  WeekDaysToStringGrid(WeekGrid, FWeek);
  UpdateTitel;
end;

procedure TForm3.UpdateTitel;
begin
  self.Caption := 'Period #' + IntToStr(FWeekIndex + 1) + ' (' + FWeek.WeekLabel + ')';
end;

end.



