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
  RxBool otherOption = true.obs;
  RxBool loading = false.obs;

  void updateObscure() {
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
          // Extract entity type from login response message
          final entityType = response.messageResponse.message
              .toUpperCase(); // "LEAD" or "CUSTOMER"

          // For email/phone login, fetch profile to get CustomerID
          if (otherOption.value) {
            try {
              final prof = await pibroRepository.getProfileByEmailPhone(
                email: emailController.text,
                phone: phoneController.text,
              );

              if (prof.user.customerID != null &&
                  prof.user.customerID!.isNotEmpty) {
                // Persist profile data
                persistProfileData(prof.user);

                // Create login data with the retrieved CustomerID
                LoginData data = LoginData(
                  customerID: prof.user.customerID,
                  email: emailController.text,
                  phone: phoneController.text,
                  entityType: entityType,
                );
                persistLoginData(data: data, remember: isRemember.value);

                // Mirror email
                final e = (prof.user.customerEmail ?? '').trim();
                if (e.isNotEmpty) {
                  GetStorage().write(StorageKeys.userEmail, e);
                }
              }
            } catch (e) {
              print('⚠️ Error fetching profile by email/phone: $e');
              // Continue with empty customerID if profile fetch fails
              LoginData data = LoginData(
                customerID: '',
                email: emailController.text,
                phone: phoneController.text,
                entityType: entityType,
              );
              persistLoginData(data: data, remember: isRemember.value);
            }
          } else {
            // Username login - use username as customerID
            LoginData data = LoginData(
              customerID: nameController.text,
              email: '',
              phone: '',
              entityType: entityType,
            );
            persistLoginData(data: data, remember: isRemember.value);
          }

          // Store entity type separately
          GetStorage().write(StorageKeys.entityType, entityType);

          // Also persist the email separately for payment flow (same as signup)
          String emailToStore = otherOption.value ? emailController.text : '';
          if (emailToStore.isNotEmpty) {
            GetStorage().write(StorageKeys.userEmail, emailToStore);
          }

          // Check if user came from quote flow BEFORE navigating to main
          try {
            final cameFromQuote =
                GetStorage().read(StorageKeys.quoteFlowFlag) == true;
            if (cameFromQuote) {
              // Continue the quote flow after auth
              await Get.find<GetQuoteController>().resumeAfterAuth();
              return; // don't navigate to main
            }
          } catch (_) {}

          Get.offNamed(AppRoutes.main);
        }
        loading.value = false;
      } catch (e) {
        loading.value = false;
        showSnackbarMessage(
            message: AppStrings.genericErrorMessage.tr, isSuccess: false);
      }
    }
  }

  void updateIsRemember(bool? value) {
    isRemember.value = value!;
  }

  void updateOtherOption() {
    otherOption.value = !otherOption.value;
  }

  @override
  void onInit() {
    final bool remembered = GetStorage().read(StorageKeys.rememberMe) != null;
    isRemember.value = remembered;

    if (remembered) {
      final storedData = convertToJsonStringQuotes(StorageKeys.loginData);
      if (storedData.isNotEmpty) {
        final savedData = LoginData.fromJson(storedData);
        final savedEmail = (savedData.email ?? '').trim();
        final savedPhone = (savedData.phone ?? '').trim();
        final savedCustomerID = (savedData.customerID ?? '').trim();

        if (savedEmail.isNotEmpty || savedPhone.isNotEmpty) {
          otherOption.value = true;
          emailController.text = savedEmail;
          phoneController.text = savedPhone;
        } else if (savedCustomerID.isNotEmpty) {
          otherOption.value = false;
          nameController.text = savedCustomerID;
        }
      }
    } else {
      otherOption.value = true;
    }

    // nameController.text = '00001A';
    // passwordController.text = '1111';
    // emailController.text = 'mycustomer@email.com';
    // phoneController.text = '09077778888';
    super.onInit();
  }
}
