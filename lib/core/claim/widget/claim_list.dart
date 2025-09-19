import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/claim/controller/claim_controller.dart';
import 'package:pibro/network/models/response/customer_policy_claims_response.dart';
import 'package:pibro/shared/empty_data.dart';
import 'package:pibro/shared/item_row_container.dart';
import 'package:pibro/shared/widget/item_row_container_column.dart';
import 'package:pibro/utils/app_utils.dart';

class ClaimList extends StatelessWidget {
  const ClaimList({super.key});

  @override
  Widget build(BuildContext context) {
    final ClaimController controller = Get.put(ClaimController());
    return Expanded(
      child: Obx(
        () => controller.loading.value && controller.policyClaims.isEmpty
            ? LoadingAnimationWidget.staggeredDotsWave(
                color: AppColors.primaryColor,
                size: 100,
              )
            : controller.policyClaims.isEmpty 
                ? EmptyData()
                : ListView.builder(
                    itemCount: controller.policyClaims.length,
                    padding: EdgeInsets.only(top: 30, bottom: 100),
                    itemBuilder: (BuildContext context, int index) {
                      final PolicyClaim claim = controller.policyClaims[index];
                      return GestureDetector(
                        onTap: () => controller.selectClaim(claim),
                        child: ItemRowContainer(
                          isLarge: true,
                          child: ItemRowContainerColumn(
                            id: claim.brokerClaimID!,
                            amount:
                                'N${formatAmount(claim.totalReceived ?? 0)}',
                            dates: formatDate(claim.accidentDate!),
                            type: claim.riskTypeID,
                            status: getClaimStatus(claim)[0],
                            color: getClaimStatus(claim)[1],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
