import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/policy/controller/renew_policy_controller.dart';
import 'package:pibro/core/policy/widget/detail_row.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/custom_input/custom_input.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/validators.dart';
import 'package:pibro/utils/view_utils.dart';

class RenewPolicyScreen extends StatelessWidget {
  const RenewPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RenewPolicyController controller = Get.put(RenewPolicyController());
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonHeader(
              title: AppStrings.renewPolicyPreference.tr,
              isTransparent: true,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: queryWidth(context) * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(
                    title: '${AppStrings.policyNumber.tr}:',
                    value: controller.policy.value?.policyBrokerID ?? '-',
                  ),
                  DetailRow(
                    title: '${AppStrings.insuranceClass.tr}:',
                    value: controller.policy.value?.businessClassID ?? '-',
                  ),
                  DetailRow(
                    title: '${AppStrings.product.tr}:',
                    value: controller.policy.value?.riskTypeID ?? '-',
                  ),
                  DetailRow(
                    title: '${AppStrings.oldStartDate.tr}:',
                    value: (controller.policy.value?.policyStartDate != null)
                        ? formatDate(controller.policy.value!.policyStartDate!)
                        : '-',
                  ),
                  DetailRow(
                    title: '${AppStrings.oldEndDate.tr}:',
                    value: (controller.policy.value?.policyEndDate != null)
                        ? formatDate(controller.policy.value!.policyEndDate!)
                        : '-',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Divider(
                color: AppColors.primaryColor,
                thickness: 5,
              ),
            ),
            Form(
              key: controller.renewFormKey,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: queryWidth(context) * 0.05),
                child: Column(
                  children: [
                    // Obx(
                    //   () => CustomDropdown(
                    //     label: AppStrings.insuranceClass.tr,
                    //     hint: AppStrings.insuranceClass.tr,
                    //     suffixIcon: Icon(
                    //       Icons.arrow_drop_down,
                    //       size: 30,
                    //       color: AppColors.hintColor,
                    //     ),
                    //     dropDownValue: controller.selectedBusinessPolicy.value,
                    //     items: controller.businessPolicies
                    //         .map((item) => DropdownMenuItem<BusinessPolicy>(
                    //               value: item,
                    //               child: Text(
                    //                 item.businessClassName!,
                    //                 style: Styles.mediumTextStyle(
                    //                   size: 14,
                    //                 ),
                    //               ),
                    //             ))
                    //         .toList(),
                    //     onChanged: null,
                    //     // dropDownValue:
                    //     //     controller.selectedBusinessPolicy.value,
                    //     // items: controller.businessPolicies
                    //     //     .map((item) => DropdownMenuItem<BusinessPolicy>(
                    //     //           value: item,
                    //     //           child: Text(
                    //     //             item.businessClassName!,
                    //     //             style: Styles.mediumTextStyle(
                    //     //               size: 14,
                    //     //             ),
                    //     //           ),
                    //     //         ))
                    //     //     .toList(),
                    //     // onChanged: controller.selectBusinessClass,
                    //   ),
                    // ),
                    // Obx(
                    //   () => CustomDropdown(
                    //     label: AppStrings.product.tr,
                    //     hint: AppStrings.product.tr,
                    //     suffixIcon: Icon(
                    //       Icons.arrow_drop_down,
                    //       size: 30,
                    //       color: AppColors.hintColor,
                    //     ),
                    //     dropDownValue: controller.selectedRiskTypeID.value,
                    //     items: controller.riskTypeIDs
                    //         .map((item) => DropdownMenuItem<RiskTypeID>(
                    //               value: item,
                    //               child: Text(
                    //                 item.riskName!,
                    //                 style: Styles.mediumTextStyle(
                    //                   size: 14,
                    //                 ),
                    //               ),
                    //             ))
                    //         .toList(),
                    //     onChanged: null,
                    //     // dropDownValue: controller.selectedRiskTypeID.value,
                    //     // items: controller.riskTypeIDs
                    //     //     .map((item) => DropdownMenuItem<RiskTypeID>(
                    //     //           value: item,
                    //     //           child: Text(
                    //     //             item.riskName!,
                    //     //             style: Styles.mediumTextStyle(
                    //     //               size: 14,
                    //     //             ),
                    //     //           ),
                    //     //         ))
                    //     //     .toList(),
                    //     // onChanged: controller.selectRiskType,
                    //   ),
                    // ),
                    CustomInput(
                      label: AppStrings.newStartDate.tr,
                      hint: AppStrings.newStartDate.tr,
                      enabled: true,
                      suffixIcon: Icon(
                        Icons.calendar_month,
                        size: 20,
                      ),
                      readonly: true,
                      onTap: () async {
                        DateTime initialDate = DateTime.now();
                        DateTime firstDate = initialDate;
                        DateTime lastDate =
                            firstDate.add(const Duration(days: 365 * 100));
                        await showDatePicker(
                          context: Get.context!,
                          initialDate: initialDate,
                          firstDate: firstDate,
                          lastDate: lastDate,
                          currentDate: controller.startDate.value,
                          barrierDismissible: false,
                        ).then((value) {
                          controller.startDate.value =
                              value ?? controller.startDate.value!;
                          controller.startDateController.text = formatDate(
                            controller.startDate.value.toString(),
                          );
                          if (value != null) {
                            controller.endDate.value = null;
                            controller.endDateController.clear();
                          }
                        });
                      },
                      controller: controller.startDateController,
                      validator: (value) => Validators.requiredValidator(
                          value, AppStrings.newStartDate.tr),
                    ),
                    CustomInput(
                      label: AppStrings.newEndDate.tr,
                      hint: AppStrings.newEndDate.tr,
                      suffixIcon: Icon(
                        Icons.calendar_month,
                        size: 20,
                      ),
                      readonly: true,
                      onTap: () async {
                        DateTime initialDate = controller.endDate.value ??
                            controller.startDate.value!;
                        DateTime firstDate = controller.startDate.value!;
                        DateTime lastDate =
                            firstDate.add(const Duration(days: 365 * 500));
                        await showDatePicker(
                          context: Get.context!,
                          initialDate: initialDate,
                          firstDate: firstDate,
                          lastDate: lastDate,
                          currentDate: controller.endDate.value,
                          barrierDismissible: false,
                        ).then((value) {
                          controller.endDate.value =
                              value ?? controller.endDate.value!;
                          controller.endDateController.text = formatDate(
                            controller.endDate.value.toString(),
                          );
                          controller.renewalDateController.text = formatDate(
                            controller.endDate.value!
                                .add(Duration(days: 1))
                                .toString(),
                          );
                        });
                      },
                      controller: controller.endDateController,
                      validator: (value) => Validators.requiredValidator(
                          value, AppStrings.newEndDate.tr),
                    ),
                    CustomInput(
                      label: AppStrings.newRenewalDate.tr,
                      hint: AppStrings.newRenewalDate.tr,
                      isRequired: false,
                      suffixIcon: Icon(
                        Icons.calendar_month,
                        size: 20,
                      ),
                      readonly: true,
                      controller: controller.renewalDateController,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Obx(
                        () => PolicyButton(
                          text: AppStrings.continueText.tr,
                          onPressed: controller.continueRenew,
                          loading: controller.getPremiumAmountLoading.value,
                          height: 50,
                          width: queryWidth(context) * 0.7,
                          bgColor: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
