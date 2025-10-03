import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/quote/controller/quote_payment_controller.dart';
import 'package:pibro/core/quote/controller/quote_summary_controller.dart';
import 'package:pibro/core/policy/widget/detail_row.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/widget/large_line.dart';
import 'package:intl/intl.dart';
import 'package:pibro/utils/app_utils.dart';

class QuoteSummaryScreen extends StatelessWidget {
  // Helper to format date strings to 'MMM dd, yyyy'
  String formatDatePretty(String dateStr) {
    if (dateStr.isEmpty || dateStr == 'N/A') return dateStr;
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt != null) {
        return DateFormat('MMM dd, yyyy').format(dt);
      }
      // Try parsing pretty formats if needed
      try {
        return DateFormat('MMM d, y')
            .format(DateFormat('MMM d, y').parse(dateStr));
      } catch (_) {}
      try {
        return DateFormat('MMM dd, yyyy')
            .format(DateFormat('MMM dd, yyyy').parse(dateStr));
      } catch (_) {}
      try {
        return DateFormat('MM-dd-yyyy')
            .format(DateFormat('MM-dd-yyyy').parse(dateStr));
      } catch (_) {}
    } catch (_) {}
    return dateStr;
  }

  const QuoteSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(QuoteSummaryController());

    // Try to get data from arguments first, then fallback to storage
    final e = Get.arguments as Map? ?? {};
    final store = GetStorage();
    final enquiry = (store.read(StorageKeys.lastEnquiry) as Map?) ?? {};
    final customerid = c.extractCustomerId();

    // Use arguments if available, otherwise use stored enquiry data
    final data = e.isNotEmpty ? e : enquiry;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(title: 'Quote Summary', isTransparent: true),
          const LargeLine(height: 0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
              child: ListView(
                children: [
                  DetailRow(title: 'Customer ID:', value: customerid),
                  // DetailRow(
                  //     title: 'Customer Name:',
                  //     value: '${data['customerName'] ?? 'N/A'}'),
                  DetailRow(
                      title: 'Insurance Class:',
                      value: '${data['businessClassName'] ?? 'N/A'}'),
                  DetailRow(
                      title: 'Product:', value: '${data['riskName'] ?? 'N/A'}'),
                  DetailRow(
                      title: 'New Start Date:',
                      value: formatDatePretty('${data['startDate'] ?? 'N/A'}')),
                  DetailRow(
                      title: 'New End Date:',
                      value: formatDatePretty('${data['endDate'] ?? 'N/A'}')),
                  DetailRow(
                      title: 'New Renewal Date:',
                      value:
                          formatDatePretty('${data['renewalDate'] ?? 'N/A'}')),
                  DetailRow(
                      title: 'Sum Insured(NGN):',
                      value: formatAmount(data['sumInsured'])),
                  DetailRow(
                      title: 'Premium Due(NGN):',
                      value: formatAmount(data['premium'])),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GetBuilder<QuotePaymentController>(
                        init: Get.isRegistered<QuotePaymentController>()
                            ? Get.find<QuotePaymentController>()
                            : Get.put(QuotePaymentController()),
                        builder: (qp) => Obx(() => PolicyButton(
                              text: 'Make Payment',
                              onPressed: () {
                                if (!qp.paymentLoading.value) {
                                  qp.paymentLoading.value = true;
                                  qp.beginPayment();
                                }
                              },
                              width: 160,
                              bgColor: AppColors.primaryColor,
                              loading: qp.paymentLoading.value,
                            )),
                      ),
                      const SizedBox(width: 12),
                      PolicyButton(
                        text: 'Cancel',
                        onPressed: () => Get.back(),
                        width: 120,
                        bgColor: AppColors.greyColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
