import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';
import 'package:pibro/shared/item_row_container.dart';
import 'package:pibro/shared/title_value_row.dart';

class ItemsInsuredList extends StatelessWidget {
  const ItemsInsuredList({
    super.key,
    required this.list,
    required this.edit,
    this.delete,
  });

  final List<ItemToInsure> list;
  final Function(ItemToInsure item) edit;
  final Function(ItemToInsure item)? delete;

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
                          value: item.itemsDescription!,
                        ),
                        TitleValueRow(
                          title: '${AppStrings.sumInsured.tr}:',
                          value: item.sumInsured.toString(),
                        ),
                        TitleValueRow(
                          title: '${AppStrings.location.tr}:',
                          value: item.itemLocation!,
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
