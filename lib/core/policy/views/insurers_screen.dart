import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/item_row_container.dart';
import 'package:pibro/shared/title_value_row.dart';

class InsurersScreen extends StatelessWidget {
  const InsurersScreen({super.key, required this.writers});

  final List<InsurancePolicyUnderwriter> writers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CommonHeader(
            title: AppStrings.insurer.tr,
          ),
          Expanded(
            child: writers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 80,
                        ),
                        Center(
                          child: Text(
                            AppStrings.noData.tr,
                            style: Styles.mediumTextStyle(),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: writers.length,
                    itemBuilder: (BuildContext context, int index) {
                      InsurancePolicyUnderwriter item = writers[index];
                      inspect(item);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ItemRowContainer(
                          isPolicyRenew: true,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TitleValueRow(
                                  title: '${AppStrings.name.tr}:',
                                  value: item.vendorName ?? '',
                                ),
                                TitleValueRow(
                                  title: '${AppStrings.apportionment.tr}:',
                                  value: 'N${item.apportionment!.toString()}',
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
