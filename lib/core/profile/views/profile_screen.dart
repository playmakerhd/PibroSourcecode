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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.white,
                      backgroundImage: AssetImage(AppImages.dashboard),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Obx(
                      () => homeController.profileLoading.value
                          ? LoadingAnimationWidget.waveDots(
                              color: Colors.white,
                              size: 50,
                            )
                          : Column(
                              children: [
                                Text(
                                  homeController
                                      .user.value!.customerName!.capitalize!,
                                  style: Styles.boldTextStyle(
                                    size: 16,
                                  ),
                                  softWrap: true,
                                ),
                                Text(
                                  '${AppStrings.username.tr}: ${homeController.user.value!.customerID!}',
                                  style: Styles.boldTextStyle(
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
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
