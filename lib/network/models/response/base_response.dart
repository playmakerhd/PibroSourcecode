import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import 'package:pibro/internalization/app_strings.dart';

class ResponseData {
  String? fromUrl;
  Response? response;
  bool hasError = false;
  String? errorMessage;
}

abstract class CustomBaseResponse {
  late ResponseData data;
  late String message;

  parseResponseData();

  CustomBaseResponse(ResponseData responseData) {
    try {
      data = responseData;
      // message = getResponseBody()['errors'][0]['message'];
    } catch (_) {
      message = AppStrings.genericErrorMessage.tr;
    } finally {
      parseResponseData();
    }
  }

  int getStatusCode() {
    if (data.response != null) {
      return data.response?.statusCode ?? -1;
    } else {
      return -1;
    }
  }

  dynamic getResponseBody() {
    if (data.response?.bodyBytes != null) {
      return json.decode(utf8.decode(data.response!.bodyBytes));
    }
  }

  String getRawBody() {
    // if(data.response?.body.toString().contains('The resource you are looking for has been removed, had its name changed, or is temporarily unavailable')) {

    //   return;
    // }
    return data.response!.body;
  }

  void handleParsingError(e) {
    data.hasError = true;
    data.errorMessage = 'Error while parsing response from ${data.fromUrl}';
    debugPrint(
        'Error while parsing response from ${data.fromUrl}\n${e.toString()}');
  }
}
