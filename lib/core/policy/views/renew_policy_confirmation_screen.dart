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
              title: AppStrings.policySummary.tr,
              isTransparent: false,
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
                  // Show gateway charges and total when a payment is required
                  if (double.parse(controller.policyPremiumAmount) > 0)
                    Builder(builder: (context) {
                      final double premium =
                          double.parse(controller.policyPremiumAmount);
                      final double usualCharge = premium * 0.015;
                      final double extraCharge =
                          (premium > 2500 ? (usualCharge + 100) : usualCharge);
                      final double appliedCharge =
                          (extraCharge > 2000 ? 2000 : extraCharge);
                      final double totalDue = premium + appliedCharge;
                      return Column(
                        children: [
                          DetailRow(
                            title: 'Charges (NGN):',
                            value: formatAmount(appliedCharge),
                          ),
                          DetailRow(
                            title: 'Total Payment Due (NGN):',
                            value: formatAmount(totalDue),
                          ),
                        ],
                      );
                    }),
                  // Show Make Payment and Contest buttons when premium due is not zero
                  if (controller.policyPremiumAmount != '0') ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Obx(
                            () => PolicyButton(
                              text: AppStrings.makePayment.tr,
                              onPressed: controller.paymentLoading.value
                                  ? () {}
                                  : controller.getPaymentToken,
                              loading: controller.paymentLoading.value,
                              height: 50,
                              width: queryWidth(context) * 0.4,
                              bgColor: AppColors.primaryColor,
                            ),
                          ),
                          PolicyButton(
                            text: 'Contest Payment',
                            onPressed: controller.showContestModal,
                            height: 50,
                            width: queryWidth(context) * 0.4,
                            bgColor: AppColors.orange,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 60.0),
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Wire to API later
                        },
                        child: Container(
                          height: 50,
                          width: queryWidth(context) * 0.7,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.print,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Print Premium Demand Note',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  // Show Submit Quote button when premium due is zero
                  if (controller.policyPremiumAmount == '0')
                    Padding(
                      padding: const EdgeInsets.only(top: 60.0, bottom: 60.0),
                      child: Obx(
                        () => PolicyButton(
                          text: AppStrings.submitQuoteForApproval.tr,
                          onPressed: controller.submitQuoteLoading.value
                              ? () {}
                              : controller.submitQuote,
                          loading: controller.submitQuoteLoading.value,
                          height: 50,
                          width: queryWidth(context) * 0.7,
                          bgColor: AppColors.primaryColor,
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
