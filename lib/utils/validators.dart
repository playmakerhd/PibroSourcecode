import 'package:get/get.dart';
import 'package:pibro/utils/extensions.dart';

import '../internalization/app_strings.dart';

class Validators {
  // static const String passwordRegex =
  //     r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[!@#\$%&*~]).{8,}$";
  static const String passwordRegex = r"^.{4,20}$";
  static const String emailRegex =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-]+\.[a-zA-Z]+";

  static String? passwordValidator(String? value) {
    if (value!.isEmpty) {
      return AppStrings.inputFieldRequired
          .trParams({'field': AppStrings.password.tr});
    }
    if (!value.isValidPassword()) {
      return AppStrings.inputFieldInvalid
          .trParams({'field': AppStrings.password.tr});
    }
    return null;
  }

  // static String? confirmPasswordValidator(
  //     String? value, String field, String password) {
  //   if (value!.isEmpty) {
  //     return AppStrings.inputFieldRequired.trParams({'field': field});
  //   }
  //   if (password.isNotEmpty && value != password) {
  //     return AppStrings.passwordNotMatch.tr;
  //   }
  //   return null;
  // }

  static String? emailValidator(String? value) {
    if (value!.isEmpty) {
      return AppStrings.inputFieldRequired
          .trParams({'field': AppStrings.email.tr});
    }
    if (value.isNotEmpty && !value.isValidEmail()) {
      return AppStrings.inputFieldInvalid
          .trParams({'field': AppStrings.email.tr});
    }
    return null;
  }

  static String? requiredValidator(dynamic value, String field) {
    if (value == null || (value is String && value.isEmpty)) {
      return AppStrings.inputFieldRequired.trParams({'field': field});
    }
    return null;
  }
}
