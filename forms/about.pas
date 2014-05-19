unit about;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, lclintf, ComCtrls, CheckLst, types, IBConnection, FBAdmin;

type

  { TForm2 }

  TForm2 = class(TForm)
	  Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
		Label3: TLabel;
    Label4: TLabel;
		ListBox1: TListBox;
    Memo1: TMemo;
		Memo2: TMemo;
    PageControl1: TPageControl;
		Panel1: TPanel;
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
  Memo1.Lines.LoadFromFile('../docs/versions/' + (ListBox1.Items[ListBox1.ItemIndex]));
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
      ListBox1.Items.Add(searchRec.Name);
    end;
  until FindNext(searchRec) <> 0;
  FindClose(searchRec);
end;

end.
