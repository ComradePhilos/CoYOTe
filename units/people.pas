{
  A unit that will contain all classes and functions that relate to people
  and groups of people. These are the "users" that are selectable in the main
  programme. Each person will have its own tables.

  NOTE that these TPersons are not USERS! TPerson just holds Data of a person
  you want to track working time of/for! So the first/default Person is you.

}

unit people;

interface

uses Classes, fgl, ExtCtrls, StdCtrls, SysUtils, workdays;

type

  // The list of weeklists
  TTimeData = specialize TFPGObjectList<TWeekList>;

  // The class that implements the people
  TPerson = class
    private
      FFirstName: String;               // First Name (can be multiple names like "Horst Kevin Jerome" :D )
      FFamilyName: String;              // Family Name
      FIDNumber: String;                // ID Number of the person in a company/team etc...
      FInternalID: Integer;             // programme-internal ID number that is unique and automatically generated
      FResidence: String;               // Where does the person live
      FStreet: String;                  // Adress-Information e.g. street
      FStreetNR: String;                // Street number
      FPhoneNumber1: String;            // Phone Numbers
      FPhoneNumber2: String;
      FEMail: String;                   // Email-Adress / nice word play ^^ Femail

      FPhoto: TImage;                                                      // whole picture binarily OR don't use any pictur
      FDaysOfVacationPerYear: Double;   // May be set either globally or for each person uniquely

      FListName: TStringList;           // List of the names referring to a WeekList in FTimeData
      FTimeData: TTimeData;    // A List of TWeekLists - This is what you see in main window/e.g. for each year

    public

      constructor Create; overload;
      constructor Create(APerson: TPerson); overload;
      destructor Destroy;
      procedure Clear;
      procedure Assign(APerson: TPerson);

      function NameToText: String;

      property FirstName: String read FFirstName write FFirstName;
      property FamilyName: String read FFamilyName write FFamilyName;
      property ID: String read FIDNumber write FIDNumber;
      property Residence: String read FResidence write FResidence;
      property Street: String read FStreet write FStreet;
      property StreetNR: String read FStreetNR write FStreetNR;
      property PhoneNumber1: String read FPhoneNumber1 write FPhoneNumber1;
      property PhoneNumber2: String read FPhoneNumber2 write FPhoneNumber2;
      property EMail: String read FEMail write FEMail;
      property TimeData: TTimeData read FTimeData write FTimeData;
  end;

  TPersonList = specialize TFPGObjectList<TPerson>;

  procedure NamesToComboBox(AComboBox: TCombobox; Persons: TPersonList);
  procedure WeekListsToComboBox(AComboBox: TCombobox; ATimeData: TTimeData);
  function GetEarliestDayOfTimeData(ATimeData: TTimeData): TWorkDay;

implementation

constructor TPerson.Create;
begin
  FTimeData := TTimeData.Create;
  Clear;
end;

constructor TPerson.Create(APerson: TPerson);
begin
  self.Assign(APerson);     // copies the values of the other instance
end;

destructor TPerson.Destroy;
begin
  FTimeData.Free;
end;

procedure TPerson.Assign(APerson: TPerson);
begin
  FFamilyName := APerson.FamilyName;
  FFirstName := APerson.FirstName;
  FResidence := APerson.Residence;
  FStreet := APerson.Street;
  FStreetNR := APerson.StreetNR;
  FPhoneNumber1 := APerson.PhoneNumber1;
  FPhoneNumber2 := APerson.PhoneNumber2;
  FEMail := APerson.EMail;
  FTimeData.Assign(APerson.TimeData);
end;

procedure TPerson.Clear;
begin
  FFirstName := '';
  FFamilyName := '';
  FResidence := '';
  FStreet := '';
  FStreetNR := '';
  FPhoneNumber1 := '';
  FPhoneNumber2 := '';
  FEMail := '';

  FTimeData.Clear;
end;

function TPerson.NameToText: String;
begin
  Result := FFamilyName +', ' + FFirstName;
end;

procedure NamesToComboBox(AComboBox: TCombobox; Persons: TPersonList);
var
  I: Integer;
begin
  AComboBox.Clear;
  For I := 0 to Persons.Count - 1 do
  begin
    AComboBox.Items.Add(Persons[I].FirstName + ' ' + Persons[I].FamilyName);
  end;
end;

procedure WeekListsToComboBox(AComboBox: TCombobox; ATimeData: TTimeData);
var
  I: Integer;
  Index: Integer;
begin
  Index := AComboBox.ItemIndex;
  AComboBox.Clear;
  for I := 0 to ATimeData.Count - 1 do
  begin
    AComboBox.Items.Add(IntToStr(I+1));
  end;
  AComboBox.ItemIndex := Index;
end;

function GetEarliestDayOfTimeData(ATimeData: TTimeData): TWorkDay;
var
  w, d: Integer;
begin
  Result := nil;
  for w := 0 to ATimeData.Count - 1 do
  begin
    for d := 0 to ATimeData.Items[w].Count - 1 do
    begin

		end;
	end;
end;

end.
