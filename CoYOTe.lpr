program CoYOTe;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  runtimetypeinfocontrols,
  main,
  workdays,
  funcs,
  about, WeekEditForm, addweekform;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
	Application.CreateForm(TForm3, Form3);
	Application.CreateForm(TForm4, Form4);
  Application.Run;
end.
