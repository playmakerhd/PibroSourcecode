import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';

class CustomExpansionTile extends StatelessWidget {
  const CustomExpansionTile(
      {super.key, required this.title, required this.details});

  final String title;
  final String details;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ExpansionTile(
        title: Text(
          title,
          style: Styles.regularTextStyle(
            size: 14,
          ),
        ),
        tilePadding: EdgeInsets.symmetric(horizontal: 10),
        childrenPadding: EdgeInsets.all(10),
        backgroundColor: AppColors.tileColor,
        collapsedBackgroundColor: AppColors.tileColor,
        trailing: Icon(
          Icons.arrow_drop_down,
          color: AppColors.tileIconColor,
          size: 50,
        ),
        collapsedShape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        visualDensity: VisualDensity(vertical: -2),
        children: [Text(details)],
      ),
    );
  }
}
