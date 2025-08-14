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
                  value:
                      '${controller.user.value!.customerContacts![0].contactFirstName!} ${controller.user.value!.customerContacts![0].contactLastName!}',
                ),
                InfoContainer(
                  title: AppStrings.phoneNumber.tr,
                  value:
                      controller.user.value!.customerContacts![0].contactPhone!,
                ),
                InfoContainer(
                  title: AppStrings.email.tr,
                  value:
                      controller.user.value!.customerContacts![0].contactEmail!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
