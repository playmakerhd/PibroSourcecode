import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/login/model/login_data.dart';
import 'package:pibro/core/quote/controller/get_quote_controller.dart';
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
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  RxBool obscurePassword = true.obs;
  RxBool loading = false.obs;
  Rx<DateTime?> selectedDateOfBirth = Rx<DateTime?>(null);
  // Default to 'Individual' to match the display strings used by the UI
  RxString selectedAccountType = 'Individual'.obs;

  void updateObscure() {
    obscurePassword.value = !obscurePassword.value;
  }

  void setAccountType(String type) {
    selectedAccountType.value = type;
  }

  Future<void> selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDateOfBirth.value ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now()
          .subtract(Duration(days: 365 * 16)), // Minimum 16 years old
    );
    if (picked != null && picked != selectedDateOfBirth.value) {
      selectedDateOfBirth.value = picked;
      dateOfBirthController.text =
          "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  Future<void> pickDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth.value ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now()
          .subtract(Duration(days: 365 * 16)), // Minimum 16 years old
    );
    if (picked != null && picked != selectedDateOfBirth.value) {
      selectedDateOfBirth.value = picked;
      dobController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
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
            dateOfBirth: selectedDateOfBirth.value?.toIso8601String(),
          ),
        );
        if (response.messageResponse.status != AppConstants.responseSuccess) {
          showSnackbarMessage(
              message: response.messageResponse.message, isSuccess: false);
        } else {
          // Store the customer ID from the response
          final customerID = response.messageResponse.message;
          persistSignupID(customerID);

          persistLoginData(
            data: LoginData(
              customerID:
                  customerID, // Use the response customer ID, not the text input
              email: emailController.text,
              phone: phoneController.text,
            ),
            remember: false,
          );

          // Also persist the email separately for payment flow
          GetStorage().write(StorageKeys.userEmail, emailController.text);

          // Store profile data with customer ID for receipt creation
          GetStorage().write(StorageKeys.profileData, {
            'CustomerID': customerID,
            'CustomerEmail': emailController.text,
            'CustomerPhone': phoneController.text,
            'CustomerName': nameController.text,
          });

          // Show success snackbar with customer ID
          showSnackbarMessage(
            message: 'Signup successful! Your Customer ID is: $customerID',
            isSuccess: true,
          );

          // After successful signup/auth
          try {
            final cameFromQuote =
                GetStorage().read(StorageKeys.quoteFlowFlag) == true;
            if (cameFromQuote) {
              await Get.find<GetQuoteController>().resumeAfterAuth();
              return; // resumeAfterAuth does its own navigation
            }
          } catch (_) {}
          Get.offNamed(AppRoutes.login);
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
