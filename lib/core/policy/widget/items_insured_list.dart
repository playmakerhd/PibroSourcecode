import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';
import 'package:pibro/shared/item_row_container.dart';
import 'package:pibro/shared/title_value_row.dart';
import 'package:pibro/utils/app_utils.dart';

class ItemsInsuredList extends StatelessWidget {
  const ItemsInsuredList({
    super.key,
    required List<ItemToInsure>? list,
    required this.edit,
    this.delete,
    this.view,
  }) : list = list ?? const [];

  final List<ItemToInsure> list;
  final Function(ItemToInsure item) edit;
  final Function(ItemToInsure item)? delete;
  final Function(ItemToInsure item)? view;

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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitleValueRow(
                          title: '${AppStrings.description.tr}:',
                          value: item.itemsDescription ?? '-',
                        ),
                        const SizedBox(height: 6),
                        TitleValueRow(
                          title: '${AppStrings.sumInsured.tr}:',
                          value: (formatAmount(item.sumInsured ?? 0)).toString(),
                        ),
                        const SizedBox(height: 6),
                        TitleValueRow(
                          title: '${AppStrings.location.tr}:',
                          value: item.itemLocation ?? '-',
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 25,
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (view != null &&
                          (item.policyItems?.isNotEmpty ?? false)) ...[
                        GestureDetector(
                          onTap: () => view!(item),
                          child: const Icon(Icons.remove_red_eye, size: 20),
                        ),
                        const SizedBox(height: 12),
                      ],
                      GestureDetector(
                        onTap: () => edit(item),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                        ),
                      ),
                      if (delete != null) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => delete!(item),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                        )
                      ]
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
