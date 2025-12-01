import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/home/controller/home_controller.dart';
import 'package:pibro/core/profile/controller/profile_controller.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/main_header.dart';
import 'package:pibro/utils/view_utils.dart';
import 'dart:math' as math;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final headerHeight = MediaQuery.of(context).padding.top + 210;
    final ProfileController controller = Get.put(ProfileController());
    final HomeController homeController = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SizedBox(
        height: queryHeight(context),
        width: queryWidth(context),
        child: Column(
          children: [
            MainHeader(
              height: headerHeight,
              borderWidth: 15,
              hasBackIcon: false,
              child: LayoutBuilder(builder: (ctx, constraints) {
                final width = constraints.maxWidth;
                // Compute responsive sizes with sensible minimums and maximums
                double avatarRadius = (width * 0.15);
                avatarRadius = avatarRadius.clamp(40.0, 80.0);
                double primaryFont = (width * 0.05).clamp(14.0, 20.0);
                double secondaryFont = (width * 0.04).clamp(12.0, 16.0);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: AppColors.white,
                      backgroundImage: AssetImage(AppImages.dashboard),
                    ),
                    SizedBox(height: math.max(8.0, avatarRadius * 0.12)),
                    Obx(() {
                      if (homeController.profileLoading.value) {
                        return LoadingAnimationWidget.waveDots(
                          color: Colors.white,
                          size: math.max(24.0, avatarRadius * 0.6),
                        );
                      }

                      final name =
                          homeController.user.value?.customerName?.capitalize ??
                              '-';
                      final id = homeController.user.value?.customerID ?? '-';

                      return Column(
                        children: [
                          Text(
                            name,
                            style: Styles.boldTextStyle(size: primaryFont),
                            softWrap: true,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${AppStrings.username.tr}: $id',
                            style: Styles.boldTextStyle(size: secondaryFont),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }),
                  ],
                );
              }),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 30),
                children: controller.profileMenus
                    .map(
                      (menu) => GestureDetector(
                        onTap: () => controller.onProfileItemPressed(menu),
                        child: Container(
                          height: 70,
                          margin: EdgeInsets.symmetric(
                            horizontal: queryWidth(context) * 0.05,
                            vertical: 5,
                          ),
                          width: queryWidth(context),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(10),
                            ),
                            border: Border.all(
                              color: AppColors.tileColor,
                              width: 3,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 15,
                                color: AppColors.primaryColor,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  menu,
                                  style: Styles.boldTextStyle(size: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
