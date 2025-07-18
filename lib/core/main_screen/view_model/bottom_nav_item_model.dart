import 'package:get/get.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/internalization/app_strings.dart';

class BottomNavItem {
  final String title;
  final String activeIcon;
  final String inactiveIcon;

  const BottomNavItem({
    required this.title,
    required this.activeIcon,
    required this.inactiveIcon,
  });
}

class BottomNavItems {
  static List<BottomNavItem> all = [
    BottomNavItem(
      title: AppStrings.home.tr,
      activeIcon: AppImages.homeActive,
      inactiveIcon: AppImages.homeInactive,
    ),
    BottomNavItem(
      title: AppStrings.support.tr,
      activeIcon: AppImages.supportActive,
      inactiveIcon: AppImages.supportInactive,
    ),
    BottomNavItem(
      title: AppStrings.profile.tr,
      activeIcon: AppImages.profileActive,
      inactiveIcon: AppImages.profileInactive,
    ),
  ];
}
