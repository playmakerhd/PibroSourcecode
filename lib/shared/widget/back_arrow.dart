import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';

class BackArrow extends StatelessWidget {
  const BackArrow({super.key, this.color = AppColors.primaryColor, this.onTap});

  final Color color;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? Get.back,
      child: Icon(
        Icons.arrow_back,
        color: color,
        size: 30,
      ),
    );
  }
}
