unit WeekAddForm;

{$mode objfpc}{$H+}

interface

uses
      Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, EditBtn,
			StdCtrls, ExtCtrls, Buttons;

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
      private
            { private declarations }
      public
            { public declarations }
      end;

var
      Form4: TForm4;

implementation

{$R *.lfm}

end.

