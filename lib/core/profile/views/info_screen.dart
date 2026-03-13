import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/home/controller/home_controller.dart';
import 'package:pibro/core/profile/widget/info_container.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:pibro/utils/app_utils.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: AppColors.tileColor,
      body: SafeArea(
        bottom: false,
        child: Container(
          color: AppColors.white,
          height: queryHeight(context),
          width: queryWidth(context),
          child: ListView(
            padding: EdgeInsets.only(
              bottom: queryBottomInset(context) + 16,
            ),
            children: [
              CommonHeader(
                title: AppStrings.myInfo.tr,
              ),
              Obx(
                () => Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 5),
                  child: Center(
                    child: Text(
                      '${AppStrings.username.tr}:  ${displayValue(controller.user.value?.customerID)}',
                      style: Styles.boldTextStyle(
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                color: AppColors.tileColor,
                thickness: 2,
              ),
              Column(
                children: [
                  InfoContainer(
                    title: AppStrings.name.tr,
                    value: controller.user.value?.customerName,
                  ),
                  InfoContainer(
                    title: AppStrings.phoneNumber.tr,
                    value: controller.user.value?.customerPhone,
                  ),
                  InfoContainer(
                    title: AppStrings.email.tr,
                    value: controller.user.value?.customerEmail,
                  ),
                  InfoContainer(
                    title: AppStrings.dob.tr,
                    // Guard against invalid or empty date strings to avoid FormatException
                    value:
                        (controller.user.value?.customerDateOfBirth != null &&
                                controller.user.value!.customerDateOfBirth!
                                    .toString()
                                    .trim()
                                    .isNotEmpty)
                            ? formatDate(
                                controller.user.value!.customerDateOfBirth!)
                            : '-',
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: queryWidth(context) * 0.5,
                        child: InfoContainer(
                          title: AppStrings.country.tr,
                          value: controller.user.value?.customerCountry,
                        ),
                      ),
                      SizedBox(
                        width: queryWidth(context) * 0.5,
                        child: InfoContainer(
                          title: AppStrings.state.tr,
                          value: controller.user.value?.customerState,
                        ),
                      ),
                    ],
                  ),
                  InfoContainer(
                    title: AppStrings.address.tr,
                    value: controller.user.value?.customerAddress1,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
