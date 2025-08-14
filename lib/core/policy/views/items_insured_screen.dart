import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/empty_data.dart';
import 'package:pibro/shared/item_row_container.dart';
import 'package:pibro/shared/title_value_row.dart';

class ItemsInsuredScreen extends StatelessWidget {
  const ItemsInsuredScreen({super.key, required this.itemsInsured});

  final List<ItemToInsure> itemsInsured;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CommonHeader(
            title: AppStrings.itemInsured.tr,
          ),
          Expanded(
            child: itemsInsured.isEmpty
                ? EmptyData()
                : ListView.builder(
                    itemCount: itemsInsured.length,
                    itemBuilder: (BuildContext context, int index) {
                      ItemToInsure item = itemsInsured[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ItemRowContainer(
                          isPolicy: item.policyItems != null,
                          isPolicyRenew: item.policyItems == null,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TitleValueRow(
                                  title: '${AppStrings.description.tr}:',
                                  value: item.itemsDescription!,
                                ),
                                TitleValueRow(
                                  title: '${AppStrings.location.tr}:',
                                  value: item.itemLocation!,
                                ),
                                TitleValueRow(
                                  title: '${AppStrings.value.tr}:',
                                  value: 'N${item.sumInsured.toString()}',
                                ),
                                if (item.policyItems != null)
                                  Image.memory(
                                    base64Decode(item.policyItems!),
                                    height: 100,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
          )
        ],
      ),
    );
  }
}
