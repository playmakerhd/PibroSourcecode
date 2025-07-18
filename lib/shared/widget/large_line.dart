import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/utils/view_utils.dart';

class LargeLine extends StatelessWidget {
  const LargeLine({super.key, this.height = 8});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: queryWidth(context),
      color: AppColors.primaryColor,
    );
  }
}
