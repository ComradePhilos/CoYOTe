program CoYOTe;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, runtimetypeinfocontrols, main, workdays, funcs, CoyoteDefaults, people,
	about, WeekEditForm, WeekAddForm, personeditform, DBConnectForm, settingsform;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
	Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm6, Form6);
	Application.CreateForm(TForm7, Form7);
  Application.Run;
end.