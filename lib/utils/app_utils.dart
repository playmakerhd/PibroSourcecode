import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_storage/get_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:intl/intl.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/home/models/policy_status.dart';
import 'package:pibro/core/login/model/login_data.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/models/platform_user/platform_user.dart';
import 'package:pibro/network/models/response/customer_policy_claims_response.dart';
import 'package:url_launcher/url_launcher.dart';

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
  encryptData(key: StorageKeys.profileData, value: user.toJson().toString());
}

void persistSignupID(String id) {
  encryptData(key: StorageKeys.signupData, value: id);
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
  return DateFormat('MMM d, y').format(DateTime.parse(date));
}

String formatClaimDate(String date) {
  return DateFormat('MM-dd-yyyy').format(DateTime.parse(date));
}

// Base64 Image upload and display
Image imageFromBase64String(String base64String) {
  return Image.memory(base64Decode(base64String));
}

Uint8List dataFromBase64String(String base64String) {
  return base64Decode(base64String);
}

String base64String(Uint8List data) {
  return base64Encode(data);
}

String formatAmount(double amount) {
  final formatter = NumberFormat('#,##0.00', 'en_US');
  return formatter.format(amount);
}

List<dynamic> getClaimStatus(PolicyClaim claim) {
  if (claim.closed == true && claim.cleared == true) {
    return [AppStrings.settled.tr, AppColors.activeGreen];
  } else if (claim.cleared == true) {
    return [AppStrings.processing.tr, AppColors.orange];
  } else {
    return [AppStrings.notSubmitted.tr, AppColors.orange];
  }
}

Future<void> launchAnyUrl(String input) async {
  Uri uri;

  // Check if it's an email
  if (RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(input)) {
    print('Email');
    // uri = Uri.parse('mailto:$input');
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
