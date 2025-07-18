import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/claim/controller/lodge_claim_controller.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';
import 'package:pibro/shared/custom_input/custom_dropdown.dart';
import 'package:pibro/shared/custom_input/custom_input.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/validators.dart';
import 'package:pibro/utils/view_utils.dart';

class MainTab extends StatelessWidget {
  const MainTab({super.key});

  @override
  Widget build(BuildContext context) {
    final LodgeClaimController controller = Get.put(LodgeClaimController());
    return Column(
      children: [
        Obx(
          () => CustomDropdown(
            label: AppStrings.policyNumber.tr,
            hint: AppStrings.policyNumber.tr,
            isRequired: !controller.isEdit,
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              size: 30,
              color: AppColors.hintColor,
            ),
            dropDownValue: controller.selectedPolicy.value,
            validator: (value) =>
                Validators.requiredValidator(value, AppStrings.policyNumber.tr),
            items: controller.policies
                .map((item) => DropdownMenuItem<PolicyData>(
                      value: item,
                      child: Text(
                        item.policyBrokerID,
                        style: Styles.mediumTextStyle(
                          size: 14,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: controller.isEdit ? null : controller.selectPolicy,
          ),
        ),
        CustomInput(
          label: AppStrings.dateOfOccurence.tr,
          hint: 'dd/mm/yyyy',
          suffixIcon: Icon(
            Icons.calendar_month,
            size: 20,
          ),
          readonly: true,
          isRequired: !controller.isEdit,
          onTap: controller.isEdit
              ? () {}
              : () async {
                  DateTime initialDate = DateTime.now();
                  DateTime firstDate =
                      initialDate.subtract(const Duration(days: 365 * 500));
                  DateTime lastDate = initialDate;
                  controller.occurenceDate.value = await showDatePicker(
                    context: Get.context!,
                    initialDate:
                        controller.occurenceDate.value ?? DateTime.now(),
                    firstDate: firstDate,
                    lastDate: lastDate,
                  );
                  if (controller.occurenceDate.value != null) {
                    controller.occurenceDateController.text = formatClaimDate(
                      controller.occurenceDate.value.toString(),
                    );
                  }
                },
          controller: controller.occurenceDateController,
          validator: (value) => Validators.requiredValidator(
              value, AppStrings.dateOfOccurence.tr),
        ),
        CustomInput(
          controller: controller.narrationController,
          label: AppStrings.narration.tr,
          readonly: controller.isEdit,
          isRequired: !controller.isEdit,
          maxLines: 3,
          hint: AppStrings.description.tr,
          validator: (value) =>
              Validators.requiredValidator(value, AppStrings.narration.tr),
        ),
        CustomInput(
          controller: controller.lodgementDateController,
          label: AppStrings.lodgementDate.tr,
          hint: 'dd/mm/yyyy',
          isRequired: false,
          suffixIcon: Icon(
            Icons.calendar_month,
            size: 20,
          ),
          readonly: true,
          // onTap: controller.isEdit
          //     ? () {}
          //     : () async {
          //         DateTime initialDate = DateTime.now();
          //         DateTime firstDate =
          //             initialDate.subtract(const Duration(days: 365 * 5));
          //         DateTime lastDate =
          //             initialDate.add(const Duration(days: 365 * 5));
          //         controller.lodgementDate.value = await showDatePicker(
          //           context: Get.context!,
          //           initialDate:
          //               controller.lodgementDate.value ?? DateTime.now(),
          //           firstDate: firstDate,
          //           lastDate: lastDate,
          //         );
          //         if (controller.lodgementDate.value != null) {
          //           controller.lodgementDateController.text = formatClaimDate(
          //             controller.lodgementDate.value.toString(),
          //           );
          //         }
          //       },
          validator: (value) =>
              Validators.requiredValidator(value, AppStrings.lodgementDate.tr),
        ),
        CustomInput(
          controller: controller.policyHolderController,
          label: AppStrings.policyHolder.tr,
          maxLines: 1,
          isRequired: false,
          readonly: true,
        ),
        CustomInput(
          controller: controller.leadInsurerController,
          label: AppStrings.leadInsurer.tr,
          maxLines: 1,
          isRequired: false,
          readonly: true,
        ),
        CustomInput(
          controller: controller.typesOfBusinessController,
          label: AppStrings.typesOfBusiness.tr,
          maxLines: 1,
          isRequired: false,
          readonly: true,
        ),
        CustomInput(
          controller: controller.productController,
          label: AppStrings.product.tr,
          maxLines: 1,
          isRequired: false,
          readonly: true,
        ),
        Row(
          children: [
            CustomInput(
              controller: controller.startDateController,
              label: AppStrings.startDate.tr,
              maxLines: 1,
              isRequired: false,
              readonly: true,
              width: queryWidth(context) * 0.42,
            ),
            SizedBox(
              width: queryWidth(context) * 0.06,
            ),
            CustomInput(
              controller: controller.endDateController,
              label: AppStrings.endDate.tr,
              maxLines: 1,
              isRequired: false,
              readonly: true,
              width: queryWidth(context) * 0.42,
            ),
          ],
        ),
      ],
    );
  }
}
