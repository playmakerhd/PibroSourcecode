import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/login/model/login_data.dart';
import 'package:pibro/network/models/platform_user/platform_user.dart';
import 'package:pibro/network/models/request/claim_request.dart';
import 'package:pibro/network/models/request/client_note_request.dart';
import 'package:pibro/network/models/request/create_receipt_request.dart';
import 'package:pibro/network/models/request/update_enquiry_status_request.dart';
import 'package:pibro/network/models/response/customer_policy_claims_response.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';
import 'package:pibro/network/models/response/quotes_response.dart';
import 'package:pibro/utils/app_utils.dart';

class ApiUtils {
  static Map<String, dynamic> receiptPayload(CreateReceiptRequest requestData) {
    print('🧾 RECEIPT_PAYLOAD: Starting receipt payload creation');
    print(
        '   Receipt ID: ${requestData.receiptID ?? "EMPTY (will be generated)"}');
    print('   Check Number: ${requestData.checkNumber}');
    print('   Amount: ${requestData.amount}');
    print('   Transaction Date: ${requestData.transactionDate}');
    print('   Document Number: ${requestData.documentNumber}');
    print('   Document Date: ${requestData.documentDate}');

    // Safe profile data retrieval with null checks
    final profileData = GetStorage().read(StorageKeys.profileData);
    print('📱 PROFILE_DATA: Raw data from storage: $profileData');

    if (profileData == null) {
      print('❌ PROFILE_DATA: Profile data is null in storage');
      throw Exception('Profile data not found. Please login again.');
    }

    PlatformUser? user;
    try {
      user = PlatformUser.fromJson(profileData);
      print('✅ PROFILE_DATA: User parsed successfully');
      print('   Customer ID: ${user.customerID}');
      print('   User Name: ${user.customerFirstName} ${user.customerLastName}');
      print('   Customer Full Name: ${user.customerFullName}');
      print('   Customer Email: ${user.customerEmail}');
    } catch (e) {
      print('❌ PROFILE_DATA: Failed to parse user data: $e');
      print('   Raw data: $profileData');
      throw Exception('Invalid profile data. Please login again.');
    }

    if (user.customerID == null || user.customerID!.isEmpty) {
      print('❌ PROFILE_DATA: Customer ID is null or empty');
      print(
          '   Available fields: customerID=${user.customerID}, customerName=${user.customerName}');
      throw Exception('Customer ID not found. Please login again.');
    }

    // Validate required request data (NOTE: receiptID can be empty for CREATE, will be populated for POST)
    if (requestData.checkNumber == null || requestData.checkNumber!.isEmpty) {
      print('❌ REQUEST_DATA: Check number is null or empty');
      throw Exception('Check number is required');
    }

    if (requestData.amount == null || requestData.amount! <= 0) {
      print('❌ REQUEST_DATA: Amount is null or zero');
      throw Exception('Valid amount is required');
    }

    if (requestData.transactionDate == null ||
        requestData.transactionDate!.isEmpty) {
      print('❌ REQUEST_DATA: Transaction date is null or empty');
      throw Exception('Transaction date is required');
    }

    // if (requestData.documentNumber == null ||
    //     requestData.documentNumber!.isEmpty) {
    //   print('❌ REQUEST_DATA: Document number is null or empty');
    //   throw Exception('Document number is required');
    // }

    // if (requestData.documentDate == null || requestData.documentDate!.isEmpty) {
    //   print('❌ REQUEST_DATA: Document date is null or empty');
    //   throw Exception('Document date is required');
    // }

    print('✅ REQUEST_DATA: All required fields validated');

    final receiptId = requestData.receiptID ?? '';
    final payload = {
      'CompanyID': user.companyID ?? '',
      'DivisionID': user.divisionID ?? '',
      'DepartmentID': user.departmentID ?? '',
      'ReceiptID': receiptId, // Empty for CREATE, populated for POST
      'ReceiptTypeID': requestData.channel?.capitalizeFirst ?? 'Online',
      'ReceiptClassID': 'Customer',
      'CheckNumber': requestData.checkNumber!,
      'CustomerID': user.customerID!,
      'Memorize': false,
      'TransactionDate': requestData.transactionDate!,
      'SystemDate': requestData.systemDate ?? DateTime.now().toIso8601String(),
      'DueToDate': null,
      'OrderDate': null,
      'CurrencyID': 'NGN',
      'CurrencyExchangeRate': 1.0,
      'Amount': requestData.amount!,
      'UnAppliedAmount': 0.0000,
      'GLBankAccount': '',
      'BankID': 'PayStack',
      'Status': '',
      'NSF': false,
      'Notes': 'Premium Amount Paid',
      'CreditAmount': 0.0000,
      'Cleared': false,
      'Posted': false,
      'Reconciled': false,
      'Deposited': false,
      'HeaderMemo1': null,
      'HeaderMemo2': null,
      'HeaderMemo3': null,
      'HeaderMemo4': null,
      'HeaderMemo5': null,
      'HeaderMemo6': null,
      'HeaderMemo7': null,
      'HeaderMemo8': null,
      'HeaderMemo9': null,
      'Approved': false,
      'ApprovedBy': null,
      'ApprovedDate': null,
      'EnteredBy': user.customerFullName ??
          user.customerName ??
          '${user.customerFirstName ?? ''} ${user.customerLastName ?? ''}',
      'BatchControlNumber': null,
      'BatchControlTotal': null,
      'Signature': null,
      'SignaturePassword': null,
      'SupervisorSignature': null,
      'SupervisorPassword': null,
      'ManagerSignature': null,
      'ManagerPassword': null,
      'LockedBy': null,
      'LockTS': null,
      'TaxGroupID': null,
      'TaxAmount': null,
      'CustomerName': user.customerFullName ?? user.customerName,
      'BranchCode': null,
      'customerReceiptsDetail': [
        {
          'CompanyID': user.companyID ?? '',
          'DivisionID': user.divisionID ?? '',
          'DepartmentID': user.departmentID ?? '',
          'ReceiptID': receiptId, // Empty for CREATE, populated for POST
          'ReceiptDetailID': 0,
          'DocumentNumber': requestData.checkNumber!,
          'DocumentDate': requestData.transactionDate!,
          'PaymentID': null,
          'PayedID': null,
          'CurrencyID': 'NGN',
          'CurrencyExchangeRate': 1.0,
          'DiscountTaken': 0.0000,
          'WriteOffAmount': 0.0000,
          'AppliedAmount': requestData.amount!,
          'Cleared': false,
          'ProjectID': null,
          'DetailMemo1': null,
          'DetailMemo2': null,
          'DetailMemo3': null,
          'DetailMemo4': null,
          'DetailMemo5': null,
          'LockedBy': null,
          'LockTS': null,
          'TaxGroupID': null,
          'TaxAmount': null,
          'TaxRate': null,
          'GLAnalysisType1': null,
          'GLAnalysisType2': null,
          'AssetID': null,
          'CommissionRate': null,
          'CommissionType': null,
          'PaidAmount': null,
          'BranchCode': null
        }
      ]
    };

    print('✅ RECEIPT_PAYLOAD: Payload created successfully');
    print('   Customer ID: ${payload['CustomerID']}');
    print(
        '   Receipt ID: $receiptId ${receiptId.isEmpty ? "(EMPTY - for CREATE)" : "(POPULATED - for POST)"}');
    print('   Amount: ${payload['Amount']}');
    print('   Check Number: ${payload['CheckNumber']}');
    print('   Customer Name: ${payload['CustomerName']}');

    return payload;
  }

  static Map<String, dynamic> notePayload(ClientNoteRequest requestData) {
    // PlatformUser user = PlatformUser.fromJson(
    //     convertToJsonStringQuotes(StorageKeys.profileData));
    PlatformUser user =
        PlatformUser.fromJson(GetStorage().read(StorageKeys.profileData) ?? {});
    return {
      'CompanyID': '',
      'DivisionID': '',
      'DepartmentID': '',
      'InvoiceNumber': requestData.invoiceNumber ?? '',
      'NoteTypeID': 'DBN',
      'PolicyBrokerID': requestData.policyBrokerID,
      'ActualPolicyBrokerID': 'HOGGNIG/GPA/2017/MAR/10018',
      'PolicyUnderwriterID': 'NGPA/600021/KD ',
      'PackagePololicyID': null,
      'EndorsementID': null,
      'CustomerID': user.customerID,
      'VendorID': 'NEM',
      'BusinessClassID': 'GPA',
      'RiskTypeID': 'GPA',
      'InvoiceDate': requestData.invoiceDate,
      'StartDate': requestData.startDate,
      'EndDate': requestData.endDate,
      'Renewaldate': requestData.renewalDate,
      'PremiumDescription': 'PREMIUM PAID',
      'SumInsured': requestData.sumInsured,
      'BasicRate': 0.0000,
      'PremiumFomular': 'FLAT',
      'PremiumDue': requestData.premiumDue,
      'BrokerCommissionRate': 20.0000,
      'BrokerCommisson': 625.0000,
      'VATRate': 5.0000,
      'VATDue': 420.6200,
      'NetDue': 33228.9800,
      'PremiumTypeID': null,
      'ContractTypeID': 'ANN',
      'IncomeTypeID': 'RNL',
      'NoteStatus': null,
      'GenerateBy': 'AJALAO',
      'ApprovedBy': 'ADMIN',
      'ProjectTypeID': 'KD2010',
      'ProjectID': 'KD20101',
      'CurrencyID': 'NGN',
      'CurrencyExchangeRate': 1.0000,
      'TaxGroupID': null,
      'Cleared': true,
      'ClearedBy': 'AJALAO',
      'ClearedDate': '2019-01-08T09:39:44.813',
      'Void': false,
      'VoidBy': null,
      'VoidDate': null,
      'Posted': true,
      'PostedBy': null,
      'PostedDate': '2019-01-08T10:20:13.577',
      'FlatAmount': false,
      'EnteredDate': null,
      'CoverStart': '2017-04-01T00:00:00',
      'NoteFormularDesc': null,
      'CustomerName': 'UNITEX LIMITED',
      'EmployeeID': 'AKINADER',
      'ReceiptID': '30748',
      'ReceiptAmount': 42062.0,
      'BankID': null,
      'PaymentDueDate': null,
      'InvoiceDueDate': null,
      'DiscountPercentage': 0.0,
      'DebitNoteFullID': 'DBN/103325/01/19',
      'PremiumWithoutDiscount': 42062.0000,
      'PremiumAfterDiscount': 42062.0000,
      'PremiumAfterAllDeductions': null,
      'PremiumAfterDiscountPlusPPD': 42062.0000,
      'DiscountValue': 0.0000,
      'Quotation': false,
      'PostingDate': null,
      'QuotationCleared': null,
      'QuotationClearedDate': null,
      'QuotationClearedBy': null,
      'ReportHeaderDescription': null,
      'ReInsurance': null,
      'InsuranceNoteGeneratedDetails': [
        {
          'CompanyID': '',
          'DivisionID': '',
          'DepartmentID': '',
          'InvoiceNumber': '',
          'InvoiceLineNumber': 0,
          'PolicyBrokerID': requestData.policyBrokerID,
          'NoteTypeID': 'DBN',
          'ActualPolicyBrokerID': null,
          'PolicyUnderwriterID': null,
          'DetailDescription': 'PREMIUM PAID',
          'PremiumFomular': null,
          'SumInsured': requestData.sumInsured,
          'PremiumDue': requestData.premiumDue,
          'Discount1': 0.0,
          'BrokerCommissionRate': 20.0000,
          'BrokerCommisson': null,
          'VATRate': 5.0000,
          'VATDue': 420.6200,
          'NetDue': 33228.9800,
          'FlatAmount': true,
          'ProjectTypeID': null,
          'ProjectID': null
        }
      ]
    };
  }

  static Map<String, dynamic> createClaim(ClaimRequest requestData) {
    return {
      "CompanyID": requestData.policy.companyID,
      "DivisionID": requestData.policy.divisionID,
      "DepartmentID": requestData.policy.departmentID,
      "BrokerClaimID": requestData.claimsID,
      "PolicyBrokerID": requestData.policy.policyBrokerID,
      "ActualBrokerClaimID": null,
      "ActualPolicyBrokerID": null,
      "TransactionID": 0,
      "UnderwriterClaimID": null,
      "BusinessClassID": requestData.policy.businessClassID,
      "RiskTypeID": requestData.policy.riskTypeID,
      "CustomerID": requestData.policy.customerID,
      "CustomerName": requestData.policy.customerName,
      "VendorID": requestData.policy.vendorID,
      "StartDate": requestData.policy.policyStartDate,
      "EndDate": requestData.policy.policyEndDate,
      "AccidentDate": requestData.accidentDate,
      "AccidentDetails": requestData.accidentDetails,
      "ThirdPartyInvolved": null,
      "ThirdPartyClaimNo": null,
      "CustomerReportDate": requestData.customerReportDate,
      "BrokerUnderwriterDate": null,
      "AdjusterAppointedDate": null,
      "AdjusterReportDate": null,
      "AdjusterReportApproveDate": null,
      "DVNumber": null,
      "DVReceiveBrokerDate": null,
      "DvReceivedBroker": null,
      "DVReceiveCustomerDate": null,
      "DVReceiveCustomer": null,
      "DVReturnCustomerDate": null,
      "DVReturnedCustomer": null,
      "DVBackVendorDate": null,
      "DVBackVendor": null,
      "DVPaymentReceiveCustomer": null,
      "DVCustomerPayments": null,
      "CustomerEstimate": null,
      "AdjusterEstimate": null,
      "DVAmount": null,
      "TotalReceived": null,
      "ClaimsStatus": null,
      "Settlementdelayby": null,
      "ReasonforDelay": null,
      "ClaimsRepudated": null,
      "RepudateReason": null,
      "RepudateDate": null,
      "EnteredBy": requestData.policy.enteredBy,
      "EnteredBy2": null,
      "DocumentsRequired": 0,
      "DocumentsDelivered": 0,
      "DocumentsOutstanding": 0,
      "DocumentStutus": "",
      "DVTO": null,
      "DVAttn": null,
      "DvLetterDate": null,
      "FirSignPost": null,
      "SecSignPost": null,
      "ReportSubmitted": null,
      "NotificationName": null,
      "Individual": null,
      "InspectionSite": null,
      "SecondSignatory": null,
      "ProjectTypeID": null,
      "ProjectID": null,
      "RegisteredDate": null,
      "Closed": null,
      "ClosedBY": null,
      "ClosedDate": null,
      "BrokerID": null,
      "ClaimCloseTypeID": null,
      "LastUpdateDate": DateTime.now().toString(),
      "Cleared": null,
      "ClearedBy": null,
      "ClearedDate": null,
      "Approved": null,
      "ApprovedBy": null,
      "ApprovedDate": null,
      "Void": null,
      "VoidBy": null,
      "VoidDate": null,
      "UnderwriterPolicyID": null,
      "InsuranceCategoryID": null,
      "BranchCode": null,
      "SubmitClaim": null,
      "InsuranceClaimsDocument": requestData.claimDocuments,
    };
  }

  static Map<String, dynamic> createQuote(
    String product,
    String businessClassID,
    String businessClassName,
    String startDate,
    String endDate,
    String renewalDate,
    List<Map<String, dynamic>> itemsToInsure, {
    String? vendorID,
    String? vendorName,
  }) {
    LoginData loginData =
        LoginData.fromJson(convertToJsonStringQuotes(StorageKeys.loginData));
    dynamic userId = decryptData(StorageKeys.signupData);

    // Format dates for human-readable display in SupportDescription
    String formatPrettyDate(String dateStr) {
      try {
        final dt = DateTime.tryParse(dateStr);
        if (dt != null) {
          return DateFormat('MMM dd, yyyy').format(dt);
        }
      } catch (_) {}
      return dateStr;
    }

    // Format dates for display, but keep originals for API fields
    String prettyStartDate = formatPrettyDate(startDate);
    String prettyEndDate = formatPrettyDate(endDate);
    String prettyRenewalDate = formatPrettyDate(renewalDate);

    return {
      "CompanyID": "",
      "DivisionID": "",
      "DepartmentID": "",
      "CaseId": "",
      "CustomerId": userId ?? loginData.customerID,
      "ProductId": product,
      "SupportDate": DateTime.now().toIso8601String(),
      // Human readable keywords (use name) but persist canonical ID in SupportRequestMethod
      "SupportKeywords": "Quote, $businessClassName, $product",
      "SupportRequestMethod":
          businessClassID, // <- BCID persisted here for backend
      "SupportDescription":
          "Start Date: $prettyStartDate, End Date: $prettyEndDate, Renewal Date: $prettyRenewalDate, VendorID: $vendorID",
      "SupportScreenShotURL": "",
      "SupportEnquiryDate": startDate,
      "SupportEnquiryLapseDate": endDate,
      "SupportType": "Quote",
      "SupportStatus": "Pending",
      "SupportPriority": 64,
      "SupportApproved": true,
      "SupportApprovedBy": "Admin",
      "SupportAssigned": true,

      // ✅ Persist vendor in structured fields as well as the description
      "SupportAssignedTo": vendorID ?? "",
      "SupportManager": vendorName ?? (vendorID ?? ""),
      "ContactName": loginData.customerID ?? "",
      "ContactPhone": loginData.phone ?? "",
      "ContactEmail": loginData.email ?? "",
      "QuoteRequest": true,
      "RequestDetails": itemsToInsure,
    };
  }

  static Map<String, dynamic> sendClaimToBroker(
    PolicyClaim claim,
  ) {
    LoginData loginData = LoginData.fromJson(
      convertToJsonStringQuotes(StorageKeys.loginData),
    );
    final itemList =
        claim.claimsDocuments!.map((item) => item.toBrokerJson()).toList();
    InsurancePolicyUnderwriter? writer =
        claim.insurancePolicyUnderwriters!.isEmpty
            ? null
            : claim.insurancePolicyUnderwriters!.reduce((current, next) {
                return ((current.apportionment ?? 0.0) >
                        (next.apportionment ?? 0.0))
                    ? current
                    : next;
              });
    return {
      "CompanyID": claim.companyID,
      "DivisionID": claim.divisionID,
      "DepartmentID": claim.departmentID,
      "CaseId": "",
      "CustomerId": loginData.customerID,
      "ProductId": claim.riskTypeID,
      "SupportDate": DateTime.now().toIso8601String(),
      "SupportKeywords":
          "Claims lodgement ${claim.brokerClaimID} for ${claim.businessClassID} class: ${claim.riskTypeID}",
      "SupportDescription":
          "PolicyBrokerID: ${claim.policyBrokerID}, Occurrence Date: ${claim.accidentDate},${writer == null ? '' : ' Lead insurer: ${writer.vendorName},'} Lodgement date: ${claim.customerReportDate}, Narration: ${claim.accidentDetails}",
      "SupportScreenShotURL": "",
      "SupportEnquiryDate": claim.startDate,
      "SupportEnquiryLapseDate": claim.endDate,
      "SupportPriority": 64,
      "SupportApproved": true,
      "SupportType": "Claims",
      "SupportStatus": "Pending",
      "SupportApprovedBy": "Admin",
      "SupportAssigned": true,
      "ContactName": loginData.customerID,
      "ContactPhone": loginData.phone,
      "ContactEmail": loginData.email,
      "QuoteRequest": true,
      "RequestDetails": itemList,
    };
  }

  static Map<String, dynamic> sendPolicyToBroker(PolicyData policyData) {
    LoginData loginData =
        LoginData.fromJson(convertToJsonStringQuotes(StorageKeys.loginData));
    dynamic userId = decryptData(StorageKeys.signupData);
    final itemList =
        policyData.itemsToInsure!.map((item) => item.toJson()).toList();

    // Format dates for human-readable display in SupportDescription
    String formatPrettyDate(String dateStr) {
      try {
        final dt = DateTime.tryParse(dateStr);
        if (dt != null) {
          return DateFormat('MMM dd, yyyy').format(dt);
        }
      } catch (_) {}
      return dateStr;
    }

    // Format dates for display, but keep originals for API fields
    String prettyStartDate = formatPrettyDate(policyData.policyStartDate ?? '');
    String prettyEndDate = formatPrettyDate(policyData.policyEndDate ?? '');
    String prettyRenewalDate = formatPrettyDate(policyData.renewalDate ?? '');

    return {
      "CompanyID": policyData.companyID,
      "DivisionID": policyData.divisionID,
      "DepartmentID": policyData.departmentID,
      "CaseId": "",
      "CustomerId": userId ?? loginData.customerID,
      "ProductId": policyData.riskTypeID,
      "SupportDate": DateTime.now().toIso8601String(),
      "SupportKeywords":
          "Quote, ${policyData.businessClassID}, ${policyData.riskTypeID}",
      "SupportDescription":
          "PolicyBrokerID: ${policyData.policyBrokerID}, New Start Date: ${prettyStartDate}, New End Date: ${prettyEndDate}, Renewal Date: ${prettyRenewalDate}",
      "SupportScreenShotURL": "",
      "SupportEnquiryDate": policyData.policyStartDate,
      "SupportEnquiryLapseDate": policyData.policyEndDate,
      "SupportPriority": 64,
      "SupportApproved": true,
      "SupportApprovedBy": "Admin",
      "SupportAssigned": true,
      "SupportType": "Policy Renewal",
      "SupportStatus": "Pending",
      "ContactName": loginData.customerID ?? "",
      "ContactPhone": loginData.phone ?? "",
      "ContactEmail": loginData.email ?? "",
      "QuoteRequest": true,
      "RequestDetails": itemList,
    };
  }

  static Map<String, dynamic> updateEnquiryStatusPayload(
      UpdateEnquiryStatusRequest req) {
    return {
      "CaseID": req.caseID, // exact casing required by backend
    };
  }
}

String getQuoteClass(QuoteInfo quote) {
  return quote.supportKeywords!.split(', ')[1];
}

List<String> getQuoteItemsData(RequestDetails details) {
  List<String> splittedMessage = details.message!.split(', ');
  return [
    splittedMessage[1].split(': ')[1],
    splittedMessage[2].split(': ')[1],
    splittedMessage[3].split(': ')[1],
  ];
}

List<String> getQuoteDates(QuoteInfo quote) {
  String startDate = '';
  String endDate = '';
  String renewalDate = '';

  // Get the description where dates are stored
  final description = quote.supportDescription ?? '';

  // First try to find dates with named fields
  final startPattern =
      RegExp(r'Start Date:?\s*([\w\d\s,.:T+-]+)', caseSensitive: false);
  final endPattern =
      RegExp(r'End Date:?\s*([\w\d\s,.:T+-]+)', caseSensitive: false);
  final renewalPattern =
      RegExp(r'Renewal Date:?\s*([\w\d\s,.:T+-]+)', caseSensitive: false);
  final newStartPattern =
      RegExp(r'New Start Date:?\s*([\w\d\s,.:T+-]+)', caseSensitive: false);
  final newEndPattern =
      RegExp(r'New End Date:?\s*([\w\d\s,.:T+-]+)', caseSensitive: false);

  // Extract named dates if available
  var match = newStartPattern.firstMatch(description) ??
      startPattern.firstMatch(description);
  if (match != null) {
    startDate = match.group(1)?.trim() ?? '';
    if (startDate.endsWith(','))
      startDate = startDate.substring(0, startDate.length - 1).trim();
  }

  match = newEndPattern.firstMatch(description) ??
      endPattern.firstMatch(description);
  if (match != null) {
    endDate = match.group(1)?.trim() ?? '';
    if (endDate.endsWith(','))
      endDate = endDate.substring(0, endDate.length - 1).trim();
  }

  match = renewalPattern.firstMatch(description);
  if (match != null) {
    renewalDate = match.group(1)?.trim() ?? '';
    if (renewalDate.endsWith(','))
      renewalDate = renewalDate.substring(0, renewalDate.length - 1).trim();
  }

  // If not found by name, look for date patterns in sequence (prioritize MMM dd, yyyy format)
  if (startDate.isEmpty || endDate.isEmpty || renewalDate.isEmpty) {
    // First try to find human-readable dates (Aug 28, 2025)
    RegExp prettyDatePattern = RegExp(r'([A-Za-z]{3} \d{1,2}, \d{4})');
    Iterable<Match> matches = prettyDatePattern.allMatches(description);
    List<String> dates =
        matches.map((match) => match.group(0)!.trim()).toList();

    // If found, use them in sequence
    if (dates.isNotEmpty) {
      if (startDate.isEmpty) startDate = dates[0];
      if (endDate.isEmpty && dates.length > 1) endDate = dates[1];
      if (renewalDate.isEmpty && dates.length > 2) renewalDate = dates[2];
    }

    // If still not complete, try ISO dates as fallback
    if (startDate.isEmpty || endDate.isEmpty || renewalDate.isEmpty) {
      RegExp isoPattern =
          RegExp(r'(\d{4}-\d{2}-\d{2}(?:T\d{2}:\d{2}:\d{2}(?:\.\d{3})?)?)');
      matches = isoPattern.allMatches(description);
      dates = matches.map((match) => match.group(0)!.trim()).toList();

      if (startDate.isEmpty && dates.isNotEmpty) startDate = dates[0];
      if (endDate.isEmpty && dates.length > 1) endDate = dates[1];
      if (renewalDate.isEmpty && dates.length > 2) renewalDate = dates[2];
    }
  }

  // Use supportEnquiryDate/supportEnquiryLapseDate as fallbacks
  if (startDate.isEmpty && quote.supportEnquiryDate?.isNotEmpty == true) {
    startDate = quote.supportEnquiryDate!;
  }

  if (endDate.isEmpty && quote.supportEnquiryLapseDate?.isNotEmpty == true) {
    endDate = quote.supportEnquiryLapseDate!;
  }

  // Calculate renewal date if still missing
  if (renewalDate.isEmpty && endDate.isNotEmpty) {
    try {
      DateTime? dt;
      // Try to parse the end date in various formats
      if (endDate.contains(',')) {
        try {
          dt = DateFormat('MMM dd, yyyy').parse(endDate);
        } catch (_) {}
      }
      if (dt == null) {
        dt = DateTime.tryParse(endDate);
      }

      if (dt != null) {
        // Return renewal in same format as end date
        if (endDate.contains(',')) {
          renewalDate = DateFormat('MMM dd, yyyy')
              .format(dt.add(const Duration(days: 1)));
        } else {
          renewalDate = dt.add(const Duration(days: 1)).toIso8601String();
        }
      }
    } catch (_) {}
  }

  return [startDate, endDate, renewalDate];
}

double getQuoteSum(QuoteInfo quote) {
  return quote.requestDetails!.isEmpty
      ? 0.0
      : quote.requestDetails!
          .fold(0.0, (sum, item) => sum + (item.value ?? 0.0));
}
