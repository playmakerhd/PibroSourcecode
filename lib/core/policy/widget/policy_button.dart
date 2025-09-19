import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/app_styles.dart';

class PolicyButton extends StatelessWidget {
  const PolicyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 30,
    this.width,
    this.bgColor = AppColors.activeGreen,
    this.isExpanded = false,
    this.loading = false,
  });

  final String text;
  final Function() onPressed;
  final double height;
  final double? width;
  final Color bgColor;
  final bool isExpanded;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTap: loading ? () {} : onPressed,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppConstants.snackBarRadius),
        ),
        child: Center(
          child: loading
              ? Transform.scale(
                  scale: 0.5,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 4,
                  ),
                )
              : Text(
                  text,
                  style: Styles.semiBoldTextStyle(
                      size: 15, color: AppColors.white),
                ),
        ),
      ),
    );
    return isExpanded ? Expanded(child: button) : button;
  }
}
