unit SettingsForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, ValEdit, ButtonPanel, Buttons, Grids, ColorBox, StdCtrls,
  { own Units }
  CoyoteDefaults;

type

  { TForm7 }

  TForm7 = class(TForm)
    ApplyButton: TBitBtn;
    BackButton: TBitBtn;
		ColorButton1: TColorButton;
		ColorButton2: TColorButton;
		Label1: TLabel;
		Label2: TLabel;
    ResetButton: TBitBtn;
    ImageList1: TImageList;
    PageControl1: TPageControl;
    StringGrid1: TStringGrid;
    TabSheet1: TTabSheet;
		TabSheet2: TTabSheet;
    procedure ApplyButtonClick(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
		procedure ResetButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form7: TForm7;

implementation

uses main;

{$R *.lfm}

{ TForm7 }

procedure TForm7.FormCreate(Sender: TObject);
begin
  self.Constraints.MinWidth := ApplyButton.Width + BackButton.Width + ResetButton.Width + (3 * 10);
  self.Constraints.MinHeight := self.Height;
end;

procedure TForm7.ResetButtonClick(Sender: TObject);
begin

  //defHoursUntilPause := 6;
  //defPausePerDay := 0.75;
  //defHoursPerDay := 8;
  //colorMarkedDays := $000080FF;
  //colorVacationDays := $00FF0080;

  StringGrid1.Cells[1,1] := FloatToStr(8);
  StringGrid1.Cells[1,2] := FloatToStr(0.75);
  StringGrid1.Cells[1,3] := FloatToStr(6);

  ColorButton1.ButtonColor := $000080FF;
  ColorButton2.ButtonColor := $00FF0080;

end;

procedure TForm7.BackButtonClick(Sender: TObject);
begin
  self.Visible := False;
end;

procedure TForm7.ApplyButtonClick(Sender: TObject);
begin
  try
    defHoursPerDay := StrToFloat(StringGrid1.Cells[1, 1]);
    defPausePerDay := StrToFloat(StringGrid1.Cells[1, 2]);
    defHoursUntilPause := StrToFloat(StringGrid1.Cells[1, 3]);
    self.Visible := False;
  except
    on e: EConvertError do
    begin
      application.MessageBox(PChar(emInvalidNumber),
        'Invalid Input', 0);
    end;
  end;

  colorMarkedDays := ColorButton1.ButtonColor;
  colorVacationDays := ColorButton2.ButtonColor;

end;

end.
