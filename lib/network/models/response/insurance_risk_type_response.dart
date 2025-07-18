import 'package:pibro/network/models/response/base_response.dart';

class InsuranceRiskTypeResponse extends CustomBaseResponse {
  InsuranceRiskTypeResponse(super.responseData);

  late List<RiskTypeID> riskTypeIDs;

  @override
  parseResponseData() {
    try {
      riskTypeIDs = getResponseBody() != []
          ? List.from(getResponseBody())
              .map((item) => RiskTypeID.fromJson(item))
              .toList()
          : [];
    } catch (e) {
      handleParsingError(e);
    }
  }
}

class RiskTypeID {
  RiskTypeID({
    this.companyID,
    this.departmentID,
    this.divisionID,
    this.businessClassID,
    this.riskTypeID,
    this.riskName,
    this.brokerComm,
    this.riskTypeName,
    this.tarrif,
  });

  late String? companyID;
  late String? divisionID;
  late String? departmentID;
  late String? businessClassID;
  late String? riskTypeID;
  late String? riskName;
  late double? brokerComm;
  late dynamic riskTypeName;
  late double? tarrif;

  factory RiskTypeID.fromJson(dynamic json) {
    return RiskTypeID(
      companyID: json['CompanyID'],
      divisionID: json['DivisionID'],
      departmentID: json['DepartmentID'],
      businessClassID: json['BusinessClassID'],
      riskTypeID: json['RiskTypeID'],
      riskName: json['RiskName'],
      brokerComm: json['BrokerComm'],
      riskTypeName: json['RiskTypeName'],
      tarrif: json['Tarrif'],
    );
  }
}
