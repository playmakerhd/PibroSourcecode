class PlatformUser {
  PlatformUser({
    this.companyID,
    this.divisionID,
    this.departmentID,
    this.customerID,
    this.customerTypeID,
    this.accountStatus,
    this.customerSalutation,
    this.customerName,
    this.customerFirstName,
    this.customerLastName,
    this.customerFullName,
    this.customerAddress1,
    this.customerAddress2,
    this.customerAddress3,
    this.customerCity,
    this.customerState,
    this.customerZip,
    this.customerCountry,
    this.customerPhone,
    this.customerEmail,
    this.customerDateOfBirth,
    this.termsID,
    this.termsStart,
    this.taxGroupID,
    this.priceMatrix,
    this.priceMatrixCurrent,
    this.statementCycleCode,
    this.customerSpecialInstructions,
    this.customerRegionID,
    this.customerPassword,
    this.customerContacts,
    // this.customerTransactions,
  });

  String? companyID;
  String? divisionID;
  String? departmentID;
  String? customerID;
  String? customerTypeID;
  String? accountStatus;
  String? customerSalutation;
  String? customerName;
  String? customerFirstName;
  String? customerLastName;
  String? customerFullName;
  String? customerAddress1;
  String? customerAddress2;
  String? customerAddress3;
  String? customerCity;
  String? customerState;
  String? customerZip;
  String? customerCountry;
  String? customerPhone;
  String? customerEmail;
  String? customerDateOfBirth;
  String? termsID;
  String? termsStart;
  String? taxGroupID;
  String? priceMatrix;
  String? priceMatrixCurrent;
  String? statementCycleCode;
  String? customerSpecialInstructions;
  String? customerRegionID;
  String? customerPassword;
  late List<CustomerContact>? customerContacts;
  // late List<CustomerTransaction>? customerTransactions;

  factory PlatformUser.fromJson(dynamic json) {
    return PlatformUser(
      companyID: json['CompanyID'],
      divisionID: json["DivisionID"],
      departmentID: json["DepartmentID"],
      customerID: json["CustomerID"],
      customerTypeID: json["CustomerTypeID"],
      accountStatus: json["AccountStatus"],
      customerSalutation: json["CustomerSalutation"],
      customerName: json["CustomerName"],
      customerFirstName: json["CustomerFirstName"],
      customerLastName: json["CustomerLastName"],
      customerFullName: json["CustomerFullName"],
      customerAddress1: json["CustomerAddress1"],
      customerAddress2: json["CustomerAddress2"],
      customerAddress3: json["CustomerAddress3"],
      customerCity: json["CustomerCity"] ?? '',
      customerState: json["CustomerState"] ?? '',
      customerZip: json["CustomerZip"],
      customerCountry: json["CustomerCountry"] ?? '',
      customerPhone: json["CustomerPhone"] ?? '',
      customerEmail: json["CustomerEmail"] ?? '',
      customerDateOfBirth: json["CustomerDateOfBirth"] ?? '',
      termsID: json["TermsID"],
      termsStart: json["TermsStart"],
      taxGroupID: json["TaxGroupID"],
      priceMatrix: json["PriceMatrix"],
      priceMatrixCurrent: json["PriceMatrixCurrent"],
      statementCycleCode: json["StatementCycleCode"],
      customerSpecialInstructions: json["CustomerSpecialInstructions"],
      customerRegionID: json["CustomerRegionID"],
      customerPassword: json["CustomerPassword"],
      customerContacts:
          json["CustomerContacts"] != null && json["CustomerContacts"] != []
              ? List.from(json["CustomerContacts"])
                  .map((item) => CustomerContact.fromJson(item))
                  .toList()
              : [],
      // customerTransactions: json["CustomerTransactions"] != null &&
      //         json["CustomerTransactions"] != []
      //     ? List.from(json["CustomerTransactions"])
      //         .map((item) => CustomerTransaction.fromJson(item))
      //         .toList()
      //     : [],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CompanyID'] = companyID;
    map['DivisionID'] = divisionID;
    map['DepartmentID'] = departmentID;
    map['CustomerID'] = customerID;
    map['CustomerTypeID'] = customerTypeID;
    map['AccountStatus'] = accountStatus;
    map['CustomerSalutation'] = customerSalutation;
    map['CustomerName'] = customerName;
    map['CustomerFirstName'] = customerFirstName;
    map['CustomerLastName'] = customerLastName;
    map['CustomerFullName'] = customerFullName;
    map['CustomerAddress1'] = customerAddress1;
    map['CustomerAddress2'] = customerAddress2;
    map['CustomerAddress3'] = customerAddress3;
    map['CustomerCity'] = customerCity;
    map['CustomerState'] = customerState;
    map['CustomerZip'] = customerZip;
    map['CustomerCountry'] = customerCountry;
    map['CustomerPhone'] = customerPhone;
    map['CustomerEmail'] = customerEmail;
    map['CustomerDateOfBirth'] = customerDateOfBirth;
    map['TermsID'] = termsID;
    map['TermsStart'] = termsStart;
    map['TaxGroupID'] = taxGroupID;
    map['PriceMatrix'] = priceMatrix;
    map['PriceMatrixCurrent'] = priceMatrixCurrent;
    map['StatementCycleCode'] = statementCycleCode;
    map['CustomerSpecialInstructions'] = customerSpecialInstructions;
    map['CustomerRegionID'] = customerRegionID;
    map['CustomerPassword'] = customerPassword;
    map['CompanyID'] = companyID;
    map['CustomerContacts'] =
        customerContacts != null && customerContacts!.isNotEmpty
            ? customerContacts?.map((v) => v.toJson()).toList()
            : [];
    // map['CustomerTransactions'] =
    //     customerTransactions != null && customerTransactions!.isNotEmpty
    //         ? customerTransactions?.map((v) => v.toJson()).toList()
    //         : [];
    return map;
  }
}

class CustomerTransaction {
  CustomerTransaction({
    this.companyID,
    this.divisionID,
    this.customerID,
    this.transactionType,
    this.transactionNumber,
    this.transactionDate,
    this.transactionAmount,
    this.currencyID,
    this.shipDate,
    this.trackingNumber,
    this.posted = false,
    this.targetForm,
    this.keyField,
  });

  late String? companyID;
  late String? divisionID;
  late String? customerID;
  late String? transactionType;
  late String? transactionNumber;
  late String? transactionDate;
  late double? transactionAmount;
  late String? currencyID;
  late String? shipDate;
  late String? trackingNumber;
  bool posted;
  late String? targetForm;
  late String? keyField;

  factory CustomerTransaction.fromJson(dynamic json) {
    return CustomerTransaction(
      companyID: json['CompanyID'],
      divisionID: json['DivisionID'],
      customerID: json['CustomerID'],
      transactionType: json['TransactionType'],
      transactionNumber: json['TransactionNumber'],
      transactionDate: json['TransactionDate'],
      transactionAmount: json['TransactionAmount'],
      currencyID: json['CurrencyID'],
      shipDate: json['ShipDate'],
      trackingNumber: json['TrackingNumber'],
      posted: json['Posted'],
      targetForm: json['TargetForm'],
      keyField: json['KeyField'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CompanyID'] = companyID;
    map['DivisionID'] = divisionID;
    map['CustomerID'] = customerID;
    map['TransactionType'] = transactionType;
    map['TransactionNumber'] = transactionNumber;
    map['TransactionDate'] = transactionDate;
    map['TransactionAmount'] = transactionAmount;
    map['CurrencyID'] = currencyID;
    map['ShipDate'] = shipDate;
    map['TrackingNumber'] = trackingNumber;
    map['Posted'] = posted;
    map['TargetForm'] = targetForm;
    map['KeyField'] = keyField;
    return map;
  }
}

class CustomerContact {
  CustomerContact({
    this.companyID,
    this.divisionID,
    this.customerID,
    this.contactID,
    this.contactType,
    this.contactFirstName,
    this.contactLastName,
    this.contactPhone,
    this.contactEmail,
  });

  late String? companyID;
  late String? divisionID;
  late String? customerID;
  late String? contactID;
  late String? contactType;
  late String? contactFirstName;
  late String? contactLastName;
  late String? contactPhone;
  late String? contactEmail;

  factory CustomerContact.fromJson(dynamic json) {
    return CustomerContact(
      companyID: json['CompanyID'],
      divisionID: json['DivisionID'],
      customerID: json['CustomerID'],
      contactID: json['ContactID'],
      contactType: json['ContactType'],
      contactFirstName: json['ContactFirstName'],
      contactLastName: json['ContactLastName'],
      contactPhone: json['ContactPhone'],
      contactEmail: json['ContactEmail'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CompanyID'] = companyID;
    map['DivisionID'] = divisionID;
    map['CustomerID'] = customerID;
    map['ContactID'] = contactID;
    map['ContactType'] = contactType;
    map['ContactFirstName'] = contactFirstName;
    map['ContactLastName'] = contactLastName;
    map['ContactPhone'] = contactPhone;
    map['ContactEmail'] = contactEmail;
    return map;
  }
}
