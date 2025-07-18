import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/policy/controller/renew_policy_controller.dart';
import 'package:pibro/core/policy/widget/detail_row.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';

class RenewPolicyConfirmationScreen extends StatelessWidget {
  const RenewPolicyConfirmationScreen({super.key});

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
              title: AppStrings.policyConfirmation.tr,
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
                    value: controller.policy.value!.policyBrokerID,
                  ),
                  DetailRow(
                    title: '${AppStrings.insuranceClass.tr}:',
                    value: controller.policy.value!.businessClassID!,
                  ),
                  DetailRow(
                    title: '${AppStrings.product.tr}:',
                    value: controller.policy.value!.riskTypeID!,
                  ),
                  DetailRow(
                    title: '${AppStrings.oldStartDate.tr}:',
                    value:
                        formatDate(controller.policy.value!.policyStartDate!),
                  ),
                  DetailRow(
                    title: '${AppStrings.oldEndDate.tr}:',
                    value: formatDate(controller.policy.value!.policyEndDate!),
                  ),
                  DetailRow(
                    title: '${AppStrings.sumInsured.tr} (NGN):',
                    value: formatAmount(controller.policy.value!.sumInsured!),
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
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: queryWidth(context) * 0.05),
              child: Column(
                children: [
                  DetailRow(
                    title: '${AppStrings.newStartDate.tr}:',
                    value: controller.startDateController.text,
                  ),
                  DetailRow(
                    title: '${AppStrings.newEndDate.tr}:',
                    value: controller.endDateController.text,
                  ),
                  DetailRow(
                    title: '${AppStrings.newRenewalDate.tr}:',
                    value: controller.renewalDateController.text,
                  ),
                  DetailRow(
                    title: '${AppStrings.premiumDue.tr} (NGN):',
                    value: formatAmount(
                        double.parse(controller.policyPremiumAmount)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Obx(
                      () => PolicyButton(
                        text: AppStrings.makePayment.tr,
                        onPressed: controller.policyPremiumAmount == '0' ||
                                controller.paymentLoading.value
                            ? () {}
                            : controller.getPaymentToken,
                        loading: controller.paymentLoading.value,
                        height: 50,
                        width: queryWidth(context) * 0.6,
                        bgColor: controller.policyPremiumAmount == '0'
                            ? AppColors.tileColor
                            : AppColors.primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Obx(
                      () => PolicyButton(
                        text: AppStrings.submitQuoteForApproval.tr,
                        onPressed: controller.policyPremiumAmount != '0' ||
                                controller.submitQuoteLoading.value
                            ? () {}
                            : controller.submitQuote,
                        loading: controller.submitQuoteLoading.value,
                        height: 50,
                        width: queryWidth(context) * 0.7,
                        bgColor: controller.policyPremiumAmount != '0'
                            ? AppColors.tileColor
                            : AppColors.primaryColor,
                      ),
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
