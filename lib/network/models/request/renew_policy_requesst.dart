class RenewPolicyRequest {
  RenewPolicyRequest({
    required this.policyBrokerID,
    this.policyStartDate,
    this.policyEndDate,
    this.renewalDate,
  });

  final String policyBrokerID;
  final String? policyStartDate;
  final String? policyEndDate;
  final String? renewalDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PolicyBrokerID'] = policyBrokerID;
    if (policyStartDate != null) map['PolicyStartDate'] = policyStartDate;
    if (policyEndDate != null) map['PolicyEndDate'] = policyEndDate;
    if (renewalDate != null) map['RenewalDate'] = renewalDate;
    return map;
  }
}
