import 'package:pibro/utils/validators.dart';

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(Validators.emailRegex).hasMatch(this);
  }
}

extension PasswordValidator on String {
  bool isValidPassword() {
    return RegExp(Validators.passwordRegex).hasMatch(this);
  }
}
