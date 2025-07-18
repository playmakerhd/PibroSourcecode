import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/login/controller/login_controller.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/auth_bg.dart';
import 'package:pibro/shared/custom_button.dart';
import 'package:pibro/shared/custom_input/custom_input.dart';
import 'package:pibro/utils/validators.dart';
import 'package:pibro/utils/view_utils.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    return AuthBg(
      title: AppStrings.welcomeBack.tr,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: queryWidth(context) * 0.05,
            ),
            child: Form(
              key: controller.loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      AppStrings.login.tr,
                      style: Styles.boldTextStyle(size: 20),
                    ),
                  ),
                  Obx(
                    () => controller.otherOption.value
                        ? Column(
                            children: [
                              CustomInput(
                                hint: AppStrings.email.tr,
                                controller: controller.emailController,
                                validator: Validators.emailValidator,
                                inputType: TextInputType.emailAddress,
                              ),
                              CustomInput(
                                hint: AppStrings.phoneNumber.tr,
                                controller: controller.phoneController,
                                validator: (value) =>
                                    Validators.requiredValidator(
                                        value, AppStrings.phoneNumber.tr),
                                inputType: TextInputType.phone,
                              ),
                            ],
                          )
                        : CustomInput(
                            hint: AppStrings.username.tr,
                            controller: controller.nameController,
                            validator: (value) => Validators.requiredValidator(
                              value,
                              AppStrings.username.tr,
                            ),
                            inputType: TextInputType.name,
                          ),
                  ),
                  Obx(
                    () => CustomInput(
                      hint: AppStrings.password.tr,
                      controller: controller.passwordController,
                      obscure: controller.obscurePassword.value,
                      noBottomPadding: true,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: GestureDetector(
                          onTap: controller.updateObscure,
                          child: Icon(
                            controller.obscurePassword.value
                                ? Icons.remove_red_eye
                                : CupertinoIcons.eye_slash_fill,
                            size: 30,
                            color: AppColors.tileColor,
                          ),
                        ),
                      ),
                      validator: Validators.passwordValidator,
                      inputType: TextInputType.visiblePassword,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.1,
                            child: Obx(
                              () => Checkbox(
                                value: controller.isRemember.value,
                                fillColor:
                                    WidgetStateProperty.resolveWith<Color>(
                                        (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return AppColors.tileColor;
                                  }
                                  return Colors.transparent;
                                }),
                                side: BorderSide(
                                    color: AppColors.tileColor, width: 3),
                                onChanged: controller.updateIsRemember,
                              ),
                            ),
                          ),
                          Text(
                            AppStrings.rememberMe.tr,
                            style: Styles.regularTextStyle(size: 12),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          AppStrings.forgotPassword.tr,
                          style: Styles.regularTextStyle(size: 12),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 30),
                    child: Obx(
                      () => CustomButton(
                        text: AppStrings.login.tr,
                        onPressed: controller.login,
                        loading: controller.loading.value,
                      ),
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: controller.updateOtherOption,
                      child: Text(
                        AppStrings.otherLoginOptions.tr,
                        style: Styles.boldTextStyle(size: 14),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.dontHaveAccount.tr,
                          style: Styles.regularTextStyle(),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () => Get.offNamed(AppRoutes.signup),
                          child: Text(
                            AppStrings.signUp.tr,
                            style: Styles.mediumTextStyle(size: 14),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
