import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/core/auth/controller/forgot_password_controller.dart';
import 'package:pibro/shared/auth_bg.dart';
import 'package:pibro/shared/widget/app_text_field.dart';
import 'package:pibro/shared/custom_button.dart';
import 'package:pibro/utils/view_utils.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ForgotPasswordController()); // Ensure controller is initialized
    return AuthBg(
      title: 'Forgot Password ?',
      showBack: false,
      titleWidget: Image.asset(
        'assets/images/pibro_logo.png',
        height: 50,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: queryWidth(context) * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            // center the title and subtitle region
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                SizedBox(height: 0),
              ],
            ),
            Center(child: _Title('Forgot Password ?')),
            const SizedBox(height: 10),
            const Center(
              child: _Subtitle(
                  'A 6-digit code will be sent to your registered Email Address'),
            ),
            const SizedBox(height: 36),

            // Toggle between username and email+phone forms (left aligned)
            Obx(() => controller.isOtherOption.value
                ? _EmailPhoneForm()
                : _UsernameForm()),

            const SizedBox(height: 36),
            Obx(() => CustomButton(
                  text: 'Get Code',
                  loading: controller.isBusy.value,
                  onPressed: controller.isOtherOption.value
                      ? controller.sendCodeWithEmailPhone
                      : controller.sendCodeWithUsername,
                  height: 51,
                  borderRadius: 80,
                  //color: const Color(0xFF0E3B66),
                )),
            const SizedBox(height: 24),
            _OtherOptions(onTap: controller.toggleOtherOption),
            const SizedBox(height: 24),
            _BackToLogin(onTap: () => safeBack()),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _UsernameForm extends GetView<ForgotPasswordController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: controller.usernameCtrl,
          hint: 'Enter your username',
        ),
      ],
    );
  }
}

class _EmailPhoneForm extends GetView<ForgotPasswordController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: controller.emailCtrl,
          hint: 'Enter your Email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 11),
        AppTextField(
          controller: controller.phoneCtrl,
          hint: 'Enter your Phone',
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0E3B66),
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  final String text;
  const _Subtitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF0E3B66),
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _OtherOptions extends StatelessWidget {
  final VoidCallback onTap;
  const _OtherOptions({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        child: const Text(
          'Other Options',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
            fontSize: 12,
            color: Color(0xFF0E3B66),
          ),
        ),
      ),
    );
  }
}

class _BackToLogin extends StatelessWidget {
  final VoidCallback onTap;
  const _BackToLogin({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
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
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF0E3B66),
            ),
          ),
        )
      ],
    );
  }
}
