import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/core/login/model/login_data.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/request/auth_request.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';

class SignupController extends GetxController {
  PibroRepository pibroRepository =
      PibroRepository(appApiProvider: ApiProvider());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  RxBool obscurePassword = true.obs;
  RxBool loading = false.obs;

  updateObscure() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> signup() async {
    if (signupFormKey.currentState!.validate()) {
      loading.value = true;
      try {
        final response = await pibroRepository.signUp(
          AuthRequest(
            username: nameController.text,
            password: passwordController.text,
            email: emailController.text,
            phoneNumber: phoneController.text,
          ),
        );
        if (response.messageResponse.status != AppConstants.responseSuccess) {
          showSnackbarMessage(
              message: response.messageResponse.message, isSuccess: false);
        } else {
          persistSignupID(response.messageResponse.message);
          persistLoginData(
            data: LoginData(
              customerID: nameController.text,
              email: emailController.text,
              phone: phoneController.text,
            ),
            remember: false,
          );
          Get.offNamed(AppRoutes.quoteConfirmation);
        }
        loading.value = false;
      } catch (e) {
        loading.value = false;
        showSnackbarMessage(
            message: AppStrings.genericErrorMessage.tr, isSuccess: false);
      }
    }
  }
}
