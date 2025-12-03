import 'package:flutter/material.dart';
import 'package:pibro/constants/app_styles.dart';

class ItemRowContainerColumn extends StatelessWidget {
  const ItemRowContainerColumn({
    super.key,
    required this.id,
    required this.amount,
    this.settlementAmount,
    required this.dates,
    required this.type,
    required this.status,
    required this.color,
  });

  final String id;
  final String amount;
  final String? settlementAmount;
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
            // Constrain the left text so it won't push the amount off-screen
            Expanded(
              child: Text(
                id,
                style: Styles.boldTextStyle(size: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Keep the amount visible but allow truncation if space is very tight
            Flexible(
              child: Text(
                amount,
                style: Styles.boldTextStyle(size: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                dates,
                style: Styles.regularTextStyle(
                  size: 12,
                ),
              ),
            ),
            Flexible(
              child: Text(
                settlementAmount != null ? '$settlementAmount' : '',
                style: Styles.boldTextStyle(size: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                type,
                style: Styles.boldTextStyle(
                  size: 12,
                ),
                overflow: TextOverflow.ellipsis,  
                maxLines: 1,
              ),
            ),
            Flexible(
              child: Text(
                status,
                style: Styles.regularTextStyle(
                  size: 12,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
