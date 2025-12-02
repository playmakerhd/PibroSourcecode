import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/claim/controller/lodge_claim_controller.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/custom_button.dart';
import 'package:pibro/utils/view_utils.dart';

class LodgeClaimsScreen extends StatelessWidget {
  const LodgeClaimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LodgeClaimController controller = Get.put(LodgeClaimController());
    // final bool isSettled = (controller.selectedClaim.value!.closed == true) &&
    //     (controller.selectedClaim.value!.cleared == true);
    return Scaffold(
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            CommonHeader(
              title: AppStrings.lodgeClaims.tr,
              // onBackPressed: () => Get.offAllNamed(AppRoutes.main),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: queryWidth(context) * 0.03),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.faintGrey,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => CustomButton(
                      text: AppStrings.main.tr,
                      onPressed: () => controller.updateIndex(1),
                      height: controller.tabIndex.value == 1 ? 40 : 32,
                      width: 70,
                      fontSize: 14,
                      borderRadius: 10,
                      color: controller.tabIndex.value == 1
                          ? AppColors.blue
                          : AppColors.tileColor,
                      enabled: !(controller.prefillLoading.value ||
                          (controller.policyLoading.value &&
                              !controller.isEdit)),
                    ),
                  ),
                  Container(
                    height: 42,
                    width: 3,
                    color: AppColors.faintGrey,
                  ),
                  Obx(
                    () => CustomButton(
                      text: AppStrings.claimDocument.tr,
                      onPressed: () => controller.updateIndex(2),
                      height: controller.tabIndex.value == 2 ? 40 : 32,
                      width: 160,
                      fontSize: 14,
                      borderRadius: 10,
                      color: controller.tabIndex.value == 2
                          ? AppColors.blue
                          : AppColors.tileColor,
                      enabled: !(controller.prefillLoading.value ||
                          (controller.policyLoading.value &&
                              !controller.isEdit)),
                    ),
                  ),
                  Container(
                    height: 42,
                    width: 3,
                    color: AppColors.faintGrey,
                  ),
                  Obx(
                    () => CustomButton(
                      text: AppStrings.insurers.tr,
                      onPressed: () => controller.updateIndex(3),
                      height: controller.tabIndex.value == 3 ? 40 : 32,
                      width: 100,
                      fontSize: 14,
                      borderRadius: 10,
                      color: controller.tabIndex.value == 3
                          ? AppColors.blue
                          : AppColors.tileColor,
                      enabled: !(controller.prefillLoading.value ||
                          (controller.policyLoading.value &&
                              !controller.isEdit)),
                    ),
                  ),
                ],
              ),
            ),
            Obx(() {
              final loading = controller.prefillLoading.value;
              return Stack(
                children: [
                  AbsorbPointer(
                    absorbing: loading ||
                        (controller.policyLoading.value && !controller.isEdit),
                    child: Form(
                      key: controller.claimFormKey,
                      child: Container(
                        height: queryHeight(context) * 0.76,
                        padding: EdgeInsets.symmetric(
                            horizontal: queryWidth(context) * 0.05,
                            vertical: 20),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => controller
                                    .tabScreens[controller.tabIndex.value - 1],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 40.0, bottom: 50),
                                child: Center(
                                  child: Obx(() {
                                    // Build the primary action button (Continue/Save/Close)
                                    final bool isEdit = controller.isEdit;
                                    final int tabIndex =
                                        controller.tabIndex.value;
                                    final hasSelected =
                                        controller.selectedClaim.value != null;

                                    Widget primaryButton;
                                    if (isEdit &&
                                        (tabIndex == 1 || tabIndex == 3)) {
                                      primaryButton = PolicyButton(
                                        text: tabIndex == 3
                                            ? AppStrings.close.tr
                                            : AppStrings.continueText.tr,
                                        onPressed: tabIndex == 3
                                            ? () => Get.offNamedUntil(
                                                AppRoutes.claim,
                                                (route) => false)
                                            : () =>
                                                controller.tabIndex.value = 2,
                                        height: 50,
                                        width: queryWidth(context) * 0.3,
                                        bgColor: AppColors.primaryColor,
                                      );
                                    } else {
                                      primaryButton = PolicyButton(
                                        text: tabIndex == 1
                                            ? hasSelected
                                                ? AppStrings.continueText.tr
                                                : AppStrings.saveAndContinue.tr
                                            : AppStrings.close.tr,
                                        onPressed: tabIndex == 1
                                            ? hasSelected
                                                ? () => controller
                                                    .tabIndex.value = 2
                                                : controller.submit
                                            : () {
                                                Get.offNamedUntil(
                                                    AppRoutes.claim,
                                                    (route) =>
                                                        route.settings.name ==
                                                        AppRoutes.claim);
                                                safeBack();
                                              },
                                        height: 50,
                                        width: tabIndex == 1
                                            ? hasSelected
                                                ? 150
                                                : 170
                                            : 120,
                                        bgColor: AppColors.primaryColor,
                                        loading: tabIndex == 1 &&
                                            // controller.saveAndContinue_.value &&
                                            controller.submitLoading.value,
                                      );
                                    }

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        primaryButton,
                                        SizedBox(
                                            width: queryWidth(context) * 0.05),
                                        if (controller.selectedClaim.value !=
                                                null &&
                                            controller.selectedClaim.value!
                                                    .submitClaim !=
                                                null &&
                                            !controller.selectedClaim.value!
                                                .submitClaim!)
                                          PolicyButton(
                                            text: AppStrings.sendToBroker.tr,
                                            onPressed: () =>
                                                controller.sendToBroker(),
                                            loading: controller
                                                .sendToBrokerLoading.value,
                                            height: 50,
                                            width: 150,
                                            bgColor: AppColors.primaryColor,
                                          ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (loading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.6),
                        child: Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: AppColors.primaryColor,
                            size: 100,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
