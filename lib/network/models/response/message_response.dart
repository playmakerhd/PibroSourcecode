import 'package:pibro/network/models/response/base_response.dart';

class CustomMessageResponse extends CustomBaseResponse {
  CustomMessageResponse(super.responseData);

  late MessageResponse messageResponse;

  @override
  parseResponseData() {
    try {
      messageResponse = MessageResponse.fromJson(getResponseBody());
    } catch (e) {
      handleParsingError(e);
    }
  }
}

class MessageResponse {
  MessageResponse({
    required this.status,
    required this.message,
  });

  late String status;
  late String message;

  factory MessageResponse.fromJson(dynamic json) {
    return MessageResponse(
      status: json['Status'],
      message: json["Message"],
    );
  }
}
