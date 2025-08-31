import 'package:pibro/network/models/response/base_response.dart';

class VendorResponse extends CustomBaseResponse {
  VendorResponse(super.responseData);
  late List<VendorInfo> vendors;

  @override
  parseResponseData() {
    try {
      final body = getResponseBody();
      vendors = (body is List)
          ? body.map((e) => VendorInfo.fromJson(e)).toList()
          : <VendorInfo>[];
    } catch (e) {
      handleParsingError(e);
      vendors = <VendorInfo>[];
    }
  }
}

class VendorInfo {
  final String? vendorID;
  final String? vendorName;
  VendorInfo({this.vendorID, this.vendorName});

  factory VendorInfo.fromJson(dynamic json) => VendorInfo(
        vendorID: json['VendorID']?.toString(),
        vendorName: json['VendorName']?.toString(),
      );

  @override
  String toString() => vendorName ?? '';
}
