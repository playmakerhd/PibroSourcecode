import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/config/model/config_model.dart';
import 'package:pibro/core/profile/widget/notification_item_row.dart';
import 'package:pibro/core/profile/widget/profile_button.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/request/change_password_request.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/shared/custom_button.dart';
import 'package:pibro/shared/custom_input/custom_input.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/image_factory.dart';
import 'package:pibro/utils/validators.dart';
import 'package:pibro/utils/view_utils.dart';

class ProfileController extends GetxController {
  PibroRepository pibroRepository =
      PibroRepository(appApiProvider: ApiProvider());
  List<String> profileMenus = [
    AppStrings.myInfo.tr,
    AppStrings.accountHandler.tr,
    AppStrings.notification.tr,
    AppStrings.configuration.tr,
    AppStrings.changePassword.tr,
    AppStrings.logout.tr,
  ];

  RxBool emailEnabled = true.obs;
  RxBool smsEnabled = true.obs;
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> changePasswordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> configFormKey = GlobalKey<FormState>();

  final TextEditingController serviceURLController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();

  RxBool obscureOldPassword = true.obs;
  RxBool obscureNewPassword = true.obs;
  RxBool obscureConfirmPassword = true.obs;
  RxBool isPasswordChangeLoading = false.obs;

  get profileLoading => null;

  updateOldObscure() {
    obscureOldPassword.value = !obscureOldPassword.value;
  }

  updateNewObscure() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  updateConfirmObscure() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  updateEmailNotification(bool value) {
    emailEnabled.value = value;
  }

  updateSMSNotification(bool value) {
    smsEnabled.value = value;
  }

  void onProfileItemPressed(String title) {
    if (title == AppStrings.myInfo.tr) {
      Get.toNamed(AppRoutes.myInfo);
    } else if (title == AppStrings.accountHandler.tr) {
      Get.toNamed(AppRoutes.accountHandler);
    } else if (title == AppStrings.configuration.tr) {
      Get.toNamed(AppRoutes.configuration);
    } else if (title == AppStrings.changePassword.tr) {
      _openChangePassword();
    } else if (title == AppStrings.notification.tr) {
      _openNotification();
    } else {
      _openLogoutDialog();
    }
  }

  void _logout() {
    GetStorage().remove(StorageKeys.loginData);
    GetStorage().remove(StorageKeys.rememberMe);
    GetStorage().remove(StorageKeys.profileData);
    GetStorage().remove(StorageKeys.quoteConfirmation);
    GetStorage().remove(StorageKeys.signupData);
    // GetStorage().erase();
    Get.deleteAll();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> _changePassword() async {
    if (changePasswordFormKey.currentState!.validate()) {
      isPasswordChangeLoading.value = true;
      try {
        final response = await pibroRepository.changePassword(
          ChangePasswordRequest(
              oldPassword: oldPasswordController.text,
              newPassword: newPasswordController.text,
              confirmPassword: confirmPasswordController.text),
        );
        if (response.messageResponse.status != AppConstants.responseSuccess) {
          showSnackbarMessage(
            message: response.messageResponse.message,
            isSuccess: false,
          );
        } else {
          clearChangePasswordForm();
          Get.back();
          _showSuccessDialog();
        }
        isPasswordChangeLoading.value = false;
      } catch (e) {
        isPasswordChangeLoading.value = false;
        showSnackbarMessage(
            message: AppStrings.genericErrorMessage.tr, isSuccess: false);
      }
    }
  }

  void _openLogoutDialog() {
    showAppDialog(
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            AppStrings.logoutConfirmation.tr,
            style: Styles.boldTextStyle(),
            textAlign: TextAlign.center,
          ),
          Column(
            children: [
              CustomButton(text: AppStrings.logout.tr, onPressed: _logout),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: Get.back,
                child: Text(
                  AppStrings.cancel.tr,
                  style: Styles.boldTextStyle(size: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openNotification() {
    showAppDialog(
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            AppStrings.notification.tr,
            style: Styles.boldTextStyle(),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: Obx(
              () => Column(
                children: [
                  NotificationItemRow(
                    title: AppStrings.email.tr,
                    value: emailEnabled.value,
                    onChanged: updateEmailNotification,
                  ),
                  NotificationItemRow(
                    title: AppStrings.sms.tr,
                    value: smsEnabled.value,
                    onChanged: updateSMSNotification,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _closePasswordChangeDialog() {
    clearChangePasswordForm();
    Get.back();
  }

  void _openChangePassword() {
    showAppDialog(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: _closePasswordChangeDialog,
                child: Icon(
                  Icons.clear,
                  size: 30,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            Text(
              AppStrings.changePassword.tr,
              style: Styles.boldTextStyle(),
              textAlign: TextAlign.center,
            ),
            Form(
              key: changePasswordFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Obx(
                    () => CustomInput(
                      hint: AppStrings.oldPassword.tr,
                      controller: oldPasswordController,
                      obscure: obscureOldPassword.value,
                      noBottomPadding: true,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: GestureDetector(
                          onTap: updateOldObscure,
                          child: Icon(
                            obscureOldPassword.value
                                ? Icons.remove_red_eye
                                : CupertinoIcons.eye_slash_fill,
                            size: 30,
                            color: AppColors.tileColor,
                          ),
                        ),
                      ),
                      validator: Validators.passwordValidator,
                      inputType: TextInputType.visiblePassword,
                      hasFillColor: true,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Obx(
                    () => CustomInput(
                      hint: AppStrings.newPassword.tr,
                      controller: newPasswordController,
                      obscure: obscureNewPassword.value,
                      noBottomPadding: true,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: GestureDetector(
                          onTap: updateNewObscure,
                          child: Icon(
                            obscureNewPassword.value
                                ? Icons.remove_red_eye
                                : CupertinoIcons.eye_slash_fill,
                            size: 30,
                            color: AppColors.tileColor,
                          ),
                        ),
                      ),
                      validator: Validators.passwordValidator,
                      inputType: TextInputType.visiblePassword,
                      hasFillColor: true,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Obx(
                    () => CustomInput(
                      hint: AppStrings.confirmPassword.tr,
                      controller: confirmPasswordController,
                      obscure: obscureConfirmPassword.value,
                      noBottomPadding: true,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: GestureDetector(
                          onTap: updateConfirmObscure,
                          child: Icon(
                            obscureConfirmPassword.value
                                ? Icons.remove_red_eye
                                : CupertinoIcons.eye_slash_fill,
                            size: 30,
                            color: AppColors.tileColor,
                          ),
                        ),
                      ),
                      validator: Validators.passwordValidator,
                      inputType: TextInputType.visiblePassword,
                      hasFillColor: true,
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => isPasswordChangeLoading.value
                  ? SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : SizedBox(),
            ),
            Obx(() => GestureDetector(
                  onTap:
                      isPasswordChangeLoading.value ? () {} : _changePassword,
                  child: Text(
                    AppStrings.save.tr,
                    style: Styles.mediumTextStyle(),
                  ),
                ))
          ],
        ),
      ),
      height: 350,
      willPop: false,
      dismissible: false,
    );
  }

  void _showSuccessDialog() {
    showAppDialog(
      Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ImageFactory.getImage(AppImages.passwordSuccess).render(
              height: 65,
              width: 65,
            ),
            Text(
              AppStrings.changePasswordSuccess.tr,
              style: Styles.mediumTextStyle(
                size: 12,
                color: AppColors.white,
              ),
            ),
            GestureDetector(
              onTap: Get.back,
              child: ProfileButton(
                text: AppStrings.ok.tr,
                height: 25,
                width: 80,
                textColor: AppColors.activeGreen,
                bgColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void clearChangePasswordForm() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onInit() {
    super.onInit();
    ConfigData configData =
        ConfigData.fromJson(convertToJsonStringQuotes(StorageKeys.configData));
    serviceURLController.text = configData.url!;
    tokenController.text = configData.token!;
  }

  @override
  void dispose() {
    clearChangePasswordForm();
    super.dispose();
  }
}
