import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/signup/controller/signup_controller.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/auth_bg.dart';
import 'package:pibro/shared/custom_button.dart';
import 'package:pibro/shared/custom_input/custom_input.dart';
import 'package:pibro/utils/validators.dart';
import 'package:pibro/utils/view_utils.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SignupController controller = Get.put(SignupController());
    return AuthBg(
      title: AppStrings.hello.tr,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: queryWidth(context) * 0.05,
            ),
            child: Form(
              key: controller.signupFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      AppStrings.signUp.tr,
                      style: Styles.boldTextStyle(size: 20),
                    ),
                  ),
                  CustomInput(
                    hint: AppStrings.email.tr,
                    controller: controller.emailController,
                    validator: Validators.emailValidator,
                    inputType: TextInputType.emailAddress,
                  ),
                   CustomInput(
                    hint: AppStrings.name.tr,
                    controller: controller.nameController,
                    validator: (value) => Validators.requiredValidator(
                      value,
                      AppStrings.username.tr,
                    ),
                    inputType: TextInputType.name,
                  ),
                  CustomInput(
                    hint: AppStrings.phoneNumber.tr,
                    controller: controller.phoneController,
                    validator: (value) => Validators.requiredValidator(
                        value, AppStrings.phoneNumber.tr),
                    inputType: TextInputType.phone,
                  ),
                 
                  Obx(
                    () => CustomInput(
                      hint: AppStrings.password.tr,
                      controller: controller.passwordController,
                      obscure: controller.obscurePassword.value,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                    child: Obx(
                      () => CustomButton(
                        text: AppStrings.signUp.tr.capitalizeFirst!,
                        loading: controller.loading.value,
                        onPressed: controller.signup,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount.tr,
                          style: Styles.regularTextStyle(),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () => Get.offNamed(AppRoutes.login),
                          child: Text(
                            AppStrings.login.tr,
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
