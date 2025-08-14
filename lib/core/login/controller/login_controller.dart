import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/login/model/login_data.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/request/auth_request.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';

class LoginController extends GetxController {
  PibroRepository pibroRepository =
      PibroRepository(appApiProvider: ApiProvider());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  RxBool obscurePassword = true.obs;
  RxBool isRemember = false.obs;
  RxBool otherOption = false.obs;
  RxBool loading = false.obs;

  updateObscure() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (loginFormKey.currentState!.validate()) {
      loading.value = true;
      try {
        final response = await pibroRepository.login(
          AuthRequest(
            username: nameController.text,
            password: passwordController.text,
            email: emailController.text,
            phoneNumber: phoneController.text,
            isOtherOption: otherOption.value,
          ),
        );
        if (response.messageResponse.status != AppConstants.responseSuccess) {
          showSnackbarMessage(
              message: response.messageResponse.message, isSuccess: false);
        } else {
          LoginData data = LoginData(
            customerID: otherOption.value ? '' : nameController.text,
            email: otherOption.value ? emailController.text : '',
            phone: otherOption.value ? phoneController.text : '',
          );
          persistLoginData(data: data, remember: isRemember.value);
          if (decryptData(StorageKeys.quoteConfirmation) != null) {
            Get.offNamed(AppRoutes.quoteConfirmation);
            deleteQuoteConfirmation();
          } else {
            Get.offNamed(AppRoutes.main);
          }
        }
        loading.value = false;
      } catch (e) {
        loading.value = false;
        showSnackbarMessage(
            message: AppStrings.genericErrorMessage.tr, isSuccess: false);
      }
    }
  }

  updateIsRemember(bool? value) {
    isRemember.value = value!;
  }

  updateOtherOption() {
    otherOption.value = !otherOption.value;
  }

  @override
  void onInit() {
    LoginData data =
        LoginData.fromJson(convertToJsonStringQuotes(StorageKeys.loginData));
    nameController.text = GetStorage().read(StorageKeys.rememberMe) != null
        ? data.customerID!
        : '';
    isRemember.value = GetStorage().read(StorageKeys.rememberMe) != null;
    // nameController.text = '00001A';
    // passwordController.text = '1111';
    // emailController.text = 'mycustomer@email.com';
    // phoneController.text = '09077778888';
    super.onInit();
  }
}
