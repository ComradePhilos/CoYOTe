unit WeekAddForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, EditBtn,
  StdCtrls, ExtCtrls, Buttons, workdays;

type

  TApplyEvent = procedure(Sender: TObject; AWeek: TWorkWeek) of object;

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
    FOnApplyClick: TApplyEvent;
    procedure Clear;
  public
    { public declarations }

    //property Week: TWorkWeek read FWeek write FWeek;
    property OnApplyClick: TApplyEvent read FOnApplyClick write FOnApplyClick;
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
  locDate: TDate;
  locWeek: TWorkWeek;
begin

  locWeek := TWorkWeek.Create;
  if (TryStrToDate(FromDateEdit.Text, locDate)) then
  begin
    locWeek.FromDate := locDate;
    if (TryStrToDate(ToDateEdit.Text, locDate)) then
    begin
      locWeek.ToDate := locDate;
      if assigned(FOnApplyClick) then
      begin
        FOnApplyClick(self, locWeek);
      end;
      self.Visible := False;
      locWeek.Free;
    end;
  end;

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





