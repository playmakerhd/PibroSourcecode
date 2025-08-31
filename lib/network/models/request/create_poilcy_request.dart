class CreatePolicyRequest {
  CreatePolicyRequest({
    required this.customerID,
    required this.employeeID,
    required this.approvedBy,
    required this.vendorID,
    required this.businessClassID,
    required this.riskTypeID,
    required this.policyStartDate,
    required this.policyEndDate,
    required this.renewalDate,
    required this.insurancePremiumMethodsID,
    required this.items,
    required this.underwriters,
  });

  final String customerID, employeeID, approvedBy, vendorID;
  final String businessClassID, riskTypeID;
  final String policyStartDate, policyEndDate, renewalDate;
  final String insurancePremiumMethodsID;
  final List<CreatePolicyItem> items;
  final List<CreatePolicyUnderwriter> underwriters;

  Map<String, dynamic> toJson() => {
        "CustomerID": customerID,
        "EmployeeID": employeeID,
        "ApprovedBy": approvedBy,
        "VendorID": vendorID,
        "BusinessClassID": businessClassID,
        "RiskTypeID": riskTypeID,
        "PolicyStartDate": policyStartDate,
        "PolicyEndDate": policyEndDate,
        "RenewalDate": renewalDate,
        "InsurancePremiumMethodsID": insurancePremiumMethodsID,
        "ItemToInsure": items.map((e) => e.toJson()).toList(),
        "InsurancePolicyUnderwriter":
            underwriters.map((e) => e.toJson()).toList(),
      };
}

class CreatePolicyItem {
  CreatePolicyItem({
    required this.manualNumbering,
    required this.itemsDescription,
    required this.sumInsured,
    required this.itemLocation,
    this.policyBrokerID = "",
    this.sectionTypeID = "SECTIONA",
    this.brokingSlipItemCount = 0,
  });

  String policyBrokerID;
  String sectionTypeID;
  String manualNumbering;
  int brokingSlipItemCount;
  String itemsDescription;
  double sumInsured;
  String itemLocation;

  Map<String, dynamic> toJson() {
    return {
      'PolicyBrokerID': policyBrokerID,
      'SectionTypeID': sectionTypeID,
      'ManualNumbering': manualNumbering,
      'BrokingSlipItemCount': brokingSlipItemCount,
      'ItemsDescription': itemsDescription,
      'SumInsured': sumInsured,
      'ItemLocation': itemLocation,
    };
  }
}

class CreatePolicyUnderwriter {
  CreatePolicyUnderwriter({
    required this.vendorID,
    required this.vendorName,
    this.apportionment = 100,
  });

  final String vendorID, vendorName;
  final int apportionment;

  Map<String, dynamic> toJson() => {
        "PolicyBrokerID": "",
        "VendorID": vendorID,
        "VendorName": vendorName,
        "Apportionment": apportionment,
      };
}
