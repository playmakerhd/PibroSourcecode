import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/core/home/view/home_screen.dart';
import 'package:pibro/core/main_screen/view_model/bottom_nav_item_model.dart';
import 'package:pibro/core/profile/views/profile_screen.dart';
import 'package:pibro/core/support/view/support_screen.dart';
import 'package:pibro/utils/image_factory.dart';

class MainController extends GetxController {
  RxInt currentIndex = 0.obs;

  updateBottomTab(int index) {
    currentIndex.value = index;
  }

  List<Widget> screens = [
    const HomeScreen(),
    const SupportScreen(),
    const ProfileScreen(),
  ];

  List<BottomNavigationBarItem> bottomNavs = BottomNavItems.all
      .map((item) => BottomNavigationBarItem(
            icon: ImageFactory.getImage(item.inactiveIcon).render(),
            label: item.title,
            activeIcon: ImageFactory.getImage(item.activeIcon).render(),
          ))
      .toList();
}
