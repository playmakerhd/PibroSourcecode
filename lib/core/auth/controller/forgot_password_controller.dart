import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/widget/success_dialog.dart' as ssd;
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:pibro/network/models/response/message_response.dart';

class ForgotPasswordController extends GetxController {
  final PibroRepository _repo = PibroRepository(appApiProvider: ApiProvider());

  // Form controllers
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final newPwdCtrl = TextEditingController();
  // confirm password removed per new flow

  // State management
  final isBusy = false.obs;
  final code = ''.obs; // 6 digits from OTP screen
  final isOtherOption = false.obs; // Toggle between username and email+phone
  final usedEmailPhone = false.obs; // whether OTP requested via email+phone

  // Password validation observables
  final hasMinLength = false.obs;
  final hasUppercase = false.obs;
  final hasLowercase = false.obs;
  final hasNumber = false.obs;
  final hasSpecialChar = false.obs;

  // Resend timer: OTP resend is allowed every 2 minutes
  final RxInt resendSeconds = 0.obs;
  final RxBool canResend = false.obs;
  Timer? _resendTimer;
  String? lastCustomerId;
  final int _resendInterval = 120; // seconds

  @override
  void onInit() {
    super.onInit();
    // Listen to password changes for real-time validation
    newPwdCtrl.addListener(_validatePassword);
  }

  void _validatePassword() {
    final password = newPwdCtrl.text;

    // Check minimum length (8 characters)
    hasMinLength.value = password.length >= 8;

    // Check for uppercase letter
    hasUppercase.value = password.contains(RegExp(r'[A-Z]'));

    // Check for lowercase letter
    hasLowercase.value = password.contains(RegExp(r'[a-z]'));

    // Check for number
    hasNumber.value = password.contains(RegExp(r'[0-9]'));

    // Check for special character
    hasSpecialChar.value = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  // --- Toggle Methods ---
  void toggleOtherOption() {
    isOtherOption.value = !isOtherOption.value;
    // Clear fields when switching
    usernameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
  }

  // --- API Actions ---
  Future<void> sendCodeWithUsername() async {
    final username = usernameCtrl.text.trim();
    if (username.isEmpty) {
      _snack('Username required', isError: true);
      return;
    }
    usedEmailPhone.value = false;
    await _sendCodeWithUsername(customerId: username);
  }

  // For email+phone option - currently shows guidance to use username
  Future<void> sendCodeWithEmailPhone() async {
    final email = emailCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    if (email.isEmpty || phone.isEmpty) {
      _snack('Enter both Email and Phone', isError: true);
      return;
    }
    // basic email validation
    if (!RegExp(r"^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}").hasMatch(email)) {
      _snack('Enter a valid email', isError: true);
      return;
    }
    // basic phone validation (digits only, 7-15 chars)
    if (!RegExp(r"^[0-9]{7,15}").hasMatch(phone)) {
      _snack('Enter a valid phone number', isError: true);
      return;
    }
    usedEmailPhone.value = true;
    await _sendCodeWithEmailPhone(email: email, phone: phone);
  }

  Future<void> _sendCodeWithUsername({required String customerId}) async {
    lastCustomerId = customerId;
    try {
      isBusy.value = true;
      final res = await _repo.resetCustomerPasswordOtp(customerId);
      if (res.messageResponse.status == AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: 'A 6-digit code has been sent to your registered email',
            isSuccess: true);
        startResendTimer(); // Start timer when OTP is sent
        Get.toNamed(AppRoutes.resetPassword,
            arguments: {'username': customerId});
      } else {
        _snack(
            res.messageResponse.message.isNotEmpty
                ? res.messageResponse.message
                : 'Failed to send code',
            isError: true);
      }
    } catch (e) {
      _snack('Network error: $e', isError: true);
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> _sendCodeWithEmailPhone(
      {required String email, required String phone}) async {
    // record last values for resend/validation
    lastCustomerId = null;
    try {
      isBusy.value = true;
      final res = await _repo.resetCustomerEmailPhonePasswordOtp(
          email: email, phone: phone);
      if (res.messageResponse.status == AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: 'A 6-digit code has been sent to your registered email',
            isSuccess: true);
        startResendTimer(); // Start timer when OTP is sent
        Get.toNamed(AppRoutes.resetPassword,
            arguments: {'email': email, 'phone': phone});
      } else {
        _snack('Check your details and try again', isError: true);
      }
    } catch (e) {
      _snack('Network error: $e', isError: true);
    } finally {
      isBusy.value = false;
    }
  }

  /// Call when user navigates into the OTP screen. This records the username.
  /// Timer should already be running from when OTP was sent.
  void enterOtpScreen(String username) {
    lastCustomerId = username;
    // Don't restart timer - it should continue from when OTP was sent
  }

  void startResendTimer() {
    _resendTimer?.cancel();
    resendSeconds.value = _resendInterval;
    canResend.value = false;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendSeconds.value <= 1) {
        canResend.value = true;
        resendSeconds.value = 0;
        t.cancel();
      } else {
        resendSeconds.value = resendSeconds.value - 1;
      }
    });
  }

  Future<void> resendCode({String? username}) async {
    if (!canResend.value) return;
    final id = username ?? lastCustomerId;
    if (!usedEmailPhone.value) {
      if (id == null || id.isEmpty) {
        _snack('Username required', isError: true);
        return;
      }
    }
    try {
      isBusy.value = true;
      CustomMessageResponse res;
      if (usedEmailPhone.value) {
        // when email+phone was used, lastCustomerId is null; expect email/phone passed
        final email = Get.arguments?['email'] as String? ?? '';
        final phone = Get.arguments?['phone'] as String? ?? '';
        if (email.isEmpty || phone.isEmpty) {
          _snack('Email and phone required to resend', isError: true);
          return;
        }
        res = await _repo.resetCustomerEmailPhonePasswordOtp(
            email: email, phone: phone);
      } else {
        res = await _repo.resetCustomerPasswordOtp(id!);
      }
      if (res.messageResponse.status == AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: 'Code resent to your registered email address',
            isSuccess: true);
        startResendTimer();
      } else {
        _snack(
            res.messageResponse.message.isNotEmpty
                ? res.messageResponse.message
                : 'Failed to resend code',
            isError: true);
      }
    } catch (e) {
      _snack('Network error: $e', isError: true);
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> confirmNewPassword({required String username}) async {
    final newPwd = newPwdCtrl.text;
    final oldOtp = code.value;

    // Validations
    if (!hasMinLength.value ||
        !hasUppercase.value ||
        !hasLowercase.value ||
        !hasNumber.value ||
        !hasSpecialChar.value) {
      _snack('Please ensure password meets all requirements', isError: true);
      return;
    }
    if (oldOtp.length != 6) {
      _snack('Invalid 6-digit code', isError: true);
      return;
    }

    try {
      isBusy.value = true;
      CustomMessageResponse res;
      if (usedEmailPhone.value) {
        final email = Get.arguments?['email'] as String? ?? '';
        final phone = Get.arguments?['phone'] as String? ?? '';
        if (email.isEmpty || phone.isEmpty) {
          _snack('Email and phone required', isError: true);
          return;
        }
        res = await _repo.validateCustomerPasswordEmailPhoneOtp(
          email: email,
          phone: phone,
          otp: oldOtp,
          newPassword: newPwd,
        );
      } else {
        res = await _repo.validateCustomerPasswordOtp(
          customerId: username,
          otp: oldOtp,
          newPassword: newPwd,
        );
      }
      if (res.messageResponse.status == AppConstants.responseSuccess) {
        await ssd.showSuccessDialog(
          title: 'Password Changed',
          message:
              'Your password has been changed successfully, kindly proceed to login',
          onPressed: () => Get.offAllNamed(AppRoutes.login),
          dismissible: false,
          willPop: false,
        );
      } else {
        _snack(
            res.messageResponse.message.isNotEmpty
                ? res.messageResponse.message
                : 'Failed to change password',
            isError: true);
      }
    } catch (e) {
      _snack('Network error: $e', isError: true);
    } finally {
      isBusy.value = false;
    }
  }

  // --- UI Helpers ---
  void _snack(String msg, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      msg,
      backgroundColor: isError
          ? AppColors.red.withOpacity(.95)
          : AppColors.green.withOpacity(.95),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  // Removed inline _showSuccessDialog — standardized to shared success dialog helper

  @override
  void onClose() {
    newPwdCtrl.removeListener(_validatePassword);
    usernameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    newPwdCtrl.dispose();
    _resendTimer?.cancel();
    super.onClose();
  }
}
