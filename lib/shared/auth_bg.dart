import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/shared/widget/back_arrow.dart';
import 'package:pibro/utils/image_factory.dart';
import 'package:pibro/utils/view_utils.dart';

class AuthBg extends StatelessWidget {
  const AuthBg(
      {super.key,
      required this.title,
      required this.child,
      this.floatingButton,
      this.titleWidget,
      this.showBack = true});

  final String title;
  final Widget? titleWidget;
  final Widget child;
  final Widget? floatingButton;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: floatingButton,
      backgroundColor: AppColors.tileColor,
      body: SafeArea(
        bottom: false,
        child: Container(
          height: queryHeight(context),
          width: queryWidth(context),
          color: AppColors.white,
          child: ListView(
            children: [
              Stack(
                children: [
                  ImageFactory.getImage(AppImages.headerBg).render(),
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: queryWidth(context) * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          if (showBack) BackArrow(),
                          SizedBox(
                            height: queryHeight(context) * 0.07,
                          ),
                          // allow screens to provide a custom widget (logo) for the header
                          titleWidget ??
                              Text(
                                title,
                                style: Styles.boldTextStyle(
                                  size: 20,
                                  color: AppColors.white,
                                ),
                              ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
