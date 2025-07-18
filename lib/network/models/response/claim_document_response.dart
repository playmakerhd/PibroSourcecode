import 'package:pibro/network/models/response/base_response.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';

class ClaimDocumentResponse extends CustomBaseResponse {
  ClaimDocumentResponse(super.responseData);

  late List<ClaimDocument> claimDocuments;

  @override
  parseResponseData() {
    try {
      claimDocuments = getResponseBody() != []
          ? List.from(getResponseBody())
              .map((item) => ClaimDocument.fromJson(item))
              .toList()
          : [];
    } catch (e) {
      handleParsingError(e);
    }
  }
}

class ClaimDocument implements PolicyDetails {
  ClaimDocument({
    required this.companyID,
    required this.departmentID,
    required this.divisionID,
    required this.policyBrokerID,
    this.brokerClaimID,
    this.claimsDocumentID,
    this.documentName,
    this.docStatus,
    this.dateSubmited,
    this.claimsDocument,
    this.underwriterClaimID,
    this.businessClassID,
    this.riskTypeID,
    this.customerID,
  });

  late String? brokerClaimID;
  late String? claimsDocumentID;
  late String? documentName;
  late bool? docStatus;
  late String? dateSubmited;
  late String? claimsDocument;
  late String? underwriterClaimID;
  late String? businessClassID;
  late String? riskTypeID;
  late String? customerID;

  factory ClaimDocument.fromJson(dynamic json) {
    return ClaimDocument(
      companyID: json['CompanyID'],
      divisionID: json['DivisionID'],
      departmentID: json['DepartmentID'],
      policyBrokerID: json['PolicyBrokerID'],
      brokerClaimID: json['BrokerClaimID'],
      claimsDocumentID: json['ClaimsDocumentID'],
      documentName: json['DocumentName'],
      docStatus: json['DocStatus'],
      dateSubmited: json['DateSubmited'],
      claimsDocument: json['ClaimsDocument'],
      underwriterClaimID: json['UnderwriterClaimID'],
      businessClassID: json['BusinessClassID'],
      riskTypeID: json['RiskTypeID'],
      customerID: json['CustomerID'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CompanyID'] = companyID;
    map['DivisionID'] = divisionID;
    map['DepartmentID'] = departmentID;
    map['PolicyBrokerID'] = policyBrokerID;
    map['BrokerClaimID'] = brokerClaimID;
    map['ClaimsDocumentID'] = claimsDocumentID;
    map['DocumentName'] = documentName;
    map['DocStatus'] = docStatus;
    map['DateSubmited'] = dateSubmited;
    map['ClaimsDocument'] = claimsDocument;
    map['UnderwriterClaimID'] = underwriterClaimID;
    map['BusinessClassID'] = businessClassID;
    map['RiskTypeID'] = riskTypeID;
    map['CustomerID'] = customerID;
    return map;
  }

  Map<String, dynamic> toBrokerJson() {
    final map = <String, dynamic>{};
    map['CaseID'] = "";
    map['Subject'] = claimsDocumentID;
    map['Message'] = "$documentName, Date Submitted: $dateSubmited";
    map['CaseIDDetail'] = 0;
    map['Created'] = "$dateSubmited";
    return map;
  }

  ClaimDocument copy() => ClaimDocument(
        companyID: companyID,
        departmentID: departmentID,
        divisionID: divisionID,
        policyBrokerID: policyBrokerID,
        brokerClaimID: brokerClaimID,
        claimsDocumentID: claimsDocumentID,
        documentName: documentName,
        docStatus: docStatus,
        dateSubmited: dateSubmited,
        claimsDocument: claimsDocument,
        underwriterClaimID: underwriterClaimID,
        businessClassID: businessClassID,
        riskTypeID: riskTypeID,
        customerID: customerID,
      );

  @override
  String companyID;

  @override
  String departmentID;

  @override
  String divisionID;

  @override
  String policyBrokerID;
}
