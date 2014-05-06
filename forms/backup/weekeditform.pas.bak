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

  { TForm3 }

  TForm3 = class(TForm)
    ApplyButton: TBitBtn;
    BackButton: TBitBtn;
		HoursPerDayEdit: TLabeledEdit;
    ImageList1: TImageList;
    Label1: TLabel;
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

    procedure arrow1Click(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
    procedure DeleteWeek(Sender: TObject);
    procedure FormCreate(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure MenuAddClick(Sender: TObject);
		procedure MenuDeleteClick(Sender: TObject);
		procedure MenuEditClick(Sender: TObject);
    procedure UndoButtonClick(Sender: TObject);
		procedure WeekGridMouseUp(Sender: TObject; Button: TMouseButton;
					Shift: TShiftState; X, Y: Integer);
  private
    { private declarations }
    FWeek: TWorkWeek;
    FWeekIndex: integer;
    FSelectionIndex: Integer;
    FOnRemoveClick: TRemoveEvent;
  public
    { public declarations }
    procedure showWeek(AWeek: TWorkWeek; ANumber: integer);

    property OnRemoveClick: TRemoveEvent read FOnRemoveClick write FOnRemoveClick;
  end;

var
  Form3: TForm3;

implementation

const
  txtDeleteMsg = 'Are you sure you want to delete the period with all data? This cannot be made undone afterwards!';

{$R *.lfm}

{ TForm3 }

procedure TForm3.FormCreate(Sender: TObject);
begin
  FWeek := TWorkWeek.create;
end;

procedure TForm3.FormDestroy(Sender: TObject);
begin
  FWeek.Free;
end;

procedure TForm3.MenuAddClick(Sender: TObject);
begin
  FWeek.Days.Add(TWorkDay.Create);
  FWeek.WeekLength := FWeek.WeekLength + 1;
  //FWeek.Days[FWeek.Days.Count-1].;
  WeekDaysToStringGrid(WeekGrid, FWeek);
  Label1.Caption := 'Period #' + IntToStr(FWeekIndex + 1) + ' (Length: ' + IntToStr(FWeek.WeekLength) + ' days)';
  //Application.MessageBox(PChar('Days: ' + IntToStr(FWeek.WeekLength)),'days',0);
end;

procedure TForm3.MenuDeleteClick(Sender: TObject);
begin
  if (MessageDlg('Delete Data?', txtDeleteMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
   if (FSelectionIndex >= 0) and (FSelectionIndex < FWeek.Days.Count) then
   begin
    FWeek.Days.Delete(FSelectionIndex);
    FWeek.WeekLength := FWeek.WeekLength-1;
    WeekDaysToStringGrid(WeekGrid, FWeek);
    Label1.Caption := 'Period #' + IntToStr(FWeekIndex + 1) + ' (Length: ' + IntToStr(FWeek.WeekLength) + ' days)';
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
     WeekDaysToStringGrid(WeekGrid,FWeek);
		end;
	finally
    calDialog.Free;
	end;

end;

procedure TForm3.UndoButtonClick(Sender: TObject);
begin

end;

procedure TForm3.WeekGridMouseUp(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbRight) then
  begin
    FSelectionIndex := Weekgrid.Row-1;
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

procedure TForm3.arrow1Click(Sender: TObject);
begin

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
  FWeek := AWeek;
  Label1.Caption := 'Period #' + IntToStr(ANumber + 1) + ' (Length: ' + IntToStr(FWeek.WeekLength) + ' days)';
  FWeekIndex := ANumber;
  WeekDaysToStringGrid(WeekGrid, FWeek);
end;


end.

