import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/utils/view_utils.dart';

class MainHeader extends StatelessWidget {
  const MainHeader({
    super.key,
    required this.height,
    required this.child,
    this.borderWidth = 10,
    this.hasBackIcon = true,
    this.isTransparent = false,
    this.onBackPressed,
  });

  final double height;
  final Widget child;
  final double borderWidth;
  final bool hasBackIcon;
  final bool isTransparent;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: queryWidth(context),
      padding: EdgeInsets.symmetric(
        vertical: 5,
        horizontal: queryWidth(context) * 0.05,
      ),
      decoration: BoxDecoration(
        color: isTransparent ? AppColors.white : AppColors.tileColor,
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryColor,
            width: borderWidth,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 4,
          )
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hasBackIcon
                ? GestureDetector(
                    onTap: onBackPressed ?? Get.back,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryColor,
                        size: 30,
                      ),
                    ),
                  )
                : SizedBox(
                    width: 30,
                  ),
            child,
            SizedBox(
              width: 30,
            ),
          ],
        ),
      ),
    );
  }
}
