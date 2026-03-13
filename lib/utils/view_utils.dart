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

double queryBottomInset(
  BuildContext? context, {
  bool includeKeyboard = false,
}) {
  if (context == null) {
    return 0;
  }

  final mediaQuery = MediaQuery.of(context);
  final double keyboardInset =
      includeKeyboard ? mediaQuery.viewInsets.bottom : 0;

  if (keyboardInset > 0) {
    return keyboardInset;
  }

  return mediaQuery.padding.bottom;
}

/// Safe navigation back that DOES NOT use Get.back()
///
/// Why?
/// -----
/// Get.back() calls into Get's navigation layer which, in this GetX version,
/// tries to close the "current snackbar" via SnackbarController. If the
/// controller has not been initialised, you get:
///
///   LateInitializationError: Field '_controller' has not been initialized
///
/// To avoid this completely, we only use Flutter's Navigator.
void safeBack({dynamic result}) {
  // 1. Try using the current context (works anywhere in the UI)
  final ctx = Get.context;
  if (ctx != null) {
    try {
      final navigator = Navigator.of(ctx);
      if (navigator.canPop()) {
        navigator.pop(result);
      } else {
        navigator.maybePop(result);
      }
      return;
    } catch (_) {
      // If anything goes wrong, fall through to the global navigator
    }
  }

  // 2. Fallback: use the root navigator directly via Get.key
  try {
    final navigator = Get.key.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop(result);
    } else {
      navigator?.maybePop(result);
    }
  } catch (_) {
    // Last resort: do nothing. Back should never crash the app.
  }
}

/// Central helper for all snackbars in the app.
/// NOTE: We intentionally do NOT call `Get.closeAllSnackbars()` or
/// `Get.closeCurrentSnackbar()` here. Let GetX manage the snackbar queue.
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

void showAppDialog(
  Widget child, {
  double height = 220,
  bool dismissible = true,
  bool willPop = true,
}) {
  Get.dialog(
    barrierDismissible: dismissible,
    Dialog(
      backgroundColor: AppColors.tileColor,
      child: PopScope(
        canPop: willPop,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 30),
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
      final mediaQuery = MediaQuery.of(sheetContext);
      final double sheetWidth = queryWidth(sheetContext);
      final double keyboardInset = mediaQuery.viewInsets.bottom;
      final double availableHeight =
          mediaQuery.size.height - mediaQuery.padding.top - keyboardInset - 12;
      final double effectiveMaxHeight =
          availableHeight > 0 && availableHeight < height
              ? availableHeight
              : height;
      final EdgeInsets sheetPadding = isImagePreview
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
              horizontal: sheetWidth * 0.08,
              vertical: 20,
            );

      final Widget sheetBody = Container(
        constraints: BoxConstraints(
          maxHeight: effectiveMaxHeight,
          maxWidth: sheetWidth,
        ),
        padding: sheetPadding,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.appRadius),
          ),
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: child,
        ),
      );

      return PopScope(
        canPop: willPop,
        onPopInvokedWithResult: (didPop, result) {
          // IMPORTANT: do NOT manually close snackbars here.
          // Let them finish naturally to avoid touching SnackbarController.
        },
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: keyboardInset),
          child: SafeArea(
            top: false,
            bottom: keyboardInset == 0,
            child: sheetBody,
          ),
        ),
      );
    },
  );
}
