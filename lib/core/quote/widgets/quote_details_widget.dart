import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pibro/core/quote/views/quote_items_screen.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/models/response/quotes_response.dart';
import 'package:pibro/network/models/response/quote_info_extensions.dart';
import 'package:pibro/shared/item_row.dart';
import 'package:pibro/utils/api_utils.dart';
import 'package:pibro/utils/view_utils.dart';

class QuoteDetailsWidget extends StatelessWidget {
  const QuoteDetailsWidget({super.key, required this.data});

  final QuoteInfo data;

  String _prettyDate(String s) {
    if (s.isEmpty) return '';
    final iso = DateTime.tryParse(s);
    if (iso != null) return DateFormat('MMM dd, yyyy').format(iso);

    // Try a few common server/user formats
    for (final fmt in const [
      'MMM d, y',
      'MMM dd, yyyy',
      'yyyy-MM-dd',
      'dd/MM/yyyy',
      'd/M/yyyy',
    ]) {
      try {
        return DateFormat('MMM dd, yyyy').format(DateFormat(fmt).parse(s));
      } catch (_) {}
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        children: [
          ItemRow(
            title: AppStrings.quoteId.tr,
            value: data.caseId!,
          ),
          ItemRow(
            title: AppStrings.insuranceClass.tr,
            value: getQuoteClass(data),
          ),
          ItemRow(
            title: AppStrings.product.tr,
            value: data.productId!,
          ),
          ItemRow(
            title: AppStrings.startDate.tr,
            value: _prettyDate(data.startDateRaw),
          ),
          ItemRow(
            title: AppStrings.endDate.tr,
            value: _prettyDate(data.endDateRaw),
          ),
          ItemRow(
            title: AppStrings.renewalDate.tr,
            value: _prettyDate(data.renewalDateRaw),
          ),
          ItemRow(
            title: AppStrings.sumInsured.tr,
            value: getQuoteSum(data).toString(),
          ),
          ItemRow(
            title: AppStrings.status.tr,
            // To Do: Color and Status
            value: data.supportStatus ?? '',
            valueColor: Colors.orange,
          ),
          ItemRow(
            title: AppStrings.itemInsured.tr,
            value: AppStrings.view.tr,
            onTap: () => Get.to(
              () => QuoteItemsScreen(itemsInsured: data.requestDetails!),
            ),
          ),
          // ItemRow(
          //   title: AppStrings.insurer.tr,
          //   value: AppStrings.view.tr,
          //   onTap: () => Get.to(
          //     () => InsurersScreen(
          //       writers: data.insurancePolicyUnderwriters!,
          //     ),
          //   ),
          // ),
          SizedBox(
            height: queryHeight(context) * 0.1,
          )
        ],
      ),
    );
  }
}
