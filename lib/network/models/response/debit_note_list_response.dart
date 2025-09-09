import 'base_response.dart';

class DebitNoteListResponse extends CustomBaseResponse {
  DebitNoteListResponse(super.responseData);

  late final List<DebitNote> notes;

  @override
  parseResponseData() {
    final body = getResponseBody();
    notes = body is List
        ? body
            .map((e) => DebitNote.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <DebitNote>[];
  }
}

class DebitNote {
  final String? companyID;
  final String? divisionID;
  final String? departmentID;
  final String? invoiceNumber;
  final String? noteTypeID;
  final String? policyBrokerID;
  final String? actualPolicyBrokerID;
  final String? endorsementID;
  final String? customerID;
  final String? vendorID;
  final String? businessClassID;
  final String? riskTypeID;
  final String? invoiceDate;
  final String? startDate;
  final String? endDate;
  final String? renewaldate;
  final String? premiumDescription;
  final double? sumInsured;
  final double? premiumDue;

  DebitNote({
    this.companyID,
    this.divisionID,
    this.departmentID,
    this.invoiceNumber,
    this.noteTypeID,
    this.policyBrokerID,
    this.actualPolicyBrokerID,
    this.endorsementID,
    this.customerID,
    this.vendorID,
    this.businessClassID,
    this.riskTypeID,
    this.invoiceDate,
    this.startDate,
    this.endDate,
    this.renewaldate,
    this.premiumDescription,
    this.sumInsured,
    this.premiumDue,
  });

  factory DebitNote.fromJson(Map<String, dynamic> json) => DebitNote(
        companyID: json['CompanyID']?.toString(),
        divisionID: json['DivisionID']?.toString(),
        departmentID: json['DepartmentID']?.toString(),
        invoiceNumber: json['InvoiceNumber']?.toString(),
        noteTypeID: json['NoteTypeID']?.toString(),
        policyBrokerID: json['PolicyBrokerID']?.toString(),
        actualPolicyBrokerID: json['ActualPolicyBrokerID']?.toString(),
        endorsementID: json['EndorsementID']?.toString(),
        customerID: json['CustomerID']?.toString(),
        vendorID: json['VendorID']?.toString(),
        businessClassID: json['BusinessClassID']?.toString(),
        riskTypeID: json['RiskTypeID']?.toString(),
        invoiceDate: json['InvoiceDate']?.toString(),
        startDate: json['StartDate']?.toString(),
        endDate: json['EndDate']?.toString(),
        renewaldate: json['Renewaldate']?.toString(),
        premiumDescription: json['PremiumDescription']?.toString(),
        sumInsured: (json['SumInsured'] is num)
            ? (json['SumInsured'] as num).toDouble()
            : double.tryParse('${json['SumInsured'] ?? ''}'),
        premiumDue: (json['PremiumDue'] is num)
            ? (json['PremiumDue'] as num).toDouble()
            : double.tryParse('${json['PremiumDue'] ?? ''}'),
      );
}
