import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';

class TitleValueRow extends StatelessWidget {
  const TitleValueRow({
    super.key,
    required this.title,
    this.value = '-',
    this.valueColor = AppColors.primaryColor,
    this.onTap,
    this.isTextBolder = false,
  });

  final String title;
  final String value;
  final Color valueColor;
  final Function()? onTap;
  final bool isTextBolder;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isTextBolder
              ? Styles.mediumTextStyle(size: 12)
              : Styles.regularTextStyle(size: 12),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: onTap != null
                  ? Styles.linkTextStyle(size: 12)
                  : isTextBolder
                      ? Styles.mediumTextStyle(size: 12, color: valueColor)
                      : Styles.regularTextStyle(
                          size: 12,
                          color: valueColor,
                        ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
