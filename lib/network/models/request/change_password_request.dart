class ChangePasswordRequest {
  ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['oldPassword'] = oldPassword;
    map['newPassword'] = newPassword;
    map['confirmPassword'] = confirmPassword;
    return map;
  }
}
