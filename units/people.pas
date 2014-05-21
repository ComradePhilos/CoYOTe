{
  A unit that will contain all classes and functions that relate to people
  and groups of people. These are the "users" that are selectable in the main
  programme. Each person will have its own tables.
}

unit people;

interface

uses Classes, fgl;


type
  TPerson = class
    private
      FFirstName: String;               // First Name (can be multiple names) e.g. Klaus Dieter
      FFamilyName: String;              // Family Name
      FIDNumber: String;                // ID Number of the person in a company/team etc...
      FResidence: String;               // Where does the person live
      FAdress: String;                  // Adress-Information e.g. street
      FPhoneNumber1: String;            // Phone Numbers
      FPhoneNumber2: String;
      FEMail: String;                   // Email-Adress
      // FRole: String;                 // What position/role does the person have ?
      FAge: Integer;                    // Age in years
      FSex: String;                     // Male / Female ... won't exclude other possibilities
      FBirthday: TDate;                 // Date of Birth
      FDateOfEmployment: TDate;         // The Date when the person got employed
    public

      property FirstName: String read FFirstName write FFirstName;
      property FamilyName: String read FFamilyName write FFamilyName;
      property ID: String read FIDNumber write FIDNumber;
	end;

implementation

end.
