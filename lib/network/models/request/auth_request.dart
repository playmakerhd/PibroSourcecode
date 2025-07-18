class AuthRequest {
  AuthRequest({
    required this.username,
    this.password,
    this.email,
    this.phoneNumber,
    this.isOtherOption = false,
  });

  late String username;
  late String? password;
  late String? email;
  late String? phoneNumber;
  bool isOtherOption;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['username'] = username;
    map['password'] = password;
    map['email'] = email;
    map['phoneNumber'] = phoneNumber;
    map['isOtherOption'] = isOtherOption;
    return map;
  }

  Map<String, dynamic> toSignUpJson() {
    final map = <String, dynamic>{};
    map['CustomerTypeID'] = 'INDIVIDUAL';
    map['AccountStatus'] = 'Open';
    map['CustomerName'] = username;
    map['CustomerFirstName'] = username.split(' ')[0];
    map['CustomerLastName'] =
        username.split(' ').length > 1 ? username.split(' ')[1] : 'null';
    map['CustomerAddress1'] = 'null';
    map['CustomerState'] = 'null';
    map['CustomerCountry'] = 'null';
    map['CustomerPhone'] = phoneNumber;
    map['CustomerEmail'] = email;
    map['CustomerDateOfBirth'] = DateTime.now().toIso8601String();
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
