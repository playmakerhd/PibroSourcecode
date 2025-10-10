import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/home/controller/home_controller.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/core/policy/widget/detail_row.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pibro/core/policy/controller/endorsement_controller.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';

class EndorsementConfirmationScreen extends StatelessWidget {
  const EndorsementConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map? ?? {};
    final policyId = (args['policyId'] ?? '').toString();
    final ref = (args['paymentReference'] ?? '').toString();
    final date = (args['paymentDate'] ?? '').toString();
    // payment amount can be retrieved via args['paymentAmount'] if needed

    final EndorsementController c = Get.put(EndorsementController());

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Screenshot(
          controller: c.screenshotController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonHeader(
                hasBackIcon: false,
                title: 'Endorsement Confirmation',
                // isTransparent: true,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: queryWidth(context) * 0.05,
                ),
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Icon(
                          Icons.check_circle,
                          size: 60,
                          color: AppColors.activeGreen,
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: 'Congratulations ',
                          style: Styles.boldTextStyle(
                            size: 14,
                            color: AppColors.activeGreen,
                          ),
                          children: [
                            TextSpan(
                              text: '',
                              style: Styles.boldTextStyle(size: 14),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text.rich(
                          TextSpan(
                            text:
                                'Your payment has been successfully processed and your policy ',
                            style: Styles.semiBoldTextStyle(size: 14),
                            children: [
                              TextSpan(
                                text: policyId.isNotEmpty ? policyId : '',
                                style: Styles.boldTextStyle(size: 14),
                              ),
                              TextSpan(
                                text: ' has been endorsed.',
                                style: Styles.semiBoldTextStyle(size: 14),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Find below the details of the transaction:',
                        style: Styles.semiBoldTextStyle(size: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Divider(
                  color: AppColors.primaryColor,
                  thickness: 5,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: queryWidth(context) * 0.05),
                child: Column(
                  children: [
                    DetailRow(
                        title: 'Policy Number:',
                        value: policyId.isNotEmpty
                            ? policyId
                            : (c.policy.value?.policyBrokerID ?? '')),
                    DetailRow(
                        title: 'Insurance Class:',
                        value: args['insuranceClass']?.toString() ??
                            (c.policy.value?.businessClassID ?? '')),
                    DetailRow(
                        title: 'Product:',
                        value: args['product']?.toString() ??
                            (c.policy.value?.riskTypeID ?? '')),
                    DetailRow(
                        title: 'Start Date:',
                        value: args['startDate'] != null
                            ? formatDate(args['startDate'].toString())
                            : (c.startDate.value != null
                                ? formatDate(
                                    c.startDate.value!.toIso8601String())
                                : '')),
                    DetailRow(
                        title: 'Updated End Date:',
                        value: args['endDate'] != null
                            ? formatDate(args['endDate'].toString())
                            : (c.endDate.value != null
                                ? formatDate(c.endDate.value!.toIso8601String())
                                : '')),
                    DetailRow(
                        title: 'Updated Renewal Date:',
                        value: args['renewalDate'] != null
                            ? formatDate(args['renewalDate'].toString())
                            : (c.endDate.value != null
                                ? formatDate(c.endDate.value!
                                    .add(const Duration(days: 1))
                                    .toIso8601String())
                                : '')),
                    Builder(builder: (context) {
                      final sumStr = args['sumInsured']?.toString();
                      final sum = double.tryParse(sumStr ?? '') ??
                          (c.policy.value?.sumInsured ?? 0.0);
                      return DetailRow(
                          title: 'Updated Sum Insured(NGN):',
                          value: formatAmount(sum));
                    }),
                    Builder(builder: (context) {
                      final adjStr = (args['additionalPremium'] ??
                              args['premiumDue'] ??
                              args['premiumAdjustment'])
                          ?.toString();
                      final adj = double.tryParse(adjStr ?? '') ??
                          c.additionalPremium.value;
                      return DetailRow(
                          title: 'Premium Adjustment(NGN):',
                          value: formatAmount(adj));
                    }),
                    if (date.isNotEmpty)
                      DetailRow(
                          title: 'Payment Date:', value: formatDate(date)),
                    if (ref.isNotEmpty)
                      DetailRow(title: 'Payment Reference:', value: ref),
                    DetailRow(
                        title: 'Payment Method:',
                        value: args['paymentMethod']?.toString() ?? 'Card'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PolicyButton(
                      text: 'OK',
                      onPressed: () {
                        // if (Get.isRegistered<HomeController>()) {
                        //   try {
                        //     Get.delete<HomeController>();
                        //   } catch (_) {}
                        // }
                        Get.offAllNamed(AppRoutes.main);
                      },
                      height: 44,
                      width: 100,
                      bgColor: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 16),
                    PolicyButton(
                      text: 'Print',
                      onPressed: c.savePageAsPdf,
                      height: 44,
                      width: 100,
                      bgColor: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
