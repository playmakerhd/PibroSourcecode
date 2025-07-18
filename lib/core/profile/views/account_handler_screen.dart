import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/profile/widget/info_container.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/utils/view_utils.dart';

class AccountHandlerScreen extends StatelessWidget {
  const AccountHandlerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SizedBox(
        height: queryHeight(context),
        width: queryWidth(context),
        child: Column(
          children: [
            CommonHeader(
              title: AppStrings.accountHandler.tr,
            ),
            SizedBox(
              height: 30,
            ),
            Column(
              children: [
                InfoContainer(
                  title: AppStrings.name.tr,
                  value: 'Adejuwon Olaide',
                ),
                InfoContainer(
                  title: AppStrings.phoneNumber.tr,
                  value: '08012345678',
                ),
                InfoContainer(
                  title: AppStrings.email.tr,
                  value: 'adejuwon@gmail.com',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
