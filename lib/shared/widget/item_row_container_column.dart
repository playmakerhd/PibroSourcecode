import 'package:flutter/material.dart';
import 'package:pibro/constants/app_styles.dart';

class ItemRowContainerColumn extends StatelessWidget {
  const ItemRowContainerColumn({
    super.key,
    required this.id,
    required this.amount,
    required this.dates,
    required this.type,
    required this.status,
    required this.color,
  });

  final String id;
  final String amount;
  final String dates;
  final String type;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              id,
              style: Styles.boldTextStyle(
                size: 12,
              ),
            ),
            Text(
              amount,
              style: Styles.boldTextStyle(
                size: 12,
              ),
            ),
          ],
        ),
        Text(
          dates,
          style: Styles.regularTextStyle(
            size: 12,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              type,
              style: Styles.boldTextStyle(
                size: 12,
              ),
            ),
            Text(
              status,
              style: Styles.regularTextStyle(
                size: 12,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
