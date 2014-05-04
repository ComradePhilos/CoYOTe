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
  emHoursPerDay = 'Error: Enter a valid amount of time per day!';

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
  locHours: integer;
begin

  // Check if the values are convertable and only execute, if the
  // Event-Handling-Routine has been assigned
  if (TryStrToDate(FromDateEdit.Text, locDate1)) then
  begin
    if (TryStrToDate(ToDateEdit.Text, locDate2)) then
    begin
      if TryStrToInt(HoursPerDayEdit.Text, locHours) then
      begin
        if assigned(FOnApplyClick) then
        begin
          FOnApplyClick(self, TWorkWeek.Create(locDate1, locDate2, locHours));
          self.Visible := False;
        end;
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
var
  locDate1: TDate;
  locDate2: TDate;
  locHours: integer;
begin
  // Check if the Input is valid
  if TryStrToDate(FromDateEdit.Text, locDate1) and TryStrToDate(ToDateEdit.Text, locDate2) then
  begin
    if TryStrToInt(HoursPerDayEdit.Text, locHours) and (locHours > 0) and (locHours <= 24) then
    begin
      if (locDate2 >= locDate1) then
      begin
        ApplyButton.Enabled := True;
        StatusBar1.Panels[0].Text := '';
      end
      else
      begin
        // Wrond Date order
        ApplyButton.Enabled := False;
        StatusBar1.Panels[0].Text := emDateOrder;
      end;
    end
    else
    begin
      // Invalid amount of work time per day
      ApplyButton.Enabled := False;
      StatusBar1.Panels[0].Text := emHoursPerDay;
    end;
  end;
end;


procedure TForm4.Clear;
begin
  FWeek.Clear;
  FromDateEdit.Text := '';
  ToDateEdit.Text := '';
  HoursPerDayEdit.Text := '8';
  ApplyButton.Enabled := False;
end;

end.






