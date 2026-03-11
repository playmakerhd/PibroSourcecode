import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/platform_user/platform_user.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';

class HomeController extends GetxController {
  PibroRepository pibroRepository =
      PibroRepository(appApiProvider: ApiProvider());

  RxBool loading = false.obs;
  RxBool profileLoading = false.obs;
  Rxn<PlatformUser> user = Rxn<PlatformUser>();
  RxList<PolicyData> policies = RxList<PolicyData>([]);
  RxList<PolicyData> displayPolicies = RxList<PolicyData>([]);
  RxString policyScreenTitle = ''.obs;

  Rxn<PolicyData> selectedPolicy = Rxn<PolicyData>();
  Rxn<ItemToInsure> selectedItem = Rxn<ItemToInsure>();
  RxInt selectedIndex = 0.obs;

  RxString selectedPageStatus = ''.obs;
  RxBool isRenewPolicyClicked = false.obs;
  RxString policyStatus = ''.obs;

  Future<void> getCustomerPolicies({String? status}) async {
    try {
      final response = await pibroRepository.getCustomerPolicies();
      policies.value = response.policies;
      if (status != null) {
        categorizePolicies(status);
      }
      loading.value = false;
    } catch (e) {
      loading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  void _logout() {
    GetStorage().erase();
    Get.deleteAll();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> getProfile() async {
    profileLoading.value = true;
    loading.value = true;
    try {
      final response = await pibroRepository.getProfile();
      if (response.user.customerID != null &&
          response.user.customerID!.isNotEmpty) {
        user.value = response.user;
        persistProfileData(user.value!);
        profileLoading.value = false;
        getCustomerPolicies();
      } else {
        _logout();
      }
    } catch (e) {
      profileLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  RxString getPolicyListCount(String status) {
    return policies.isEmpty
        ? '0'.obs
        : policies
            .where((item) =>
                getPolicyStatus(item.policyEndDate ?? DateTime.now().toString(),
                        item.approved ?? false)
                    .status ==
                status)
            .toList()
            .length
            .toString()
            .obs;
  }

  void categorizePolicies(String status) {
    policyScreenTitle.value = status.isEmpty
        ? AppStrings.policies.tr
        : status == AppStrings.active.tr
            ? AppStrings.activePolicies.trParams({'break': ' '})
            : AppStrings.expiredPolicies.trParams({'break': ' '});
    isRenewPolicyClicked.value = false;
    displayPolicies.value = status.isEmpty
        ? policies
        : policies
            .where((item) =>
                getPolicyStatus(item.policyEndDate ?? DateTime.now().toString(),
                        item.approved ?? false)
                    .status ==
                status)
            .toList();
  }

  void navigateToPolicyScreens({String? status = ''}) {
    // Always set the requested status, categorize and navigate.
    // This allows opening the Policies screen even when the policies list is empty.
    policyStatus.value = status ?? '';
    categorizePolicies(policyStatus.value);
    Get.toNamed(AppRoutes.policy);
  }

  void navigateToQuoteScreen() {
    // if (policies.isNotEmpty) {
    Get.toNamed(AppRoutes.quoteList);
    // } else {
    //   showSnackbarMessage(
    //       message: 'Policies data still loading...', isWarning: true);
    // }
  }

  void clickRenewPolicyInHomeScreen() {
    if (policies.isNotEmpty) {
      isRenewPolicyClicked.value = true;
      displayPolicies.value = policies;
      policyScreenTitle.value = AppStrings.policies.tr;
      Get.toNamed(AppRoutes.policy);
    } else {
      showSnackbarMessage(
          message: 'Policies data still loading...', isWarning: true);
    }
  }

  void navigateToClaimScreen() {
    // Allow opening the Claims screen even if there are no policies yet.
    Get.toNamed(AppRoutes.claim);
  }

  void navigateToPolicyDetails(PolicyData data) {
    selectedPolicy.value = data;
    if (isRenewPolicyClicked.value) {
      navigateToRenewPolicyScreen();
    } else {
      Get.toNamed(AppRoutes.policyDetail);
    }
  }

  void navigateToRenewPolicyScreen() {
    Get.toNamed(
      AppRoutes.renewPolicy,
      arguments: selectedPolicy.value,
    );
  }

  void navigateToLodgeClaimScreen() {
    Get.toNamed(
      AppRoutes.lodgeClaims,
      arguments: selectedPolicy.value,
    );
  }

  void navigateToEndorsePolicyScreen() {
    Get.toNamed(AppRoutes.endorsePolicy, arguments: selectedPolicy.value);
  }

  @override
  void onInit() {
    getProfile();
    super.onInit();
  }
}
