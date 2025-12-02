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

/// Safe navigation back that handles snackbar controller issues
/// This is a workaround for GetX LateInitializationError in snackbar_controller
void safeBack({dynamic result}) {
  // Use Navigator.pop directly to avoid GetX snackbar controller issues
  try {
    if (Get.context != null && Navigator.of(Get.context!).canPop()) {
      Navigator.of(Get.context!).pop(result);
      return;
    }
  } catch (e) {
    // Fallback if context-based navigation fails
  }

  // Fallback: try Get.back but catch any snackbar-related errors
  try {
    // Manually check and close snackbars before navigation
    if (Get.isSnackbarOpen) {
      try {
        Get.closeAllSnackbars();
      } catch (_) {
        // Ignore snackbar closing errors
      }
    }
    Get.back(result: result, closeOverlays: false);
  } catch (e) {
    // Catch specific GetX snackbar controller error
    if (e.runtimeType.toString() == 'LateInitializationError' &&
        e.toString().contains('_controller@')) {
      // This is the snackbar controller error - use Navigator as fallback
      if (Get.context != null) {
        Navigator.of(Get.context!).maybePop(result);
      }
      return;
    }
    // Last resort fallback
    if (Get.context != null) {
      Navigator.of(Get.context!).maybePop(result);
    }
  }
}

/// Safe close all snackbars - catches LateInitializationError
void safeCloseAllSnackbars() {
  try {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
  } catch (e) {
    // Ignore errors from closing non-existent or uninitialized snackbars
  }
}

void showSnackbarMessage({
  required String message,
  bool isSuccess = true,
  bool isWarning = false,
}) {
  // Close any existing snackbar safely before showing a new one
  safeCloseAllSnackbars();

  if (_isSnackbarShowing) {
    // Prevent showing another snackbar while one is active
    return;
  }

  _isSnackbarShowing = true; // Lock

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

  // Release lock after duration + a small buffer (to account for animation)
  Future.delayed(const Duration(milliseconds: 3500), () {
    _isSnackbarShowing = false;
  });
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
  return Get.bottomSheet(
    PopScope(
      canPop: willPop,
      onPopInvokedWithResult: (didPop, result) {
        // When the bottom sheet is dismissed by gesture or back button,
        // this callback helps prevent the GetX snackbar error
        if (didPop) {
          // Sheet was already popped, just ensure snackbars are safely closed
          safeCloseAllSnackbars();
        }
      },
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
