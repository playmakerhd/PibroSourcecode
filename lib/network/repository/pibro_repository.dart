import 'dart:async';

import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/request/auth_request.dart';
import 'package:pibro/network/models/request/change_password_request.dart';
import 'package:pibro/network/models/request/claim_request.dart';
import 'package:pibro/network/models/request/client_note_request.dart';
import 'package:pibro/network/models/request/create_receipt_request.dart';
import 'package:pibro/network/models/request/get_premium_amount_request.dart';
import 'package:pibro/network/models/request/renew_policy_requesst.dart';
import 'package:pibro/network/models/response/business_policy_response.dart';
import 'package:pibro/network/models/response/claim_document_response.dart';
import 'package:pibro/network/models/response/company_data_response.dart';
import 'package:pibro/network/models/response/company_info_response.dart';
import 'package:pibro/network/models/response/customer_policy_claims_response.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';
import 'package:pibro/network/models/response/insurance_risk_type_response.dart';
import 'package:pibro/network/models/response/message_response.dart';
import 'package:pibro/network/models/response/payment_init_response.dart';
import 'package:pibro/network/models/response/payment_verfication_response.dart';
import 'package:pibro/network/models/response/profile_response.dart';
import 'package:pibro/network/models/response/quotes_response.dart';

class PibroRepository {
  ApiProvider appApiProvider;

  PibroRepository({required this.appApiProvider});

  Future<CustomMessageResponse> login(AuthRequest body) async =>
      appApiProvider.callLoginApi(body);

  Future<CustomMessageResponse> signUp(AuthRequest body) async =>
      appApiProvider.callSignUpApi(body);

  Future<CustomMessageResponse> changePassword(
          ChangePasswordRequest body) async =>
      appApiProvider.callChangePasswordApi(body);

  Future<ProfileResponse> getProfile() async => appApiProvider.callGetProfile();

  Future<CustomerPolicyResponse> getCustomerPolicies() async =>
      appApiProvider.callGetCustomerPolicies();

  Future<QuotesResponse> getQuotes() async => appApiProvider.callGetQuotes();

  Future<CustomerPolicyClaimsResponse> getCustomerClaims() async =>
      appApiProvider.callGetCustomerClaims();

  Future<BusinessPolicyResponse> getInsuranceBusinessClass() async =>
      appApiProvider.callGetInsuranceBusinessClass();

  Future<InsuranceRiskTypeResponse> getInsuranceRiskType(
          String businessClassID) async =>
      appApiProvider.callGetInsuranceRiskType(businessClassID);

  Future<CustomMessageResponse> renewPolicy(PolicyData data) async =>
      appApiProvider.callRenewPolicy(data);

  Future<CustomMessageResponse> updatePolicy(RenewPolicyRequest data) async =>
      appApiProvider.callUpdatePolicy(data);

  Future<CustomMessageResponse> bookPolicy(RenewPolicyRequest data) async =>
      appApiProvider.callBookPolicy(data);

  Future<CustomMessageResponse> postPolicy(RenewPolicyRequest data) async =>
      appApiProvider.callPostPolicy(data);

  Future<CustomMessageResponse> createClientNote(
          ClientNoteRequest data) async =>
      appApiProvider.callCreateClientNote(data);

  Future<CustomMessageResponse> bookClientNote(ClientNoteRequest data) async =>
      appApiProvider.callBookClientNote(data);

  Future<CustomMessageResponse> postClientNote(ClientNoteRequest data) async =>
      appApiProvider.callPostClientNote(data);

  Future<CustomMessageResponse> getPremiumAmount(
          GetPremiumAmountRequest data) async =>
      appApiProvider.callGetPremiumAmount(data);

  Future<CustomMessageResponse> getPaymentToken() async =>
      appApiProvider.callGetPaymentToken();

  Future<CustomMessageResponse> createReceipt(
          CreateReceiptRequest data) async =>
      appApiProvider.callCreateReceipt(data);

  Future<CustomMessageResponse> addOrUpdateItemToInsure(
          ItemToInsure data, bool isNew) async =>
      appApiProvider.callAddOrUpdateItemToInsure(data, isNew);

  Future<CustomMessageResponse> postReceipt(CreateReceiptRequest data) async =>
      appApiProvider.callPostReceipt(data);

  Future<PaymentInitResponse> initializePayment(
          String accessToken, int amount) async =>
      appApiProvider.callInitializePayment(accessToken, amount);

  Future<PaymentVerificationResponse> verifyPayment(
          String accessToken, String reference) async =>
      appApiProvider.callVerifyPayment(accessToken, reference);

  Future<CustomMessageResponse> createClaim(ClaimRequest body) async =>
      appApiProvider.callCreateClaim(body);

  Future<CustomMessageResponse> updateClaim(ClaimRequest body) async =>
      appApiProvider.callUpdateClaim(body);

  Future<CustomMessageResponse> claimRecalc(ClaimRequest body) async =>
      appApiProvider.callClaimRecalc(body);

  Future<CustomMessageResponse> uploadClaimDoc(ClaimDocument body) async =>
      appApiProvider.callUploadClaimDoc(body);

  Future<ClaimDocumentResponse> getClaimDocuments(String id) async =>
      appApiProvider.callGetClaimDocuments(id);

  Future<PolicyClaimResponse> getClaim(String id) async =>
      appApiProvider.callGetClaim(id);

  Future<CompanyInfoResponse> getCompanyInformation() async =>
      appApiProvider.callGetCompanyInformation();

  Future<CompanyDataResponse> getCompanyFaq() async =>
      appApiProvider.callGetCompanyFaq();

  Future<CompanyDataResponse> getCompanyChat() async =>
      appApiProvider.callGetCompanyChat();

  Future<CustomMessageResponse> sendToBroker(dynamic body) async =>
      appApiProvider.callSendToBroker(body);

  Future<CustomMessageResponse> sendClaimToBroker(dynamic body) async =>
      appApiProvider.callSendClaimToBroker(body);

  Future<CustomMessageResponse> submitClaim(String body) async =>
      appApiProvider.callSubmitClaim(body);
}
