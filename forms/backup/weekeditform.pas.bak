unit WeekEditForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  Buttons, StdCtrls, Arrow,
  { eigene Units }
  workdays, funcs;

type

  { TForm3 }

  TForm3 = class(TForm)
    ApplyButton: TBitBtn;
    Arrow1: TArrow;
    Arrow2: TArrow;
    BackButton: TBitBtn;
    Label1: TLabel;
    UndoButton: TBitBtn;
    WeekGrid: TStringGrid;

    procedure BackButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
    FWeek: TWorkWeek;
  public
    { public declarations }
    procedure showWeek(AWeek: TWorkWeek; ANumber: Integer);
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

procedure TForm3.showWeek(AWeek: TWorkWeek; ANumber: Integer);
begin
  Label1.Caption := 'Period ' + IntToStr(ANumber+1) + ' (Length: ' + IntToStr(AWeek.WeekLength) +')' ;
  WeekDaysToStringGrid(WeekGrid, AWeek);
end;


end.

