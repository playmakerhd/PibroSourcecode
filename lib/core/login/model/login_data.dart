class LoginData {
  LoginData({
    this.customerID,
    this.email,
    this.phone,
    this.entityType, // 'LEAD' or 'CUSTOMER'
  });

  String? customerID; // Can be LeadID or CustomerID
  String? email;
  String? phone;
  String? entityType; // 'LEAD' or 'CUSTOMER'

  factory LoginData.fromJson(dynamic json) {
    return LoginData(
      customerID: json['customerID'],
      email: json["email"],
      phone: json["phone"],
      entityType: json["entityType"] ??
          'CUSTOMER', // Default to CUSTOMER for backward compatibility
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['customerID'] = customerID;
    map['email'] = email;
    map['phone'] = phone;
    map['entityType'] = entityType;
    return map;
  }

  bool get isLead => entityType?.toUpperCase() == 'LEAD';
  bool get isCustomer => entityType?.toUpperCase() == 'CUSTOMER';
}
