import 'package:flutter/material.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/shared/main_header.dart';

class CommonHeader extends StatelessWidget {
  const CommonHeader({
    super.key,
    required this.title,
    this.isTransparent = false,
    this.hasBackIcon = true,
    this.onBackPressed,
  });

  final String title;
  final bool isTransparent;
  final bool hasBackIcon;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final headerHeight =
        MediaQuery.of(context).padding.top + AppConstants.headerHeight;
    return MainHeader(
      height: headerHeight,
      hasBackIcon: hasBackIcon,
      onBackPressed: onBackPressed,
      isTransparent: isTransparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Text(
          title,
          style: Styles.boldTextStyle(
            size: 20,
          ),
        ),
      ),
    );
  }
}
