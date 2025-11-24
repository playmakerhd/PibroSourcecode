class AuthRequest {
  AuthRequest({
    required this.username,
    this.password,
    this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.isOtherOption = false,
    this.firstName,
    this.lastName,
    this.accountType,
  });

  late String username;
  late String? password;
  late String? email;
  late String? phoneNumber;
  late String? dateOfBirth;
  bool isOtherOption;
  String? firstName;
  String? lastName;
  String? accountType;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['username'] = username;
    map['password'] = password;
    map['email'] = email;
    map['phoneNumber'] = phoneNumber;
    map['isOtherOption'] = isOtherOption;
    map['firstName'] = firstName;
    map['lastName'] = lastName;
    map['accountType'] = accountType;
    return map;
  }

  // Create Lead payload
  Map<String, dynamic> toCreateLeadJson() {
    final map = <String, dynamic>{};
    map['CompanyID'] = '';
    map['DivisionID'] = '';
    map['DepartmentID'] = '';
    map['LeadID'] = '';
    map['LeadFirstName'] = firstName ?? username.split(' ').first;
    map['LeadLastName'] = lastName ??
        (username.split(' ').length > 1 ? username.split(' ').last : '');
    map['LeadEmail'] = email;
    map['LeadPhone'] = phoneNumber;
    map['LeadAddress1'] = '';
    map['LeadCity'] = '';
    map['LeadState'] = '';
    map['LeadCountry'] = 'Nigeria';
    map['LeadDateOfBirth'] = dateOfBirth ?? DateTime.now().toIso8601String();
    map['LeadFullName'] = '';
    map['LeadLogin'] = username;
    map['LeadPassword'] = password;
    map['LeadPasswordOld'] = password;
    map['LeadPasswordDate'] = DateTime.now().toIso8601String();
    map['LeadPasswordExpires'] = true;
    map['LeadTypeID'] = accountType?.toUpperCase() ?? 'INDIVIDUAL';
    map['LeadComments'] = [
      {'CommentType': 'General', 'Comment': 'sample string 7'}
    ];
    map['LeadContacts'] = [
      {
        'ContactFirstName': '',
        'ContactLastName': '',
        'ContactEmail': '',
        'ContactPhone': ''
      }
    ];
    return map;
  }

  // Legacy: Create Customer payload (no longer used for signup)
  Map<String, dynamic> toSignUpJson() {
    final map = <String, dynamic>{};
    map['CustomerTypeID'] = 'INDIVIDUAL';
    map['AccountStatus'] = 'Open';
    map['CustomerName'] = username;
    map['CustomerFirstName'] = username.split(' ')[0];
    map['CustomerLastName'] =
        username.split(' ').length > 1 ? username.split(' ')[1] : 'null';
    map['CustomerAddress1'] = "null";
    map['CustomerState'] = "null";
    map['CustomerCountry'] = "Nigeria";
    map['CustomerPhone'] = phoneNumber;
    map['CustomerEmail'] = email;
    map['CustomerDateOfBirth'] = dateOfBirth ?? "null";
    map['CurrencyID'] = 'NGN';
    map['ApprovalDate'] = DateTime.now().toIso8601String();
    map['CustomerSince'] = DateTime.now().toIso8601String();
    map['EnteredBy'] = 'ADMIN';
    map['SMSforCreationSent'] = true;
    map['CustomerNationality'] = null;
    map['CustomerGender'] = 'null';
    map['CustomerReligion'] = 'null';
    map['CustomerPolicalExposedPerson'] = true;
    map['CustomerStateOfOrigin'] = 'null';
    map['CustomerMaritalStatus'] = 'null';
    map['CustomerNationality'] = 'Nigerian';
    map['CustomerPassword'] = password;
    return map;
  }
}
