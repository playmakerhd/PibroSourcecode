import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/core/quote/controller/quote_controller.dart';
import 'package:pibro/core/quote/widgets/quote_details_widget.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/utils/view_utils.dart';

class QuoteDetailsScreen extends StatelessWidget {
  const QuoteDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QuoteController controller = Get.put(QuoteController());
    final bool isCompleted =
        ((controller.selectedQuote.value?.supportStatus ?? '')
                .toString()
                .toLowerCase() ==
            'completed');
    return Scaffold(
      backgroundColor: AppColors.tileColor,
      floatingActionButton: isCompleted
          ? null
          : PolicyButton(
              height: 40,
              width: 180,
              text: AppStrings.makePayment.tr,
              bgColor: AppColors.primaryColor,
              onPressed: () {
                QuoteDetailsWidget(data: controller.selectedQuote.value!);
                controller.navigateToQuoteSummaryForPayment();
              },
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
                title: AppStrings.quoteDetail.tr,
              ),
              QuoteDetailsWidget(data: controller.selectedQuote.value!),
            ],
          ),
        ),
      ),
    );
  }
}
