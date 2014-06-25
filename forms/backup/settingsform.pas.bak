unit SettingsForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, ValEdit, ButtonPanel, Buttons, Grids,
  { own Units }
  CoyoteDefaults;

type

  { TForm7 }

  TForm7 = class(TForm)
    ApplyButton: TBitBtn;
    BackButton: TBitBtn;
    ResetButton: TBitBtn;
    ImageList1: TImageList;
    PageControl1: TPageControl;
    StringGrid1: TStringGrid;
    TabSheet1: TTabSheet;
    procedure ApplyButtonClick(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form7: TForm7;

implementation

{$R *.lfm}

{ TForm7 }

procedure TForm7.FormCreate(Sender: TObject);
begin
  self.Constraints.MinWidth := ApplyButton.Width + BackButton.Width + ResetButton.Width + (3 * 10);
  self.Constraints.MinHeight := self.Height;
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

end;

end.
