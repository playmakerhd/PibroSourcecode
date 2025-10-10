import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/policy/controller/renew_policy_controller.dart';
import 'package:pibro/core/home/controller/home_controller.dart';
import 'package:pibro/core/policy/widget/detail_row.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:screenshot/screenshot.dart';

class PolicyConfirmationScreen extends StatelessWidget {
  const PolicyConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final renew = Get.find<RenewPolicyController>();
    final args = (Get.arguments as Map?) ?? {};
    final store = GetStorage();

    // Values from arguments (quote flow → passed after posting policy/debit)
    final String policyId = (args['policyId'] ?? '').toString();
    final String paymentRef = (args['paymentReference'] ?? '').toString();
    final String paymentDate = (args['paymentDate'] ?? '').toString();
    final String paymentMethod = (args['paymentMethod'] ?? 'Card').toString();
    final String paymentAmountStr = (args['paymentAmount'] ?? '').toString();

    // Fallbacks from the enquiry we persisted earlier
    final Map<String, dynamic> enquiry = Map<String, dynamic>.from(
        (store.read(StorageKeys.lastEnquiry) as Map?) ?? {});
    final String businessClass =
        (enquiry['businessClassName'] ?? '').toString();
    final String product = (enquiry['riskName'] ?? '').toString();
    final String startDate = (enquiry['startDate'] ?? '').toString();
    final String endDate = (enquiry['endDate'] ?? '').toString();
    final String renewalDate = (enquiry['renewalDate'] ?? '').toString();

    // Sum insured & premium – format nicely
    final double sumInsured = double.tryParse(
            '${enquiry['sumInsured'] ?? 0}'.toString().replaceAll(',', '')) ??
        0.0;
    final double premium = double.tryParse(
            '${enquiry['premium'] ?? paymentAmountStr}'
                .toString()
                .replaceAll(',', '')) ??
        0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Screenshot(
        controller: renew.screenshotController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonHeader(
              title: 'Policy Confirmation',
              isTransparent: true,
              onBackPressed: () {
                Get.offAllNamed(AppRoutes.main);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: queryWidth(context) * 0.05,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        // Top blue divider
                        Container(
                          height: 6,
                          margin: const EdgeInsets.only(bottom: 10),
                          color: AppColors.primaryColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Icon(
                            Icons.check_circle,
                            size: 60,
                            color: AppColors.activeGreen,
                          ),
                        ),
                        Text(
                          'Congratulations',
                          style: Styles.semiBoldTextStyle(
                            color: AppColors.activeGreen,
                            size: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          policyId.isNotEmpty
                              ? 'Your Policy $policyId has been successfully created and is now active.'
                              : 'Your Policy has been successfully created and is now active.',
                          textAlign: TextAlign.center,
                          style: Styles.mediumTextStyle(
                            size: 12,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Find below the details of the Policy:',
                          textAlign: TextAlign.center,
                          style: Styles.semiBoldTextStyle(
                            color: AppColors.primaryColor,
                            size: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Middle divider
                        Container(
                          height: 4,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        if (policyId.isNotEmpty)
                          DetailRow(title: 'Policy Number:', value: policyId),
                        DetailRow(
                            title: 'Insurance Class:', value: businessClass),
                        DetailRow(title: 'Product:', value: product),
                        DetailRow(title: 'New Start Date:', value: startDate),
                        DetailRow(title: 'New End Date:', value: endDate),
                        DetailRow(
                            title: 'New Renewal Date:', value: renewalDate),
                        DetailRow(
                          title: 'Sum Insured(NGN):',
                          value: formatAmount(sumInsured),
                        ),
                        DetailRow(
                          title: 'Premium Due(NGN):',
                          value: formatAmount(premium),
                        ),
                        if (paymentDate.isNotEmpty)
                          DetailRow(title: 'Payment Date:', value: paymentDate),
                        if (paymentRef.isNotEmpty)
                          DetailRow(
                              title: 'Payment Reference:', value: paymentRef),
                        if (paymentMethod.isNotEmpty)
                          DetailRow(
                              title: 'Payment Method:', value: paymentMethod),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PolicyButton(
                              text: 'OK',
                              onPressed: () async {
                                // if (Get.isRegistered<HomeController>()) {
                                //   try {
                                //     final HomeController home =
                                //         Get.find<HomeController>();
                                //     await home.getProfile();
                                //   } catch (e) {
                                //     try {
                                //       Get.delete<HomeController>(force: true);
                                //     } catch (_) {}
                                //   }
                                // }
                                Get.offAllNamed(AppRoutes.main);
                              },
                              height: 50,
                              width: 100,
                              bgColor: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 16),
                            PolicyButton(
                              text: 'Print',
                              onPressed: renew.savePageAsPdf,
                              height: 50,
                              width: 100,
                              bgColor: AppColors.primaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
