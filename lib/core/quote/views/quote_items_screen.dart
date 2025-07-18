import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/models/response/quotes_response.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/item_row_container.dart';
import 'package:pibro/shared/title_value_row.dart';
import 'package:pibro/utils/api_utils.dart';

class QuoteItemsScreen extends StatelessWidget {
  const QuoteItemsScreen({super.key, required this.itemsInsured});

  final List<RequestDetails> itemsInsured;

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
                    itemCount: itemsInsured.length,
                    itemBuilder: (BuildContext context, int index) {
                      RequestDetails item = itemsInsured[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ItemRowContainer(
                          isPolicy: item.screenShotURL != null,
                          isPolicyRenew: item.screenShotURL == null,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TitleValueRow(
                                  title: '${AppStrings.description.tr}:',
                                  value: getQuoteItemsData(item)[2],
                                ),
                                TitleValueRow(
                                  title: '${AppStrings.location.tr}:',
                                  value: getQuoteItemsData(item)[1],
                                ),
                                TitleValueRow(
                                  title: '${AppStrings.value.tr}:',
                                  value: getQuoteItemsData(item)[0],
                                ),
                                if (item.screenShotURL != null)
                                  Image.memory(
                                    base64Decode(AppConstants.base64),
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
