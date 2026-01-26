import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/app_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final double? width;
  final double? height;
  final double fontSize;
  final bool isOutline;
  final bool enabled;
  final double borderWidth;
  final double borderRadius;
  final bool loading;
  final Color? color;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize = 16,
    this.width,
    this.height = 50,
    this.isOutline = false,
    this.enabled = true,
    this.borderWidth = 2,
    this.borderRadius = AppConstants.appRadius,
    this.loading = false,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: loading || !enabled ? () {} : onPressed,
      child: Container(
        height: height,
        width: width ?? size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: isOutline
              ? Border.all(color: AppColors.primaryColor, width: borderWidth)
              : const Border.symmetric(),
          color: color ??
              (isOutline
                  ? AppColors.white
                  : !enabled
                      ? AppColors.greyColor
                      : AppColors.primaryColor),
        ),
        child: Center(
          child: loading
              ? Transform.scale(
                  scale: 0.5,
                  child: CircularProgressIndicator(
                    color: isOutline ? AppColors.primaryColor : AppColors.white,
                    strokeWidth: 4,
                  ),
                )
              : Center(
                  child: Text(
                    text,
                    style: Styles.boldTextStyle(
                      size: fontSize,
                      color: textColor ??
                          (isOutline || !enabled
                              ? AppColors.white
                              : AppColors.white),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ),
      ),
    );
  }
}
