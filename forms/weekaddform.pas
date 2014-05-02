unit WeekAddForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, EditBtn,
  StdCtrls, ExtCtrls, Buttons, ComCtrls, workdays;

type

  TApplyEvent = procedure(Sender: TObject; AWeek: TWorkWeek) of object;

  { TForm4 }

  TForm4 = class(TForm)
    ApplyButton: TBitBtn;
    FromDateEdit: TDateEdit;
    HoursPerDayEdit: TLabeledEdit;
    Label1: TLabel;
    Label2: TLabel;
		StatusBar1: TStatusBar;
    ToDateEdit: TDateEdit;
    UndoButton: TBitBtn;
    procedure ApplyButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckInputs(Sender: TObject);
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

const
  emDateOrder = 'Error: The dates are in the wrong order!';

{$R *.lfm}

{ TForm4 }

procedure TForm4.UndoButtonClick(Sender: TObject);
begin
  self.Visible := False;
end;

procedure TForm4.ApplyButtonClick(Sender: TObject);
var
  locDate1: TDate;
  locDate2: TDate;
begin

  if (TryStrToDate(FromDateEdit.Text, locDate1)) then
  begin
    if (TryStrToDate(ToDateEdit.Text, locDate2)) then
    begin
      if assigned(FOnApplyClick) then
      begin
        FOnApplyClick(self, TWorkWeek.Create(locDate1, locDate2));
        self.Visible := False;
      end;
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

procedure TForm4.CheckInputs(Sender: TObject);
begin
  // Check if the Input is valid
  if (length(FromDateEdit.Text) > 0) and (length(ToDateEdit.Text) > 0) then
  begin
    if (StrToDate(ToDateEdit.Text) >= StrToDate(FromDateEdit.Text)) then
    begin
      ApplyButton.Enabled := True;
      StatusBar1.Panels[0].Text := '';
    end
    else
    begin
      ApplyButton.Enabled := False;
      StatusBar1.Panels[0].Text := emDateOrder;
    end;
  end;
end;


procedure TForm4.Clear;
begin
  FWeek.Clear;
  FromDateEdit.Text := '';
  ToDateEdit.Text := '';
  HoursPerDayEdit.Text := '';
  ApplyButton.Enabled := False;
end;

end.






