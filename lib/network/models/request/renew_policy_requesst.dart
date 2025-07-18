class RenewPolicyRequest {
  RenewPolicyRequest({
    required this.policyBrokerID,
    required this.policyStartDate,
    required this.policyEndDate,
    required this.renewalDate,
  });

  late String policyBrokerID;
  late String policyStartDate;
  late String policyEndDate;
  late String renewalDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PolicyBrokerID'] = policyBrokerID;
    map['PolicyStartDate'] = policyStartDate;
    map['PolicyEndDate'] = policyEndDate;
    map['RenewalDate'] = renewalDate;
    return map;
  }
}
