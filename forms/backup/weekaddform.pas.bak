unit WeekAddForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, EditBtn,
  StdCtrls, ExtCtrls, Buttons, workdays;

type

  { TForm4 }

  TForm4 = class(TForm)
    ApplyButton: TBitBtn;
    FromDateEdit: TDateEdit;
    HoursPerDayEdit: TLabeledEdit;
    Label1: TLabel;
    Label2: TLabel;
    ToDateEdit: TDateEdit;
    UndoButton: TBitBtn;
    procedure ApplyButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure UndoButtonClick(Sender: TObject);

  private
    { private declarations }
    FWeek: TWorkWeek;

    procedure Clear;
  public
    { public declarations }

    property Week: TWorkWeek read FWeek write FWeek;
  end;

var
  Form4: TForm4;

implementation

{$R *.lfm}

{ TForm4 }

procedure TForm4.UndoButtonClick(Sender: TObject);
begin
  self.Visible := False;
end;

procedure TForm4.ApplyButtonClick(Sender: TObject);
var
  FDate: TDate;
begin
  FWeek.Clear;

  if (TryStrToDate(FromDateEdit.Text, FDate)) then
  begin
    FWeek.FromDate := FDate;
  end;
  if (TryStrToDate(FromDateEdit.Text, FDate)) then
  begin
    FWeek.FromDate := FDate;
  end;

  self.Visible := False;

end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  FWeek := TworkWeek.Create;
  Clear;
end;

procedure TForm4.FormDestroy(Sender: TObject);
begin
  FWeek.Free;
end;

procedure TForm4.FormShow(Sender: TObject);
begin
  Clear;
end;


procedure TForm4.Clear;
begin
  FWeek.Clear;
  FromDateEdit.Text := '';
  ToDateEdit.Text := '';
  HoursPerDayEdit.Text := '';
end;

end.

