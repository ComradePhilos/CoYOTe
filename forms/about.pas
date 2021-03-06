unit about;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IpHtml, Ipfilebroker, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, lclintf, ComCtrls, CheckLst, types,
  funcs;

type

  { TForm2 }

  TForm2 = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    PageControl1: TPageControl;
    Panel1: TPanel;
    StaticText1: TStaticText;
		StatusBar1: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Contributors: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure OpenGithubClick(Sender: TObject);
    procedure OpenGPLClick(Sender: TObject);
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


procedure TForm2.OpenGithubClick(Sender: TObject);
begin
  OpenURL('https://github.com/ComradePhilos/CoYOTe');
end;


procedure TForm2.OpenGPLClick(Sender: TObject);
begin
  OpenURL('http://www.gnu.org/licenses/gpl-3.0.txt');
end;

procedure TForm2.RadioGroup1Click(Sender: TObject);
begin
  if (ListBox1.ItemIndex >= 0) then
  begin
    Memo1.Lines.LoadFromFile('../docs/versions/' + (ListBox1.Items[ListBox1.ItemIndex]));
  end;
end;

procedure TForm2.FormCreate(Sender: TObject);
var
  searchRec: TSearchRec;
  AboutText: TStringList;
begin
  PageControl1.PageIndex := 1;
  FindFirst('../docs/versions/*', faAnyFile, searchRec);
  repeat
    if (length(searchRec.Name) > 2) then
    begin
      ListBox1.Items.Add(searchRec.Name);
      ListBox1.ItemIndex := ListBox1.Items.Count - 1;
      RadioGroup1Click(self);
    end;
  until FindNext(searchRec) <> 0;
  FindClose(searchRec);

  try
    Memo2.Lines.LoadFromFile('../docs/about.txt');
  except
    Memo2.Lines[0] := 'about.txt not found!';
  end;

  try
    Memo3.Lines.LoadFromFile('../docs/gpl.txt');
  except
    Memo3.Lines.Add('License Text not found!');
  end;

  self.Constraints.MinHeight := (Panel1.Top*2) + Panel1.Height;
  self.Constraints.MinWidth := (Panel1.Left*2) + Panel1.Width;

end;

end.
