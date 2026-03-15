import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/quote/widgets/quote_list.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/utils/view_utils.dart';

class QuoteListScreen extends StatelessWidget {
  const QuoteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => Get.toNamed(AppRoutes.getQuote),
        ),
      ),
      body: Column(
        children: [
          CommonHeader(
            title: AppStrings.quotes.tr,
            hasBackIcon: true,
          ),
          QuoteList(),
        ],
      ),
    );
  }
}
