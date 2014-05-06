unit WeekEditForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  Buttons, StdCtrls, Arrow, ExtCtrls, Menus,
  { eigene Units }
  workdays, funcs;

type

  TRemoveEvent = procedure(Sender: TObject; Index: integer) of object;

  { TForm3 }

  TForm3 = class(TForm)
    ApplyButton: TBitBtn;
    BackButton: TBitBtn;
		HoursPerDayEdit: TLabeledEdit;
    Label1: TLabel;
		MenuItem1: TMenuItem;
		MenuItem2: TMenuItem;
		MenuItem3: TMenuItem;
		MenuItem4: TMenuItem;
		MenuItem5: TMenuItem;
		PopupMenu1: TPopupMenu;
    UndoButton: TBitBtn;
    UndoButton1: TBitBtn;
    arrow2: TBitBtn;
    arrow1: TBitBtn;
    WeekGrid: TStringGrid;

    procedure BackButtonClick(Sender: TObject);
    procedure DeleteWeek(Sender: TObject);
    procedure FormCreate(Sender: TObject);
		procedure MenuItem2Click(Sender: TObject);
  private
    { private declarations }
    FIndex: integer;
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

end;

procedure TForm3.MenuItem2Click(Sender: TObject);
begin
  if (MessageDlg('Delete Data?', txtDeleteMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
   // WeekGrid.SelectedColumn.Index;
	end;
end;

procedure TForm3.BackButtonClick(Sender: TObject);
begin
  self.Visible := False;
end;

procedure TForm3.DeleteWeek(Sender: TObject);
begin
  if (MessageDlg('Delete Data?', txtDeleteMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    if assigned(FOnRemoveClick) then
    begin
      FOnRemoveClick(self, FIndex);
      self.Visible := False;
    end;
  end;
end;


procedure TForm3.showWeek(AWeek: TWorkWeek; ANumber: integer);
begin
  Label1.Caption := 'Period #' + IntToStr(ANumber + 1) + ' (Length: ' + IntToStr(AWeek.WeekLength) + ' days)';
  FIndex := ANumber;
  WeekDaysToStringGrid(WeekGrid, AWeek);
end;


end.

