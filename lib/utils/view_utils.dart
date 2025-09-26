import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/app_styles.dart';

double queryHeight(BuildContext? context) {
  return context != null ? MediaQuery.of(context).size.height : Get.size.height;
}

double queryWidth(BuildContext? context) {
  return context != null ? MediaQuery.of(context).size.width : Get.size.width;
}

bool _isSnackbarShowing = false;

void showSnackbarMessage({
  required String message,
  bool isSuccess = true,
  bool isWarning = false,
}) {
  if (_isSnackbarShowing || Get.isSnackbarOpen) {
    // Prevent showing another snackbar while one is active
    return;
  }

  _isSnackbarShowing = true; // Lock

  final snackbar = GetSnackBar(
    titleText: Text(
      isWarning
          ? 'Info'
          : isSuccess
              ? 'Success'
              : 'Error',
      style: Styles.mediumTextStyle(color: AppColors.white, size: 18),
    ),
    messageText: Text(
      message,
      style: Styles.regularTextStyle(color: AppColors.white, size: 14),
    ),
    backgroundColor: isWarning
        ? Colors.orangeAccent
        : isSuccess
            ? Colors.green.shade900
            : Colors.red.shade900,
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
    borderRadius: AppConstants.snackBarRadius,
  );

  Get.showSnackbar(snackbar);

  // Release lock after duration + a small buffer (to account for animation)
  Future.delayed(const Duration(seconds: 3), () {
    _isSnackbarShowing = false;
  });
}

void showAppDialog(Widget child,
    {double height = 220, bool dismissible = true, bool willPop = true}) {
  Get.dialog(
    barrierDismissible: dismissible,
    Dialog(
      backgroundColor: AppColors.tileColor,
      child: WillPopScope(
        onWillPop: () async => willPop,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.appRadius),
          ),
          child: child,
        ),
      ),
    ),
  );
}

Future<dynamic> showAppBottomSheet({
  required Widget child,
  double height = 460,
  bool isDismissible = true,
  bool enableDrag = true,
  bool willPop = true,
  bool isImagePreview = false,
}) {
  return Get.bottomSheet(
    WillPopScope(
      onWillPop: () async => willPop,
      child: Container(
        height: height,
        width: queryWidth(null),
        padding: isImagePreview
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(
                horizontal: Get.size.width * 0.08, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.appRadius),
          ),
        ),
        child: SingleChildScrollView(child: child),
      ),
    ),
    isDismissible: isDismissible,
    enableDrag: enableDrag,
  );
}
