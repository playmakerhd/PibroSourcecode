import 'package:pibro/network/models/response/base_response.dart';

class PaymentVerificationResponse extends CustomBaseResponse {
  PaymentVerificationResponse(super.responseData);

  late VerificationData verificationData;

  @override
  parseResponseData() {
    try {
      verificationData = VerificationData.fromJson(getResponseBody());
    } catch (e) {
      handleParsingError(e);
    }
  }
}

class VerificationData {
  VerificationData({
    this.status = false,
    this.message,
    this.data,
  });

  late bool status;
  late String? message;
  late Details? data;

  factory VerificationData.fromJson(dynamic json) {
    return VerificationData(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? Details.fromJson(json['data']) : null,
    );
  }
}

class Details {
  Details({
    this.status,
    this.reference,
    this.amount,
    this.paidAt,
    this.channel,
  });

  late String? status;
  late String? reference;
  late int? amount;
  late String? paidAt;
  late String? channel;

  factory Details.fromJson(dynamic json) {
    return Details(
      status: json['status'],
      reference: json['reference'],
      amount: json['amount'],
      paidAt: json['paid_at'],
      channel: json['channel'],
    );
  }
}
