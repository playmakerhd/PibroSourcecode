class SalesQuotationResponse {
  SalesQuotationResponse({
    this.companyID,
    this.divisionID,
    this.departmentID,
    this.invoiceNumber,
    this.noteTypeID,
    this.policyBrokerID,
    this.actualPolicyBrokerID,
    this.policyUnderwriterID,
    this.packagePolicyID,
    this.endorsementID,
    this.customerID,
    this.vendorID,
    this.businessClassID,
    this.riskTypeID,
    this.invoiceDate,
    this.startDate,
    this.endDate,
    this.renewaldate,
    this.premiumDescription,
    this.sumInsured,
    this.basicRate,
    this.premiumFormular,
    this.premiumDue,
    this.noteStatus,
    this.session,
    this.generateBy,
    this.approvedBy,
    this.currencyID,
    this.quotation,
    this.postingDate,
    this.quotationCleared,
    this.quotationClearedDate,
    this.quotationClearedBy,
    this.reportHeaderDescription,
    this.itemsToInsure,
    this.insurers,
  });

  String? companyID;
  String? divisionID;
  String? departmentID;
  String? invoiceNumber; // QuoteID like QN/11
  String? noteTypeID;
  String? policyBrokerID;
  String? actualPolicyBrokerID;
  String? policyUnderwriterID;
  String? packagePolicyID;
  String? endorsementID;
  String? customerID; // Can be lead/14 or CUS/84902
  String? vendorID;
  String? businessClassID;
  String? riskTypeID;
  String? invoiceDate;
  String? startDate;
  String? endDate;
  String? renewaldate;
  String? premiumDescription;
  double? sumInsured;
  double? basicRate;
  String? premiumFormular;
  double? premiumDue;
  String? noteStatus;
  String? session;
  String? generateBy;
  String? approvedBy;
  String? currencyID;
  bool? quotation;
  String? postingDate;
  bool? quotationCleared;
  String? quotationClearedDate;
  String? quotationClearedBy;
  String? reportHeaderDescription;
  List<QuotationItem>? itemsToInsure;
  List<dynamic>? insurers;

  factory SalesQuotationResponse.fromJson(dynamic json) {
    return SalesQuotationResponse(
      companyID: json['CompanyID'],
      divisionID: json['DivisionID'],
      departmentID: json['DepartmentID'],
      invoiceNumber: json['InvoiceNumber'],
      noteTypeID: json['NoteTypeID'],
      policyBrokerID: json['PolicyBrokerID'],
      actualPolicyBrokerID: json['ActualPolicyBrokerID'],
      policyUnderwriterID: json['PolicyUnderwriterID'],
      packagePolicyID: json['PackagePololicyID'],
      endorsementID: json['EndorsementID'],
      customerID: json['CustomerID'],
      vendorID: json['VendorID'],
      businessClassID: json['BusinessClassID'],
      riskTypeID: json['RiskTypeID'],
      invoiceDate: json['InvoiceDate'],
      startDate: json['StartDate'],
      endDate: json['EndDate'],
      renewaldate: json['Renewaldate'],
      premiumDescription: json['PremiumDescription'],
      sumInsured: _parseDouble(json['SumInsured']),
      basicRate: _parseDouble(json['BasicRate']),
      premiumFormular: json['PremiumFomular'],
      premiumDue: _parseDouble(json['PremiumDue']),
      noteStatus: json['NoteStatus'],
      session: json['Session'],
      generateBy: json['GenerateBy'],
      approvedBy: json['ApprovedBy'],
      currencyID: json['CurrencyID'],
      quotation: json['Quotation'],
      postingDate: json['PostingDate'],
      quotationCleared: json['QuotationCleared'],
      quotationClearedDate: json['QuotationClearedDate'],
      quotationClearedBy: json['QuotationClearedBy'],
      reportHeaderDescription: json['ReportHeaderDescription'],
      itemsToInsure: (json['ItemsToInsure'] as List?)
          ?.map((item) => QuotationItem.fromJson(item))
          .toList(),
      insurers: json['Insurers'],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'CompanyID': companyID,
      'DivisionID': divisionID,
      'DepartmentID': departmentID,
      'InvoiceNumber': invoiceNumber,
      'NoteTypeID': noteTypeID,
      'PolicyBrokerID': policyBrokerID,
      'ActualPolicyBrokerID': actualPolicyBrokerID,
      'PolicyUnderwriterID': policyUnderwriterID,
      'PackagePololicyID': packagePolicyID,
      'EndorsementID': endorsementID,
      'CustomerID': customerID,
      'VendorID': vendorID,
      'BusinessClassID': businessClassID,
      'RiskTypeID': riskTypeID,
      'InvoiceDate': invoiceDate,
      'StartDate': startDate,
      'EndDate': endDate,
      'Renewaldate': renewaldate,
      'PremiumDescription': premiumDescription,
      'SumInsured': sumInsured,
      'BasicRate': basicRate,
      'PremiumFomular': premiumFormular,
      'PremiumDue': premiumDue,
      'NoteStatus': noteStatus,
      'Session': session,
      'GenerateBy': generateBy,
      'ApprovedBy': approvedBy,
      'CurrencyID': currencyID,
      'Quotation': quotation,
      'PostingDate': postingDate,
      'QuotationCleared': quotationCleared,
      'QuotationClearedDate': quotationClearedDate,
      'QuotationClearedBy': quotationClearedBy,
      'ReportHeaderDescription': reportHeaderDescription,
      'ItemsToInsure': itemsToInsure?.map((item) => item.toJson()).toList(),
      'Insurers': insurers,
    };
  }
}

class QuotationItem {
  QuotationItem({
    this.companyID,
    this.divisionID,
    this.departmentID,
    this.policyBrokerID,
    this.sectionTypeID,
    this.manualNumbering,
    this.brokingSlipItemCount,
    this.itemsDescription,
    this.sumInsured,
    this.excessAmount,
    this.itemLocation,
    this.detailMemo1,
    this.detailMemo2,
    this.detailMemo3,
    this.detailMemo4,
    this.detailMemo5,
    this.detailMemo6,
    this.detailMemo7,
    this.detailMemo8,
    this.detailMemo9,
    this.detailMemo10,
    this.detailMemo11,
    this.detailMemo12,
    this.discount,
    this.itemRate,
    this.policyItems,
  });

  String? companyID;
  String? divisionID;
  String? departmentID;
  String? policyBrokerID;
  String? sectionTypeID;
  dynamic manualNumbering;
  int? brokingSlipItemCount;
  String? itemsDescription;
  double? sumInsured;
  double? excessAmount;
  String? itemLocation;
  String? detailMemo1;
  String? detailMemo2;
  String? detailMemo3;
  String? detailMemo4;
  String? detailMemo5;
  String? detailMemo6;
  String? detailMemo7;
  String? detailMemo8;
  String? detailMemo9;
  String? detailMemo10;
  String? detailMemo11;
  String? detailMemo12;
  double? discount;
  dynamic itemRate;
  String? policyItems;

  factory QuotationItem.fromJson(dynamic json) {
    return QuotationItem(
      companyID: json['CompanyID'],
      divisionID: json['DivisionID'],
      departmentID: json['DepartmentID'],
      policyBrokerID: json['PolicyBrokerID'],
      sectionTypeID: json['SectionTypeID'],
      manualNumbering: json['ManualNumbering'],
      brokingSlipItemCount: json['BrokingSlipItemCount'],
      itemsDescription: json['ItemsDescription'],
      sumInsured: _parseDouble(json['SumInsured']),
      excessAmount: _parseDouble(json['ExcessAmount']),
      itemLocation: json['ItemLocation'],
      detailMemo1: json['DetailMemo1'],
      detailMemo2: json['DetailMemo2'],
      detailMemo3: json['DetailMemo3'],
      detailMemo4: json['DetailMemo4'],
      detailMemo5: json['DetailMemo5'],
      detailMemo6: json['DetailMemo6'],
      detailMemo7: json['DetailMemo7'],
      detailMemo8: json['DetailMemo8'],
      detailMemo9: json['DetailMemo9'],
      detailMemo10: json['DetailMemo10'],
      detailMemo11: json['DetailMemo11'],
      detailMemo12: json['DetailMemo12'],
      discount: _parseDouble(json['Discount']),
      itemRate: json['ItemRate'],
      policyItems: json['PolicyItems'],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'CompanyID': companyID,
      'DivisionID': divisionID,
      'DepartmentID': departmentID,
      'PolicyBrokerID': policyBrokerID,
      'SectionTypeID': sectionTypeID,
      'ManualNumbering': manualNumbering,
      'BrokingSlipItemCount': brokingSlipItemCount,
      'ItemsDescription': itemsDescription,
      'SumInsured': sumInsured,
      'ExcessAmount': excessAmount,
      'ItemLocation': itemLocation,
      'DetailMemo1': detailMemo1,
      'DetailMemo2': detailMemo2,
      'DetailMemo3': detailMemo3,
      'DetailMemo4': detailMemo4,
      'DetailMemo5': detailMemo5,
      'DetailMemo6': detailMemo6,
      'DetailMemo7': detailMemo7,
      'DetailMemo8': detailMemo8,
      'DetailMemo9': detailMemo9,
      'DetailMemo10': detailMemo10,
      'DetailMemo11': detailMemo11,
      'DetailMemo12': detailMemo12,
      'Discount': discount,
      'ItemRate': itemRate,
      'PolicyItems': policyItems,
    };
  }
}

class SalesQuotationListResponse {
  SalesQuotationListResponse(this.quotations);

  List<SalesQuotationResponse> quotations;

  factory SalesQuotationListResponse.fromJson(List<dynamic> json) {
    return SalesQuotationListResponse(
      json.map((item) => SalesQuotationResponse.fromJson(item)).toList(),
    );
  }
}
