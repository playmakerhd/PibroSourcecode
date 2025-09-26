class Endpoints {
  // Auth
  static const String login = '/CustomerLoginByID';
  static const String signup = '/CreateCustomerInformation';
  static const String otherLogin = '/CustomerLoginByEmailPhone';

  // Profile
  static const String profile = '/GetCustomerInformationByID';
  static const String profileByEmail = '/GetCustomerInformationByEmailPhone';
  static const String changePassword = '/ChangeCustomerPassword';

  // Policies
  static const String customerPolicies = '/GetInsurancePolicyByCustomerID';
  static const String customerClaims = '/GetInsurancePolicyClaimsByCustomerID';
  static const String getInsuranceBusinessClass = '/GetInsuranceBusinessClass';
  static const String getSingleInsuranceBusinessClass =
      '/GetClmDocsByBusinessClassID';
  static const String getInsuranceRiskType =
      '/GetInsuranceRiskTypeByBusinessClassID';
  static const String renewPolicy = '/InsurancePolicyRenewal';
  static const String updateInsurancePolicy = '/UpdateInsurancePolicyByID';
  // +++ ADD:
  static const String endorsePolicy = '/EndorseInsurancePolicy';
  static const String createClientNoteEndorsement =
      '/CreateInsuranceClientNoteEndorsement';
  static const String bookPolicy = '/InsurancePolicyBooking';
  static const String postPolicy = '/InsurancePolicyPost';
  static const String createClientNote = '/CreateInsuranceClientNote';
  static const String bookClientNote = '/InsuranceClientNoteBooking';
  static const String postClientNote = '/InsuranceClientNotePost';
  static const String createInsurancePolicy = '/CreateInsurancePolicyClient';
  static const String getPremiumAmount = '/GetComputePolicyPremium';
  static const String getPaymentToken = '/GetCompanyPayment';
  static const String createReceipt = '/CreateCustomerReceipts';
  static const String postReceipt = '/CustomerReceiptPost';
  static const String updatePolicyItem = '/UpdateInsurancePolicyItemToInsure';
  static const String createPolicyItem = '/CreateInsurancePolicyItemToInsure';
  static const String createClaims = '/CreateInsurancePolicyClaims';
  static const String claimRecalc = '/InsurancePolicyClaimsRecalc';
  static const String updateClaims = '/UpdateInsurancePolicyClaimsByID';
  static const String uploadClaimDoc = '/UpLoadClaimsDocuments';
  static const String getClaimDocuments = '/GetClaimsDocumentsByID';
  static const String getClaim = '/GetInsurancePolicyClaimsByID';
  static const String sendToBroker = '/createCustomerEnquiry';
  static const String submitClaim = '/SubmitClaim';
  static const String quotes = '/GetCustomerEnquiriesByCustomerID';

  // Transactions
  // Transactions
  static const String getClientNotesByCustomer =
      '/GetInsuranceClientNotesByCustomerID';
  static const String getCustomerTransactions =
      '/GetCustomerTransactionsByCustomer';
  static const String viewCustomerTransactionReport =
      '/ViewCustomerTransactionReport';

  // Vendors / Enquiries
  static const String getVendors = '/GetVendorInformation';
  static const String getCustomerEnquiryById = '/GetCustomerEnquiriesByID';
  static const String updateCustomerEnquiryStatus =
      '/UpdateCustomerEnquiryStatus'; // NEW

  // About Section
  static const String getCompanyInfo = '/GetCompanyInformationByID';
  static const String getCompanyFaq = '/GetCompanyFAQ';
  static const String getCompanyChat = '/GetCompanyChat';
}
