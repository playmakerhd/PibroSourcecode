import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/landing/widget/custom_expansion_tile.dart';
import 'package:pibro/core/support/controller/support_controller.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/widget/back_arrow.dart';
import 'package:pibro/shared/widget/large_line.dart';
import 'package:pibro/utils/view_utils.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SupportController controller = Get.put(SupportController());
    return Scaffold(
      appBar: AppBar(
        leading: BackArrow(),
      ),
      body: SizedBox(
        height: queryHeight(context),
        width: queryWidth(context),
        child: Column(
          children: [
            Text(
              AppStrings.faq.tr.toUpperCase(),
              style: Styles.boldTextStyle(size: 20),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 50),
              child: LargeLine(),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: queryWidth(context) * 0.05),
              child: Obx(
                () => controller.faqLoading.value &&
                        controller.companyFAQs.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: AppColors.blue,
                            size: 40,
                          ),
                        ),
                      )
                    : Column(
                        children: controller.companyFAQs
                            .map(
                              (item) => CustomExpansionTile(
                                title: item.systemMessage!,
                                details: item.description!,
                              ),
                            )
                            .toList(),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
