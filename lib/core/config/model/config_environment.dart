class ConfigEnvironment {
  final String name;
  final String url;
  final String token;
  final String? description;

  ConfigEnvironment({
    required this.name,
    required this.url,
    required this.token,
    this.description,
  });

  factory ConfigEnvironment.fromJson(Map<String, dynamic> json) {
    return ConfigEnvironment(
      name: json["name"] ?? '',
      url: json["url"] ?? '',
      token: json["token"] ?? '',
      description: json["description"],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['url'] = url;
    map['token'] = token;
    if (description != null) {
      map['description'] = description;
    }
    return map;
  }

  @override
  String toString() {
    return 'ConfigEnvironment(name: $name, url: $url, token: ${token.substring(0, 5)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConfigEnvironment &&
        other.name == name &&
        other.url == url &&
        other.token == token;
  }

  @override
  int get hashCode => name.hashCode ^ url.hashCode ^ token.hashCode;
}
