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

/// Safe navigation back that handles snackbar controller issues
void safeBack({dynamic result}) {
  try {
    if (Get.context != null && Navigator.of(Get.context!).canPop()) {
      Navigator.of(Get.context!).pop(result);
      return;
    }
  } catch (e) {
    // Fallback if context-based navigation fails
  }

  try {
    Get.back(result: result, closeOverlays: false);
  } catch (e) {
    if (Get.context != null) {
      Navigator.of(Get.context!).maybePop(result);
    }
  }
}

void showSnackbarMessage({
  required String message,
  bool isSuccess = true,
  bool isWarning = false,
}) {
  Get.snackbar(
    isWarning
        ? 'Info'
        : isSuccess
            ? 'Success'
            : 'Error',
    message,
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
    snackPosition: SnackPosition.BOTTOM,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
  );
}

void showAppDialog(Widget child,
    {double height = 220, bool dismissible = true, bool willPop = true}) {
  Get.dialog(
    barrierDismissible: dismissible,
    Dialog(
      backgroundColor: AppColors.tileColor,
      child: PopScope(
        canPop: willPop,
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
  final context = Get.context;
  if (context == null) {
    return Future.value();
  }

  return showModalBottomSheet<dynamic>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final double sheetWidth = queryWidth(sheetContext);
      final EdgeInsets sheetPadding = isImagePreview
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
              horizontal: sheetWidth * 0.08,
              vertical: 20,
            );

      final Widget sheetBody = Container(
        height: height,
        width: sheetWidth,
        padding: sheetPadding,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.appRadius),
          ),
        ),
        child: SingleChildScrollView(child: child),
      );

      return PopScope(
        canPop: willPop,
        onPopInvokedWithResult: (didPop, result) {
          // No need to close snackbars here - let them finish naturally
        },
        child: SafeArea(
          top: false,
          child: sheetBody,
        ),
      );
    },
  );
}
