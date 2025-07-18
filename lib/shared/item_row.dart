import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/shared/item_row_container.dart';
import 'package:pibro/shared/title_value_row.dart';

class ItemRow extends StatelessWidget {
  const ItemRow({
    super.key,
    required this.title,
    required this.value,
    this.valueColor = AppColors.primaryColor,
    this.onTap,
  });

  final String title;
  final String value;
  final Color valueColor;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ItemRowContainer(
      child: TitleValueRow(
        title: title,
        value: value,
        valueColor: valueColor,
        onTap: onTap,
      ),
    );
  }
}
