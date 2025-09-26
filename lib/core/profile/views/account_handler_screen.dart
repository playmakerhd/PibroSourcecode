import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/home/controller/home_controller.dart';
import 'package:pibro/core/profile/widget/info_container.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/utils/view_utils.dart';

class AccountHandlerScreen extends StatelessWidget {
  const AccountHandlerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    // local helper to display '-' for null/empty values
    String safe(String? v) => (v == null || v.trim().isEmpty) ? '-' : v.trim();

    // guard access to customer contacts and pick the first contact if available
    final user = controller.user.value;
    final contacts = user?.customerContacts;
    final firstContact =
        (contacts != null && contacts.isNotEmpty) ? contacts[0] : null;
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
                  value: safe(
                      '${firstContact?.contactFirstName ?? ''} ${firstContact?.contactLastName ?? ''}'
                          .trim()),
                ),
                InfoContainer(
                  title: AppStrings.phoneNumber.tr,
                  value: safe(firstContact?.contactPhone),
                ),
                InfoContainer(
                  title: AppStrings.email.tr,
                  value: safe(firstContact?.contactEmail),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
