import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/policy/widget/detail_row.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/core/quote/controller/get_quote_controller.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';

class QuoteConfirmationScreen extends StatelessWidget {
  const QuoteConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GetQuoteController controller = Get.put(GetQuoteController());
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
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
                  title: '${AppStrings.insuranceClass.tr}:',
                  value: controller
                      .selectedBusinessPolicy.value!.businessClassName!,
                ),
                DetailRow(
                  title: '${AppStrings.product.tr}:',
                  value: controller.selectedRiskTypeID.value!.riskName!,
                ),
                DetailRow(
                  title: '${AppStrings.oldStartDate.tr}:',
                  value: controller.startDateController.text,
                ),
                DetailRow(
                  title: '${AppStrings.oldEndDate.tr}:',
                  value: controller.endDateController.text,
                ),
                DetailRow(
                  title: '${AppStrings.renewalDate.tr}:',
                  value: formatDate(controller.endDate.value!
                      .add(Duration(days: 1))
                      .toIso8601String()),
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: queryWidth(context) * 0.05),
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: PolicyButton(
                      text: AppStrings.makePayment.tr,
                      onPressed: () {},
                      // loading: controller.paymentLoading.value,
                      height: 50,
                      width: queryWidth(context) * 0.6,
                      bgColor: AppColors.primaryColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 50),
                    child: Obx(
                      () => PolicyButton(
                        text: AppStrings.submitQuoteForApproval.tr,
                        onPressed: controller.submitQuote,
                        loading: controller.submitLoading.value,
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
    );
  }
}
