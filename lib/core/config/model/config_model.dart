class ConfigData {
  ConfigData({
    this.url,
    this.token,
  });

  String? url;
  String? token;

  factory ConfigData.fromJson(dynamic json) {
    return ConfigData(
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
