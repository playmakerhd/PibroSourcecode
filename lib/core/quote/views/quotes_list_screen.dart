import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/quote/widgets/quote_list.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/common_header.dart';

class QuoteListScreen extends StatelessWidget {
  const QuoteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          size: 50,
          color: AppColors.white,
        ),
        onPressed: () => Get.toNamed(AppRoutes.getQuote),
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
