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
                  // Header row (title + settings)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.signUp.tr,
                          style: Styles.boldTextStyle(size: 20),
                        ),
                        GestureDetector(
                          child: const Icon(Icons.settings, size: 20),
                          onTap: () => Get.offAllNamed(AppRoutes.serviceConfig),
                        ),
                      ],
                    ),
                  ),

                  // Account Type selector
                  Text(
                    AppStrings.accountType.tr,
                    style: Styles.mediumTextStyle(size: 14),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final value = controller.selectedAccountType.value;
                    final isSelected = [
                      value == 'Individual',
                      value == 'Company',
                      value == 'Joint Account',
                    ];

                    return Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.inputGrey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: ToggleButtons(
                        isSelected: isSelected,
                        onPressed: (index) {
                          switch (index) {
                            case 0:
                              controller.setAccountType('Individual');
                              break;
                            case 1:
                              controller.setAccountType('Company');
                              break;
                            case 2:
                              controller.setAccountType('Joint Account');
                              break;
                          }
                        },
                        borderRadius: BorderRadius.circular(999),
                        selectedBorderColor: AppColors.primaryColor,
                        borderColor: AppColors.tileColor,
                        selectedColor: AppColors.primaryColor,
                        fillColor:
                            AppColors.primaryColor.withValues(alpha: 0.12),
                        textStyle: Styles.mediumTextStyle(size: 12),
                        constraints:
                            const BoxConstraints(minHeight: 36, minWidth: 0),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(AppStrings.individual.tr),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(AppStrings.company.tr),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(AppStrings.jointAccount.tr),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // Email
                  CustomInput(
                    hint: AppStrings.email.tr,
                    controller: controller.emailController,
                    validator: Validators.emailValidator,
                    inputType: TextInputType.emailAddress,
                  ),

                  // Name fields - dynamic based on account type
                  Obx(() {
                    final t = controller.selectedAccountType.value;

                    // For Individual accounts, show First Name and Last Name separately
                    if (t == 'Individual') {
                      return Column(
                        children: [
                          CustomInput(
                            hint: AppStrings.firstName.tr,
                            controller: controller.firstNameController,
                            validator: (value) => Validators.requiredValidator(
                              value,
                              AppStrings.firstName.tr,
                            ),
                          ),
                          CustomInput(
                            hint: AppStrings.lastName.tr,
                            controller: controller.lastNameController,
                            validator: (value) => Validators.requiredValidator(
                              value,
                              AppStrings.lastName.tr,
                            ),
                          ),
                        ],
                      );
                    }

                    // For Company and Joint Account, show single name field
                    final nameHint = t == 'Company'
                        ? AppStrings.companyName.tr
                        : AppStrings.accountName.tr;
                    return CustomInput(
                      hint: nameHint,
                      controller: controller.nameController,
                      validator: (value) => Validators.requiredValidator(
                        value,
                        nameHint,
                      ),
                    );
                  }),

                  // Phone
                  CustomInput(
                    hint: AppStrings.phoneNumber.tr,
                    controller: controller.phoneController,
                    validator: (value) => Validators.requiredValidator(
                      value,
                      AppStrings.phoneNumber.tr,
                    ),
                    inputType: TextInputType.phone,
                  ),

                  // Date of Birth / Date of Incorporation / Primary Holder DOB
                  Obx(() {
                    final t = controller.selectedAccountType.value;
                    final dobHint = t == 'Company'
                        ? AppStrings.dateOfIncorporation.tr
                        : t == 'Joint Account'
                            ? AppStrings.primaryHolderDob.tr
                            : AppStrings.dob.tr;

                    return CustomInput(
                      hint: dobHint,
                      controller: controller.dobController,
                      readonly: true,
                      onTap: () => controller.pickDateOfBirth(context),
                      validator: (value) =>
                          Validators.requiredValidator(value, dobHint),
                      inputType: TextInputType.none,
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.calendar_today,
                          size: 24,
                          color: AppColors.tileColor,
                        ),
                      ),
                    );
                  }),

                  // Password
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
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Submit button
                  Obx(
                    () => CustomButton(
                      text: AppStrings.signUp.tr,
                      loading: controller.loading.value,
                      onPressed: () {
                        if (controller.signupFormKey.currentState?.validate() ??
                            false) {
                          controller.signup();
                        }
                      },
                    ),
                  ),

                  // Navigation back to login
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount.tr,
                          style: Styles.regularTextStyle(),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => Get.offNamed(AppRoutes.login),
                          child: Text(
                            AppStrings.login.tr,
                            style: Styles.mediumTextStyle(size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
