import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/landing/view_models/drawer_data.dart';
import 'package:pibro/core/support/controller/support_controller.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/custom_button.dart';
import 'package:pibro/shared/widget/back_arrow.dart';
import 'package:pibro/shared/widget/rotated_container.dart';
import 'package:pibro/utils/image_factory.dart';
import 'package:pibro/utils/view_utils.dart';

class LandingScreen extends StatelessWidget {
  LandingScreen({super.key});

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final SupportController controller = Get.put(SupportController());
    return Scaffold(
      key: scaffoldKey,
      endDrawer: Drawer(
        backgroundColor: AppColors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 40, left: 20),
                child: BackArrow(
                  color: AppColors.drawerIconColor,
                  onTap: () => scaffoldKey.currentState!.closeEndDrawer(),
                ),
              ),
              Column(
                children:
                    DrawerData.all.indexed.map(((int, dynamic) drawerItem) {
                  final (index, item) = drawerItem;
                  return GestureDetector(
                    onTap: index == 2
                        ? controller.navigateToFAQ
                        : index == 1
                            ? controller.navigateToContactUs
                            : controller.navigateToAboutUs,
                    child: Container(
                      height: 60,
                      width: queryWidth(context),
                      margin: EdgeInsets.only(bottom: 10),
                      color: AppColors.tileColor,
                      padding: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.title,
                        style: Styles.boldTextStyle(
                            size: 14, color: AppColors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        height: queryHeight(context),
        width: queryWidth(context),
        padding: EdgeInsetsDirectional.symmetric(
            horizontal: queryWidth(context) * 0.05),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.landingBg),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: queryHeight(context) * 0.04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ImageFactory.getImage(AppImages.pibroLogo)
                          .render(height: 35),
                      GestureDetector(
                        onTap: () => scaffoldKey.currentState?.openEndDrawer(),
                        child: Icon(
                          Icons.menu,
                          color: AppColors.white,
                          size: 30,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: queryHeight(context) * 0.05),
                    child: ImageFactory.getImage(AppImages.landing)
                        .render(height: 120),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        AppStrings.welcomeText.tr,
                        style: Styles.boldTextStyle(
                          size: 20,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RotatedContainer(
                          text: AppStrings.explore.tr,
                          image: AppImages.explore,
                          hasBoxShadow: false,
                          onPressed: () => Get.offNamed(AppRoutes.main),
                        ),
                        RotatedContainer(
                          text: AppStrings.getQuote.tr,
                          image: AppImages.getQuote,
                          hasBoxShadow: false,
                          onPressed: () => Get.toNamed(AppRoutes.quote),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: queryHeight(context) * 0.06,
                  ),
                  CustomButton(
                    text: AppStrings.signUp.tr.capitalizeFirst!,
                    onPressed: () => Get.toNamed(AppRoutes.signup),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: queryHeight(context) * 0.02,
                        bottom: queryHeight(context) * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppStrings.alreadyHaveAccount.tr,
                            style: Styles.regularTextStyle(size: 14)),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.login),
                          child: Text(AppStrings.login.tr,
                              style: Styles.boldTextStyle(size: 14)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
