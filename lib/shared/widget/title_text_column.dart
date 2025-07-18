import 'package:flutter/material.dart';
import 'package:pibro/constants/app_styles.dart';

class TitleTextColumn extends StatelessWidget {
  const TitleTextColumn({super.key, required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Styles.boldTextStyle(size: 14),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: Styles.regularTextStyle(size: 14),
          ),
        ],
      ),
    );
  }
}
