import 'package:pibro/network/models/response/claim_document_response.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';

class ClaimRequest {
  ClaimRequest({
    required this.accidentDate,
    required this.accidentDetails,
    required this.customerReportDate,
    required this.policy,
    this.claimsID = '',
    this.claimDocuments = const [],
  });

  late String accidentDate;
  late String accidentDetails;
  late String customerReportDate;
  late PolicyData policy;
  late String claimsID;
  late List<ClaimDocument> claimDocuments;
}
