import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/custom_button.dart';

class DocumentContainer extends StatelessWidget {
  const DocumentContainer({
    super.key,
    required this.title,
    this.date = '',
    this.onTap,
    this.preview,
    this.document,
    this.status = false,
  });

  final String title;
  final String date;
  final Function()? onTap;
  final Function()? preview;
  final dynamic document;
  final bool status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Styles.semiBoldTextStyle(size: 14),
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       title,
          //       style: Styles.mediumTextStyle(size: 14),
          //     ),
          //     CustomButton(
          //       text: AppStrings.upload.tr,
          //       onPressed: onTap!,
          //       height: 20,
          //       width: 70,
          //       borderRadius: 5,
          //       fontSize: 12,
          //       color: AppColors.activeGreen.withValues(alpha: 0.7),
          //     )
          //   ],
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.date.tr}: ${date.isEmpty ? '--/--/--' : date}',
                style: Styles.mediumTextStyle(size: 14),
              ),
              CustomButton(
                text: AppStrings.upload.tr,
                onPressed: onTap!,
                height: 20,
                width: 70,
                borderRadius: 5,
                fontSize: 12,
                color: AppColors.activeGreen.withValues(alpha: 0.7),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                document != null && status
                    ? AppStrings.submitted.tr
                    : document != null
                        ? AppStrings.added.tr
                        : AppStrings.notSubmitted.tr,
                style: Styles.mediumTextStyle(
                  size: 14,
                  color: document != null && status
                      ? AppColors.activeGreen
                      : AppColors.orange,
                ),
              ),
              if (preview != null)
                CustomButton(
                  text: AppStrings.preview.tr,
                  onPressed: preview!,
                  height: 20,
                  width: 70,
                  borderRadius: 5,
                  fontSize: 12,
                  color: AppColors.tileColor,
                )
            ],
          ),
          // TitleValueRow(
          //   title: '${AppStrings.date.tr}: ${date.isEmpty ? '--/--/--' : date}',
          //   value: document != null && status
          //       ? AppStrings.submitted.tr
          //       : document != null
          //           ? AppStrings.added.tr
          //           : AppStrings.notSubmitted.tr,
          //   valueColor: document != null && status
          //       ? AppColors.activeGreen
          //       : AppColors.orange,
          // ),
        ],
      ),
    );
  }
}
