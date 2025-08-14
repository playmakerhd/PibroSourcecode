import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/policy/controller/renew_policy_controller.dart';
import 'package:pibro/core/policy/widget/items_insured_list.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/core/quote/controller/get_quote_controller.dart';
import 'package:pibro/core/quote/widgets/quote_items_list.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/utils/view_utils.dart';

class ItemsToInsureScreen extends StatelessWidget {
  const ItemsToInsureScreen({super.key, required this.controller});

  final dynamic controller;

  @override
  Widget build(BuildContext context) {
    // final RenewPolicyController controller = Get.put(RenewPolicyController());
    return Scaffold(
      body: SizedBox(
        height: queryHeight(context),
        width: queryWidth(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonHeader(
                title: controller is GetQuoteController
                    ? AppStrings.getQuote.tr
                    : AppStrings.renewPolicy.tr,
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
                      controller is GetQuoteController
                          ? controller
                              .selectedBusinessPolicy.value!.businessClassName!
                          : controller.policy.value!.businessClassID!,
                      style: Styles.mediumTextStyle(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Text(
                        AppStrings.itemToInsure.tr,
                        style: Styles.regularTextStyle(),
                      ),
                    ),
                    Obx(
                      () => Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.faintGrey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppConstants.snackBarRadius,
                          ),
                        ),
                        child: (controller is GetQuoteController &&
                                    controller.items.isEmpty) ||
                                (controller is RenewPolicyController &&
                                    controller.policyItems.isEmpty &&
                                    controller.newPolicyItems.isEmpty)
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Icon(
                                      Icons.hourglass_empty,
                                      size: 40,
                                    ),
                                    Center(
                                      child: Text(
                                        AppStrings.noData.tr,
                                        style: Styles.mediumTextStyle(),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  if (controller is GetQuoteController) ...[
                                    Obx(
                                      () => QuoteItemsList(
                                        list: controller.items.value.reversed
                                            .toList(),
                                        edit: (item) => controller
                                            .showAddOrUpdateSheet(item),
                                        delete: (item) =>
                                            controller.removeItemFromList(item),
                                      ),
                                    ),
                                  ] else ...[
                                    Obx(
                                      () => ItemsInsuredList(
                                        list: controller.policyItems.value,
                                        edit: (item) =>
                                            controller.showAddOrUpdateItemSheet(
                                                data: item),
                                      ),
                                    ),
                                    Obx(
                                      () => ItemsInsuredList(
                                        list: controller
                                            .newPolicyItems.value.reversed
                                            .toList(),
                                        edit: (item) =>
                                            controller.showAddOrUpdateItemSheet(
                                                data: item, isNew: true),
                                        delete: (item) =>
                                            controller.removeItemFromList(
                                          item,
                                          controller.newPolicyItems,
                                        ),
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                      ),
                    ),
                    if (controller is GetQuoteController)
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => controller is GetQuoteController
                              ? controller.showAddOrUpdateSheet(null)
                              : controller.showAddOrUpdateItemSheet(
                                  data: null,
                                  isNew: true,
                                ),
                          child: Container(
                            height: 40,
                            width: 40,
                            margin: EdgeInsets.only(top: 30),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor,
                            ),
                            child: Icon(
                              Icons.add,
                              color: AppColors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Center(
                        child: Obx(
                          () => PolicyButton(
                            text: AppStrings.submit.tr,
                            loading: controller is GetQuoteController
                                ? controller.submitLoading.value
                                : controller.renewPolicyLoading.value,
                            onPressed: controller is GetQuoteController
                                ? controller.submit
                                : controller.submitItemToInsure,
                            height: 50,
                            width: queryWidth(context) * 0.7,
                            bgColor: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
