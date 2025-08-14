import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/home/models/policy_status.dart';
import 'package:pibro/core/profile/widget/profile_button.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/response/customer_policy_claims_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/utils/api_utils.dart';
import 'package:pibro/utils/image_factory.dart';
import 'package:pibro/utils/view_utils.dart';

class ClaimController extends GetxController {
  PibroRepository pibroRepository =
      PibroRepository(appApiProvider: ApiProvider());

  RxBool loading = false.obs;
  RxBool submitLoading = false.obs;
  RxList<PolicyClaim> policyClaims = RxList<PolicyClaim>([]);
  Rxn<PolicyClaim> selectedClaim = Rxn<PolicyClaim>();

  Future<void> getCustomerClaims() async {
    loading.value = true;
    try {
      final response = await pibroRepository.getCustomerClaims();
      policyClaims.value = response.policyClaims.reversed.toList();
      loading.value = false;
    } catch (e) {
      loading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  PolicyStatus getPolicyStatus(String date, bool approved) {
    if (!approved) {
      return PolicyStatus(
          status: AppStrings.pending.tr, color: AppColors.orange);
    } else {
      if (DateTime.now().isAfter(DateTime.parse(date))) {
        return PolicyStatus(
            status: AppStrings.expired.tr, color: AppColors.red);
      } else {
        return PolicyStatus(
            status: AppStrings.active.tr, color: AppColors.activeGreen);
      }
    }
  }

  selectClaim(PolicyClaim data) {
    selectedClaim.value = data;
    Get.toNamed(AppRoutes.claimDetail);
  }

  navigateToEditScreen() {
    Get.toNamed(AppRoutes.lodgeClaims, arguments: selectedClaim.value);
  }

  Future<void> sendToBroker() async {
    submitLoading.value = true;
    try {
      final response = await pibroRepository
          .sendClaimToBroker(ApiUtils.sendClaimToBroker(selectedClaim.value!));
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        submitLoading.value = false;
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
      } else {
        submitClaim();
      }
    } catch (e) {
      submitLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Future<void> submitClaim() async {
    try {
      final response = await pibroRepository
          .submitClaim(selectedClaim.value!.brokerClaimID!);
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
      } else {
        _showSuccessDialog();
      }
      submitLoading.value = false;
    } catch (e) {
      submitLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  void _showSuccessDialog() {
    showAppDialog(
      dismissible: false,
      willPop: false,
      Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ImageFactory.getImage(AppImages.passwordSuccess).render(
              height: 65,
              width: 65,
            ),
            Column(
              children: [
                Text(
                  AppStrings.submitClaim.tr,
                  style: Styles.semiBoldTextStyle(
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  AppStrings.claimSuccess.tr,
                  style: Styles.mediumTextStyle(
                    size: 12,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => Get.offAllNamed(AppRoutes.main),
              child: ProfileButton(
                text: AppStrings.ok.tr,
                height: 25,
                width: 80,
                textColor: AppColors.activeGreen,
                bgColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onInit() {
    getCustomerClaims();
    super.onInit();
  }
}
