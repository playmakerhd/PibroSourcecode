import 'dart:developer';

import 'package:pibro/network/models/response/base_response.dart';

class QuotesResponse extends CustomBaseResponse {
  QuotesResponse(super.responseData);

  late List<QuoteInfo> quotes;

  @override
  parseResponseData() {
    try {
      quotes = getResponseBody() != []
          ? List.from(getResponseBody())
              .map((item) => QuoteInfo.fromJson(item))
              .toList()
          : [];
    } catch (e) {
      handleParsingError(e);
    }
  }
}

class QuoteInfo {
  QuoteInfo({
    this.companyID,
    this.divisionID,
    this.departmentID,
    this.caseId,
    this.customerId,
    this.contactId,
    this.productId,
    this.supportManager,
    this.supportAssigned = false,
    this.supportAssignedTo,
    this.supportRequestMethod,
    this.supportStatus,
    this.supportPriority,
    this.supportType,
    this.supportVersion,
    this.supportDate,
    this.supportQuestion,
    this.supportKeywords,
    this.supportDescription,
    this.supportScreenShotURL,
    this.supportResolution,
    this.supportResolutionDate,
    this.supportTimeSpentFixing,
    this.suportNotesPrivate,
    this.supportApproved = false,
    this.supportApprovedBy,
    this.supportEnquiryDate,
    this.supportEnquiryLapseDate,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    this.quoteRequest = false,
    this.requestDetails,
  });

  late String? companyID;
  late String? divisionID;
  late String? departmentID;
  late String? caseId;
  late String? customerId;
  late String? contactId;
  late String? productId;
  late String? supportManager;
  late bool supportAssigned;
  late String? supportAssignedTo;
  late String? supportRequestMethod;
  late String? supportStatus;
  late int? supportPriority;
  late String? supportType;
  late String? supportVersion;
  late String? supportDate;
  late String? supportQuestion;
  late String? supportKeywords;
  late String? supportDescription;
  late String? supportScreenShotURL;
  late String? supportResolution;
  late String? supportResolutionDate;
  late String? supportTimeSpentFixing;
  late String? suportNotesPrivate;
  late bool supportApproved;
  late String? supportApprovedBy;
  late String? supportEnquiryDate;
  late String? supportEnquiryLapseDate;
  late String? contactName;
  late String? contactPhone;
  late String? contactEmail;
  late bool quoteRequest;
  late List<RequestDetails>? requestDetails;

  factory QuoteInfo.fromJson(dynamic json) {
    inspect(json);
    return QuoteInfo(
      companyID: json['CompanyID'],
      divisionID: json['DivisionID'],
      departmentID: json['DepartmentID'],
      caseId: json['CaseId'],
      customerId: json['CustomerId'],
      contactId: json['ContactId'],
      productId: json['ProductId'],
      supportManager: json['SupportManager'],
      supportAssigned: json['SupportAssigned'],
      supportAssignedTo: json['SupportAssignedTo'],
      supportRequestMethod: json['SupportRequestMethod'],
      supportStatus: json['SupportStatus'],
      supportPriority: json['SupportPriority'],
      supportType: json['SupportType'],
      supportVersion: json['SupportVersion'],
      supportDate: json['SupportDate'],
      supportQuestion: json['SupportQuestion'],
      supportKeywords: json['SupportKeywords'],
      supportDescription: json['SupportDescription'],
      supportScreenShotURL: json['SupportScreenShotURL'],
      supportResolution: json['SupportResolution'],
      supportResolutionDate: json['SupportResolutionDate'],
      supportTimeSpentFixing: json['SupportTimeSpentFixing'],
      suportNotesPrivate: json['SuportNotesPrivate'],
      supportApproved: json['SupportApproved'],
      supportApprovedBy: json['SupportApprovedBy'],
      supportEnquiryDate: json['SupportEnquiryDate'],
      supportEnquiryLapseDate: json['SupportEnquiryLapseDate'],
      contactName: json['ContactName'],
      contactPhone: json['ContactPhone'],
      contactEmail: json['ContactEmail'],
      quoteRequest: json['QuoteRequest'],
      requestDetails:
          json['RequestDetails'] != null && json['RequestDetails'] != []
              ? List.from(json['RequestDetails'])
                  .map((item) => RequestDetails.fromJson(item))
                  .toList()
              : [],
    );
  }
}

class RequestDetails {
  RequestDetails({
    this.companyID,
    this.divisionID,
    this.departmentID,
    this.caseID,
    this.subject,
    this.created,
    this.message,
    this.screenShotURL,
    this.lockedBy,
    this.lockTS,
    this.caseIDDetail,
    this.branchCode,
    this.value,
  });

  late String? companyID;
  late String? divisionID;
  late String? departmentID;
  late String? caseID;
  late String? subject;
  late String? created;
  late String? message;
  late String? screenShotURL;
  late String? lockedBy;
  late String? lockTS;
  late int? caseIDDetail;
  late String? branchCode;
  late double? value;

  factory RequestDetails.fromJson(dynamic json) {
    return RequestDetails(
      companyID: json['CompanyID'],
      divisionID: json['DivisionID'],
      departmentID: json['DepartmentID'],
      caseID: json['CaseID'],
      subject: json['Subject'],
      created: json['Created'],
      message: json['Message'],
      screenShotURL: json['ScreenShotURL'],
      lockedBy: json['LockedBy'],
      lockTS: json['LockTS'],
      caseIDDetail: json['CaseIDDetail'],
      branchCode: json['BranchCode'],
      value: json['Value'],
    );
  }
}
