import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/claim/controller/claim_controller.dart';
import 'package:pibro/core/claim/widget/claim_list.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/utils/view_utils.dart';

class ClaimScreen extends StatelessWidget {
  const ClaimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ClaimController controller = Get.put(ClaimController());
    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: queryBottomInset(context) + 8,
        ),
        child: FloatingActionButton(
          backgroundColor: AppColors.primaryColor,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            size: 50,
            color: AppColors.white,
          ),
          onPressed: () => Get.toNamed(AppRoutes.lodgeClaims),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.getCustomerClaims,
        child: Column(
          children: [
            CommonHeader(
              title: AppStrings.claims.tr,
            ),
            ClaimList(),
          ],
        ),
      ),
    );
  }
}
