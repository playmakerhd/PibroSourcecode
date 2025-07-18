import 'package:flutter/material.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/shared/item_row_container.dart';

class InfoContainer extends StatelessWidget {
  const InfoContainer({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ItemRowContainer(
      isLarge: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            title,
            style: Styles.regularTextStyle(),
          ),
          Text(
            value,
            style: Styles.boldTextStyle(size: 12),
          ),
        ],
      ),
    );
  }
}
