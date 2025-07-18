class LoginData {
  LoginData({
    this.customerID,
    this.email,
    this.phone,
  });

  String? customerID;
  String? email;
  String? phone;

  factory LoginData.fromJson(dynamic json) {
    return LoginData(
      customerID: json['customerID'],
      email: json["email"],
      phone: json["phone"],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['customerID'] = customerID;
    map['email'] = email;
    map['phone'] = phone;
    return map;
  }
}
