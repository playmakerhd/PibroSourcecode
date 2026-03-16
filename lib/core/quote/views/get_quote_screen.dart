import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/core/quote/controller/get_quote_controller.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/models/response/business_policy_response.dart';
import 'package:pibro/network/models/response/insurance_risk_type_response.dart';
import 'package:pibro/network/models/response/vendor_response.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/custom_input/custom_dropdown.dart';
import 'package:pibro/shared/custom_input/custom_input.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/validators.dart';
import 'package:pibro/utils/view_utils.dart';

class GetQuoteScreen extends StatelessWidget {
  const GetQuoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GetQuoteController controller = Get.put(GetQuoteController());
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double keyboardInset = mediaQuery.viewInsets.bottom;
    final double safeBottomInset = mediaQuery.padding.bottom;

    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
          bottom: keyboardInset + safeBottomInset + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonHeader(
              title: AppStrings.getQuote.tr,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: queryWidth(context) * 0.05,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.renewPolicyPreference.tr,
                    style: Styles.mediumTextStyle(),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        Obx(
                          () => CustomDropdown(
                            label: AppStrings.insuranceClass.tr,
                            hint: AppStrings.insuranceClass.tr,
                            suffixIcon: Icon(
                              Icons.arrow_drop_down,
                              size: 30,
                              color: AppColors.hintColor,
                            ),
                            dropDownValue:
                                controller.selectedBusinessPolicy.value,
                            items: controller.businessPolicies
                                .map((item) => DropdownMenuItem<BusinessPolicy>(
                                      value: item,
                                      child: Text(
                                        item.businessClassName!,
                                        style: Styles.mediumTextStyle(
                                          size: 14,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: controller.selectBusinessClass,
                          ),
                        ),
                        Obx(
                          () => CustomDropdown(
                            label: AppStrings.product.tr,
                            hint: AppStrings.product.tr,
                            suffixIcon: Icon(
                              Icons.arrow_drop_down,
                              size: 30,
                              color: AppColors.hintColor,
                            ),
                            dropDownValue: controller.selectedRiskTypeID.value,
                            items: controller.riskTypeIDs
                                .map((item) => DropdownMenuItem<RiskTypeID>(
                                      value: item,
                                      child: Text(
                                        item.riskName!,
                                        style: Styles.mediumTextStyle(
                                          size: 14,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: controller.selectRiskType,
                          ),
                        ),
                        CustomInput(
                          label: AppStrings.startDate.tr,
                          hint: AppStrings.startDate.tr,
                          suffixIcon: Icon(
                            Icons.calendar_month,
                            size: 20,
                          ),
                          readonly: true,
                          onTap: () async {
                            DateTime initialDate = DateTime.now();
                            DateTime firstDate = initialDate;
                            DateTime lastDate =
                                initialDate.add(const Duration(days: 365 * 5));
                            controller.startDate.value = await showDatePicker(
                              context: Get.context!,
                              initialDate:
                                  controller.startDate.value ?? DateTime.now(),
                              firstDate: firstDate,
                              lastDate: lastDate,
                            );
                            if (controller.startDate.value != null) {
                              if (controller.endDate.value != null &&
                                  controller.startDate.value!
                                      .isAfter(controller.endDate.value!)) {
                                controller.endDate.value = null;
                                controller.endDateController.clear();
                              }
                              controller.startDateController.text = formatDate(
                                controller.startDate.value.toString(),
                              );
                            }
                          },
                          controller: controller.startDateController,
                          validator: (value) => Validators.requiredValidator(
                              value, AppStrings.startDate),
                        ),
                        CustomInput(
                          label: AppStrings.endDate.tr,
                          hint: AppStrings.endDate.tr,
                          suffixIcon: Icon(
                            Icons.calendar_month,
                            size: 20,
                          ),
                          readonly: true,
                          onTap: () async {
                            DateTime initialDate =
                                controller.startDate.value ?? DateTime.now();
                            DateTime firstDate = initialDate;
                            DateTime lastDate =
                                initialDate.add(const Duration(days: 365 * 5));
                            controller.endDate.value = await showDatePicker(
                              context: Get.context!,
                              initialDate:
                                  controller.endDate.value ?? initialDate,
                              firstDate: firstDate,
                              lastDate: lastDate,
                            );
                            if (controller.endDate.value != null) {
                              controller.endDateController.text = formatDate(
                                controller.endDate.value.toString(),
                              );
                            }
                          },
                          controller: controller.endDateController,
                          validator: (value) => Validators.requiredValidator(
                              value, AppStrings.endDate),
                        ),
                        // Preferred Insurer dropdown (uses your CustomDropdown)
                        Obx(
                          () => CustomDropdown(
                            label: AppStrings.vendorInsurer.tr,
                            hint: AppStrings.vendorInsurer.tr,
                            suffixIcon: Icon(
                              Icons.arrow_drop_down,
                              size: 30,
                              color: AppColors.hintColor,
                            ),
                            dropDownValue: controller.selectedVendor.value,
                            items: controller.vendors
                                .map((v) => DropdownMenuItem<VendorInfo>(
                                      value: v,
                                      child: Text(
                                        v.vendorName ?? '',
                                        style: Styles.mediumTextStyle(size: 14),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                controller.selectVendor(val as VendorInfo?),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: PolicyButton(
                            text: AppStrings.continueText.tr,
                            onPressed: () {
                              // First validate form fields (start/end date inputs)
                              final bool isValid =
                                  controller.formKey.currentState?.validate() ??
                                      false;
                              if (!isValid) return;
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: PolicyButton(
                            text: AppStrings.continueText.tr,
                            onPressed: () {
                              // First validate form fields (start/end date inputs)
                              final bool isValid =
                                  controller.formKey.currentState?.validate() ??
                                      false;
                              if (!isValid) return;

                              // Then validate dropdowns and other required selections
                              if (controller.selectedBusinessPolicy.value ==
                                  null) {
                                showSnackbarMessage(
                                    message: AppStrings
                                        .pleaseSelectInsuranceClass.tr,
                                    isSuccess: false);
                                return;
                              }
                              if (controller.selectedRiskTypeID.value == null) {
                                showSnackbarMessage(
                                    message: AppStrings.pleaseSelectProduct.tr,
                                    isSuccess: false);
                                return;
                              }
                              if (controller.startDate.value == null) {
                                showSnackbarMessage(
                                    message:
                                        AppStrings.pleaseSelectStartDate.tr,
                                    isSuccess: false);
                                return;
                              }
                              if (controller.endDate.value == null) {
                                showSnackbarMessage(
                                    message: AppStrings.pleaseSelectEndDate.tr,
                                    isSuccess: false);
                                return;
                              }
                              if (controller.selectedVendor.value == null) {
                                showSnackbarMessage(
                                    message: AppStrings
                                        .pleaseSelectPreferredInsurer.tr,
                                    isSuccess: false);
                                return;
                              }
                              // Then validate dropdowns and other required selections
                              if (controller.selectedBusinessPolicy.value ==
                                  null) {
                                showSnackbarMessage(
                                    message: AppStrings
                                        .pleaseSelectInsuranceClass.tr,
                                    isSuccess: false);
                                return;
                              }
                              if (controller.selectedRiskTypeID.value == null) {
                                showSnackbarMessage(
                                    message: AppStrings.pleaseSelectProduct.tr,
                                    isSuccess: false);
                                return;
                              }
                              if (controller.startDate.value == null) {
                                showSnackbarMessage(
                                    message:
                                        AppStrings.pleaseSelectStartDate.tr,
                                    isSuccess: false);
                                return;
                              }
                              if (controller.endDate.value == null) {
                                showSnackbarMessage(
                                    message: AppStrings.pleaseSelectEndDate.tr,
                                    isSuccess: false);
                                return;
                              }
                              if (controller.selectedVendor.value == null) {
                                showSnackbarMessage(
                                    message: AppStrings
                                        .pleaseSelectPreferredInsurer.tr,
                                    isSuccess: false);
                                return;
                              }

                              controller.navigateToItemsToInsure();
                            },
                            height: 50,
                            width: queryWidth(context) * 0.7,
                            bgColor: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
                              controller.navigateToItemsToInsure();
                            },
                            height: 50,
                            width: queryWidth(context) * 0.7,
                            bgColor: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
