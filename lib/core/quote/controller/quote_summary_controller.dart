import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/login/model/login_data.dart';
import 'package:pibro/core/policy/controller/renew_policy_controller.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/core/quote/controller/quote_payment_controller.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/platform_user/platform_user.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/shared/custom_input/custom_input.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:intl/intl.dart';

class QuoteSummaryController extends GetxController {
  // Flexible date parser for ISO and pretty formats
  DateTime _parseDateFlex(dynamic v, {DateTime? fallback}) {
    if (v is DateTime) return v;
    final s = (v ?? '').toString().trim();
    if (s.isEmpty) return fallback ?? DateTime.now();
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    try {
      return DateFormat('MMM d, y').parse(s);
    } catch (_) {}
    try {
      return DateFormat('MM-dd-yyyy').parse(s);
    } catch (_) {}
    return fallback ?? DateTime.now();
  }

  late final RenewPolicyController renew;
  // UI observables
  final RxString insuranceClass = ''.obs;
  final RxString product = ''.obs;
  final RxString startDateText = ''.obs;
  final RxString endDateText = ''.obs;
  final RxString renewalDateText = ''.obs;
  final RxString sumInsuredText = ''.obs;
  final RxString premiumText = ''.obs;

  // Contest fields
  RxBool contestLoading = false.obs;
  final TextEditingController contestSubjectController =
      TextEditingController();
  final TextEditingController contestMessageController =
      TextEditingController();
  PibroRepository pibroRepository =
      PibroRepository(appApiProvider: ApiProvider());

  Map<String, dynamic> enquiry = const {};

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<RenewPolicyController>()) {
      renew = Get.find<RenewPolicyController>();
    } else {
      renew = Get.put(RenewPolicyController());
    }
    _hydrateFromStorage();
  }

  void _hydrateFromStorage() {
    final e = GetStorage().read(StorageKeys.lastEnquiry) as Map? ?? {};
    enquiry = Map<String, dynamic>.from(e);
    final resolvedQuoteId = _resolveQuoteId();
    if (resolvedQuoteId != null) {
      enquiry['quoteID'] = resolvedQuoteId;
    }

    insuranceClass.value = '${e['businessClassName'] ?? ''}';
    product.value = '${e['riskName'] ?? ''}';

    // Parse ISO or pretty dates safely
    final parsedStart = _parseDateFlex(e['startDate']);
    final parsedEnd = _parseDateFlex(e['endDate'],
        fallback: parsedStart.add(const Duration(days: 364)));
    final parsedRenewal = _parseDateFlex(e['renewalDate'],
        fallback: parsedEnd.add(const Duration(days: 1)));

    startDateText.value = formatDate(parsedStart.toIso8601String());
    endDateText.value = formatDate(parsedEnd.toIso8601String());
    renewalDateText.value = formatDate(parsedRenewal.toIso8601String());

    final sum = (e['sumInsured'] ?? 0).toString();
    final prem = (e['premium'] ?? 0).toString();

    sumInsuredText.value =
        formatAmount(double.tryParse(sum.replaceAll(',', '')) ?? 0);
    premiumText.value =
        formatAmount(double.tryParse(prem.replaceAll(',', '')) ?? 0);

    // Switch renew controller into "quote mode"
    renew.isQuoteFlow = true;

    // premium used by client note creation later
    final premNum = double.tryParse(prem.replaceAll(',', '')) ?? 0;
    renew.policyPremiumAmount = premNum.toStringAsFixed(2);

    // If you mirror into RenewPolicyController for downstream usage:
    renew.startDate.value = parsedStart;
    renew.endDate.value = parsedEnd;
  }

  /// Trigger Paystack via RenewPolicyController
  Future<void> beginPayment() async {
    try {
      // Build/ensure lastEnquiry is already persisted as you do now
      await Get.put(QuotePaymentController()).beginPayment();
    } catch (err) {
      // PibroLogger.logResponse('beginPayment error: $err\n$st');
      showSnackbarMessage(
        message: AppStrings.genericErrorMessage.tr,
        isSuccess: false,
      );
    }
  }

  String extractCustomerId() {
    print('🔍 EXTRACT_CUSTOMER_ID: Starting customer ID extraction');

    try {
      final profileData = GetStorage().read(StorageKeys.profileData);
      print('📱 EXTRACT_CUSTOMER_ID: Raw profile data: $profileData');

      if (profileData != null) {
        try {
          final user = PlatformUser.fromJson(profileData);
          print('✅ EXTRACT_CUSTOMER_ID: User parsed successfully');
          print('   Customer ID: ${user.customerID}');
          return user.customerID ?? '';
        } catch (e) {
          print('❌ EXTRACT_CUSTOMER_ID: Failed to parse profileData: $e');
        }
      }

      // Fallback: try loginData (may be encrypted/serialized)
      try {
        final loginRaw = decryptData(StorageKeys.loginData) ??
            GetStorage().read(StorageKeys.loginData);
        if (loginRaw != null) {
          if (loginRaw is Map) {
            final possible = loginRaw['customerID'] ??
                loginRaw['CustomerID'] ??
                loginRaw['username'] ??
                loginRaw['Username'];
            if (possible != null && possible.toString().trim().isNotEmpty) {
              print('🔁 EXTRACT_CUSTOMER_ID: Found in loginData: $possible');
              return possible.toString();
            }
          } else if (loginRaw is String) {
            // attempt JSON parse
            try {
              final m = jsonDecode(loginRaw);
              if (m is Map) {
                final possible = m['customerID'] ??
                    m['CustomerID'] ??
                    m['username'] ??
                    m['Username'];
                if (possible != null && possible.toString().trim().isNotEmpty) {
                  print(
                      '🔁 EXTRACT_CUSTOMER_ID: Found in loginData string: $possible');
                  return possible.toString();
                }
              }
            } catch (_) {}
          }
        }
      } catch (_) {}

      // Final fallback: signupData
      try {
        final signup = decryptData(StorageKeys.signupData) ??
            GetStorage().read(StorageKeys.signupData);
        if (signup != null) {
          if (signup is Map) {
            final possible = signup['customerID'] ??
                signup['CustomerID'] ??
                signup['username'];
            if (possible != null && possible.toString().trim().isNotEmpty) {
              return possible.toString();
            }
          } else if (signup is String) {
            try {
              final m = jsonDecode(signup);
              if (m is Map) {
                final possible =
                    m['customerID'] ?? m['CustomerID'] ?? m['username'];
                if (possible != null && possible.toString().trim().isNotEmpty) {
                  return possible.toString();
                }
              }
            } catch (_) {}
          }
        }
      } catch (_) {}

      print('❌ EXTRACT_CUSTOMER_ID: No customer id found in storage');
      return '';
    } catch (e, st) {
      print('❌ EXTRACT_CUSTOMER_ID: Error extracting customer ID: $e');
      print('📍 STACK TRACE: $st');
      return '';
    }
  }

  void showContestModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.greyColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Contest Payment',
                      style: Styles.semiBoldTextStyle(
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    controller: contestSubjectController,
                    hint: 'Subject',
                    label: 'Subject',
                    height: 35,
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    controller: contestMessageController,
                    hint: 'Message',
                    label: 'Message',
                    maxLines: 3,
                    height: 75,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PolicyButton(
                        text: 'Cancel',
                        onPressed: () => Get.back(),
                        width: 80,
                        height: 35,
                        bgColor: AppColors.primaryColor,
                      ),
                      Obx(
                        () => PolicyButton(
                          text: 'Submit',
                          onPressed:
                              contestLoading.value ? () {} : submitContest,
                          loading: contestLoading.value,
                          width: 80,
                          height: 35,
                          bgColor: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> submitContest() async {
    if (contestSubjectController.text.trim().isEmpty ||
        contestMessageController.text.trim().isEmpty) {
      showSnackbarMessage(
        message: 'Please fill in both subject and message',
        isSuccess: false,
      );
      return;
    }

    contestLoading.value = true;
    try {
      final response =
          await pibroRepository.sendToBroker(_createContestPayload());
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
      } else {
        Get.back(); // Close modal
        contestSubjectController.clear();
        contestMessageController.clear();
        showSnackbarMessage(
            message: 'Contest submitted successfully', isSuccess: true);
      }
      contestLoading.value = false;
    } catch (e) {
      contestLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Map<String, dynamic> _createContestPayload() {
    LoginData loginData =
        LoginData.fromJson(convertToJsonStringQuotes(StorageKeys.loginData));
    final entityID =
        resolveEntityID(loginCustomerID: loginData.customerID) ?? '';

    final sumInsuredValue = double.tryParse(
            enquiry['sumInsured']?.toString().replaceAll(',', '') ?? '0') ??
        0.0;
    final premiumValue = double.tryParse(
            enquiry['premium']?.toString().replaceAll(',', '') ?? '0') ??
        0.0;

    // Create enhanced description with contest details
    final originalDescription =
        "Quote Request - Business Class: ${enquiry['businessClassName']}, Product: ${enquiry['riskName']}, Start Date: ${enquiry['startDate']}, End Date: ${enquiry['endDate']}, Sum Insured: $sumInsuredValue, Premium: $premiumValue";
    final contestDescription =
        "$originalDescription\n\nCONTEST DETAILS:\nSubject: ${contestSubjectController.text.trim()}\nMessage: ${contestMessageController.text.trim()}";

    return {
      "CompanyID": "",
      "DivisionID": "",
      "DepartmentID": "",
      "CaseId": "",
      "CustomerId": entityID,
      "ProductId": enquiry['riskName'] ?? '',
      "SupportDate": DateTime.now().toIso8601String(),
      "SupportKeywords":
          "Contest Quote, ${enquiry['businessClassName']}, ${enquiry['riskName']}, Sum Insured: $sumInsuredValue, Premium: $premiumValue",
      "SupportDescription": contestDescription,
      "SupportScreenShotURL": "",
      "SupportEnquiryDate": enquiry['startDate'],
      "SupportEnquiryLapseDate": enquiry['endDate'],
      "SupportPriority": 64,
      "SupportApproved": true,
      "SupportApprovedBy": "Admin",
      "SupportAssigned": true,
      "SupportType": "Contest Quote",
      "SupportStatus": "Pending",
      "ContactName": loginData.customerID ?? "",
      "ContactPhone": loginData.phone ?? "",
      "ContactEmail": loginData.email ?? "",
      "QuoteRequest": true,
      "RequestDetails": enquiry['items'] ?? [],
    };
  }

  /// Fetches premium demand note PDF bytes for the current quote.
  /// Returns null on error.
  Future<Uint8List?> fetchPremiumDemandNoteBytes() async {
    try {
      // Get quoteID from stored enquiry data
      final quoteID = _resolveQuoteId();

      if (quoteID == null || quoteID.isEmpty) {
        print('❌ PREMIUM_DEMAND_NOTE: No quote ID found in enquiry data');
        showSnackbarMessage(
          message: 'No quote ID available',
          isSuccess: false,
        );
        return null;
      }

      print('🔍 PREMIUM_DEMAND_NOTE: Fetching for Quote ID: $quoteID');

      final resp = await pibroRepository.viewPremiumDemandNoteReport(
        quoteID: quoteID,
      );

      final status = resp.messageResponse.status;
      final msg = resp.messageResponse.message; // Base64 PDF

      if (status.toLowerCase() != 'success' || msg.isEmpty) {
        print('❌ PREMIUM_DEMAND_NOTE: API returned failure or empty message');
        return null;
      }

      // Decode base64 to bytes
      final cleanedBase64 =
          msg.startsWith('data:') ? msg.substring(msg.indexOf(',') + 1) : msg;
      final bytes = base64Decode(cleanedBase64);

      print(
          '✅ PREMIUM_DEMAND_NOTE: Successfully fetched ${bytes.length} bytes');
      return Uint8List.fromList(bytes);
    } catch (e) {
      print('❌ PREMIUM_DEMAND_NOTE: Error: $e');
      showSnackbarMessage(
        message: 'Error loading premium demand note: $e',
        isSuccess: false,
      );
      return null;
    }
  }

  String? _resolveQuoteId() {
    final raw = enquiry['quoteID'] ?? enquiry['caseId'] ?? enquiry['CaseId'];
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }
}
