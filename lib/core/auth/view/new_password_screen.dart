import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/shared/auth_bg.dart';
import 'package:pibro/core/auth/controller/forgot_password_controller.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/widget/app_text_field.dart';
import 'package:pibro/shared/custom_button.dart';

class NewPasswordScreen extends GetView<ForgotPasswordController> {
  const NewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String username = (Get.arguments?['username'] ?? '') as String;

    return AuthBg(
      title: 'Set New Password',
      showBack: false,
      titleWidget: Image.asset(AppImages.pibroLogo, height: 50),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(child: const _Title('Set New Password')),
            const SizedBox(height: 8),
            const _PasswordRequirements(),
            const SizedBox(height: 28),
            AppTextField(
              controller: controller.newPwdCtrl,
              hint: 'Enter new password',
              obscure: true,
            ),
            const SizedBox(height: 15),
            const SizedBox(height: 5),
            const SizedBox(height: 36),
            Obx(() => CustomButton(
                  text: 'Confirm',
                  loading: controller.isBusy.value,
                  onPressed: () =>
                      controller.confirmNewPassword(username: username),
                  height: 50,
                  borderRadius: 80,
                  color: const Color(0xFF0E3B66),
                )),
            const SizedBox(height: 16),
            Center(
              child: _ResendCodeButton(
                onTap: () => controller.resendFromNewPassword(),
              ),
            ),
            const SizedBox(height: 24),
            _BackToLogin(onTap: () => Get.offAllNamed(AppRoutes.login)),
          ],
        ),
      ),
    );
  }
}

// Header provided by shared MainHeader

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0E3B66)));
}

class _PasswordRequirements extends GetView<ForgotPasswordController> {
  const _PasswordRequirements();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password must contain:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0E3B66),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => _RequirementItem(
              text: 'At least 8 characters',
              isMet: controller.hasMinLength.value,
            )),
        Obx(() => _RequirementItem(
              text: 'One uppercase letter (A-Z)',
              isMet: controller.hasUppercase.value,
            )),
        Obx(() => _RequirementItem(
              text: 'One lowercase letter (a-z)',
              isMet: controller.hasLowercase.value,
            )),
        Obx(() => _RequirementItem(
              text: 'One number (0-9)',
              isMet: controller.hasNumber.value,
            )),
        Obx(() => _RequirementItem(
              text: 'One special character (!@#\$%^&*)',
              isMet: controller.hasSpecialChar.value,
            )),
      ],
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;
  final bool isMet;

  const _RequirementItem({
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color:
                isMet ? Colors.green : const Color(0xFF0E3B66).withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isMet
                    ? Colors.green
                    : const Color(0xFF0E3B66).withOpacity(0.7),
                fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResendCodeButton extends GetView<ForgotPasswordController> {
  final VoidCallback onTap;
  const _ResendCodeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canResend = controller.canResend.value;
      final seconds = controller.resendSeconds.value;
      final isBusy = controller.isBusy.value;
      final isDisabled = isBusy || !canResend;

      return InkWell(
        onTap: isDisabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
                color: isDisabled
                    ? const Color(0xFF0E3B66).withOpacity(0.3)
                    : const Color(0xFF0E3B66)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh,
                color: isDisabled
                    ? const Color(0xFF0E3B66).withOpacity(0.5)
                    : const Color(0xFF0E3B66),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                canResend ? 'Resend Code' : 'Resend Code (${seconds}s)',
                style: TextStyle(
                  fontSize: 13,
                  color: isDisabled
                      ? const Color(0xFF0E3B66).withOpacity(0.5)
                      : const Color(0xFF0E3B66),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _BackToLogin extends StatelessWidget {
  final VoidCallback onTap;
  const _BackToLogin({required this.onTap});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.arrow_back,
            color: Color(0xFF0E3B66),
            size: 12,
          ),
          const SizedBox(width: 5),
          InkWell(
            onTap: onTap,
            child: const Text('Back to login',
                style: TextStyle(fontSize: 12, color: Color(0xFF0E3B66))),
          ),
        ],
      );
}
