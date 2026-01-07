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
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  RxBool obscurePassword = true.obs;
  RxBool loading = false.obs;
  Rx<DateTime?> selectedDateOfBirth = Rx<DateTime?>(null);
  RxString selectedAccountType = 'INDIVIDUAL'.obs;

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
        // Determine username based on account type
        final String username;
        final String? firstName;
        final String? lastName;

        if (selectedAccountType.value == 'INDIVIDUAL') {
          username = '${firstNameController.text}${lastNameController.text}'
              .toUpperCase();
          firstName = firstNameController.text;
          lastName = lastNameController.text;
        } else {
          username = nameController.text;
          firstName = null;
          lastName = null;
        }

        // Create Lead instead of Customer (new flow)
        final response = await pibroRepository.createLead(
          AuthRequest(
            username: username,
            password: passwordController.text,
            email: emailController.text,
            phoneNumber: phoneController.text,
            dateOfBirth: selectedDateOfBirth.value?.toIso8601String(),
            firstName: firstName,
            lastName: lastName,
            accountType: selectedAccountType.value,
            state: stateController.text,
            address: addressController.text,
          ),
        );

        if (response.messageResponse.status != AppConstants.responseSuccess) {
          showSnackbarMessage(
              message: response.messageResponse.message, isSuccess: false);
        } else {
          // Extract Lead ID from response (e.g., "LEAD/14")
          final leadID = response.messageResponse.message;
          persistSignupID(leadID);

          // Store login data with entity type as LEAD
          persistLoginData(
            data: LoginData(
              customerID: leadID,
              email: emailController.text,
              phone: phoneController.text,
              entityType: 'LEAD',
            ),
            remember: false,
          );

          // Also persist the email separately for payment flow
          GetStorage().write(StorageKeys.userEmail, emailController.text);

          // Store profile data with Lead ID
          final displayName = selectedAccountType.value == 'INDIVIDUAL'
              ? '${firstNameController.text} ${lastNameController.text}'
              : nameController.text;

          GetStorage().write(StorageKeys.profileData, {
            'CustomerID': leadID,
            'CustomerEmail': emailController.text,
            'CustomerPhone': phoneController.text,
            'CustomerName': displayName,
            'CustomerFirstName': firstName ?? nameController.text,
            'CustomerLastName': lastName ?? '',
            'CustomerState': stateController.text,
            'CustomerAddress1': addressController.text,
            'CustomerDateOfBirth':
                selectedDateOfBirth.value?.toIso8601String() ?? '',
          });

          // Store entity type
          GetStorage().write(StorageKeys.entityType, 'LEAD');

          // Show success snackbar with Lead ID
          showSnackbarMessage(
            message: 'Signup successful! Your ID is: $leadID',
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
