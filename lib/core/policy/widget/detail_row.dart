import 'package:flutter/material.dart';
import 'package:pibro/constants/app_styles.dart';

class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Styles.semiBoldTextStyle(size: 14),
          ),
          Text(
            value,
            style: Styles.semiBoldTextStyle(size: 14),
          ),
        ],
      ),
    );
  }
}
