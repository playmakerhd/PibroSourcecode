import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/policy/controller/renew_policy_controller.dart';
import 'package:pibro/core/policy/widget/detail_row.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/core/quote/controller/quote_confirmation_controller.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/widget/large_line.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:screenshot/screenshot.dart';

class QuoteConfirmationScreen extends StatelessWidget {
  // Helper to format date strings to 'MMM dd, yyyy'
  String formatDatePretty(String dateStr) {
    if (dateStr.isEmpty) return '';
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

  const QuoteConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure RenewPolicyController is available for Print (screenshot → PDF)
    final renew = Get.isRegistered<RenewPolicyController>()
        ? Get.find<RenewPolicyController>()
        : Get.put(RenewPolicyController());

    Get.put(QuoteConfirmationController());
    //final e = c.quoteData;

    final store = GetStorage();
    final args = (Get.arguments as Map?) ?? {};

    final String overrideStart = (args['newStartDate'] ?? '').toString();
    final String overrideEnd = (args['newEndDate'] ?? '').toString();
    final String overrideRenew = (args['newRenewalDate'] ?? '').toString();

    // Already present:
    final enquiry = (store.read(StorageKeys.lastEnquiry) as Map?) ?? {};

    // If we have a policyId or payment fields, render as Policy Confirmation
    final String policyId = (args['policyId'] ?? '').toString();
    final String paymentRef = (args['paymentReference'] ?? '').toString();
    final String paymentDate = (args['paymentDate'] ?? '').toString();
    final String paymentMethod = (args['paymentMethod'] ?? 'Card').toString();
    final String paymentAmountStr = (args['paymentAmount'] ?? '').toString();

    final bool isPolicyMode = policyId.isNotEmpty ||
        paymentRef.isNotEmpty ||
        paymentAmountStr.isNotEmpty;

    String formatPaymentDate(String dateString) {
      if (dateString.isEmpty) return '';
      try {
        final date = DateTime.parse(dateString);
        return DateFormat('MMM dd, yyyy').format(date);
      } catch (e) {
        return dateString; // Return original if parsing fails
      }
    }

    final String businessClass =
        (enquiry['businessClassName'] ?? '').toString();
    final String product = (enquiry['riskName'] ?? '').toString();

    // Stored by quote flow as pretty strings; by renew we pass ISO strings.
    // Prefer overrides (if any), otherwise use stored strings.
    final String startDate = overrideStart.isNotEmpty
        ? formatDatePretty(overrideStart)
        : formatDatePretty((enquiry['startDate'] ?? '').toString());

    final String endDate = overrideEnd.isNotEmpty
        ? formatDatePretty(overrideEnd)
        : formatDatePretty((enquiry['endDate'] ?? '').toString());

    final String renewalDate = overrideRenew.isNotEmpty
        ? formatDatePretty(overrideRenew)
        : formatDatePretty((enquiry['renewalDate'] ?? '').toString());

    final double sumInsured = double.tryParse(
          '${enquiry['sumInsured'] ?? 0}'.toString().replaceAll(',', ''),
        ) ??
        0.0;
    final double premium = double.tryParse(
          '${enquiry['premium'] ?? paymentAmountStr}'
              .toString()
              .replaceAll(',', ''),
        ) ??
        0.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Screenshot(
        controller: renew.screenshotController,
        child: Column(
          children: [
            CommonHeader(
              title:
                  isPolicyMode ? 'Policy Confirmation' : 'Quote Confirmation',
              isTransparent: true,
            ),
            const LargeLine(height: 0),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Icon(
                      Icons.check_circle,
                      color:
                          isPolicyMode ? AppColors.activeGreen : Colors.green,
                      size: 64,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isPolicyMode
                          ? (policyId.isNotEmpty
                              ? 'Your Policy $policyId has been successfully created and is now active.'
                              : 'Your Policy has been successfully created and is now active.')
                          : 'Your quote has been successfully sent to the broker for Approval.',
                      style: Styles.mediumTextStyle(
                          size: 14, color: AppColors.primaryColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isPolicyMode
                          ? 'Find below the details of the Policy:'
                          : 'Find below the details of the Quote:',
                      style: Styles.boldTextStyle(size: 14),
                    ),
                    const Divider(
                        height: 32,
                        thickness: 3,
                        color: AppColors.primaryColor),

                    if (isPolicyMode && policyId.isNotEmpty)
                      DetailRow(title: 'Policy Number:', value: policyId),

                    DetailRow(title: 'Insurance Class:', value: businessClass),
                    DetailRow(title: 'Product:', value: product),
                    DetailRow(
                        title: 'New Start Date:',
                        value: formatDatePretty(startDate)),
                    DetailRow(
                        title: 'New End Date:',
                        value: formatDatePretty(endDate)),
                    DetailRow(
                        title: 'New Renewal Date:',
                        value: formatDatePretty(renewalDate)),
                    DetailRow(
                      title: 'Sum Insured (NGN):',
                      value: formatAmount(sumInsured),
                    ),
                    DetailRow(
                      title: 'Premium Due (NGN):',
                      value: formatAmount(premium),
                    ),

                    // Show payment specifics only in Policy mode
                    if (isPolicyMode && paymentDate.isNotEmpty)
                      DetailRow(
                          title: 'Payment Date:',
                          value: formatPaymentDate(paymentDate)),
                    if (isPolicyMode && paymentRef.isNotEmpty)
                      DetailRow(title: 'Payment Reference:', value: paymentRef),
                    if (isPolicyMode && paymentMethod.isNotEmpty)
                      DetailRow(title: 'Payment Method:', value: paymentMethod),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PolicyButton(
                          text: 'OK',
                          onPressed: () {
                            // Navigate to the main route. It will handle routing for
                            // both logged-in users (to dashboard) and guests (to landing).
                            Get.offAllNamed(AppRoutes.main);
                          },
                          width: 120,
                          bgColor: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 16),
                        PolicyButton(
                          text: 'Print',
                          onPressed:
                              renew.savePageAsPdf, // 🔗 wired to PDF export
                          width: 120,
                          bgColor: AppColors.primaryColor,
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
      ),
    );
  }
}
