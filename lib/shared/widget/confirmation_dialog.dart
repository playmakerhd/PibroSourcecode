import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/utils/view_utils.dart';

/// Shows a confirmation dialog with custom message and action buttons.
///
/// Parameters:
/// - title: headline text
/// - message: confirmation message
/// - onConfirm: callback when user taps continue/confirm button
/// - onCancel: callback when user taps exit/cancel button (defaults to Get.back())
/// - confirmText: text for confirm button (defaults to "Continue")
/// - cancelText: text for cancel button (defaults to "Exit")
Future<dynamic> showConfirmationDialog({
  required String title,
  required String message,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  String confirmText = 'Continue',
  String cancelText = 'Exit',
  double height = 240,
  bool dismissible = true,
}) {
  return Get.dialog(
    barrierDismissible: dismissible,
    Dialog(
      backgroundColor: AppColors.tileColor,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Icon
            Icon(
              Icons.info_outline,
              size: 60,
              color: AppColors.primaryColor,
            ),
            // Title and Message
            Column(
              children: [
                Text(
                  title,
                  style: Styles.boldTextStyle(
                    color: AppColors.primaryColor,
                    size: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: Styles.mediumTextStyle(
                    size: 13,
                    color: AppColors.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: PolicyButton(
                    text: cancelText,
                    onPressed: onCancel ?? () => safeBack(),
                    height: 40,
                    bgColor: AppColors.greyColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PolicyButton(
                    text: confirmText,
                    onPressed: () {
                      safeBack();
                      onConfirm();
                    },
                    height: 40,
                    bgColor: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
