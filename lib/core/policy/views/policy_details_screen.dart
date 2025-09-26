import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/home/controller/home_controller.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/policy_details_widget.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';

class PolicyDetailsScreen extends StatelessWidget {
  const PolicyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final policy = controller.selectedPolicy.value;

    return Scaffold(
      backgroundColor: AppColors.tileColor,
      floatingActionButton: (policy != null &&
              getPolicyStatus(policy.policyEndDate ?? '', policy.approved)
                      .status ==
                  AppStrings.expired.tr)
          ? PolicyButton(
              text: AppStrings.renew.tr,
              onPressed: controller.navigateToRenewPolicyScreen,
              bgColor: AppColors.primaryColor,
              isExpanded: false,
              width: 120,
            )
          : Padding(
              padding: EdgeInsets.only(
                  left: queryWidth(context) * 0.05,
                  right: queryWidth(context) * 0.05,
                  bottom: 10),
              child: Row(
                children: [
                  PolicyButton(
                    text: AppStrings.renew.tr,
                    onPressed: controller.navigateToRenewPolicyScreen,
                    isExpanded: true,
                  ),
                  SizedBox(width: 7),
                  if (policy != null &&
                      getPolicyStatus(
                                  policy.policyEndDate ?? '', policy.approved)
                              .status ==
                          AppStrings.active.tr)
                    PolicyButton(
                      text: AppStrings.endorse.tr,
                      onPressed: controller.navigateToEndorsePolicyScreen,
                      isExpanded: true,
                    ),
                  SizedBox(width: 7),
                  PolicyButton(
                    text: AppStrings.claim.tr,
                    onPressed: controller.navigateToLodgeClaimScreen,
                    isExpanded: true,
                  ),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        bottom: false,
        child: Container(
          color: AppColors.white,
          height: queryHeight(context),
          width: queryWidth(context),
          child: ListView(
            children: [
              CommonHeader(
                title: AppStrings.policyDetail.tr,
              ),
              PolicyDetailsWidget(data: controller.selectedPolicy.value!),
            ],
          ),
        ),
      ),
    );
  }
}
