class CreateReceiptRequest {
  CreateReceiptRequest({
    this.checkNumber,
    this.receiptID,
    this.transactionDate,
    this.systemDate,
    this.amount,
    this.documentNumber,
    this.documentDate,
    this.channel,
  });

  late String? checkNumber;
  late String? receiptID;
  late String? transactionDate;
  late String? systemDate;
  late double? amount;
  late String? documentNumber;
  late String? documentDate;
  late String? channel;
}
