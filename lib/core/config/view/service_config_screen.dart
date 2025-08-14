import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/config/controller/config_controller.dart';
import 'package:pibro/core/profile/widget/profile_button.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/custom_input/custom_input.dart';
import 'package:pibro/utils/validators.dart';
import 'package:pibro/utils/view_utils.dart';

class ServiceConfigScreen extends StatelessWidget {
  const ServiceConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ConfigController controller = Get.put(ConfigController());
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SizedBox(
        height: queryHeight(context),
        width: queryWidth(context),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CommonHeader(
                title: AppStrings.configuration.tr,
                hasBackIcon: false,
              ),
              SizedBox(
                height: queryHeight(context) * 0.17,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: queryWidth(context) * 0.05),
                child: Form(
                  key: controller.configFormKey,
                  // autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      CustomInput(
                        hint: AppStrings.enterServiceUrl.tr,
                        controller: controller.serviceURLController,
                        validator: (value) =>
                            Validators.requiredValidator(value, 'Service URL'),
                        isReducedBorderRadius: true,
                      ),
                      CustomInput(
                        hint: AppStrings.enterToken.tr,
                        controller: controller.tokenController,
                        validator: (value) =>
                            Validators.requiredValidator(value, 'Token'),
                        isReducedBorderRadius: true,
                      ),
                      SizedBox(
                        height: queryHeight(context) * 0.05,
                      ),
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: Container(
                      //     height: 50,
                      //     width: 160,
                      //     margin: EdgeInsets.only(top: 10, bottom: 60),
                      //     decoration: BoxDecoration(
                      //       color: AppColors.primaryColor,
                      //       borderRadius:
                      //           BorderRadius.circular(AppConstants.appRadius),
                      //     ),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         ImageFactory.getImage(AppImages.scan)
                      //             .render(width: 15),
                      //         SizedBox(
                      //           width: 10,
                      //         ),
                      //         Text(
                      //           AppStrings.scanQR.tr,
                      //           style: Styles.semiBoldTextStyle(
                      //               color: AppColors.white),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      GestureDetector(
                        onTap: controller.saveConfigData,
                        child: ProfileButton(
                          text: AppStrings.save.tr,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
