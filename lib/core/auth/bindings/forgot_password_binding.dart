import 'package:get/get.dart';
import 'package:pibro/core/auth/controller/forgot_password_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    // lazyPut ensures controller is created only when needed and during navigation
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
  }
}
