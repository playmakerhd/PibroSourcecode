import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/models/response/base_response.dart';
import 'package:pibro/utils/pibro_logger.dart';
import 'package:pibro/utils/view_utils.dart';

enum CacheTypes { onlyNetwork, networkFirst, cacheFirst }

abstract class BaseProvider {
  final Client httpClient = Client();
  Map<String, ResponseData> cache = {};

  Future<ResponseData?> makeGetCall(
    Uri url,
    bool isAuthenticatedCall, {
    cacheType = CacheTypes.networkFirst,
    String? languageHeader,
    bool refreshToken = false,
  }) async {
    ResponseData? responseData;
    switch (cacheType) {
      case CacheTypes.onlyNetwork:
        {
          responseData = await _makeCall(
            url,
            'get',
            isAuthenticatedCall: isAuthenticatedCall,
          );
          break;
        }
      case CacheTypes.networkFirst:
        {
          responseData = await _makeCall(
            url,
            'get',
            isAuthenticatedCall: isAuthenticatedCall,
          );
          if (responseData.response != null &&
              (responseData.response?.statusCode == 401 ||
                  responseData.response?.statusCode == 403)) {
            break;
          }
          if (responseData.hasError && cache[url.toString()] != null) {
            responseData = _getResponseDataFromCache(url);
          }
          break;
        }
      case CacheTypes.cacheFirst:
        {
          if (cache[url.toString()] != null) {
            responseData = _getResponseDataFromCache(url);
          } else {
            responseData = await _makeCall(
              url,
              'get',
              isAuthenticatedCall: isAuthenticatedCall,
            );
          }
          break;
        }
    }
    return responseData;
  }

  ResponseData? _getResponseDataFromCache(Uri url) {
    var responseData = cache[url.toString()];
    debugPrint('Response for ${responseData?.fromUrl} taken from cache');
    return responseData;
  }

  Future<ResponseData> makePutCall(
    Uri url,
    String body,
    bool isAuthenticatedCall, {
    bool refreshToken = false,
    String? languageHeader,
  }) async {
    return _makeCall(
      url,
      'put',
      requestBody: body,
      isAuthenticatedCall: isAuthenticatedCall,
    );
  }

  Future<ResponseData> makeDeleteCall({
    required Uri url,
    String? body,
    required bool isAuthenticatedCall,
    bool refreshToken = false,
    String? languageHeader,
  }) async {
    return _makeCall(
      url,
      'delete',
      requestBody: body,
      isAuthenticatedCall: isAuthenticatedCall,
    );
  }

  Future<ResponseData> makePostCall(
    Uri url,
    String body,
    bool isAuthenticatedCall, {
    bool refreshToken = false,
    String? languageHeader,
  }) async {
    return _makeCall(
      url,
      'post',
      requestBody: body,
      isAuthenticatedCall: isAuthenticatedCall,
    );
  }

  Future<Response> _call(String callType, url, headers, requestBody) async {
    switch (callType) {
      case 'get':
        {
          return await httpClient.get(url, headers: headers);
        }
      case 'post':
        {
          return await httpClient.post(url,
              body: requestBody, headers: headers);
        }
      case 'put':
        {
          return await httpClient.put(url, body: requestBody, headers: headers);
        }
      case 'delete':
        {
          return await httpClient.delete(url,
              body: requestBody, headers: headers);
        }
      default:
        {
          throw Exception('Method call not supported');
        }
    }
  }

  Future<ResponseData> _makeCall(
    Uri url,
    String callType, {
    String? requestBody,
    bool isAuthenticatedCall = true,
  }) async {
    var responseData = ResponseData();
    Response response;
    var urlSuffix = url.toString();
    responseData.fromUrl = urlSuffix;
    var headers = await _getHeaders(isAuthenticatedCall, urlSuffix);
    try {
      response = await _call(callType, url, headers, requestBody);
      var requestData = "No request data";
      if (requestBody != null) {
        requestData = requestBody;
      }

      var responseBody = "No response body";
      responseBody = response.body;

      PibroLogger.logHttp(
        url: urlSuffix,
        headers: "$headers",
        requestData: requestData,
        code: "${response.statusCode}",
        body: responseBody,
      );

      if (response.statusCode == 500) {
        showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr,
          isSuccess: false,
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        responseData.hasError = true;
        switch (response.statusCode) {
          case 400:
            responseData.errorMessage = 'Bad request';
            break;
          case 401:
            responseData.errorMessage = 'Unauthorised';
            break;
          case 403:
            responseData.errorMessage = 'Forbidden';
            break;
          case 404:
            responseData.errorMessage = 'Not found';
            break;
          case 500:
            responseData.errorMessage = 'Internal server error';
            break;
          default:
            responseData.errorMessage =
                'Error occurred while communication with server, StatusCode : ${response.statusCode}';
        }
      }
      responseData.response = response;
    } catch (e) {
      responseData.hasError = true;
      responseData.errorMessage = e.toString();
      debugPrint('Error calling $urlSuffix\n${e.toString()}');
    }

    if (callType == 'get' && !responseData.hasError) {
      cache[urlSuffix] = responseData;
    }
    return Future.value(responseData);
  }

  Future<Map<String, String>> _getHeaders(
      bool authenticated, String url) async {
    Map<String, String> headers = {};
    headers["Content-type"] = "application/json";
    headers["Accept"] = "application/json";
    // if (authenticated) {
    //   final apiToken = decryptData(AppConstants.accessToken);
    //   headers["Authorization"] = 'Bearer $apiToken';
    // }

    return headers;
  }
}

// abstract class BaseProviderWithRefreshTokenManagement extends BaseProvider {
//   @override
//   Future<ResponseData> _makeCall(
//     Uri url,
//     String callType, {
//     String? requestBody,
//     bool isAuthenticatedCall = true,
//   }) async {
//     ResponseData responseData = await super._makeCall(
//       url,
//       callType,
//       requestBody: requestBody,
//       isAuthenticatedCall: isAuthenticatedCall,
//     );

//     return responseData;
//   }
// }
