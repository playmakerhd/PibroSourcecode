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

class QuoteSummaryScreen extends StatelessWidget {
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
                   DetailRow(
                      title: 'Customer ID:', value: customerid),
                  DetailRow(
                      title: 'Customer Name:',
                      value: '${data['customerName'] ?? 'N/A'}'),
                  DetailRow(
                      title: 'Insurance Class:',
                      value: '${data['businessClassName'] ?? 'N/A'}'),
                  DetailRow(
                      title: 'Product:', value: '${data['riskName'] ?? 'N/A'}'),
                  DetailRow(
                      title: 'New Start Date:',
                      value: '${data['startDate'] ?? 'N/A'}'),
                  DetailRow(
                      title: 'New End Date:',
                      value: '${data['endDate'] ?? 'N/A'}'),
                  DetailRow(
                      title: 'New Renewal Date:',
                      value: '${data['renewalDate'] ?? 'N/A'}'),
                  DetailRow(
                      title: 'Sum Insured(NGN):',
                      value: '${data['sumInsured'] ?? 'N/A'}'),
                  DetailRow(
                      title: 'Premium Due(NGN):',
                      value: '${data['premium'] ?? 'N/A'}'),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PolicyButton(
                        text: 'Make Payment',
                        onPressed: () async {
                          final qp = Get.isRegistered<QuotePaymentController>()
                              ? Get.find<QuotePaymentController>()
                              : Get.put(QuotePaymentController());
                          await qp.beginPayment();
                        },
                        width: 160,
                        bgColor: AppColors.primaryColor,
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
