import 'package:pibro/network/models/response/base_response.dart';

class BusinessPolicyResponse extends CustomBaseResponse {
  BusinessPolicyResponse(super.responseData);

  late List<BusinessPolicy> businessPolicies;

  @override
  parseResponseData() {
    try {
      businessPolicies = getResponseBody() != []
          ? List.from(getResponseBody())
              .map((item) => BusinessPolicy.fromJson(item))
              .toList()
          : [];
    } catch (e) {
      handleParsingError(e);
    }
  }
}

class BusinessPolicy {
  BusinessPolicy({
    this.companyID,
    this.departmentID,
    this.divisionID,
    this.businessClassID,
    this.businessClassName,
    this.brokersComm,
    this.existingBusiness,
    this.active = false,
    this.chargeVAT = false,
  });

  late String? companyID;
  late String? divisionID;
  late String? departmentID;
  late String? businessClassID;
  late String? businessClassName;
  late double? brokersComm;
  late double? existingBusiness;
  late bool active;
  late bool chargeVAT;

  factory BusinessPolicy.fromJson(dynamic json) {
    return BusinessPolicy(
      companyID: json['CompanyID'],
      divisionID: json['DivisionID'],
      departmentID: json['DepartmentID'],
      businessClassID: json['BusinessClassID'],
      businessClassName: json['BusinessClassName'],
      brokersComm: json['BrokersComm'],
      existingBusiness: json['ExistingBusiness'],
      active: json['Active'],
      chargeVAT: json['ChargeVAT'],
    );
  }
}
