import 'package:pibro/network/models/response/base_response.dart';

class CompanyInfoResponse extends CustomBaseResponse {
  CompanyInfoResponse(super.responseData);

  late CompanyInfo companyInfo;

  @override
  parseResponseData() {
    try {
      companyInfo = CompanyInfo.fromJson(getResponseBody());
    } catch (e) {
      handleParsingError(e);
    }
  }
}

class CompanyInfo {
  CompanyInfo({
    this.companyName,
    this.companyAddress1,
    this.companyAddress2,
    this.companyPhone,
    this.companyEmail,
    this.companyWebAddress,
    this.companyLogoUrl,
    this.socialAccounts,
  });

  late String? companyName;
  late String? companyAddress1;
  late String? companyAddress2;
  late String? companyPhone;
  late String? companyEmail;
  late String? companyWebAddress;
  late String? companyLogoUrl;
  late List<SocialAccount>? socialAccounts;

  factory CompanyInfo.fromJson(dynamic json) {
    return CompanyInfo(
      companyName: json['CompanyName'],
      companyAddress1: json['CompanyAddress1'],
      companyAddress2: json['CompanyAddress2'],
      companyPhone: json['CompanyPhone'],
      companyEmail: json['CompanyEmail'],
      companyWebAddress: json['CompanyWebAddress'] ?? '',
      companyLogoUrl: json['CompanyLogoUrl'],
      socialAccounts:
          json['SocialAccounts'] != null && json['SocialAccounts'] != []
              ? List.from(json['SocialAccounts'])
                  .map((item) => SocialAccount.fromJson(item))
                  .toList()
              : [],
    );
  }
}

class SocialAccount {
  SocialAccount({
    this.socialID,
    this.profileUrl,
  });

  late String? socialID;
  late String? profileUrl;

  factory SocialAccount.fromJson(dynamic json) {
    return SocialAccount(
      socialID: json['SocialID'],
      profileUrl: json['ProfileUrl'],
    );
  }
}
