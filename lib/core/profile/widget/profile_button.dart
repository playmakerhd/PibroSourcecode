import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({
    super.key,
    required this.text,
    this.height = 35,
    this.width = 150,
    this.bgColor = AppColors.primaryColor,
    this.textColor = AppColors.white,
  });

  final double height;
  final double width;
  final String text;
  final Color textColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration:
          BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(5)),
      child: Center(
        child: Text(
          text,
          style: Styles.mediumTextStyle(color: textColor),
        ),
      ),
    );
  }
}
