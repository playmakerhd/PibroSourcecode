class ClientNoteRequest {
  ClientNoteRequest({
    this.policyBrokerID,
    this.startDate,
    this.endDate,
    this.renewalDate,
    this.invoiceDate,
    this.sumInsured,
    this.premiumDue,
    this.invoiceNumber,
  });

  late String? policyBrokerID;
  late String? startDate;
  late String? endDate;
  late String? renewalDate;
  late String? invoiceDate;
  late double? sumInsured;
  late double? premiumDue;
  late String? invoiceNumber;
}
