{
  A unit that will contain all classes and functions that relate to people
  and groups of people. These are the "users" that are selectable in the main
  programme. Each person will have its own tables.

  NOTE that these TPersons are not USERS! TPerson just holds Data of a person
  you want to track working time of/for! So the first/default Person is you.

}

unit people;

interface

uses Classes, fgl, ExtCtrls, workdays;

type

  // The list of weeklists
  TPersonnelTimeList = specialize TFPGObjectList<TWeekList>;

  // The class that implements the people
  TPerson = class

      PeopleCount: Integer;

    private
      FFirstName: String;               // First Name (can be multiple names like "Horst Kevin Jerome" :D )
      FFamilyName: String;              // Family Name
      FIDNumber: String;                // ID Number of the person in a company/team etc...
      FInternalID: Integer;             // programme-internal ID number that is unique and automatically generated
      FResidence: String;               // Where does the person live
      FAdress: String;                  // Adress-Information e.g. street
      FPhoneNumber1: String;            // Phone Numbers
      FPhoneNumber2: String;
      FEMail: String;                   // Email-Adress

      FPhoto: TImage;                   // Maybe it is better to store the local path to a picture instead of a
                                        // whole picture binarily
      FAge: Integer;                    // Age in years
      FSex: String;                     // Male / Female ... won't exclude other possibilities
      FBirthday: TDate;                 // Date of Birth
      FDaysOfVacationPerYear: Double;   // May be set either globally or for each person uniquely
      FDateOfEmployment: TDate;         // The Date when the person got employed

      // essential programme data
      FListName: TStringList;           // List of the names referring to a WeekList in FTimeData
      FTimeData: TPersonnelTimeList;    // A List of TWeekLists - This is what you see in main window/e.g. for each year
    public

      constructor Create;
      destructor Destroy;

      property FirstName: String read FFirstName write FFirstName;
      property FamilyName: String read FFamilyName write FFamilyName;
      property ID: String read FIDNumber write FIDNumber;
      property TimeData: TPersonnelTimeList read FTimeData write FTimeData;
	end;

implementation

constructor TPerson.Create;
begin
  FTimeData := TPersonnelTimeList.Create;
end;

destructor TPerson.Destroy;
begin
  FTimeData.Free;
end;

end.
