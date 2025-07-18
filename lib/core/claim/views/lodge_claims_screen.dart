import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/claim/controller/lodge_claim_controller.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/custom_button.dart';
import 'package:pibro/utils/view_utils.dart';

class LodgeClaimsScreen extends StatelessWidget {
  const LodgeClaimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LodgeClaimController controller = Get.put(LodgeClaimController());
    inspect(controller.selectedClaim.value);
    return Scaffold(
      body: Column(
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
                    borderRadius: 10,
                    color: controller.tabIndex.value == 1
                        ? AppColors.blue
                        : AppColors.tileColor,
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
                    width: 180,
                    borderRadius: 10,
                    color: controller.tabIndex.value == 2
                        ? AppColors.blue
                        : AppColors.tileColor,
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
                    borderRadius: 10,
                    color: controller.tabIndex.value == 3
                        ? AppColors.blue
                        : AppColors.tileColor,
                  ),
                ),
              ],
            ),
          ),
          Form(
            key: controller.claimFormKey,
            child: Container(
              height: queryHeight(context) * 0.76,
              padding: EdgeInsets.symmetric(
                  horizontal: queryWidth(context) * 0.05, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () =>
                          controller.tabScreens[controller.tabIndex.value - 1],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0, bottom: 50),
                      child: Center(
                        child: Obx(
                          () => controller.isEdit &&
                                  (controller.tabIndex.value == 1 ||
                                      controller.tabIndex.value == 3)
                              ? PolicyButton(
                                  text: controller.tabIndex.value == 3
                                      ? AppStrings.close.tr
                                      : AppStrings.continueText.tr,
                                  onPressed: controller.tabIndex.value == 3
                                      ? () => Get.offAllNamed(AppRoutes.main)
                                      : () => controller.tabIndex.value = 2,
                                  height: 50,
                                  width: queryWidth(context) * 0.7,
                                  bgColor: AppColors.primaryColor,
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    PolicyButton(
                                      text: controller.tabIndex.value == 1
                                          ? controller.selectedClaim.value !=
                                                  null
                                              ? AppStrings.continueText.tr
                                              : AppStrings.saveAndContinue.tr
                                          : AppStrings.close.tr,
                                      onPressed: () => controller
                                                  .tabIndex.value ==
                                              1
                                          ? controller.selectedClaim.value !=
                                                  null
                                              ? controller.tabIndex.value = 2
                                              : controller.submit()
                                          : Get.offAllNamed(AppRoutes.main),
                                      height: 50,
                                      width: controller.tabIndex.value == 1
                                          ? 170
                                          : 120,
                                      bgColor: AppColors.primaryColor,
                                      loading: controller.tabIndex.value == 1 &&
                                          // controller.saveAndContinue_.value &&
                                          controller.submitLoading.value,
                                    ),
                                    SizedBox(
                                      width: queryWidth(context) * 0.05,
                                    ),
                                    Obx(
                                      () => controller.selectedClaim.value !=
                                                  null &&
                                              !controller.selectedClaim.value!
                                                  .submitClaim!
                                          ? PolicyButton(
                                              text: AppStrings.sendToBroker.tr,
                                              onPressed: () =>
                                                  controller.sendToBroker(),
                                              loading: controller
                                                  .sendToBrokerLoading.value,
                                              height: 50,
                                              width: 150,
                                              bgColor: AppColors.primaryColor,
                                            )
                                          : SizedBox(),
                                    ),
                                    // controller.tabIndex.value == 1 ||
                                    //         controller.tabIndex.value > 1 &&
                                    //             controller
                                    //                 .claimDocuments.isNotEmpty
                                    //     ? PolicyButton(
                                    //         text: controller.tabIndex.value == 1
                                    //             ? AppStrings.sendToBroker.tr
                                    //             : controller.isEdit
                                    //                 ? AppStrings
                                    //                     .updateDocuments.tr
                                    //                 : AppStrings
                                    //                     .uploadDocuments.tr,
                                    //         onPressed: () => controller
                                    //                     .tabIndex.value ==
                                    //                 1
                                    //             ? controller.submit(false)
                                    //             : controller.isEdit
                                    //                 ? controller.updateClaim()
                                    //                 : controller.uploadDoc(),
                                    //         loading: (controller
                                    //                     .submitLoading.value &&
                                    //                 !controller.saveAndContinue_
                                    //                     .value) ||
                                    //             controller.updateLoading.value,
                                    //         height: 50,
                                    //         width:
                                    //             controller.tabIndex.value == 1
                                    //                 ? 130
                                    //                 : 170,
                                    //         bgColor: AppColors.primaryColor,
                                    //       )
                                    //     : SizedBox(),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
