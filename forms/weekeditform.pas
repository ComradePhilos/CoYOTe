unit WeekEditForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  Buttons, StdCtrls, Arrow,
  { eigene Units }
  workdays, funcs;

type

    TRemoveEvent = procedure(Sender: TObject; Index: Integer) of object;

  { TForm3 }

  TForm3 = class(TForm)
    ApplyButton: TBitBtn;
    BackButton: TBitBtn;
    Label1: TLabel;
    UndoButton: TBitBtn;
		UndoButton1: TBitBtn;
		arrow2: TBitBtn;
		arrow1: TBitBtn;
    WeekGrid: TStringGrid;

    procedure BackButtonClick(Sender: TObject);
		procedure DeleteWeek(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
    FWeek: TWorkWeek;
    FIndex: Integer;

    FOnRemoveClick: TRemoveEvent;
  public
    { public declarations }
    procedure showWeek(AWeek: TWorkWeek; ANumber: Integer);

    property OnRemoveClick: TRemoveEvent read FOnRemoveClick write FOnRemoveClick;
  end;

var
  Form3: TForm3;

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.FormCreate(Sender: TObject);
begin

end;

procedure TForm3.BackButtonClick(Sender: TObject);
begin
  self.Visible := False;
end;

procedure TForm3.DeleteWeek(Sender: TObject);
begin
   if assigned(FOnRemoveClick) then
   begin
     FOnRemoveClick(self, FIndex);
     self.Visible := False;
   end;
end;


procedure TForm3.showWeek(AWeek: TWorkWeek; ANumber: Integer);
begin
  Label1.Caption := 'Period #' + IntToStr(ANumber+1) + ' (Length: ' + IntToStr(AWeek.WeekLength) +')' ;
  FIndex := ANumber;
  WeekDaysToStringGrid(WeekGrid, AWeek);
end;


end.

