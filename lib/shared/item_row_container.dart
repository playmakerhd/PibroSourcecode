import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/utils/view_utils.dart';

class ItemRowContainer extends StatelessWidget {
  const ItemRowContainer({
    super.key,
    this.isLarge = false,
    this.isPolicy = false,
    this.isPolicyRenew = false,
    this.noHorizontalMargin = false,
    this.noHeight = false,
    required this.child,
  });

  final bool isLarge;
  final bool isPolicy;
  final bool isPolicyRenew;
  final Widget child;
  final bool noHorizontalMargin;
  final bool noHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: noHeight
          ? null
          : isPolicy
              ? 180
              : isPolicyRenew || isLarge
                  ? 80
                  : 40,
      width: queryWidth(context),
      margin: EdgeInsets.symmetric(
        vertical: isLarge ? 10 : 7,
        horizontal: noHorizontalMargin
            ? 0
            : queryWidth(context) * (isPolicyRenew ? 0.02 : 0.05),
      ),
      padding: EdgeInsets.symmetric(
          vertical: !isLarge ? 5 : 10,
          horizontal: isPolicyRenew
              ? 5
              : isPolicy
                  ? 0
                  : 15),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.tileColor,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(AppConstants.snackBarRadius),
      ),
      child: child,
    );
  }
}
