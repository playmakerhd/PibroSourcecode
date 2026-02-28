import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/claim/controller/lodge_claim_controller.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/item_row_container.dart';
import 'package:pibro/shared/title_value_row.dart';
import 'package:pibro/utils/app_utils.dart';

class InsurersTab extends StatelessWidget {
  const InsurersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final LodgeClaimController controller = Get.put(LodgeClaimController());
    return Column(
      children: [
        controller.selectedClaim.value == null ||
                controller
                    .selectedClaim.value!.insurancePolicyUnderwriters!.isEmpty
            ? Center(
                child: Text(
                  AppStrings.noData.tr,
                  style: Styles.mediumTextStyle(size: 18),
                ),
              )
            : SizedBox(
                height: controller.selectedClaim.value!
                        .insurancePolicyUnderwriters!.length *
                    194,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller
                      .selectedClaim.value!.insurancePolicyUnderwriters!.length,
                  itemBuilder: (context, index) {
                    final underwriter = controller.selectedClaim.value!
                        .insurancePolicyUnderwriters![index];
                    return ItemRowContainer(
                      isPolicy: true,
                      noHorizontalMargin: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TitleValueRow(
                              isTextBolder: true,
                              title: '${AppStrings.insurer.tr}:',
                              value: underwriter.vendorName ?? '-',
                            ),
                            TitleValueRow(
                              isTextBolder: true,
                              title: '${AppStrings.apportionment.tr}:',
                              value: displayAmount(
                                  underwriter.underWriterApportion),
                            ),
                            TitleValueRow(
                              isTextBolder: true,
                              title: '${AppStrings.total.tr}:',
                              value: formatAmount(underwriter.dvAmount ?? 0),
                            ),
                            TitleValueRow(
                              isTextBolder: true,
                              title: '${AppStrings.amountPaid.tr}:',
                              value: formatAmount(underwriter.receiptAmount ?? 0),
                            ),
                            TitleValueRow(
                              isTextBolder: true,
                              title: '${AppStrings.balanceDue.tr}:',
                              value: formatAmount(underwriter.balanceDue ?? 0),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
      ],
    );
  }

  String displayAmount(double? amount) {
    return amount == null ? '-' : amount.toString();
  }
}
