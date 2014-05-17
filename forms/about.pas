unit about;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, lclintf, ComCtrls, types;

type

  { TForm2 }

  TForm2 = class(TForm)
	  Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
		Panel1: TPanel;
    RadioGroup1: TRadioGroup;
    StaticText1: TStaticText;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);


  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }


procedure TForm2.Image1Click(Sender: TObject);
begin
  openDocument('https://github.com/ComradePhilos/CoYOTe');
end;

procedure TForm2.RadioGroup1Click(Sender: TObject);
begin
  Memo1.Lines.LoadFromFile('../docs/versions/' + (RadioGroup1.Items[RadioGroup1.ItemIndex]));
end;

procedure TForm2.FormCreate(Sender: TObject);
var
  files: TStringList;
  searchRec: TSearchRec;
begin
  FindFirst('../docs/versions/*', faAnyFile, searchRec);
  repeat
    if (length(searchRec.Name) > 2) then
    begin
      RadioGroup1.Items.Add(searchRec.Name);
    end;
  until FindNext(searchRec) <> 0;
  FindClose(searchRec);

  //Memo1.Lines.LoadFromFile('../docs/versions.log');
end;






end.