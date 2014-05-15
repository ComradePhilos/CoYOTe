unit WeekAddForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, EditBtn,
  StdCtrls, ExtCtrls, Buttons, ComCtrls, Calendar,
  workdays, WeekEditForm,
  CoyoteDefaults;

type

  TApplyEvent = procedure(Sender: TObject; AWeek: TWorkWeek; EditAfterwards: boolean) of object;

  { TForm4 }

  TForm4 = class(TForm)
    ApplyButton: TBitBtn;
    Calendar1: TCalendar;
    Calendar2: TCalendar;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    StatusBar1: TStatusBar;
    UndoButton: TBitBtn;
    procedure ApplyButtonClick(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckInputs(Sender: TObject);
    procedure UndoButtonClick(Sender: TObject);

  private
    { private declarations }
    FOnApplyClick: TApplyEvent;
    procedure Clear;
  public
    { public declarations }

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
  locDate1: TDate;
  locDate2: TDate;
begin

  if CheckBox2.Checked then
  begin
    FOnApplyClick(self, TWorkWeek.Create, CheckBox1.Checked);
    self.Visible := False;
  end
  else
  begin
    // Check if the values are convertable and only execute, if the
    // Event-Handling-Routine has been assigned
    if (TryStrToDate(Calendar1.Date, locDate1)) then
    begin
      if (TryStrToDate(Calendar2.Date, locDate2)) then
      begin
        if assigned(FOnApplyClick) then
        begin
          FOnApplyClick(self, TWorkWeek.Create(locDate1, locDate2), CheckBox1.Checked);
          self.Visible := False;
        end;
      end;
    end;
  end;

end;

procedure TForm4.CheckBox2Change(Sender: TObject);
begin
  //{$IFDEF mswindows}
  //Calendar1.Visible := not CheckBox2.Checked;     // Would look shitty in windows otherwise
  //Calendar2.Visible := not CheckBox2.Checked;
  //{$ENDIF}
  Calendar1.Enabled := not CheckBox2.Checked;
  Calendar2.Enabled := not CheckBox2.Checked;
  CheckInputs(self);
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  Clear;
end;

procedure TForm4.FormDestroy(Sender: TObject);
begin
end;

procedure TForm4.FormShow(Sender: TObject);
begin
  Clear;
  CheckInputs(self);
end;

procedure TForm4.CheckInputs(Sender: TObject);
var
  locDate1: TDate;
  locDate2: TDate;
  locHours: integer;
begin
  if not CheckBox2.Checked then
  begin
    ApplyButton.Enabled := False;
    // Check if the Input is valid
    if TryStrToDate(Calendar1.Date, locDate1) and TryStrToDate(Calendar2.Date, locDate2) then
    begin
      if (locDate2 >= locDate1) then
      begin
        ApplyButton.Enabled := True;
        StatusBar1.Panels[0].Text := '';
      end
      else
      begin
        // Wrong Date order
        ApplyButton.Enabled := False;
        StatusBar1.Panels[0].Text := emDateOrder;
      end;
    end;
  end
  else
  begin
    ApplyButton.Enabled := True;
    StatusBar1.Panels[0].Text := '';
  end;
end;


procedure TForm4.Clear;
begin
  ApplyButton.Enabled := False;
end;

end.






