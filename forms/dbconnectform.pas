// TODO:
// * use the main IB-Connection instead of this local one. Maybe using a reference to the
//   instance in the main form
// * maybe only use this window as an input. The main programme will then decide when to connect to the database

unit DBConnectForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IBConnection, FileUtil, Forms, Controls, Graphics, Dialogs,
  Buttons, ExtCtrls, maskedit, StdCtrls, ComCtrls,
  CoyoteDefaults;

type

  TDBConnectEvent = procedure(Sender: TObject; canConnect: Boolean) of object;

  { TForm6 }

  TForm6 = class(TForm)
    BitBtn2: TBitBtn;
		BitBtn3: TBitBtn;
		ConnectBtn1: TBitBtn;
    IBConnection1: TIBConnection;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    LabeledEdit4: TLabeledEdit;
    LabeledEdit5: TLabeledEdit;
    StatusBar1: TStatusBar;
		procedure BitBtn3Click(Sender: TObject);
  procedure ConnectBtn1Click(Sender: TObject);
    procedure ConnectBtnClick(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure DisconnectBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IBConnection1AfterConnect(Sender: TObject);
    procedure IBConnection1AfterDisconnect(Sender: TObject);
  private
    { private declarations }
    FDBConnectEvent: TDBConnectEvent;
  public
    { public declarations }
    property DBConnectEvent: TDBConnectEvent read FDBConnectEvent write FDBConnectEvent;
  end;

var
  Form6: TForm6;

implementation

{$R *.lfm}

{ TForm6 }

procedure TForm6.FormCreate(Sender: TObject);
begin
  {
  LabeledEdit1.Text := '';                        // will be loaded from settings file in future
  LabeledEdit2.Text := dbDefaultFirebirdPort;
  LabeledEdit3.Text := dbDefaultFirebirdUser;
  LabeledEdit5.Text := '';   }
end;

procedure TForm6.IBConnection1AfterConnect(Sender: TObject);
begin
  Statusbar1.Panels[0].Text := 'Database is connectable! =)';
  //ConnectBtn.Enabled := False;
  //DisconnectBtn.Enabled := True;
  FDBConnectEvent(self, True);
end;

procedure TForm6.IBConnection1AfterDisconnect(Sender: TObject);
begin
  //Statusbar1.Panels[0].Text := 'Datenbank Verbindung getrennt...';
  //ConnectBtn.Enabled := True;
  //DisconnectBtn.Enabled := False;
end;

procedure TForm6.BitBtn2Click(Sender: TObject);
begin
  self.Visible := False;
end;

procedure TForm6.DisconnectBtnClick(Sender: TObject);
begin
  IBconnection1.Close();
end;

procedure TForm6.ConnectBtnClick(Sender: TObject);
begin
  IBConnection1.HostName := LabeledEdit1.Text;
  if (LabeledEdit2.Text <> '') then
  begin
    IBConnection1.HostName := IBConnection1.HostName + ':' + LabeledEdit2.Text;
  end;
  IBConnection1.DatabaseName := LabeledEdit5.Text;
  IBConnection1.UserName := LabeledEdit3.Text;
  IBConnection1.Password := LabeledEdit4.Text;

  IBConnection1.Open;

end;

procedure TForm6.ConnectBtn1Click(Sender: TObject);
begin
  FDBConnectEvent(self, False);
  Statusbar1.Panels[0].Text := 'Database is not connectable! =(';
  try
    connectbtnClick(nil);
	except
    on e:Exception do
    begin
		end;
	end;
	DisconnectBtnClick(nil);
end;

procedure TForm6.BitBtn3Click(Sender: TObject);
begin
  LabeledEdit1.Text := '';
  LabeledEdit2.Text := '';
  LabeledEdit3.Text := '';
  LabeledEdit4.Text := '';
  LabeledEdit5.Text := '';
end;

end.

