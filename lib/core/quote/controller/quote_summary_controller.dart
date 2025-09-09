import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/policy/controller/renew_policy_controller.dart';
import 'package:pibro/core/quote/controller/get_quote_controller.dart';
import 'package:pibro/core/quote/controller/quote_controller.dart';
import 'package:pibro/core/quote/controller/quote_payment_controller.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/models/platform_user/platform_user.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/pibro_logger.dart';
import 'package:pibro/utils/view_utils.dart';

class QuoteSummaryController extends GetxController {
  late final RenewPolicyController renew;
  // UI observables
  final RxString insuranceClass = ''.obs;
  final RxString product = ''.obs;
  final RxString startDateText = ''.obs;
  final RxString endDateText = ''.obs;
  final RxString renewalDateText = ''.obs;
  final RxString sumInsuredText = ''.obs;
  final RxString premiumText = ''.obs;

  Map<String, dynamic> enquiry = const {};

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<RenewPolicyController>()) {
      renew = Get.find<RenewPolicyController>();
    } else {
      renew = Get.put(RenewPolicyController());
    }
  }

  Map<String, dynamic> _readProfileMap() {
    final raw = GetStorage().read(StorageKeys.profileData);
    if (raw == null) return <String, dynamic>{};
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String) {
      try {
        final m = jsonDecode(raw);
        if (m is Map) return Map<String, dynamic>.from(m);
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _readLoginMap() {
    try {
      final m = convertToJsonStringQuotes(StorageKeys.loginData);
      return m is Map<String, dynamic> ? m : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _firstNonEmpty(Iterable<dynamic> vals) {
    for (final v in vals) {
      final s = (v ?? '').toString().trim();
      if (s.isNotEmpty) return s;
    }
    return '';
  }

  /// ✅ Robust CustomerID extractor
  String extractCustomerId() {
    try {
      final profileMap = _readProfileMap();
      if (profileMap.isNotEmpty) {
        final user = PlatformUser.fromJson(profileMap);
        final id = (user.customerID ?? '').trim();
        if (id.isNotEmpty) return id;
      }

      final loginMap = _readLoginMap();
      final id = _firstNonEmpty([
        loginMap['customerID'],
        loginMap['CustomerID'],
        loginMap['customerId'],
        loginMap['CustomerId'],
        loginMap['username'],
        loginMap['Username'],
      ]);
      if (id.isNotEmpty) return id;

      return '';
    } catch (e, st) {
      print('❌ extractCustomerId error: $e\n$st');
      return '';
    }
  }

  /// ✅ Robust CustomerEmail extractor
  String extractCustomerEmail() {
    try {
      final profileMap = _readProfileMap();
      if (profileMap.isNotEmpty) {
        final user = PlatformUser.fromJson(profileMap);
        final email = (user.customerEmail ?? '').trim();
        if (email.isNotEmpty) return email;
        if (user.customerContacts != null) {
          for (final c in user.customerContacts!) {
            final em = (c.contactEmail ?? '').trim();
            if (em.isNotEmpty) return em;
          }
        }
      }

      final loginMap = _readLoginMap();
      final email = _firstNonEmpty([
        loginMap['email'],
        loginMap['Email'],
      ]);
      if (email.isNotEmpty) return email;

      final stored = GetStorage().read(StorageKeys.userEmail);
      if (stored is String && stored.trim().isNotEmpty) return stored.trim();

      return '';
    } catch (e, st) {
      print('❌ extractCustomerEmail error: $e\n$st');
      return '';
    }
  }

  Future<void> beginPayment() async {
    try {
      await Get.put(QuotePaymentController()).beginPayment();
    } catch (err, st) {
      showSnackbarMessage(
        message: AppStrings.genericErrorMessage.tr,
        isSuccess: false,
      );
    }
  }
}
