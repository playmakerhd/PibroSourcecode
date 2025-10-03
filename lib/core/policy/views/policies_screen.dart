import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/core/home/controller/home_controller.dart';
import 'package:pibro/core/policy/widget/policy_list.dart';
import 'package:pibro/shared/common_header.dart';

class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => controller.getCustomerPolicies(
          status: controller.policyStatus.value,
        ),
        child: Column(
          children: [
            Obx(
              () => CommonHeader(
                title: controller.policyScreenTitle.value,
              ),
            ),
            PolicyList(),
          ],
        ),
      ),
    );
  }
}
