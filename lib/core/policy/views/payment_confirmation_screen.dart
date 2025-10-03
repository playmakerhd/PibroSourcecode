import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/home/controller/home_controller.dart';
import 'package:pibro/core/policy/controller/renew_policy_controller.dart';
import 'package:pibro/core/policy/widget/detail_row.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:screenshot/screenshot.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  const PaymentConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RenewPolicyController controller = Get.put(RenewPolicyController());
    final HomeController homeController = Get.find<HomeController>();

    final Map args = (Get.arguments as Map?) ?? {};
    final String overrideStart = (args['newStartDate'] ?? '').toString();
    final String overrideEnd = (args['newEndDate'] ?? '').toString();
    final String overrideRenew = (args['newRenewalDate'] ?? '').toString();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Screenshot(
              controller: controller.screenshotController,
              child: Column(
                children: [
                  CommonHeader(
                    hasBackIcon: false,
                    title: AppStrings.paymentConfirmation.tr,
                    isTransparent: true,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: queryWidth(context) * 0.05,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Icon(
                              Icons.check_circle,
                              size: 50,
                              color: AppColors.activeGreen,
                            ),
                          ),
                          Text.rich(
                            style: Styles.boldTextStyle(
                              size: 14,
                              color: AppColors.activeGreen,
                            ),
                            TextSpan(
                              text: '${AppStrings.congratulations.tr} ',
                              children: [
                                TextSpan(
                                  text: homeController.user.value?.customerName
                                          ?.capitalize ??
                                      '-',
                                  style: Styles.boldTextStyle(size: 14),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text.rich(
                              style: Styles.semiBoldTextStyle(size: 14),
                              TextSpan(
                                text: '${AppStrings.paymentSuccess.tr} ',
                                children: [
                                  TextSpan(
                                      text: controller
                                              .policy.value?.policyBrokerID ??
                                          '-',
                                      style: Styles.boldTextStyle(size: 14)),
                                  TextSpan(
                                      text:
                                          ' ${AppStrings.paymentSuccessNowActive.tr}.')
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text(
                            '${AppStrings.detailsBelow.tr}:',
                            style: Styles.semiBoldTextStyle(size: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Divider(
                      color: AppColors.primaryColor,
                      thickness: 5,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: queryWidth(context) * 0.05),
                    child: Column(
                      children: [
                        DetailRow(
                          title: '${AppStrings.policyNumber.tr}:',
                          value: controller.policy.value?.policyBrokerID ?? '-',
                        ),
                        DetailRow(
                          title: '${AppStrings.insuranceClass.tr}:',
                          value:
                              controller.policy.value?.businessClassID ?? '-',
                        ),
                        DetailRow(
                          title: '${AppStrings.product.tr}:',
                          value: controller.policy.value?.riskTypeID ?? '-',
                        ),
                        DetailRow(
                          title: '${AppStrings.startDate.tr}:',
                          value: overrideStart.isNotEmpty
                              ? formatDate(overrideStart)
                              : (controller.policy.value?.policyStartDate !=
                                      null
                                  ? formatDate(
                                      controller.policy.value!.policyStartDate!)
                                  : '-'),
                        ),
                        DetailRow(
                          title: '${AppStrings.endDate.tr}:',
                          value: overrideEnd.isNotEmpty
                              ? formatDate(overrideEnd)
                              : (controller.policy.value?.policyEndDate != null
                                  ? formatDate(
                                      controller.policy.value!.policyEndDate!)
                                  : '-'),
                        ),
                        DetailRow(
                          title: '${AppStrings.renewalDate.tr}:',
                          value: overrideRenew.isNotEmpty
                              ? formatDate(overrideRenew)
                              : (controller.policy.value?.renewalDate != null
                                  ? formatDate(
                                      controller.policy.value!.renewalDate!)
                                  : '-'),
                        ),
                        DetailRow(
                          title: ('${AppStrings.sumInsured.tr} (NGN):'),
                          value: controller.policy.value?.sumInsured != null
                              ? formatAmount(double.tryParse(controller
                                      .policy.value!.sumInsured
                                      .toString()
                                      .replaceAll(',', '')) ??
                                  0)
                              : '-',
                        ),
                        DetailRow(
                          title: '${AppStrings.premiumDue.tr} (NGN):',
                          value: formatAmount(double.tryParse(controller
                                  .policyPremiumAmount
                                  .toString()
                                  .replaceAll(',', '')) ??
                              0),
                        ),
                        DetailRow(
                          title: '${AppStrings.paymentDate.tr}:',
                          value: formatDate(
                              controller.createReceiptRequest.transactionDate!),
                        ),
                        DetailRow(
                          title: '${AppStrings.paymentReference.tr}:',
                          value: controller.createReceiptRequest.checkNumber!,
                        ),
                        DetailRow(
                          title: '${AppStrings.paymentMethod.tr}:',
                          value: controller
                              .createReceiptRequest.channel!.capitalizeFirst!,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PolicyButton(
                    text: AppStrings.ok.tr,
                    onPressed: () {
                      if (Get.isRegistered<HomeController>()) {
                        try {
                          Get.delete<HomeController>();
                        } catch (_) {}
                      }
                      Get.offAllNamed(AppRoutes.main);
                    },
                    height: 50,
                    width: 100,
                    bgColor: AppColors.primaryColor,
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  PolicyButton(
                    text: AppStrings.print.tr,
                    onPressed: controller.savePageAsPdf,
                    height: 50,
                    width: 100,
                    bgColor: AppColors.primaryColor,
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
