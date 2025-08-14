import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/core/policy/views/insurers_screen.dart';
import 'package:pibro/core/policy/views/items_insured_screen.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';
import 'package:pibro/shared/item_row.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';

class PolicyDetailsWidget extends StatelessWidget {
  const PolicyDetailsWidget({super.key, required this.data});

  final PolicyData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        children: [
          ItemRow(
            title: AppStrings.policyNumber.tr,
            value: data.policyBrokerID,
          ),
          ItemRow(
            title: AppStrings.insuranceClass.tr,
            value: data.businessClassID!,
          ),
          ItemRow(
            title: AppStrings.product.tr,
            value: data.riskTypeID!,
          ),
          ItemRow(
            title: AppStrings.startDate.tr,
            value: formatDate(data.policyStartDate!),
          ),
          ItemRow(
            title: AppStrings.endDate.tr,
            value: formatDate(data.policyEndDate!),
          ),
          ItemRow(
            title: AppStrings.renewalDate.tr,
            value: formatDate(data.renewalDate!),
          ),
          ItemRow(
            title: AppStrings.sumInsured.tr,
            value: formatAmount(data.sumInsured!),
          ),
          ItemRow(
            title: AppStrings.premium.tr,
            value: formatAmount(data.premiumAmount!),
          ),
          ItemRow(
            title: AppStrings.accountHandler.tr,
            value: data.approvedBy ?? '',
          ),
          ItemRow(
            title: AppStrings.status.tr,
            value: getPolicyStatus(data.policyEndDate!, data.approved).status,
            valueColor:
                getPolicyStatus(data.policyEndDate!, data.approved).color,
          ),
          ItemRow(
            title: AppStrings.itemInsured.tr,
            value: AppStrings.view.tr,
            onTap: () => Get.to(
              () => ItemsInsuredScreen(itemsInsured: data.itemsToInsure!),
            ),
          ),
          ItemRow(
            title: AppStrings.insurer.tr,
            value: AppStrings.view.tr,
            onTap: () => Get.to(
              () => InsurersScreen(
                writers: data.insurancePolicyUnderwriters!,
              ),
            ),
          ),
          SizedBox(
            height: queryHeight(context) * 0.1,
          )
        ],
      ),
    );
  }
}
