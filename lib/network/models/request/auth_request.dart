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
    this.state,
    this.address,
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
  String? state;
  String? address;

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
    map['LeadAddress1'] = address ?? '';
    map['LeadCity'] = '';
    map['LeadState'] = state ?? '';
    map['LeadCountry'] = 'Nigeria';
    map['LeadDateOfBirth'] = dateOfBirth ?? DateTime.now().toIso8601String();
    map['LeadFullName'] = username;
    map['LeadLogin'] = '';
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
}
