class ItemData {
  ItemData({
    this.caseID,
    this.subject,
    this.message,
    this.screenShotURL,
    this.caseIDDetail,
    this.value,
    this.location,
    this.description,
    this.regNo,
    this.chasisId,
    this.engineNo,
    this.vehicleMake,
  });

  String? caseID;
  String? subject;
  String? message;
  String? screenShotURL;
  String? caseIDDetail;
  String? value;
  String? location;
  String? description;
  String? regNo;
  String? chasisId;
  String? engineNo;
  String? vehicleMake;

  factory ItemData.fromJson(dynamic json) {
    return ItemData(
      caseID: json['CaseID'],
      subject: json['Subject'],
      message: json['Message'],
      screenShotURL: json['ScreenShotURL'],
      caseIDDetail: json['CaseIDDetail'],
      value: json['Value'],
    );
  }

  Map<String, dynamic> toJson() {
    String computedMessage =
        '$subject, Value: N$value, Location: $location, Description: $description';
    final map = <String, dynamic>{};
    map['CaseID'] = caseID ?? '';
    map['Subject'] = subject;
    map['Message'] = computedMessage;
    map['ScreenShotURL'] = screenShotURL ?? '';
    map['CaseIDDetail'] = 0;
    map['Value'] = value;
    return map;
  }

  Map<String, dynamic> toMotorJson() {
    String computedMessage =
        '$subject, Value: N$value, Location: $location, Description: $description, Registration Number: $regNo, Chasis ID: $chasisId, Engine Number: $engineNo, Vehicle Make: $vehicleMake';
    final map = <String, dynamic>{};
    map['CaseID'] = caseID ?? '';
    map['Subject'] = subject;
    map['Message'] = computedMessage;
    map['ScreenShotURL'] = screenShotURL ?? '';
    map['CaseIDDetail'] = 0;
    map['Value'] = value;
    return map;
  }
}
