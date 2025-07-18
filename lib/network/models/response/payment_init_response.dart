import 'package:pibro/network/models/response/base_response.dart';

class PaymentInitResponse extends CustomBaseResponse {
  PaymentInitResponse(super.responseData);

  late PaymentInitData initData;

  @override
  parseResponseData() {
    try {
      initData = PaymentInitData.fromJson(getResponseBody());
    } catch (e) {
      handleParsingError(e);
    }
  }
}

class PaymentInitData {
  PaymentInitData({
    this.status = false,
    this.message,
    this.data,
  });

  late bool status;
  late String? message;
  late PaymentData? data;

  factory PaymentInitData.fromJson(dynamic json) {
    return PaymentInitData(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? PaymentData.fromJson(json['data']) : null,
    );
  }
}

class PaymentData {
  PaymentData({
    this.authorizationUrl,
    this.accessCode,
    this.reference,
  });

  late String? authorizationUrl;
  late String? accessCode;
  late String? reference;

  factory PaymentData.fromJson(dynamic json) {
    return PaymentData(
      authorizationUrl: json['authorization_url'],
      accessCode: json['access_code'],
      reference: json['reference'],
    );
  }
}
