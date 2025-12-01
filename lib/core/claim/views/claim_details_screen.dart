import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/claim/controller/claim_controller.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/custom_button.dart';
import 'package:pibro/shared/item_row.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';

class ClaimDetailsScreen extends StatelessWidget {
  const ClaimDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ClaimController controller = Get.put(ClaimController());
    final claim = controller.selectedClaim.value;
    if (claim == null) {
      // If no claim is selected, navigate back after the current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          Get.back();
        } catch (e) {
          debugPrint('Error navigating back from ClaimDetailsScreen: $e');
        }
      });
      return const SizedBox.shrink();
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CommonHeader(
              title: AppStrings.claimDetails.tr,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Column(
                children: [
                  ItemRow(
                    title: AppStrings.claimNumber.tr,
                    value: claim.brokerClaimID!,
                  ),
                  ItemRow(
                    title: AppStrings.policyNumber.tr,
                    value: claim.policyBrokerID,
                  ),
                  ItemRow(
                    title: AppStrings.insuranceClass.tr,
                    value: claim.businessClassID,
                  ),
                  ItemRow(
                    title: AppStrings.product.tr,
                    value: claim.riskTypeID,
                  ),
                  ItemRow(
                    title: AppStrings.incidentDate.tr,
                    value: formatDate(claim.accidentDate!),
                  ),
                  ItemRow(
                    title: AppStrings.claimReportedDate.tr,
                    value: formatDate(claim.customerReportDate!),
                  ),
                  ItemRow(
                    title: AppStrings.description.tr,
                    value: claim.accidentDetails!,
                  ),
                  ItemRow(
                    title: AppStrings.claimAmount.tr,
                    value: 'N${formatAmount(claim.customerEstimate!)}',
                  ),
                  ItemRow(
                    title: AppStrings.settlementAmount.tr,
                    value: 'N${formatAmount(claim.dVAmount)}',
                  ),
                  ItemRow(
                    title: AppStrings.status.tr,
                    value: getClaimStatus(claim)[0],
                    valueColor: getClaimStatus(claim)[1],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: queryHeight(context) * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                          text: AppStrings.edit.tr,
                          onPressed: controller.navigateToEditScreen,
                          height: 50,
                          width: 100,
                          borderRadius: 10,
                          color: AppColors.primaryColor,
                        ),
                        if (claim.submitClaim == false)
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Obx(
                              () => CustomButton(
                                text: AppStrings.sendToBroker.tr,
                                onPressed: controller.sendToBroker,
                                height: 50,
                                width: 180,
                                borderRadius: 10,
                                color: AppColors.primaryColor,
                                loading: controller.submitLoading.value,
                              ),
                            ),
                          )
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
