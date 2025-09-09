import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/core/home/controller/home_controller.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';
import 'package:pibro/shared/item_row_container.dart';
import 'package:pibro/shared/widget/item_row_container_column.dart';
import 'package:pibro/utils/app_utils.dart';

class PolicyList extends StatelessWidget {
  const PolicyList({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    return Expanded(
      child: Obx(
        () {
          final items = controller.displayPolicies;

          // Optional: show friendly empty state when there are no policies.
          if (items.isEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No policies yet',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            padding: EdgeInsets.only(top: 30, bottom: 50),
            itemBuilder: (BuildContext context, int index) {
              final PolicyData policy = items[index];
              return GestureDetector(
                onTap: () => controller.navigateToPolicyDetails(policy),
                child: ItemRowContainer(
                  isLarge: true,
                  child: ItemRowContainerColumn(
                    id: policy.policyBrokerID,
                    amount: 'N${formatAmount(policy.premiumAmount!)}',
                    dates:
                        '${formatDate(policy.policyStartDate!)} - ${formatDate(policy.policyEndDate!)}',
                    type: policy.riskTypeID!,
                    status:
                        getPolicyStatus(policy.policyEndDate!, policy.approved)
                            .status,
                    color:
                        getPolicyStatus(policy.policyEndDate!, policy.approved)
                            .color,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
