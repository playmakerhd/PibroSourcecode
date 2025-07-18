import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pibro/constants/app_colors.dart';

class LinkIcon extends StatelessWidget {
  const LinkIcon({super.key, required this.icon, required this.onTap});

  final Function() onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GestureDetector(
        onTap: onTap,
        child: FaIcon(
          icon,
          size: 30,
          color: AppColors.green,
        ),
      ),
    );
  }
}
