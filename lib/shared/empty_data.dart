import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/internalization/app_strings.dart';

class EmptyData extends StatelessWidget {
  const EmptyData({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 80,
          ),
          Center(
            child: Text(
              AppStrings.noData.tr,
              style: Styles.mediumTextStyle(),
            ),
          ),
        ],
      ),
    );
  }
}
