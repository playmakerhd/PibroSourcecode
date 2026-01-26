import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/core/auth/controller/forgot_password_controller.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/auth_bg.dart';
import 'package:pibro/shared/widget/app_text_field.dart';
import 'package:pibro/shared/custom_button.dart';

class ResetPasswordScreen extends GetView<ForgotPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String username = (Get.arguments?['username'] ?? '') as String;

    // Notify controller we entered the screen so timer can start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.enterOtpScreen(username);
    });

    return AuthBg(
      title: 'Reset Password',
      showBack: false,
      titleWidget: Image.asset(AppImages.pibroLogo, height: 50),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            const _Title('Reset Password'),
            const SizedBox(height: 8),
            const _Subtitle(
                'Enter the 6-digit code sent to your registered Email Address'),
            const SizedBox(height: 28),

            // OTP Input Section
            _OtpBoxes(onChanged: (val) => controller.code.value = val),
            const SizedBox(height: 18),
            _ResendHint(username: username),
            const SizedBox(height: 8),
            const Text('OTP expires in 2mins',
                style: TextStyle(color: Color(0xFF0E3B66), fontSize: 12)),
            const SizedBox(height: 32),

            // Divider
            Row(
              children: const [
                Expanded(
                    child: Divider(color: Color(0xFFB7D3EE), thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Set New Password',
                    style: TextStyle(
                      color: Color(0xFF0E3B66),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                    child: Divider(color: Color(0xFFB7D3EE), thickness: 1)),
              ],
            ),
            const SizedBox(height: 24),

            // Password Requirements
            const _PasswordRequirements(),
            const SizedBox(height: 24),

            // New Password Input
            AppTextField(
              controller: controller.newPwdCtrl,
              hint: 'Enter new password',
              obscure: true,
            ),
            const SizedBox(height: 36),

            // Confirm Button
            Obx(() => CustomButton(
                  text: 'Confirm',
                  loading: controller.isBusy.value,
                  enabled: controller.code.value.length == 6,
                  onPressed: () =>
                      controller.confirmNewPassword(username: username),
                  height: 50,
                  borderRadius: 80,
                  color: const Color(0xFF0E3B66),
                )),
            const SizedBox(height: 24),
            _BackToLogin(onTap: () => Get.offAllNamed(AppRoutes.login)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0E3B66),
        ),
      );
}

class _Subtitle extends StatelessWidget {
  final String text;
  const _Subtitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF0E3B66),
        ),
      );
}

class _ResendHint extends StatelessWidget {
  final String username;
  const _ResendHint({required this.username});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ForgotPasswordController>();
    return Obx(() {
      final can = ctrl.canResend.value;
      final seconds = ctrl.resendSeconds.value;
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Color(0xFF0E3B66), fontSize: 12),
          children: [
            const TextSpan(text: "Didn't receive email?  "),
            WidgetSpan(
              child: MouseRegion(
                cursor:
                    can ? SystemMouseCursors.click : SystemMouseCursors.basic,
                child: GestureDetector(
                  onTap: can ? () => ctrl.resendCode(username: username) : null,
                  child: Text(
                    can ? 'Click to resend' : 'Resend available in ${seconds}s',
                    style: TextStyle(
                      decoration:
                          can ? TextDecoration.underline : TextDecoration.none,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color:
                          can ? const Color(0xFF0E3B66) : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
            child: const Text(
              'Back to login',
              style: TextStyle(fontSize: 12, color: Color(0xFF0E3B66)),
            ),
          ),
        ],
      );
}

class _OtpBoxes extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const _OtpBoxes({required this.onChanged});

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<_OtpBoxes> {
  final _nodes = List.generate(6, (_) => FocusNode());
  final _ctrs = List.generate(6, (_) => TextEditingController());

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    for (final c in _ctrs) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boxes = List.generate(6, (i) => _buildBox(i));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: boxes,
    );
  }

  Widget _buildBox(int i) {
    return Container(
      width: 40,
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFB7D3EE), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _ctrs[i],
        focusNode: _nodes[i],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0E3B66),
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (v) {
          if (v.isNotEmpty && i < 5) {
            _nodes[i + 1].requestFocus();
          } else if (v.isEmpty && i > 0) {
            _nodes[i - 1].requestFocus();
          }
          final value = _ctrs.map((c) => c.text).join();
          widget.onChanged(value);
        },
      ),
    );
  }
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
