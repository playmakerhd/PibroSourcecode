import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/widget/rotated_container.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:pibro/constants/app_images.dart';

class TransactionsHubScreen extends StatelessWidget {
  const TransactionsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            CommonHeader(title: 'Transactions'),
            SizedBox(height: 200),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: queryWidth(context) * 0.1),
              child: Column(
                children: [
                  RotatedContainer(
                    text: 'Debit Notes',
                    image: AppImages.policy, // reuse existing asset
                    borderColor: AppColors.tileColor,
                    onPressed: () => Get.toNamed(AppRoutes.debitNoteList),
                  ),
                  SizedBox(height: 80),
                  RotatedContainer(
                    text: 'Customer Transactions',
                    image: AppImages.quote, // reuse existing asset
                    borderColor: AppColors.tileColor,
                    onPressed: () =>
                        Get.toNamed(AppRoutes.customerTransactionsList),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
