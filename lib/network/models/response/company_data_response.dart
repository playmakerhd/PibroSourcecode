import 'package:pibro/network/models/response/base_response.dart';

class CompanyDataResponse extends CustomBaseResponse {
  CompanyDataResponse(super.responseData);

  late List<CompanyData> companyData;

  @override
  parseResponseData() {
    try {
      companyData = getResponseBody() != []
          ? List.from(getResponseBody())
              .map((item) => CompanyData.fromJson(item))
              .toList()
          : [];
    } catch (e) {
      handleParsingError(e);
    }
  }
}

class CompanyData {
  CompanyData({
    this.systemMessage,
    this.description,
  });

  late String? systemMessage;
  late String? description;

  factory CompanyData.fromJson(dynamic json) {
    return CompanyData(
      systemMessage: json['SystemMessage'],
      description: json['Description'],
    );
  }
}
