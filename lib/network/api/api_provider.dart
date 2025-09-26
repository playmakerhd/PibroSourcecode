import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/config/model/config_model.dart';
import 'package:pibro/core/login/model/login_data.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/models/platform_user/platform_user.dart';
import 'package:pibro/network/models/request/auth_request.dart';
import 'package:pibro/network/models/request/change_password_request.dart';
import 'package:pibro/network/models/request/claim_request.dart';
import 'package:pibro/network/models/request/client_note_request.dart';
import 'package:pibro/network/models/request/create_receipt_request.dart';
import 'package:pibro/network/models/request/get_premium_amount_request.dart';
import 'package:pibro/network/models/request/renew_policy_requesst.dart';
import 'package:pibro/network/models/request/update_enquiry_status_request.dart';
import 'package:pibro/network/models/response/base_response.dart';
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
import 'package:pibro/network/models/response/vendor_response.dart';
import 'package:pibro/network/models/response/message_response.dart'; // CustomMessageResponse
import 'package:pibro/network/models/response/quote_by_id_response.dart';
import 'package:pibro/network/models/response/debit_note_list_response.dart';
import 'package:pibro/network/models/response/customer_transactions_response.dart';

import 'package:pibro/utils/api_utils.dart';
import 'package:pibro/utils/app_utils.dart';

import 'package:http/http.dart' as http;
import 'package:pibro/utils/view_utils.dart';

import 'base_provider.dart';
import 'endpoints.dart';

class ApiProvider extends BaseProvider {
  String _baseApiPath = '';
  String _acessToken = '';
  final String _paystackBaseUrl = 'https://api.paystack.co/transaction';

  ApiProvider() {
    ConfigData configData =
        ConfigData.fromJson(convertToJsonStringQuotes(StorageKeys.configData));
    if (configData.url == null || configData.token == null) {
      showSnackbarMessage(
        message: AppStrings.configError.tr,
        isSuccess: false,
      );
      Get.offAllNamed(AppRoutes.serviceConfig);
    } else {
      _baseApiPath = configData.url!;
      _acessToken = configData.token!;
    }
  }

  Future<CustomMessageResponse> callLoginApi(AuthRequest body) async {
    dynamic endpoint = body.isOtherOption
        ? '$_baseApiPath${Endpoints.otherLogin}/${body.email}/${body.phoneNumber}/${body.password}/$_acessToken'
        : '$_baseApiPath${Endpoints.login}/${body.username}/${body.password}/$_acessToken';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return CustomMessageResponse(responseData!);
  }

  Future<CustomMessageResponse> callSignUpApi(AuthRequest body) async {
    final responseData = await makePostCall(
      Uri.parse('$_baseApiPath${Endpoints.signup}?token=$_acessToken'),
      json.encode(body.toSignUpJson()),
      false,
    );
    return CustomMessageResponse(responseData);
  }

  Future<CustomMessageResponse> callChangePasswordApi(
      ChangePasswordRequest body) async {
    // PlatformUser data = PlatformUser.fromJson(
    //     convertToJsonStringQuotes(StorageKeys.profileData));
    PlatformUser data =
        PlatformUser.fromJson(GetStorage().read(StorageKeys.profileData) ?? {});
    dynamic endpoint =
        '$_baseApiPath${Endpoints.changePassword}?EntityID=${data.customerID}&OldPassword=${body.oldPassword}&NewPassword=${body.newPassword}&ConfirmPassword=${body.confirmPassword}&token=$_acessToken';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return CustomMessageResponse(responseData!);
  }

  Future<ProfileResponse> callGetProfile() async {
    LoginData data =
        LoginData.fromJson(convertToJsonStringQuotes(StorageKeys.loginData));
    dynamic endpoint = data.customerID!.isNotEmpty
        ? '$_baseApiPath${Endpoints.profile}/${data.customerID}/$_acessToken'
        : '$_baseApiPath${Endpoints.profileByEmail}/${data.email}/${data.phone}/$_acessToken';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return ProfileResponse(responseData!);
  }

  Future<CustomerPolicyResponse> callGetCustomerPolicies() async {
    // PlatformUser data = PlatformUser.fromJson(
    //     convertToJsonStringQuotes(StorageKeys.profileData));
    PlatformUser data =
        PlatformUser.fromJson(GetStorage().read(StorageKeys.profileData) ?? {});
    dynamic endpoint =
        '$_baseApiPath${Endpoints.customerPolicies}/${data.customerID}/$_acessToken';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return CustomerPolicyResponse(responseData!);
  }

  Future<DebitNoteListResponse> callGetClientNotesByCustomer() async {
    final data =
        PlatformUser.fromJson(GetStorage().read(StorageKeys.profileData) ?? {});
    final endpoint =
        '$_baseApiPath${Endpoints.getClientNotesByCustomer}/${data.customerID}/$_acessToken';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return DebitNoteListResponse(responseData!);
  }

  Future<CustomerTransactionsResponse> callGetCustomerTransactions({
    required String customerID,
    required int pageNum,
    required int size,
    String sortDir = 'desc',
    required String periodFrom,
    required String periodTo,
  }) async {
    final endpoint =
        '$_baseApiPath${Endpoints.getCustomerTransactions}/$_acessToken'
        '?CustomerID=$customerID&PageNum=$pageNum&Size=$size&sortDir=$sortDir'
        '&periodFrom=$periodFrom&periodTo=$periodTo';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return CustomerTransactionsResponse(responseData!);
  }

  Future<QuotesResponse> callGetQuotes() async {
    // PlatformUser data = PlatformUser.fromJson(
    //     convertToJsonStringQuotes(StorageKeys.profileData));
    PlatformUser data =
        PlatformUser.fromJson(GetStorage().read(StorageKeys.profileData) ?? {});
    dynamic endpoint =
        '$_baseApiPath${Endpoints.quotes}/${data.customerID}/$_acessToken?PageNum=1&Size=50&SupportType=Quote';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return QuotesResponse(responseData!);
  }

  Future<CustomerPolicyClaimsResponse> callGetCustomerClaims() async {
    // PlatformUser data = PlatformUser.fromJson(
    //     convertToJsonStringQuotes(StorageKeys.profileData));
    PlatformUser data =
        PlatformUser.fromJson(GetStorage().read(StorageKeys.profileData) ?? {});
    dynamic endpoint =
        '$_baseApiPath${Endpoints.customerClaims}/${data.customerID}/$_acessToken';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return CustomerPolicyClaimsResponse(responseData!);
  }

  Future<BusinessPolicyResponse> callGetInsuranceBusinessClass() async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.getInsuranceBusinessClass}/$_acessToken?PageNum=1&Size=100';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return BusinessPolicyResponse(responseData!);
  }

  Future<InsuranceRiskTypeResponse> callGetInsuranceRiskType(
      String businessID) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.getInsuranceRiskType}/$businessID/$_acessToken';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return InsuranceRiskTypeResponse(responseData!);
  }

  // Vendors
  Future<VendorResponse> callGetVendors() async {
    final endpoint =
        '$_baseApiPath${Endpoints.getVendors}/$_acessToken?PageNum=1&Size=100';
    final resp = await makeGetCall(Uri.parse(endpoint), false);
    return VendorResponse(resp!);
  }

  // Enquiry by ID (returns QuoteInfo with SupportResolution/SupportScreenShotURL)
  Future<QuoteByIdResponse> callGetCustomerEnquiryById(String caseId) async {
    final endpoint =
        '$_baseApiPath${Endpoints.getCustomerEnquiryById}/$caseId/$_acessToken';
    final resp = await makeGetCall(Uri.parse(endpoint), false);
    return QuoteByIdResponse(resp!);
  }

  // Create Policy (new policy path after Paystack)
  Future<CustomMessageResponse> callCreateInsurancePolicyClient(
      Map<String, dynamic> body) async {
    final endpoint =
        '$_baseApiPath${Endpoints.createInsurancePolicy}?token=$_acessToken';
    final resp =
        await makePostCall(Uri.parse(endpoint), jsonEncode(body), false);
    return CustomMessageResponse(resp);
  }

  // Book/Post policy by ID (new policy path convenience)
  Future<CustomMessageResponse> callBookPolicyById(String id) async {
    final endpoint = '$_baseApiPath${Endpoints.bookPolicy}?token=$_acessToken';
    final resp = await makePostCall(
        Uri.parse(endpoint), jsonEncode({"PolicyBrokerID": id}), false);
    return CustomMessageResponse(resp);
  }

  Future<CustomMessageResponse> callPostPolicyById(String id) async {
    final endpoint = '$_baseApiPath${Endpoints.postPolicy}?token=$_acessToken';
    final resp = await makePostCall(
        Uri.parse(endpoint), jsonEncode({"PolicyBrokerID": id}), false);
    return CustomMessageResponse(resp);
  }

  Future<CustomMessageResponse> callRenewPolicy(PolicyData data) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.renewPolicy}?token=$_acessToken';
    final responseData = await makePostCall(
        Uri.parse(endpoint), jsonEncode(data.toJson()), false);
    return CustomMessageResponse(responseData);
  }

  Future<CustomMessageResponse> callUpdatePolicy(
      RenewPolicyRequest data) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.updateInsurancePolicy}?token=$_acessToken';
    final responseData = await makePostCall(
        Uri.parse(endpoint), jsonEncode(data.toJson()), false);
    return CustomMessageResponse(responseData);
  }

  Future<CustomMessageResponse> callBookPolicy(RenewPolicyRequest data) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.bookPolicy}?token=$_acessToken';
    final responseData = await makePostCall(
        Uri.parse(endpoint), jsonEncode(data.toJson()), false);
    return CustomMessageResponse(responseData);
  }

  Future<CustomMessageResponse> callPostPolicy(RenewPolicyRequest data) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.postPolicy}?token=$_acessToken';
    final responseData = await makePostCall(
        Uri.parse(endpoint), jsonEncode(data.toJson()), false);
    return CustomMessageResponse(responseData);
  }

  Future<CustomMessageResponse> callCreateClientNote(
      ClientNoteRequest data) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.createClientNote}?token=$_acessToken';
    final requestBody = ApiUtils.notePayload(data);
    final responseData =
        await makePostCall(Uri.parse(endpoint), jsonEncode(requestBody), false);
    return CustomMessageResponse(responseData);
  }

  // Endorse policy – returns additional premium in Message
  Future<CustomMessageResponse> callEndorsePolicy(
      Map<String, dynamic> body) async {
    final endpoint =
        '$_baseApiPath${Endpoints.endorsePolicy}?token=$_acessToken';
    final resp =
        await makePostCall(Uri.parse(endpoint), jsonEncode(body), false);
    return CustomMessageResponse(resp);
  }

  // Create endorsement debit note (DBN) after payment
  Future<CustomMessageResponse> callCreateClientNoteEndorsement(
      Map<String, dynamic> body) async {
    final endpoint =
        '$_baseApiPath${Endpoints.createClientNoteEndorsement}?token=$_acessToken';
    final resp =
        await makePostCall(Uri.parse(endpoint), jsonEncode(body), false);
    return CustomMessageResponse(resp);
  }

  Future<CustomMessageResponse> callBookClientNote(
      ClientNoteRequest data) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.bookClientNote}?token=$_acessToken';
    final requestBody = ApiUtils.notePayload(data);
    final responseData =
        await makePostCall(Uri.parse(endpoint), jsonEncode(requestBody), false);
    return CustomMessageResponse(responseData);
  }

  Future<CustomMessageResponse> callPostClientNote(
      ClientNoteRequest data) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.postClientNote}?token=$_acessToken';
    final requestBody = ApiUtils.notePayload(data);
    final responseData =
        await makePostCall(Uri.parse(endpoint), jsonEncode(requestBody), false);
    return CustomMessageResponse(responseData);
  }

  Future<CustomMessageResponse> callGetPremiumAmount(
      GetPremiumAmountRequest data) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.getPremiumAmount}/$_acessToken?PolicyBrokerId=${data.brokerId}&PolicyStartDate=${data.startDate}&PolicyEndDate=${data.endDate}';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return CustomMessageResponse(responseData!);
  }

  Future<CustomMessageResponse> callGetPaymentToken() async {
    dynamic endpoint = '$_baseApiPath${Endpoints.getPaymentToken}/$_acessToken';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return CustomMessageResponse(responseData!);
  }

  Future<CustomMessageResponse> callCreateReceipt(
      CreateReceiptRequest data) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.createReceipt}?token=$_acessToken';
    final requestBody = ApiUtils.receiptPayload(data);
    final responseData =
        await makePostCall(Uri.parse(endpoint), jsonEncode(requestBody), false);
    return CustomMessageResponse(responseData);
  }

  Future<CustomMessageResponse> callAddOrUpdateItemToInsure(
      ItemToInsure data, bool isNew) async {
    dynamic endpoint =
        '$_baseApiPath${isNew ? Endpoints.createPolicyItem : Endpoints.updatePolicyItem}?token=$_acessToken';
    final responseData = await makePostCall(
        Uri.parse(endpoint), jsonEncode(data.toJson()), false);
    return CustomMessageResponse(responseData);
  }

  Future<CustomMessageResponse> callPostReceipt(
      CreateReceiptRequest data) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.postReceipt}?token=$_acessToken';
    final requestBody = ApiUtils.receiptPayload(data);
    final responseData =
        await makePostCall(Uri.parse(endpoint), jsonEncode(requestBody), false);
    return CustomMessageResponse(responseData);
  }

  Future<PaymentInitResponse> callInitializePayment(
      String accessToken, int amount) async {
    // PlatformUser data = PlatformUser.fromJson(
    //   convertToJsonStringQuotes(StorageKeys.profileData),
    // );
    PlatformUser data =
        PlatformUser.fromJson(GetStorage().read(StorageKeys.profileData) ?? {});
    var resData = ResponseData();
    dynamic endpoint = '$_paystackBaseUrl/initialize';

    // Defensive email resolution: profile -> explicit stored email -> login data -> default
    String email = (data.customerEmail ?? '').trim();
    if (email.isEmpty) {
      email =
          (GetStorage().read(StorageKeys.userEmail) ?? '').toString().trim();
    }
    if (email.isEmpty) {
      try {
        final ld = LoginData.fromJson(
            convertToJsonStringQuotes(StorageKeys.loginData));
        email = (ld.email ?? '').trim();
      } catch (_) {}
    }
    // Last resort default to avoid Paystack rejecting empty email
    if (email.isEmpty) email = 'no-reply@pibro.com';

    final responseData = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(
        {
          'email': email, // ✅ resolved defensively
          'amount': amount,
          'currency': 'NGN',
        },
      ),
    );
    resData.response = responseData;
    return PaymentInitResponse(resData);
  }

  Future<PaymentVerificationResponse> callVerifyPayment(
      String accessToken, String reference) async {
    var resData = ResponseData();
    dynamic endpoint = '$_paystackBaseUrl/verify/$reference';
    final responseData = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    resData.response = responseData;
    return PaymentVerificationResponse(resData);
  }

  Future<CustomMessageResponse> callCreateClaim(ClaimRequest data) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.createClaims}?token=$_acessToken';
    final requestBody = ApiUtils.createClaim(data);
    final responseData =
        await makePostCall(Uri.parse(endpoint), jsonEncode(requestBody), false);
    return CustomMessageResponse(responseData);
  }

  Future<CustomMessageResponse> callUpdateClaim(ClaimRequest data) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.updateClaims}?token=$_acessToken';
    final requestBody = ApiUtils.createClaim(data);
    final responseData =
        await makePutCall(Uri.parse(endpoint), jsonEncode(requestBody), false);
    return CustomMessageResponse(responseData);
  }

  Future<CustomMessageResponse> callClaimRecalc(ClaimRequest data) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.claimRecalc}?token=$_acessToken';
    final requestBody = ApiUtils.createClaim(data);
    final responseData =
        await makePostCall(Uri.parse(endpoint), jsonEncode(requestBody), false);
    return CustomMessageResponse(responseData);
  }

  Future<CustomMessageResponse> callUploadClaimDoc(ClaimDocument data) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.uploadClaimDoc}?token=$_acessToken';
    // final requestBody = data.map((element) => element.toJson()).toList();
    final responseData = await makePostCall(
        Uri.parse(endpoint), jsonEncode(data.toJson()), false);
    return CustomMessageResponse(responseData);
  }

  Future<ClaimDocumentResponse> callGetClaimDocuments(String id) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.getClaimDocuments}/$_acessToken?BrokerClaimID=$id';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return ClaimDocumentResponse(responseData!);
  }

  Future<PolicyClaimResponse> callGetClaim(String id) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.getClaim}/$_acessToken?BrokerClaimID=$id';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return PolicyClaimResponse(responseData!);
  }

  Future<CompanyInfoResponse> callGetCompanyInformation() async {
    dynamic endpoint = '$_baseApiPath${Endpoints.getCompanyInfo}/$_acessToken';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return CompanyInfoResponse(responseData!);
  }

  Future<CompanyDataResponse> callGetCompanyFaq() async {
    dynamic endpoint = '$_baseApiPath${Endpoints.getCompanyFaq}/$_acessToken';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return CompanyDataResponse(responseData!);
  }

  Future<CompanyDataResponse> callGetCompanyChat() async {
    dynamic endpoint = '$_baseApiPath${Endpoints.getCompanyChat}/$_acessToken';
    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return CompanyDataResponse(responseData!);
  }

  Future<CustomMessageResponse> callSendToBroker(dynamic data) async {
    dynamic endpoint = '$_baseApiPath${Endpoints.sendToBroker}/$_acessToken';
    final responseData =
        await makePostCall(Uri.parse(endpoint), jsonEncode(data), false);
    return CustomMessageResponse(responseData);
  }

  Future<CustomMessageResponse> callSendClaimToBroker(dynamic data) async {
    dynamic endpoint = '$_baseApiPath${Endpoints.sendToBroker}/$_acessToken';
    final responseData =
        await makePostCall(Uri.parse(endpoint), jsonEncode(data), false);
    return CustomMessageResponse(responseData);
  }

  Future<CustomMessageResponse> callSubmitClaim(String claimId) async {
    dynamic endpoint =
        '$_baseApiPath${Endpoints.submitClaim}?token=$_acessToken';
    final responseData =
        await makePostCall(Uri.parse(endpoint), jsonEncode(claimId), false);
    return CustomMessageResponse(responseData);
  }

  Future<CustomMessageResponse> callUpdateCustomerEnquiryStatus(
      UpdateEnquiryStatusRequest data) async {
    final endpoint =
        '$_baseApiPath${Endpoints.updateCustomerEnquiryStatus}/$_acessToken';
    final body = jsonEncode(ApiUtils.updateEnquiryStatusPayload(data));
    final resp = await makePutCall(Uri.parse(endpoint), body, false);
    return CustomMessageResponse(resp);
  }

  Future<CustomMessageResponse> callViewCustomerTransactionReport({
    required String transactionNumber,
    required String reportType,
  }) async {
    final endpoint = '$_baseApiPath${Endpoints.viewCustomerTransactionReport}'
        '?TransactionNumber=$transactionNumber'
        '&ReportType=$reportType'
        '&token=$_acessToken';

    final responseData = await makeGetCall(Uri.parse(endpoint), false);
    return CustomMessageResponse(responseData!);
  }
}
