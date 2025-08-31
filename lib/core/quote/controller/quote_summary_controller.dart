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
    _hydrateFromStorage();
  }

  void _hydrateFromStorage() {
    final e = GetStorage().read(StorageKeys.lastEnquiry) as Map? ?? {};
    enquiry = Map<String, dynamic>.from(e);

    insuranceClass.value = '${e['businessClassName'] ?? ''}';
    product.value = '${e['riskName'] ?? ''}';
    startDateText.value = '${e['startDate'] ?? ''}';
    endDateText.value = '${e['endDate'] ?? ''}';
    renewalDateText.value = '${e['renewalDate'] ?? ''}';

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

    // set dates for debit note flow (avoid new helpers, mirror renew controller style)
    renew.startDate.value =
        DateTime.tryParse(e['startDate']?.toString() ?? '') ?? DateTime.now();
    renew.endDate.value = DateTime.tryParse(e['endDate']?.toString() ?? '') ??
        DateTime.now().add(const Duration(days: 364));
  }

  /// Trigger Paystack via RenewPolicyController
  Future<void> beginPayment() async {
    try {
      // Build/ensure lastEnquiry is already persisted as you do now
      await Get.put(QuotePaymentController()).beginPayment();
    } catch (err, st) {
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

      if (profileData == null) {
        print('❌ EXTRACT_CUSTOMER_ID: Profile data is null');
        return '';
      }

      final user = PlatformUser.fromJson(profileData);
      print('✅ EXTRACT_CUSTOMER_ID: User parsed successfully');
      print('   Customer ID: ${user.customerID}');
      print('   Customer Name: ${user.customerName}');
      print('   Customer Full Name: ${user.customerFullName}');
      print('   Customer First Name: ${user.customerFirstName}');
      print('   Customer Last Name: ${user.customerLastName}');
      print('   Customer Email: ${user.customerEmail}');

      return user.customerID ?? '';
    } catch (e, st) {
      print('❌ EXTRACT_CUSTOMER_ID: Error extracting customer ID: $e');
      print('📍 STACK TRACE: $st');
      return '';
    }
  }
}
