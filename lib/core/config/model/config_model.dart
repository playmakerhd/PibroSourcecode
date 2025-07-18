class LoginData {
  LoginData({
    this.url,
    this.token,
  });

  String? url;
  String? token;

  factory LoginData.fromJson(dynamic json) {
    return LoginData(
      url: json["url"],
      token: json["token"],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['url'] = url;
    map['token'] = token;
    return map;
  }
}
