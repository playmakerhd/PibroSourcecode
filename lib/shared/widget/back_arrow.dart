import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/utils/view_utils.dart';

class BackArrow extends StatelessWidget {
  const BackArrow({super.key, this.color = AppColors.primaryColor, this.onTap});

  final Color color;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Use safeBack by default instead of Get.back
      onTap: onTap ?? () => safeBack(),
      child: Icon(
        Icons.arrow_back,
        color: color,
        size: 30,
      ),
    );
  }
}
