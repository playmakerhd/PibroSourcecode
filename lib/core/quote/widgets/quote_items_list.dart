import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/core/policy/model/item_data.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/item_row_container.dart';
import 'package:pibro/shared/title_value_row.dart';

class QuoteItemsList extends StatelessWidget {
  const QuoteItemsList({
    super.key,
    required this.list,
    required this.edit,
    this.delete,
  });

  final List<ItemData> list;
  final Function(ItemData item) edit;
  final Function(ItemData item)? delete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: list
          .map(
            (item) => Row(
              children: [
                Expanded(
                  child: ItemRowContainer(
                    noHeight: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TitleValueRow(
                          title: '${AppStrings.description.tr}:',
                          value: item.description!,
                        ),
                        TitleValueRow(
                          title: '${AppStrings.sumInsured.tr}:',
                          value: item.value!,
                        ),
                        TitleValueRow(
                          title: '${AppStrings.location.tr}:',
                          value: item.location!,
                        ),
                        if (item.regNo != null)
                          TitleValueRow(
                            title: '${AppStrings.regNo.tr}:',
                            value: item.regNo!,
                          ),
                        if (item.chasisId != null)
                          TitleValueRow(
                            title: '${AppStrings.chasisId.tr}:',
                            value: item.chasisId!,
                          ),
                        if (item.engineNo != null)
                          TitleValueRow(
                            title: '${AppStrings.engineNo.tr}:',
                            value: item.engineNo!,
                          ),
                        if (item.vehicleMake != null)
                          TitleValueRow(
                            title: '${AppStrings.vehicleMake.tr}:',
                            value: item.vehicleMake!,
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 25,
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Column(
                    spacing: 15,
                    children: [
                      GestureDetector(
                        onTap: () => edit(item),
                        child: Icon(
                          Icons.edit,
                          size: 20,
                        ),
                      ),
                      if (delete != null)
                        GestureDetector(
                          onTap: () => delete!(item),
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                        )
                    ],
                  ),
                )
              ],
            ),
          )
          .toList(),
    );
  }
}
