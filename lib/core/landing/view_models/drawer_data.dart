import 'package:pibro/navigation/routes.dart';

class DrawerItem {
  const DrawerItem({required this.title, required this.route});

  final String title;
  final String route;
}

class DrawerData {
  static const List<DrawerItem> all = [
    DrawerItem(title: 'About Us', route: AppRoutes.aboutUs),
    DrawerItem(title: 'Contact Us', route: AppRoutes.contactUs),
    DrawerItem(title: 'FAQ', route: AppRoutes.faq),
  ];
}
