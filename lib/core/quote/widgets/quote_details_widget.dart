import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pibro/core/quote/views/quote_items_screen.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/models/response/sales_quotation_response.dart';
import 'package:pibro/shared/item_row.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';

class QuoteDetailsWidget extends StatelessWidget {
  const QuoteDetailsWidget({super.key, required this.data});

  final SalesQuotationResponse data;

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
            value: data.invoiceNumber ?? 'N/A',
          ),
          ItemRow(
            title: AppStrings.insuranceClass.tr,
            value: data.businessClassID ?? 'N/A',
          ),
          ItemRow(
            title: AppStrings.product.tr,
            value: data.riskTypeID ?? 'Unknown',
          ),
          ItemRow(
            title: AppStrings.startDate.tr,
            value: _prettyDate(data.startDate ?? ''),
          ),
          ItemRow(
            title: AppStrings.endDate.tr,
            value: _prettyDate(data.endDate ?? ''),
          ),
          ItemRow(
            title: AppStrings.renewalDate.tr,
            value: _prettyDate(data.renewaldate ?? ''),
          ),
          ItemRow(
            title: AppStrings.sumInsured.tr,
            value: formatAmount(data.sumInsured ?? 0.0),
          ),
          ItemRow(
            title: 'Premium Due',
            value: formatAmount(data.premiumDue ?? 0.0),
          ),
          ItemRow(
            title: AppStrings.vendorInsurer.tr,
            value: data.vendorID ?? 'N/A',
          ),
          // Status with color: Completed -> green, Pending -> orange
          Builder(builder: (ctx) {
            final sessionValue = (data.session ?? '').trim().toUpperCase();
            final bool isCompleted = sessionValue == 'CLOSED';
            final statusText = isCompleted ? 'Completed' : 'Pending';
            final statusColor =
                isCompleted ? AppColors.activeGreen : Colors.orange;

            return ItemRow(
              title: AppStrings.status.tr,
              value: statusText,
              valueColor: statusColor,
            );
          }),
          ItemRow(
            title: AppStrings.itemInsured.tr,
            value: AppStrings.view.tr,
            onTap: () => Get.to(
              () => QuoteItemsScreen(itemsInsured: data.itemsToInsure ?? []),
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
