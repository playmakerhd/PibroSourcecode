import 'package:pibro/network/models/response/base_response.dart';
import 'package:pibro/network/models/response/claim_document_response.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';

class CustomerPolicyClaimsResponse extends CustomBaseResponse {
  CustomerPolicyClaimsResponse(super.responseData);

  late List<PolicyClaim> policyClaims;

  @override
  parseResponseData() {
    try {
      policyClaims = getResponseBody() != []
          ? List.from(getResponseBody())
              .map((item) => PolicyClaim.fromJson(item))
              .toList()
          : [];
    } catch (e) {
      handleParsingError(e);
    }
  }
}

class PolicyClaimResponse extends CustomBaseResponse {
  PolicyClaimResponse(super.responseData);

  late PolicyClaim policyClaim;

  @override
  parseResponseData() {
    try {
      policyClaim = PolicyClaim.fromJson(getResponseBody());
    } catch (e) {
      handleParsingError(e);
    }
  }
}

class PolicyClaim implements PolicyDetails {
  PolicyClaim({
    required this.companyID,
    required this.divisionID,
    required this.departmentID,
    required this.policyBrokerID,
    this.brokerClaimID,
    this.transactionID,
    this.customerID,
    this.accidentDate,
    this.accidentDetails,
    this.customerReportDate,
    this.startDate,
    this.endDate,
    this.totalReceived,
    this.enteredBy,
    this.documentStatus,
    this.lastUpdateDate,
    this.businessClassID,
    this.riskTypeID,
    this.customerName,
    this.dVAmount,
    this.claimsStatus,
    this.reportSubmitted,
    this.customerEstimate,
    this.closed,
    this.cleared,
    this.claimsDocuments,
    this.insurancePolicyUnderwriters,
    this.submitClaim,
  });

  late String? brokerClaimID;
  late int? transactionID;
  late String? customerID;
  late String? accidentDate;
  late String? accidentDetails;
  late String? customerReportDate;
  late String? startDate;
  late String? endDate;
  late double? totalReceived;
  late String? enteredBy;
  late String? documentStatus;
  late String? lastUpdateDate;
  late dynamic businessClassID;
  late dynamic riskTypeID;
  late dynamic customerName;
  late dynamic dVAmount;
  late dynamic claimsStatus;
  late dynamic customerEstimate;
  late dynamic reportSubmitted;
  late bool? closed;
  late bool? cleared;
  late List<ClaimDocument>? claimsDocuments;
  late List<InsurancePolicyUnderwriter>? insurancePolicyUnderwriters;
  late bool? submitClaim;

  factory PolicyClaim.fromJson(dynamic json) {
    return PolicyClaim(
      companyID: json['CompanyID'],
      divisionID: json['DivisionID'],
      departmentID: json['DepartmentID'],
      policyBrokerID: json['PolicyBrokerID'],
      brokerClaimID: json['BrokerClaimID'],
      transactionID: json['TransactionID'],
      customerID: json['CustomerID'],
      accidentDate: json['AccidentDate'],
      startDate: json['StartDate'],
      endDate: json['EndDate'],
      accidentDetails: json['AccidentDetails'],
      customerReportDate: json['CustomerReportDate'],
      totalReceived: json['TotalReceived'] ?? 0.0,
      enteredBy: json['EnteredBy'],
      documentStatus: json['DocumentStatus'],
      lastUpdateDate: json['LastUpdateDate'],
      businessClassID: json['BusinessClassID'] ?? '',
      riskTypeID: json['RiskTypeID'] ?? '',
      customerName: json['CustomerName'],
      dVAmount: json['DVAmount'] ?? 0.0,
      claimsStatus: json['ClaimsStatus'] ?? '',
      reportSubmitted: json['ReportSubmitted'] ?? '',
      customerEstimate: json['CustomerEstimate'] ?? 0.0,
      closed: json['Closed'] ?? false,
      cleared: json['Cleared'] ?? false,
      claimsDocuments: json['InsuranceClaimsDocument'] != null &&
              json['InsuranceClaimsDocument'] != []
          ? List.from(json['InsuranceClaimsDocument'])
              .map((item) => ClaimDocument.fromJson(item))
              .toList()
          : [],
      insurancePolicyUnderwriters:
          json['InsuranceClaimsUnderwriters'] != null &&
                  json['InsuranceClaimsUnderwriters'] != []
              ? List.from(json['InsuranceClaimsUnderwriters'])
                  .map((item) => InsurancePolicyUnderwriter.fromJson(item))
                  .toList()
              : [],
      submitClaim: json['SubmitClaim'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CompanyID'] = companyID;
    map['DivisionID'] = divisionID;
    map['DepartmentID'] = departmentID;
    map['PolicyBrokerID'] = policyBrokerID;
    map['BrokerClaimID'] = brokerClaimID;
    map['TransactionID'] = transactionID;
    map['CustomerID'] = customerID;
    map['AccidentDate'] = accidentDate;
    map['AccidentDetails'] = accidentDetails;
    map['CustomerReportDate'] = customerReportDate;
    map['StartDate'] = startDate;
    map['EndDate'] = endDate;
    map['TotalReceived'] = totalReceived;
    map['EnteredBy'] = enteredBy;
    map['DocumentStatus'] = documentStatus;
    map['LastUpdateDate'] = lastUpdateDate;
    map['BusinessClassID'] = businessClassID;
    map['RiskTypeID'] = riskTypeID;
    map['CustomerName'] = customerName;
    map['DVAmount'] = dVAmount;
    map['ClaimsStatus'] = claimsStatus;
    map['ReportSubmitted'] = reportSubmitted;
    map['CustomerEstimate'] = customerEstimate;
    map['Closed'] = closed;
    map['Cleared'] = cleared;
    map['InsuranceClaimsDocument'] =
        claimsDocuments != null && claimsDocuments!.isNotEmpty
            ? claimsDocuments?.map((v) => v.toJson()).toList()
            : [];
    map['InsuranceClaimsUnderwriters'] = insurancePolicyUnderwriters != null &&
            insurancePolicyUnderwriters!.isNotEmpty
        ? insurancePolicyUnderwriters?.map((v) => v.toJson()).toList()
        : [];
    // map['SupportDate'] = supportDate;
    return map;
  }

  @override
  String companyID;

  @override
  String departmentID;

  @override
  String divisionID;

  @override
  String policyBrokerID;
}
