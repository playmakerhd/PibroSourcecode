import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/main_screen/controller/main_controller.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.put(MainController());
    return Scaffold(
      bottomNavigationBar: SafeArea(
        top: false,
        child: Obx(
          () => BottomNavigationBar(
            items: controller.bottomNavs,
            currentIndex: controller.currentIndex.value,
            onTap: controller.updateBottomTab,
            selectedLabelStyle: Styles.boldTextStyle(size: 12),
            unselectedLabelStyle:
                Styles.boldTextStyle(color: AppColors.greyColor, size: 12),
          ),
        ),
      ),
      body: Obx(
        () => controller.screens[controller.currentIndex.value],
      ),
    );
  }
}
