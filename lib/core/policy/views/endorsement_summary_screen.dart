import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/policy/controller/endorsement_controller.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/core/policy/widget/detail_row.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/widget/premium_demand_note_sheet.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/profile/widget/profile_button.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/utils/image_factory.dart';

class EndorsementSummaryScreen extends StatelessWidget {
  const EndorsementSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EndorsementController c = Get.find();
    final args = Get.arguments as Map?;
    final DateTime start = args?['startDate'] ?? c.startDate.value!;
    final DateTime end = args?['endDate'] ?? c.endDate.value!;
    final double addPrem =
        (args?['additionalPremium'] ?? c.additionalPremium.value).toDouble();

    final DateTime oldEnd =
        DateTime.tryParse(c.policy.value?.policyEndDate ?? '') ?? end;
    final DateTime oldRenew = oldEnd.add(const Duration(days: 1));
    final double oldSumInsured = (c.policy.value?.sumInsured ?? 0).toDouble();
    final double oldPremium = (c.policy.value?.premiumAmount ?? 0).toDouble();

    double sumItems(dynamic items) {
      if (items == null) return 0.0;
      double s = 0.0;
      if (items is List) {
        for (var it in items) {
          if (it == null) continue;
          try {
            if (it is Map) {
              s += (it['sumInsured'] as num?)?.toDouble() ?? 0.0;
            } else {
              s += (it.sumInsured ?? 0).toDouble();
            }
          } catch (_) {}
        }
      }
      return s;
    }

    final double updatedSumInsured =
        sumItems(args?['items']) > 0 ? sumItems(args?['items']) : oldSumInsured;
    final double updatedPremium = (oldPremium + addPrem);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CommonHeader(title: 'Endorsement Summary'),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: queryWidth(context) * 0.05, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(
                    title: 'Policy Number:',
                    value: c.policy.value?.policyBrokerID ?? '-',
                  ),
                  //const SizedBox(height: 8),
                  DetailRow(
                    title: 'Insurance Class:',
                    value: c.policy.value?.businessClassID ?? '-',
                  ),
                  //const SizedBox(height: 8),
                  DetailRow(
                    title: 'Product:',
                    value: c.policy.value?.riskTypeID ?? '-',
                  ),
                  //const SizedBox(height: 8),
                  DetailRow(
                    title: 'Start Date:',
                    value: formatDate(start.toIso8601String()),
                  ),
                  //const SizedBox(height: 8),
                  DetailRow(
                    title: 'Old End Date:',
                    value: formatDate(oldEnd.toIso8601String()),
                  ),
                  // const SizedBox(height: 8),
                  DetailRow(
                    title: 'Old Renewal Date:',
                    value: formatDate(oldRenew.toIso8601String()),
                  ),
                  //const SizedBox(height: 8),
                  DetailRow(
                    title: 'Old Sum Insured(NGN):',
                    value: formatAmount(oldSumInsured),
                  ),
                  // const SizedBox(height: 8),
                  DetailRow(
                    title: 'Old Premium(NGN):',
                    value: formatAmount(oldPremium),
                  ),
                  const SizedBox(height: 16),
                  Container(
                      height: 6,
                      width: double.infinity,
                      color: AppColors.primaryColor),
                  //  const SizedBox(height: 16),
                  DetailRow(
                    title: 'Updated End Date:',
                    value: formatDate(end.toIso8601String()),
                  ),
                  // const SizedBox(height: 8),
                  DetailRow(
                    title: 'Updated Renewal Date:',
                    value: formatDate(
                        end.add(const Duration(days: 1)).toIso8601String()),
                  ),
                  // const SizedBox(height: 8),
                  DetailRow(
                    title: 'Updated Sum Insured(NGN):',
                    value: formatAmount(updatedSumInsured),
                  ),
                  // const SizedBox(height: 8),
                  DetailRow(
                    title: 'Updated Premium(NGN):',
                    value: formatAmount(updatedPremium),
                  ),
                  // const SizedBox(height: 8),
                  DetailRow(
                    title: 'Premium Adjustment Due(NGN):',
                    value: formatAmount(addPrem),
                  ),
                  // If there's an additional premium to pay, show gateway charges and total due
                  if (addPrem > 0)
                    Builder(builder: (context) {
                      final double premium = addPrem;
                      final double usualCharge = premium * 0.015;
                      final double extraCharge =
                          (premium > 2500 ? (usualCharge + 100) : usualCharge);
                      final double appliedCharge =
                          (extraCharge > 2000 ? 2000 : extraCharge);
                      final double totalDue = premium + appliedCharge;
                      return Column(
                        children: [
                          DetailRow(
                            title: 'Charges (NGN):',
                            value: formatAmount(appliedCharge),
                          ),
                          DetailRow(
                            title: 'Total Payment Due (NGN):',
                            value: formatAmount(totalDue),
                          ),
                        ],
                      );
                    }),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      // increased width so the two buttons in the row have more room
                      width: queryWidth(context) * 0.9,
                      child: addPrem == 0.0
                          ? Obx(() => PolicyButton(
                                text: c.sendToBrokerLoading.value
                                    ? 'Please wait...'
                                    : 'Send for Approval',
                                onPressed: c.sendToBrokerLoading.value
                                    ? () {}
                                    : () async {
                                        final ok =
                                            await c.sendEndorsementToBroker();
                                        if (ok) {
                                          showAppDialog(
                                            dismissible: false,
                                            willPop: false,
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  ImageFactory.getImage(
                                                          AppImages
                                                              .passwordSuccess)
                                                      .render(
                                                          height: 65,
                                                          width: 65),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        'Endorsement',
                                                        style: Styles
                                                            .semiBoldTextStyle(
                                                                color: AppColors
                                                                    .white),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        'Endorsement request sent to broker for approval',
                                                        style: Styles
                                                            .mediumTextStyle(
                                                                size: 12,
                                                                color: AppColors
                                                                    .white),
                                                      ),
                                                    ],
                                                  ),
                                                  GestureDetector(
                                                    onTap: () =>
                                                        Get.offAllNamed(
                                                            AppRoutes.main),
                                                    child: ProfileButton(
                                                      text: AppStrings.ok.tr,
                                                      height: 25,
                                                      width: 80,
                                                      textColor:
                                                          AppColors.activeGreen,
                                                      bgColor: AppColors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                height: 44,
                                bgColor: AppColors.primaryColor,
                                isExpanded: false,
                              ))
                          : Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Obx(() => Expanded(
                                          child: PolicyButton(
                                            text: 'Pay Additional Premium',
                                            loading: c.paymentLoading.value,
                                            onPressed: c.paymentLoading.value
                                                ? () {}
                                                : () =>
                                                    c.getPaymentTokenAndInit(
                                                        addPrem),
                                            height: 44,
                                            width: queryWidth(context) * 0.40,
                                            bgColor: AppColors.primaryColor,
                                            isExpanded: false,
                                          ),
                                        )),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: PolicyButton(
                                        text: 'Contest Payment',
                                        onPressed: c.showContestModal,
                                        height: 44,
                                        width: queryWidth(context) * 0.40,
                                        bgColor: AppColors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {
                                    final quoteID = c.quoteNumber;
                                    if (quoteID != null && quoteID.isNotEmpty) {
                                      showPremiumDemandNoteSheet(
                                        context: context,
                                        fetchPdfBytes:
                                            c.fetchPremiumDemandNoteBytes,
                                        quoteID: quoteID,
                                      );
                                    } else {
                                      showSnackbarMessage(
                                        message:
                                            'No quote number available for premium demand note',
                                        isSuccess: false,
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 50,
                                    // match the row width increase so the print button is wider
                                    width: queryWidth(context) * 0.7,
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
                                          Flexible(
                                            child: Text(
                                              'Print Premium Demand Note',
                                              style: TextStyle(
                                                color: AppColors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
