import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/landing/controller/landing_controller.dart';
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
    final LandingController controller = Get.find<LandingController>();
    final SupportController supportController =
        Get.isRegistered<SupportController>()
            ? Get.find<SupportController>()
            : Get.put(SupportController());
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
                        ? supportController.navigateToFAQ
                        : index == 1
                            ? supportController.navigateToContactUs
                            : supportController.navigateToAboutUs,
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
          child: Stack(
            children: [
              // Reserve bottom space for the footer so the UI above doesn't collide with it.
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(bottom: queryHeight(context) * 0.09),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: queryHeight(context) *
                                0.035, // slightly reduced top gap
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ImageFactory.getImage(AppImages.pibroLogo)
                                  .render(height: 35),
                              GestureDetector(
                                onTap: () =>
                                    scaffoldKey.currentState?.openEndDrawer(),
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
                                vertical: queryHeight(context) * 0.045),
                            child: ImageFactory.getImage(AppImages.landing)
                                .render(
                                    height:
                                        110), // slightly smaller to free space
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Obx(
                                () => Text(
                                  controller.getWelcomeText(),
                                  style: Styles.boldTextStyle(
                                    size: 20,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: queryHeight(context) * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            child: Icon(Icons.settings, size: 20),
                            onTap: () {
                              Get.offAllNamed(AppRoutes.serviceConfig);
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 120, // reduced so the block moves up
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                RotatedContainer(
                                  text: AppStrings.getQuote.tr,
                                  image: AppImages.getQuote,
                                  hasBoxShadow: false,
                                  onPressed: () =>
                                      Get.toNamed(AppRoutes.getQuote),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: queryHeight(context) * 0.05,
                          ),
                          CustomButton(
                            text: AppStrings.signUp.tr.capitalizeFirst!,
                            onPressed: () => Get.toNamed(AppRoutes.signup),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: queryHeight(context) * 0.02,
                                bottom: queryHeight(context) * 0.01),
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
              // Footer pinned to bottom with comfortable spacing
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Text(
                    'Powered by Powersoft Integrated Solutions',
                    textAlign: TextAlign.center,
                    style: Styles.regularTextStyle(
                      size: 12,
                      color: AppColors.primaryColor.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
