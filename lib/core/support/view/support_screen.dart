import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/support/controller/support_controller.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/widget/rotated_container.dart';
import 'package:pibro/utils/view_utils.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SupportController controller = Get.put(SupportController());
    return Scaffold(
      backgroundColor: AppColors.tileColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: queryHeight(context) * 0.1,
                  bottom: queryHeight(context) * 0.15),
              child: Center(
                child: Text(
                  AppStrings.support.tr,
                  style: Styles.boldTextStyle(size: 20, color: AppColors.white),
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RotatedContainer(
                      text: AppStrings.contactUs.tr,
                      image: AppImages.contactUs,
                      borderColor: AppColors.tileColor,
                      onPressed: controller.navigateToContactUs,
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    RotatedContainer(
                      text: AppStrings.faq.tr,
                      image: AppImages.faq,
                      borderColor: AppColors.tileColor,
                      onPressed: controller.navigateToFAQ,
                    ),
                  ],
                ),
                RotatedContainer(
                  text: AppStrings.chat.tr,
                  image: AppImages.chat,
                  borderColor: AppColors.tileColor,
                  onPressed: controller.navigateToChat,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
