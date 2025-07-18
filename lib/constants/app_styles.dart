import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';

class Styles {
  static TextStyle thinTextStyle({
    Color color = AppColors.primaryColor,
    double size = 14,
    TextDecoration decoration = TextDecoration.none,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w100,
      color: color,
      letterSpacing: -0.5,
      decoration: decoration,
      fontStyle: fontStyle,
    );
  }

  static TextStyle lightTextStyle({
    Color color = AppColors.primaryColor,
    double size = 14,
    TextDecoration decoration = TextDecoration.none,
    bool italic = false,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w300,
      color: color,
      decoration: decoration,
      letterSpacing: -0.5,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    );
  }

  static TextStyle regularTextStyle({
    Color color = AppColors.primaryColor,
    double size = 14,
    FontStyle fontStyle = FontStyle.normal,
    TextDecoration decoration = TextDecoration.none,
    TextDecorationStyle decorationStyle = TextDecorationStyle.solid,
    Color decorationColor = AppColors.primaryColor,
    double decorationThickness = 1.0,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: color,
      fontStyle: fontStyle,
      decoration: decoration,
      letterSpacing: -0.5,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }

  static TextStyle mediumTextStyle({
    Color color = AppColors.primaryColor,
    double size = 16,
    FontStyle fontStyle = FontStyle.normal,
    TextDecoration decoration = TextDecoration.none,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: -0.5,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle semiBoldTextStyle({
    Color color = AppColors.primaryColor,
    double size = 16,
    FontStyle fontStyle = FontStyle.normal,
    TextDecoration decoration = TextDecoration.none,
    TextDecorationStyle decorationStyle = TextDecorationStyle.solid,
    Color decorationColor = AppColors.primaryColor,
    double decorationThickness = 1.0,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      fontStyle: fontStyle,
      letterSpacing: -0.5,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }

  static TextStyle boldTextStyle({
    Color color = AppColors.primaryColor,
    double size = 16,
    TextDecoration decoration = TextDecoration.none,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return TextStyle(
      fontSize: size,
      letterSpacing: -0.5,
      fontWeight: FontWeight.w700,
      color: color,
      decoration: decoration,
      fontStyle: fontStyle,
    );
  }

  static TextStyle extraBoldTextStyle({
    Color color = AppColors.primaryColor,
    double size = 16,
    TextDecoration decoration = TextDecoration.none,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return TextStyle(
      fontSize: size,
      decoration: decoration,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: -0.5,
      fontStyle: fontStyle,
    );
  }

  static TextStyle linkTextStyle({
    double size = 16,
    Color color = AppColors.primaryColor,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: Colors.transparent,
      height: 1.1,
      shadows: [Shadow(color: color, offset: Offset(0, -2))],
      letterSpacing: -0.5,
      decoration: TextDecoration.underline,
      decorationColor: color,
    );
  }
}
