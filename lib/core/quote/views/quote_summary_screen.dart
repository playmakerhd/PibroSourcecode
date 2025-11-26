import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/quote/controller/quote_payment_controller.dart';
import 'package:pibro/core/quote/controller/quote_summary_controller.dart';
import 'package:pibro/core/policy/widget/detail_row.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/widget/large_line.dart';
import 'package:pibro/shared/widget/premium_demand_note_sheet.dart';
import 'package:intl/intl.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';

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

  double _parsePremium(dynamic premium) {
    if (premium == null) return 0.0;
    if (premium is num) return premium.toDouble();
    final sanitized = premium.toString().replaceAll(',', '').trim();
    return double.tryParse(sanitized) ?? 0.0;
  }

  double _calculateAppliedCharge(double premium) {
    if (premium <= 0) return 0.0;
    final usualCharge = premium * 0.015;
    final extraCharge = premium > 2500 ? usualCharge + 100 : usualCharge;
    return extraCharge > 2000 ? 2000 : extraCharge;
  }

  const QuoteSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final summaryController = Get.put(QuoteSummaryController());

    // Try to get data from arguments first, then fallback to storage
    final e = Get.arguments as Map? ?? {};
    final store = GetStorage();
    final enquiry = (store.read(StorageKeys.lastEnquiry) as Map?) ?? {};
    final customerId = summaryController.extractCustomerId();

    // Use arguments if available, otherwise use stored enquiry data
    final data = e.isNotEmpty ? e : enquiry;
    final premiumValue = _parsePremium(data['premium']);
    final appliedCharge =
        premiumValue > 0 ? _calculateAppliedCharge(premiumValue) : 0.0;
    final totalDue = premiumValue > 0 ? premiumValue + appliedCharge : 0.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final quotePaymentController = premiumValue > 0
        ? (Get.isRegistered<QuotePaymentController>()
            ? Get.find<QuotePaymentController>()
            : Get.put(QuotePaymentController()))
        : null;

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
                  DetailRow(title: 'Customer ID:', value: customerId),
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
                      value: formatAmount(premiumValue)),
                  if (premiumValue > 0) ...[
                    DetailRow(
                        title: 'Charges (NGN):',
                        value: formatAmount(appliedCharge)),
                    DetailRow(
                        title: 'Total Payment Due (NGN):',
                        value: formatAmount(totalDue)),
                  ],
                  const SizedBox(height: 28),
                  if (premiumValue > 0 && quotePaymentController != null)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Obx(() {
                              final isLoading =
                                  quotePaymentController.paymentLoading.value;
                              return PolicyButton(
                                text: 'Make Payment',
                                onPressed: isLoading
                                    ? () {}
                                    : () =>
                                        quotePaymentController.beginPayment(),
                                width: screenWidth * 0.4,
                                height: 44,
                                bgColor: AppColors.primaryColor,
                                loading: isLoading,
                              );
                            }),
                            PolicyButton(
                              text: 'Contest Payment',
                              onPressed: () =>
                                  summaryController.showContestModal(context),
                              width: screenWidth * 0.4,
                              height: 44,
                              bgColor: AppColors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            final quoteId =
                                summaryController.enquiry['quoteID'] as String?;
                            if (quoteId != null && quoteId.isNotEmpty) {
                              showPremiumDemandNoteSheet(
                                context: context,
                                fetchPdfBytes: summaryController
                                    .fetchPremiumDemandNoteBytes,
                                quoteID: quoteId,
                              );
                            } else {
                              showSnackbarMessage(
                                message: 'No quote ID available',
                                isSuccess: false,
                              );
                            }
                          },
                          child: Container(
                            height: 44,
                            width: screenWidth * 0.7,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.print,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Print Premium Demand Note',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        PolicyButton(
                          text: 'Cancel',
                          onPressed: () => Get.offNamed(AppRoutes.quoteList),
                          width: 120,
                          bgColor: AppColors.greyColor,
                        ),
                      ],
                    )
                  else
                    PolicyButton(
                      text: 'Cancel',
                      onPressed: () => Get.offAllNamed(AppRoutes.quoteList),
                      width: 120,
                      bgColor: AppColors.greyColor,
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
