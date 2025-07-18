import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';

class AppInputBorders {
  static const outlineFocusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(AppConstants.appRadius),
    ),
    borderSide: BorderSide(color: AppColors.tileColor, width: 1),
  );

  static const outlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(AppConstants.appRadius),
    ),
    borderSide: BorderSide(color: AppColors.tileColor, width: 3),
  );

  static const reducedFocusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(AppConstants.snackBarRadius),
    ),
    borderSide: BorderSide(color: AppColors.tileColor, width: 1),
  );

  static const reducedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(AppConstants.snackBarRadius),
    ),
    borderSide: BorderSide(color: AppColors.tileColor, width: 3),
  );

  static const withLabelFocusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(AppConstants.snackBarRadius),
    ),
    borderSide: BorderSide(color: AppColors.greyColor, width: 0),
  );

  static const withLabelBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(AppConstants.snackBarRadius),
    ),
    borderSide: BorderSide(color: AppColors.greyColor, width: 0),
  );

  static const disabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(AppConstants.appRadius),
    ),
    borderSide: BorderSide(color: AppColors.greyColor, width: 3),
  );

  static const fillFocusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(AppConstants.appRadius),
    ),
    borderSide: BorderSide(color: Color(0xFFF1F1F1), width: 2),
  );

  static const fillBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(AppConstants.appRadius),
    ),
    borderSide: BorderSide(color: Color(0xFFF1F1F1), width: 1),
  );
}
