unit insertToIndexForm;

{$mode objfpc}{$H+}

interface

uses
      Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
			ComCtrls, Spin, Buttons;

type

			{ TInsertToIndexForm }

      TInsertToIndexForm = class(TForm)
						SpinEdit1: TSpinEdit;
      private
            { private declarations }
      public
            { public declarations }
        procedure Init(AMax, AMin: Integer);
      end;

var
      Form8: TInsertToIndexForm;

implementation

procedure TInsertToIndexForm.Init(AMax, AMin: Integer);
begin
  SpinEdit1.MaxValue := AMax;
  SpinEdit1.MinValue := AMin;
end;

{$R *.lfm}

end.

