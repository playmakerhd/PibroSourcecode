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
                    value: controller.selectedClaim.value!.brokerClaimID!,
                  ),
                  ItemRow(
                    title: AppStrings.policyNumber.tr,
                    value: controller.selectedClaim.value!.policyBrokerID,
                  ),
                  ItemRow(
                    title: AppStrings.insuranceClass.tr,
                    value: controller.selectedClaim.value!.businessClassID!,
                  ),
                  ItemRow(
                    title: AppStrings.product.tr,
                    value: controller.selectedClaim.value!.riskTypeID!,
                  ),
                  ItemRow(
                    title: AppStrings.incidentDate.tr,
                    value: formatDate(
                        controller.selectedClaim.value!.accidentDate!),
                  ),
                  ItemRow(
                    title: AppStrings.lodgementDate.tr,
                    value: formatDate(
                        controller.selectedClaim.value!.customerReportDate!),
                  ),
                  ItemRow(
                    title: AppStrings.description.tr,
                    value: controller.selectedClaim.value!.accidentDetails!,
                  ),
                  ItemRow(
                    title: AppStrings.claimAmount.tr,
                    value:
                        'N${formatAmount(controller.selectedClaim.value!.customerEstimate!)}',
                  ),
                  ItemRow(
                    title: AppStrings.settlementAmount.tr,
                    value:
                        'N${formatAmount(controller.selectedClaim.value!.dVAmount)}',
                  ),
                  ItemRow(
                    title: AppStrings.status.tr,
                    value: getClaimStatus(controller.selectedClaim.value!)[0],
                    valueColor:
                        getClaimStatus(controller.selectedClaim.value!)[1],
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
                        if (controller.selectedClaim.value != null &&
                            controller.selectedClaim.value!.submitClaim !=
                                null &&
                            !controller.selectedClaim.value!.submitClaim!)
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
