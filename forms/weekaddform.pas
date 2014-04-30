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
						procedure ApplyButtonClick(Sender: TObject; AWeekList: TWeekList);
      procedure UndoButtonClick(Sender: TObject);
      private
            { private declarations }
      public
            { public declarations }
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

procedure TForm4.ApplyButtonClick(Sender: TObject; AWeekList: TWeekList);
var
  FWeek: TWorkWeek;
begin
  FWeek := TWorkWeek.Create;
  FWeek.FromDate := StrToDate(FromDateEdit.Text);
  AWeekList.Add(FWeek);
end;

end.

