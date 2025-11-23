class LeadInformation {
  LeadInformation({
    this.companyID,
    this.divisionID,
    this.departmentID,
    this.leadID,
    this.leadCompany,
    this.leadLastName,
    this.leadFirstName,
    this.leadSalutation,
    this.leadAddress1,
    this.leadAddress2,
    this.leadAddress3,
    this.leadCity,
    this.leadState,
    this.leadZip,
    this.leadCountry,
    this.leadEmail,
    this.leadWebPage,
    this.leadPhone,
    this.leadFax,
    this.leadLogin,
    this.leadPassword,
    this.leadPasswordOld,
    this.leadPasswordDate,
    this.leadPasswordExpires,
    this.leadPasswordExpiresDate,
    this.leadSecurityGroup,
    this.attention,
    this.employeeID,
    this.currencyID,
    this.leadTypeID,
    this.leadRegionID,
    this.leadSourceID,
    this.leadIndustryID,
    this.firstContacted,
    this.lastFollowUp,
    this.nextFollowUp,
    this.referedByExistingCustomer,
    this.referedBy,
    this.referedDate,
    this.referalURL,
    this.lastVisit,
    this.ipAddress,
    this.numberOfVisits,
    this.primaryInterest,
    this.confirmed,
    this.validated,
    this.optInEmail,
    this.newsletter,
    this.optInNewsletter,
    this.messageBoard,
    this.portal,
    this.hot,
    this.convertedToCustomer,
    this.convertedToCustomerBy,
    this.convertedToCustomerDate,
    this.leadMemo1,
    this.leadMemo2,
    this.leadMemo3,
    this.leadMemo4,
    this.leadMemo5,
    this.leadMemo6,
    this.leadMemo7,
    this.leadMemo8,
    this.leadMemo9,
    this.lockedBy,
    this.lockTS,
    this.commission,
    this.revocated,
    this.leadNationality,
    this.leadOccupation,
    this.leadGender,
    this.leadCACRegNumber,
    this.leadCACRegState,
    this.leadCACRegCountry,
    this.leadResidentialPermit,
    this.leadReligion,
    this.leadMaidenName,
    this.leadMothersMaidenName,
    this.leadSMSNotification,
    this.leadEmailNotification,
    this.leadPostalNotification,
    this.leadEmployerName,
    this.leadDesignation,
    this.leadSubAccount,
    this.leadPolicalExposedPerson,
    this.leadPictureURL,
    this.leadBankAccountNumber,
    this.leadBankAccountName,
    this.leadBankAccountVerified,
    this.leadCentralSecurityClearingSystemNo,
    this.leadPFA,
    this.leadStateOfOrigin,
    this.leadMaritalStatus,
    this.leadDateOfBirth,
    this.leadDefaultPassWord,
    this.leadFullName,
    this.leadContacts,
    this.leadComments,
    this.leadSatisfactions,
  });

  String? companyID;
  String? divisionID;
  String? departmentID;
  String? leadID;
  String? leadCompany;
  String? leadLastName;
  String? leadFirstName;
  String? leadSalutation;
  String? leadAddress1;
  String? leadAddress2;
  String? leadAddress3;
  String? leadCity;
  String? leadState;
  String? leadZip;
  String? leadCountry;
  String? leadEmail;
  String? leadWebPage;
  String? leadPhone;
  String? leadFax;
  String? leadLogin;
  String? leadPassword;
  String? leadPasswordOld;
  String? leadPasswordDate;
  bool? leadPasswordExpires;
  String? leadPasswordExpiresDate;
  String? leadSecurityGroup;
  String? attention;
  String? employeeID;
  String? currencyID;
  String? leadTypeID;
  String? leadRegionID;
  String? leadSourceID;
  String? leadIndustryID;
  String? firstContacted;
  String? lastFollowUp;
  String? nextFollowUp;
  String? referedByExistingCustomer;
  String? referedBy;
  String? referedDate;
  String? referalURL;
  String? lastVisit;
  String? ipAddress;
  int? numberOfVisits;
  String? primaryInterest;
  bool? confirmed;
  bool? validated;
  bool? optInEmail;
  bool? newsletter;
  bool? optInNewsletter;
  bool? messageBoard;
  bool? portal;
  bool? hot;
  bool? convertedToCustomer;
  String? convertedToCustomerBy;
  String? convertedToCustomerDate;
  String? leadMemo1;
  String? leadMemo2;
  String? leadMemo3;
  String? leadMemo4;
  String? leadMemo5;
  String? leadMemo6;
  String? leadMemo7;
  String? leadMemo8;
  String? leadMemo9;
  String? lockedBy;
  String? lockTS;
  double? commission;
  bool? revocated;
  String? leadNationality;
  String? leadOccupation;
  String? leadGender;
  String? leadCACRegNumber;
  String? leadCACRegState;
  String? leadCACRegCountry;
  String? leadResidentialPermit;
  String? leadReligion;
  String? leadMaidenName;
  String? leadMothersMaidenName;
  bool? leadSMSNotification;
  bool? leadEmailNotification;
  bool? leadPostalNotification;
  String? leadEmployerName;
  String? leadDesignation;
  String? leadSubAccount;
  bool? leadPolicalExposedPerson;
  String? leadPictureURL;
  String? leadBankAccountNumber;
  String? leadBankAccountName;
  bool? leadBankAccountVerified;
  String? leadCentralSecurityClearingSystemNo;
  String? leadPFA;
  String? leadStateOfOrigin;
  String? leadMaritalStatus;
  String? leadDateOfBirth;
  String? leadDefaultPassWord;
  String? leadFullName;
  List<dynamic>? leadContacts;
  List<dynamic>? leadComments;
  List<dynamic>? leadSatisfactions;

  factory LeadInformation.fromJson(dynamic json) {
    return LeadInformation(
      companyID: json['CompanyID'],
      divisionID: json['DivisionID'],
      departmentID: json['DepartmentID'],
      leadID: json['LeadID'],
      leadCompany: json['LeadCompany'],
      leadLastName: json['LeadLastName'],
      leadFirstName: json['LeadFirstName'],
      leadSalutation: json['LeadSalutation'],
      leadAddress1: json['LeadAddress1'] ?? '',
      leadAddress2: json['LeadAddress2'],
      leadAddress3: json['LeadAddress3'],
      leadCity: json['LeadCity'] ?? '',
      leadState: json['LeadState'] ?? '',
      leadZip: json['LeadZip'],
      leadCountry: json['LeadCountry'] ?? 'Nigeria',
      leadEmail: json['LeadEmail'] ?? '',
      leadWebPage: json['LeadWebPage'],
      leadPhone: json['LeadPhone'] ?? '',
      leadFax: json['LeadFax'],
      leadLogin: json['LeadLogin'] ?? '',
      leadPassword: json['LeadPassword'],
      leadPasswordOld: json['LeadPasswordOld'],
      leadPasswordDate: json['LeadPasswordDate'],
      leadPasswordExpires: json['LeadPasswordExpires'],
      leadPasswordExpiresDate: json['LeadPasswordExpiresDate'],
      leadSecurityGroup: json['LeadSecurityGroup'],
      attention: json['Attention'],
      employeeID: json['EmployeeID'],
      currencyID: json['CurrencyID'],
      leadTypeID: json['LeadTypeID'],
      leadRegionID: json['LeadRegionID'],
      leadSourceID: json['LeadSourceID'],
      leadIndustryID: json['LeadIndustryID'],
      firstContacted: json['FirstContacted'],
      lastFollowUp: json['LastFollowUp'],
      nextFollowUp: json['NextFollowUp'],
      referedByExistingCustomer: json['ReferedByExistingCustomer'],
      referedBy: json['ReferedBy'],
      referedDate: json['ReferedDate'],
      referalURL: json['ReferalURL'],
      lastVisit: json['LastVisit'],
      ipAddress: json['IPAddress'],
      numberOfVisits: json['NumberOfVisits'],
      primaryInterest: json['PrimaryInterest'],
      confirmed: json['Confirmed'],
      validated: json['Validated'],
      optInEmail: json['OptInEmail'],
      newsletter: json['Newsletter'],
      optInNewsletter: json['OptInNewsletter'],
      messageBoard: json['MessageBoard'],
      portal: json['Portal'],
      hot: json['Hot'],
      convertedToCustomer: json['ConvertedToCustomer'],
      convertedToCustomerBy: json['ConvertedToCustomerBy'],
      convertedToCustomerDate: json['ConvertedToCustomerDate'],
      leadMemo1: json['LeadMemo1'],
      leadMemo2: json['LeadMemo2'],
      leadMemo3: json['LeadMemo3'],
      leadMemo4: json['LeadMemo4'],
      leadMemo5: json['LeadMemo5'],
      leadMemo6: json['LeadMemo6'],
      leadMemo7: json['LeadMemo7'],
      leadMemo8: json['LeadMemo8'],
      leadMemo9: json['LeadMemo9'],
      lockedBy: json['LockedBy'],
      lockTS: json['LockTS'],
      commission: json['Commission'],
      revocated: json['Revocated'],
      leadNationality: json['LeadNationality'],
      leadOccupation: json['LeadOccupation'],
      leadGender: json['LeadGender'],
      leadCACRegNumber: json['LeadCACRegNumber'],
      leadCACRegState: json['LeadCACRegState'],
      leadCACRegCountry: json['LeadCACRegCountry'],
      leadResidentialPermit: json['LeadResidentialPermit'],
      leadReligion: json['LeadReligion'],
      leadMaidenName: json['LeadMaidenName'],
      leadMothersMaidenName: json['LeadMothersMaidenName'],
      leadSMSNotification: json['LeadSMSNotification'],
      leadEmailNotification: json['LeadEmailNotification'],
      leadPostalNotification: json['LeadPostalNotification'],
      leadEmployerName: json['LeadEmployerName'],
      leadDesignation: json['LeadDesignation'],
      leadSubAccount: json['LeadSubAccount'],
      leadPolicalExposedPerson: json['LeadPolicalExposedPerson'],
      leadPictureURL: json['LeadPictureURL'],
      leadBankAccountNumber: json['LeadBankAccountNumber'],
      leadBankAccountName: json['LeadBankAccountName'],
      leadBankAccountVerified: json['LeadBankAccountVerified'],
      leadCentralSecurityClearingSystemNo:
          json['LeadCentralSecurityClearingSystemNo'],
      leadPFA: json['LeadPFA'],
      leadStateOfOrigin: json['LeadStateOfOrigin'],
      leadMaritalStatus: json['LeadMaritalStatus'],
      leadDateOfBirth: json['LeadDateOfBirth'],
      leadDefaultPassWord: json['LeadDefaultPassWord'],
      leadFullName: json['LeadFullName'] ?? '',
      leadContacts: json['LeadContacts'],
      leadComments: json['LeadComments'],
      leadSatisfactions: json['LeadSatisfactions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CompanyID': companyID,
      'DivisionID': divisionID,
      'DepartmentID': departmentID,
      'LeadID': leadID,
      'LeadCompany': leadCompany,
      'LeadLastName': leadLastName,
      'LeadFirstName': leadFirstName,
      'LeadSalutation': leadSalutation,
      'LeadAddress1': leadAddress1,
      'LeadAddress2': leadAddress2,
      'LeadAddress3': leadAddress3,
      'LeadCity': leadCity,
      'LeadState': leadState,
      'LeadZip': leadZip,
      'LeadCountry': leadCountry,
      'LeadEmail': leadEmail,
      'LeadWebPage': leadWebPage,
      'LeadPhone': leadPhone,
      'LeadFax': leadFax,
      'LeadLogin': leadLogin,
      'LeadPassword': leadPassword,
      'LeadPasswordOld': leadPasswordOld,
      'LeadPasswordDate': leadPasswordDate,
      'LeadPasswordExpires': leadPasswordExpires,
      'LeadPasswordExpiresDate': leadPasswordExpiresDate,
      'LeadSecurityGroup': leadSecurityGroup,
      'Attention': attention,
      'EmployeeID': employeeID,
      'CurrencyID': currencyID,
      'LeadTypeID': leadTypeID,
      'LeadRegionID': leadRegionID,
      'LeadSourceID': leadSourceID,
      'LeadIndustryID': leadIndustryID,
      'FirstContacted': firstContacted,
      'LastFollowUp': lastFollowUp,
      'NextFollowUp': nextFollowUp,
      'ReferedByExistingCustomer': referedByExistingCustomer,
      'ReferedBy': referedBy,
      'ReferedDate': referedDate,
      'ReferalURL': referalURL,
      'LastVisit': lastVisit,
      'IPAddress': ipAddress,
      'NumberOfVisits': numberOfVisits,
      'PrimaryInterest': primaryInterest,
      'Confirmed': confirmed,
      'Validated': validated,
      'OptInEmail': optInEmail,
      'Newsletter': newsletter,
      'OptInNewsletter': optInNewsletter,
      'MessageBoard': messageBoard,
      'Portal': portal,
      'Hot': hot,
      'ConvertedToCustomer': convertedToCustomer,
      'ConvertedToCustomerBy': convertedToCustomerBy,
      'ConvertedToCustomerDate': convertedToCustomerDate,
      'LeadMemo1': leadMemo1,
      'LeadMemo2': leadMemo2,
      'LeadMemo3': leadMemo3,
      'LeadMemo4': leadMemo4,
      'LeadMemo5': leadMemo5,
      'LeadMemo6': leadMemo6,
      'LeadMemo7': leadMemo7,
      'LeadMemo8': leadMemo8,
      'LeadMemo9': leadMemo9,
      'LockedBy': lockedBy,
      'LockTS': lockTS,
      'Commission': commission,
      'Revocated': revocated,
      'LeadNationality': leadNationality,
      'LeadOccupation': leadOccupation,
      'LeadGender': leadGender,
      'LeadCACRegNumber': leadCACRegNumber,
      'LeadCACRegState': leadCACRegState,
      'LeadCACRegCountry': leadCACRegCountry,
      'LeadResidentialPermit': leadResidentialPermit,
      'LeadReligion': leadReligion,
      'LeadMaidenName': leadMaidenName,
      'LeadMothersMaidenName': leadMothersMaidenName,
      'LeadSMSNotification': leadSMSNotification,
      'LeadEmailNotification': leadEmailNotification,
      'LeadPostalNotification': leadPostalNotification,
      'LeadEmployerName': leadEmployerName,
      'LeadDesignation': leadDesignation,
      'LeadSubAccount': leadSubAccount,
      'LeadPolicalExposedPerson': leadPolicalExposedPerson,
      'LeadPictureURL': leadPictureURL,
      'LeadBankAccountNumber': leadBankAccountNumber,
      'LeadBankAccountName': leadBankAccountName,
      'LeadBankAccountVerified': leadBankAccountVerified,
      'LeadCentralSecurityClearingSystemNo':
          leadCentralSecurityClearingSystemNo,
      'LeadPFA': leadPFA,
      'LeadStateOfOrigin': leadStateOfOrigin,
      'LeadMaritalStatus': leadMaritalStatus,
      'LeadDateOfBirth': leadDateOfBirth,
      'LeadDefaultPassWord': leadDefaultPassWord,
      'LeadFullName': leadFullName,
      'LeadContacts': leadContacts,
      'LeadComments': leadComments,
      'LeadSatisfactions': leadSatisfactions,
    };
  }

  // Helper method to convert to PlatformUser-like structure
  Map<String, dynamic> toPlatformUserFormat() {
    return {
      'CustomerID': leadID,
      'CustomerName':
          leadFullName ?? '${leadFirstName ?? ''} ${leadLastName ?? ''}'.trim(),
      'CustomerFirstName': leadFirstName,
      'CustomerLastName': leadLastName,
      'CustomerEmail': leadEmail,
      'CustomerPhone': leadPhone,
      'CustomerAddress1': leadAddress1,
      'CustomerCity': leadCity,
      'CustomerState': leadState,
      'CustomerCountry': leadCountry,
      'CustomerDateOfBirth': leadDateOfBirth,
      'CustomerTypeID': leadTypeID,
    };
  }
}
