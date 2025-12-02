import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:intl/intl.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/config/model/config_model.dart';
import 'package:pibro/core/home/models/policy_status.dart';
import 'package:pibro/core/login/model/login_data.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/models/platform_user/platform_user.dart';
import 'package:pibro/network/models/response/customer_policy_claims_response.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pibro/core/landing/controller/landing_controller.dart';
import 'package:pibro/core/support/controller/support_controller.dart';

// Normalizes display values from API/model to a user-friendly string.
String displayValue(dynamic v) {
  if (v == null) return '-';
  final s = v.toString().trim();
  if (s.isEmpty) return '-';
  final lower = s.toLowerCase();
  const nullTokens = {
    'null',
    'nil',
    'n/a',
    'na',
    'undefined',
    'unknown',
    'none',
    '-'
  };
  if (nullTokens.contains(lower)) return '-';
  return s;
}

void persistLoginData({
  required LoginData data,
  required bool remember,
}) {
  encryptData(key: StorageKeys.loginData, value: data.toJson().toString());
  if (remember) {
    GetStorage().write(StorageKeys.rememberMe, StorageKeys.rememberMe);
  } else {
    GetStorage().remove(StorageKeys.rememberMe);
  }
}

void persistProfileData(PlatformUser user) {
  // encryptData(key: StorageKeys.profileData, value: user.toJson().toString());
  GetStorage().write(StorageKeys.profileData, user.toJson());
}

void deleteQuoteConfirmation() {
  if (GetStorage().hasData(StorageKeys.quoteConfirmation)) {
    GetStorage().remove(StorageKeys.quoteConfirmation);
  }
}

void persistSignupID(String id) {
  encryptData(key: StorageKeys.signupData, value: id);
}

/// Returns the best available entity identifier (CustomerID/LeadID).
/// Prefers the current login data (which reflects Lead→Customer promotion)
/// and falls back to the originally stored signup ID when login data is empty.
String? resolveEntityID({String? loginCustomerID}) {
  final loginId = loginCustomerID?.trim();
  if (loginId != null && loginId.isNotEmpty) {
    return loginId;
  }

  final storedSignup = decryptData(StorageKeys.signupData);
  if (storedSignup == null) {
    return null;
  }

  final signupId = storedSignup.toString().trim();
  return signupId.isEmpty ? null : signupId;
}

void encryptData({required String key, String value = ''}) {
  final encryptKey = encrypt.Key.fromUtf8(key);
  final iv = encrypt.IV.fromUtf8('HgNRbGHbDS3Pibro');

  final encrypter = encrypt.Encrypter(encrypt.AES(encryptKey));
  final encrypted = encrypter.encrypt(value, iv: iv);
  GetStorage().write(key, encrypted.base64);
}

dynamic decryptData(String key) {
  final encryptKey = encrypt.Key.fromUtf8(key);
  final iv = encrypt.IV.fromUtf8('HgNRbGHbDS3Pibro');

  final decrypter = encrypt.Encrypter(encrypt.AES(encryptKey));
  final encrypted = GetStorage().read(key);
  if (encrypted != null) {
    final decrypted =
        decrypter.decryptBytes(encrypt.Encrypted.fromBase64(encrypted), iv: iv);
    final decryptedData = utf8.decode(decrypted);
    // final finalData = jsonDecode(decryptedData);
    return decryptedData;
  }
  return null;
}

Map<String, dynamic> convertToJsonStringQuotes(String key) {
  dynamic jsonString = decryptData(key);

  if (jsonString != null) {
    /// add quotes to json string
    jsonString = jsonString.replaceAll('{', '{"');
    jsonString = jsonString.replaceAll(': ', '": "');
    jsonString = jsonString.replaceAll(', ', '", "');
    jsonString = jsonString.replaceAll('}', '"}');

    /// remove quotes on object json string
    jsonString = jsonString.replaceAll('"{"', '{"');
    jsonString = jsonString.replaceAll('"}"', '"}');

    /// remove quotes on array json string
    jsonString = jsonString.replaceAll('"[{', '[{');
    jsonString = jsonString.replaceAll('}]"', '}]');

    final Map<String, dynamic> result = json.decode(jsonString);

    return result;
  } else {
    return {};
  }
}

String formatDate(String date) {
  try {
    if (date.isEmpty) return 'N/A';
    return DateFormat('MMM d, y').format(DateTime.parse(date));
  } catch (e) {
    return 'N/A';
  }
}

String formatClaimDate(String date) {
  return DateFormat('MM-dd-yyyy').format(DateTime.parse(date));
}

// Base64 Image upload and display
Future<String> convertFileToBase64(File file) async {
  final bytes = await file.readAsBytes();
  String base64String = base64Encode(bytes);
  return base64String;
}

String formatAmount(double amount) {
  final formatter = NumberFormat('#,##0.00', 'en_US');
  return formatter.format(amount);
}

List<dynamic> getClaimStatus(PolicyClaim claim) {
  if (claim.closed == true && claim.cleared == true) {
    return [AppStrings.settled.tr, AppColors.activeGreen];
  } else if (claim.cleared == true) {
    return [AppStrings.processing.tr, AppColors.green];
  } else if (claim.submitClaim == true) {
    return [AppStrings.submitted.tr, AppColors.orange];
  } else {
    return [AppStrings.notSubmitted.tr, AppColors.red];
  }
}

Future<void> launchAnyUrl(String input) async {
  Uri uri;

  // Check if it's an email
  if (RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(input)) {
    uri = Uri(
      scheme: 'mailto',
      path: input,
      // query: 'subject=Hello&body=Hi there!', // Optional
    );
  }

  // Check if it's a valid URL
  else if (!input.startsWith('http')) {
    uri = Uri.parse('https://$input');
  } else {
    uri = Uri.parse(input);
  }

  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  } catch (e) {
    debugPrint('Error launching url ${e.toString()}');
  }
  // if (!await launchUrl(Uri.parse(url))) {
  //   throw Exception('Could not launch $url');
  // }
}

Future<void> launchPhone(String number) async {
  final Uri uri = Uri(scheme: 'tel', path: number);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch phone dialer';
  }
}

PolicyStatus getPolicyStatus(String date, bool approved) {
  if (!approved) {
    return PolicyStatus(status: AppStrings.pending.tr, color: AppColors.orange);
  } else {
    if (DateTime.now().isAfter(DateTime.parse(date))) {
      return PolicyStatus(status: AppStrings.expired.tr, color: AppColors.red);
    } else {
      return PolicyStatus(
          status: AppStrings.active.tr, color: AppColors.activeGreen);
    }
  }
}

Future<void> saveConfig(GlobalKey<FormState> formKey,
    {String url = '', String token = '', bool isProfile = false}) async {
  if (formKey.currentState!.validate()) {
    try {
      final configData = ConfigData(
        url: url,
        token: token,
      ).toJson();

      encryptData(key: StorageKeys.configData, value: configData.toString());
      // Clear cached controllers so they will reload company info when the app
      // navigates to the splash/landing screen after saving a new config.
      try {
        Get.delete<LandingController>(force: true);
      } catch (_) {}
      try {
        Get.delete<SupportController>(force: true);
      } catch (_) {}

      if (isProfile) {
        safeBack();
      } else {
        Get.offAllNamed(AppRoutes.splash, arguments: {'forceRefresh': true});
      }
    } catch (e) {
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }
}
