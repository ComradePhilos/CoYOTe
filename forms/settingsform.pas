unit SettingsForm;

{$mode objfpc}{$H+}

interface

uses
      Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
			ExtCtrls, ValEdit, ButtonPanel, Buttons;

type

			{ TForm7 }

      TForm7 = class(TForm)
						BitBtn1: TBitBtn;
						BitBtn2: TBitBtn;
						BitBtn3: TBitBtn;
						ImageList1: TImageList;
						PageControl1: TPageControl;
						TabSheet1: TTabSheet;
						procedure BitBtn2Click(Sender: TObject);
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
  self.Constraints.MinWidth := BitBtn1.Width + BitBtn2.Width + BitBtn3.Width + (3*10);
  self.Constraints.MinHeight := self.Height;
end;

procedure TForm7.BitBtn2Click(Sender: TObject);
begin
  self.Visible := False;
end;

end.

