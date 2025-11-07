import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/core/profile/widget/profile_button.dart';
import 'package:pibro/utils/image_factory.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';

/// Shows a standardized success dialog using `showAppDialog`.
///
/// Parameters:
/// - title: headline text
/// - message: subtext
/// - onPressed: callback for OK button (defaults to Get.back())
/// - image: AppImages asset to render (defaults to passwordSuccess)
Future<dynamic> showSuccessDialog({
  required String title,
  required String message,
  VoidCallback? onPressed,
  String image = AppImages.passwordSuccess,
  double height = 220,
  bool dismissible = false,
  bool willPop = false,
}) {
  return Get.dialog(
    Dialog(
      backgroundColor: AppColors.tileColor,
      child: PopScope(
        canPop: willPop,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ImageFactory.getImage(image).render(
                  height: 65,
                  width: 65,
                ),
                Column(
                  children: [
                    Text(
                      title,
                      style: Styles.semiBoldTextStyle(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      message,
                      style: Styles.mediumTextStyle(
                        size: 12,
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onPressed ?? () => Get.back(),
                  child: ProfileButton(
                    text: 'OK',
                    height: 25,
                    width: 80,
                    textColor: AppColors.activeGreen,
                    bgColor: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    barrierDismissible: dismissible,
  );
}
