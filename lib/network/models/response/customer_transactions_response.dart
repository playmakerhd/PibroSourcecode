import 'base_response.dart';

class CustomerTransactionsResponse extends CustomBaseResponse {
  CustomerTransactionsResponse(super.responseData);

  late final List<CustomerTransaction> transactions;

  @override
  parseResponseData() {
    final body = getResponseBody();
    transactions = body is List
        ? body
            .map((e) =>
                CustomerTransaction.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <CustomerTransaction>[];
  }
}

class CustomerTransaction {
  final String? companyID;
  final String? divisionID;
  final String? departmentID;
  final String? customerID;
  final String? transactionType;
  final String? transactionNumber;
  final String? transactionDate;
  final double? transactionAmount;
  final String? currencyID;
  final bool? posted;
  final String? targetForm;
  final String? keyField;

  CustomerTransaction({
    this.companyID,
    this.divisionID,
    this.departmentID,
    this.customerID,
    this.transactionType,
    this.transactionNumber,
    this.transactionDate,
    this.transactionAmount,
    this.currencyID,
    this.posted,
    this.targetForm,
    this.keyField,
  });

  factory CustomerTransaction.fromJson(Map<String, dynamic> json) =>
      CustomerTransaction(
        companyID: json['CompanyID']?.toString(),
        divisionID: json['DivisionID']?.toString(),
        departmentID: json['DepartmentID']?.toString(),
        customerID: json['CustomerID']?.toString(),
        transactionType: json['TransactionType']?.toString(),
        transactionNumber: json['TransactionNumber']?.toString(),
        transactionDate: json['TransactionDate']?.toString(),
        transactionAmount: (json['TransactionAmount'] is num)
            ? (json['TransactionAmount'] as num).toDouble()
            : double.tryParse('${json['TransactionAmount'] ?? ''}'),
        currencyID: json['CurrencyID']?.toString(),
        posted: json['Posted'] == true,
        targetForm: json['TargetForm']?.toString(),
        keyField: json['KeyField']?.toString(),
      );
}
