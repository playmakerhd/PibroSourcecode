import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/policy/views/items_to_insure_screen.dart';
import 'package:pibro/core/policy/views/payment_screen.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/core/profile/widget/profile_button.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/request/client_note_request.dart';
import 'package:pibro/network/models/request/create_receipt_request.dart';
import 'package:pibro/network/models/request/get_premium_amount_request.dart';
import 'package:pibro/network/models/request/renew_policy_requesst.dart';
import 'package:pibro/network/models/response/business_policy_response.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';
import 'package:pibro/network/models/response/insurance_risk_type_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/shared/custom_input/custom_input.dart';
import 'package:pibro/utils/api_utils.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/image_factory.dart';
import 'package:pibro/utils/validators.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class RenewPolicyController extends GetxController {
  PibroRepository pibroRepository =
      PibroRepository(appApiProvider: ApiProvider());
  RxBool businessLoading = false.obs;
  RxBool riskTypeLoading = false.obs;
  RxBool renewPolicyLoading = false.obs;
  RxBool submitQuoteLoading = false.obs;
  RxBool getPremiumAmountLoading = false.obs;
  RxBool paymentLoading = false.obs;

  Rxn<DateTime> startDate = Rxn<DateTime>();
  final TextEditingController startDateController = TextEditingController();
  Rxn<DateTime> endDate = Rxn<DateTime>();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController renewalDateController = TextEditingController();
  final GlobalKey<FormState> addItemFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> renewFormKey = GlobalKey<FormState>();

  final TextEditingController regNoController = TextEditingController();
  final TextEditingController chasisIdController = TextEditingController();
  final TextEditingController engineNoController = TextEditingController();
  final TextEditingController vehicleMakeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  RxList<BusinessPolicy> businessPolicies = RxList<BusinessPolicy>([]);
  Rxn<BusinessPolicy> selectedBusinessPolicy = Rxn<BusinessPolicy>();
  RxList<RiskTypeID> riskTypeIDs = RxList<RiskTypeID>([]);
  Rxn<RiskTypeID> selectedRiskTypeID = Rxn<RiskTypeID>();

  Rxn<PolicyData> policy = Rxn<PolicyData>();
  RxList<ItemToInsure> policyItems = RxList<ItemToInsure>([]);
  RxList<ItemToInsure> newPolicyItems = RxList<ItemToInsure>([]);
  String policyPremiumAmount = '';
  String _accessToken = '';
  CreateReceiptRequest createReceiptRequest = CreateReceiptRequest();
  ClientNoteRequest clientNoteRequest = ClientNoteRequest();
  late RenewPolicyRequest _renewPolicyRequest;

  // PAYMENT
  late InAppWebViewController webViewController;
  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> getInsuranceBusinessClass() async {
    businessLoading.value = true;
    try {
      final response = await pibroRepository.getInsuranceBusinessClass();
      businessPolicies.value = response.businessPolicies;
      selectedBusinessPolicy.value = businessPolicies.firstWhere(
          (item) => item.businessClassID == policy.value!.businessClassID!);
      businessLoading.value = false;
    } catch (e) {
      businessLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  // void selectBusinessClass(dynamic value) {
  //   selectedBusinessPolicy.value = value;
  //   getInsuranceRiskTypeID((value as BusinessPolicy).businessClassID!);
  //   selectedRiskTypeID.value = null;
  // }

  // void selectRiskType(dynamic value) {
  //   selectedRiskTypeID.value = value;
  // }

  Future<void> getInsuranceRiskTypeID() async {
    riskTypeLoading.value = true;
    try {
      final response = await pibroRepository
          .getInsuranceRiskType(policy.value!.businessClassID!);
      // riskTypeIDs.clear();
      riskTypeIDs.value = response.riskTypeIDs;
      selectedRiskTypeID.value = riskTypeIDs
          .firstWhere((item) => item.riskTypeID == policy.value!.riskTypeID!);
      riskTypeLoading.value = false;
    } catch (e) {
      riskTypeLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Future<void> getPremiumAmount() async {
    getPremiumAmountLoading.value = true;
    try {
      final response = await pibroRepository.getPremiumAmount(
        GetPremiumAmountRequest(
          brokerId: policy.value!.policyBrokerID,
          startDate: startDateController.text,
          endDate: endDateController.text,
        ),
      );
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
      } else {
        policyPremiumAmount = response.messageResponse.message;
        Get.to(() => ItemsToInsureScreen(controller: this));
      }
      getPremiumAmountLoading.value = false;
    } catch (e) {
      getPremiumAmountLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  continueRenew() {
    if (renewFormKey.currentState!.validate()) {
      getPremiumAmount();
    }
  }

  void _showSuccessDialog() {
    showAppDialog(
      dismissible: false,
      willPop: false,
      Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ImageFactory.getImage(AppImages.passwordSuccess).render(
              height: 65,
              width: 65,
            ),
            Column(
              children: [
                Text(
                  AppStrings.renewPolicy.tr,
                  style: Styles.semiBoldTextStyle(
                    color: AppColors.white,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  AppStrings.renewPolicySuccess.tr,
                  style: Styles.mediumTextStyle(
                    size: 12,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => Get.offAllNamed(AppRoutes.main),
              child: ProfileButton(
                text: AppStrings.ok.tr,
                height: 25,
                width: 80,
                textColor: AppColors.activeGreen,
                bgColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitQuote() async {
    submitQuoteLoading.value = true;
    try {
      final response = await pibroRepository
          .sendToBroker(ApiUtils.sendPolicyToBroker(policy.value!));
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
      } else {
        _showSuccessDialog();
      }
      submitQuoteLoading.value = false;
    } catch (e) {
      submitQuoteLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Future<void> submitItemToInsure() async {
    Get.toNamed(AppRoutes.renewPolicyConfirmation);
  }

  void addOrUpdateItem({ItemToInsure? data, required bool isNew}) {
    if (addItemFormKey.currentState!.validate()) {
      if (data != null) {
        removeItemFromList(data, isNew ? newPolicyItems : policyItems);
        data.itemsDescription = descriptionController.text;
        data.sumInsured = double.parse(valueController.text);
        data.itemLocation = locationController.text;
        addData(data, isNew);
      } else {
        addData(
          ItemToInsure(
            companyID: policy.value!.companyID,
            departmentID: policy.value!.departmentID,
            divisionID: policy.value!.divisionID,
            policyBrokerID: policy.value!.policyBrokerID,
            manualNumbering: '0',
            brokingSlipItemCount: 0,
            excessAmount: 0.0,
            discount: 0.0,
            itemsDescription: descriptionController.text,
            sumInsured: double.parse(valueController.text),
            itemLocation: locationController.text,
          ),
          isNew,
        );
      }
      _closeSheet();
    }
  }

  addData(ItemToInsure data, bool isNew) {
    isNew ? newPolicyItems.add(data) : policyItems.add(data);
  }

  void removeItemFromList(
      ItemToInsure itemData, RxList<ItemToInsure> itemList) {
    itemList.value = itemList.where((item) => item != itemData).toList();
  }

  Future<void> sendPolicyItems(List<ItemToInsure> list, bool isNew) async {
    try {
      for (var i = 0; i < list.length; i++) {
        await pibroRepository.addOrUpdateItemToInsure(list[i], isNew);
      }
    } catch (e) {
      paymentLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  void clearInputData() {
    regNoController.clear();
    chasisIdController.clear();
    engineNoController.clear();
    vehicleMakeController.clear();
    valueController.clear();
    locationController.clear();
    descriptionController.clear();
  }

  _closeSheet() {
    clearInputData();
    Get.back();
  }

  void populateInputFields(ItemToInsure data) {
    descriptionController.text = data.itemsDescription!;
    valueController.text = data.sumInsured.toString();
    locationController.text = data.itemLocation!;
  }

  void showAddOrUpdateItemSheet({ItemToInsure? data, bool isNew = false}) {
    if (data != null) {
      populateInputFields(data);
    }
    showAppBottomSheet(
      height: 500,
      isDismissible: false,
      child: Form(
        key: addItemFormKey,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: _closeSheet,
                child: Icon(
                  Icons.clear,
                  size: 30,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            // CustomInput(
            //   controller: regNoController,
            //   label: AppStrings.regId.tr,
            //   hint: '',
            //   validator: (value) =>
            //       Validators.requiredValidator(value, AppStrings.regId.tr),
            // ),
            // CustomInput(
            //   controller: chasisIdController,
            //   label: AppStrings.chasisId.tr,
            //   hint: '',
            //   validator: (value) =>
            //       Validators.requiredValidator(value, AppStrings.chasisId.tr),
            // ),
            // CustomInput(
            //   controller: engineNoController,
            //   label: AppStrings.engineNo.tr,
            //   hint: '',
            //   validator: (value) =>
            //       Validators.requiredValidator(value, AppStrings.engineNo.tr),
            // ),
            // CustomInput(
            //   controller: vehicleMakeController,
            //   label: AppStrings.vehicleMake.tr,
            //   hint: '',
            //   validator: (value) => Validators.requiredValidator(
            //       value, AppStrings.vehicleMake.tr),
            // ),
            CustomInput(
              controller: valueController,
              label: AppStrings.value.tr,
              hint: '',
              validator: (value) =>
                  Validators.requiredValidator(value, AppStrings.value.tr),
            ),
            CustomInput(
              controller: locationController,
              label: AppStrings.location.tr,
              hint: '',
              validator: (value) =>
                  Validators.requiredValidator(value, AppStrings.location.tr),
            ),
            CustomInput(
              controller: descriptionController,
              label: AppStrings.description.tr,
              hint: '',
              validator: (value) => Validators.requiredValidator(
                  value, AppStrings.description.tr),
              maxLines: 3,
            ),
            SizedBox(
              height: 20,
            ),
            PolicyButton(
              text: AppStrings.save.tr,
              onPressed: () => addOrUpdateItem(data: data, isNew: isNew),
              height: 50,
              width: queryWidth(null) * 0.5,
              bgColor: AppColors.primaryColor,
            ),
          ],
        ),
      ),
      willPop: false,
    );
  }

  // PAYMENT FUNCTIONALITIES
  Future<void> getPaymentToken() async {
    paymentLoading.value = true;
    try {
      final response = await pibroRepository.getPaymentToken();
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
        paymentLoading.value = false;
      } else {
        _accessToken = response.messageResponse.message;
        initializePayment(response.messageResponse.message);
      }
    } catch (e) {
      paymentLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  int getChargeAmount(String amount) {
    final amountToDouble = double.parse(amount);
    final usualCharge = amountToDouble * 0.015;
    final extraCharge =
        (amountToDouble > 2500 ? (usualCharge + 100) : usualCharge);
    return ((amountToDouble + (extraCharge > 2000 ? 2000 : extraCharge)) * 100)
        .round();
  }

  Future<void> initializePayment(String token) async {
    try {
      final response = await pibroRepository.initializePayment(
          token, getChargeAmount(policyPremiumAmount));
      if (!response.initData.status) {
        showSnackbarMessage(
            message: response.initData.message!, isSuccess: false);
        paymentLoading.value = false;
      } else {
        createReceiptRequest.checkNumber = response.initData.data!.reference;
        Get.to(
          () => PaymentScreen(
              paystackUrl: response.initData.data!.authorizationUrl!),
        );
      }
    } catch (e) {
      paymentLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Future<void> sendItemsToBackend() async {
    if (policyItems.isNotEmpty) {
      await sendPolicyItems(policyItems, false);
    }
    if (newPolicyItems.isNotEmpty) {
      await sendPolicyItems(newPolicyItems, true);
    }
  }

  Future<void> verifyPayment(String reference) async {
    paymentLoading.value = true;
    try {
      final response =
          await pibroRepository.verifyPayment(_accessToken, reference);

      if (response.verificationData.data!.status!.capitalizeFirst !=
          AppConstants.responseSuccess) {
        showSnackbarMessage(
          message: response.verificationData.message!,
          isSuccess: false,
        );
        paymentLoading.value = false;
      } else {
        createReceiptRequest.transactionDate =
            response.verificationData.data!.paidAt;
        createReceiptRequest.amount =
            response.verificationData.data!.amount! ~/ 100;
        createReceiptRequest.systemDate = DateTime.now().toIso8601String();
        createReceiptRequest.documentNumber =
            response.verificationData.data!.reference;
        createReceiptRequest.documentDate =
            response.verificationData.data!.paidAt;
        createReceiptRequest.channel = response.verificationData.data!.channel;
        createReceipt(createReceiptRequest);
      }
    } catch (e) {
      paymentLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  void checkPaymentStatus(String url) {
    if (url.contains("powersoftrd.com/EnterpriseDemo")) {
      Get.back();
      // showSnackbarMessage(message: 'Your transaction was successful!');
      verifyPayment(url.substring(url.length - 10));
    }
  }

  Future<void> createReceipt(CreateReceiptRequest requestData) async {
    try {
      final response = await pibroRepository.createReceipt(requestData);
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
        paymentLoading.value = false;
      } else {
        createReceiptRequest.receiptID = response.messageResponse.message;
        postReceipt(createReceiptRequest);
      }
    } catch (e) {
      paymentLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Future<void> postReceipt(CreateReceiptRequest requestData) async {
    try {
      final response = await pibroRepository.postReceipt(requestData);
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
        paymentLoading.value = false;
      } else {
        await sendItemsToBackend();
        renewPolicy();
      }
    } catch (e) {
      paymentLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Future<void> renewPolicy() async {
    PolicyData dataToSend = policy.value!;
    try {
      final response = await pibroRepository.renewPolicy(dataToSend);
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
        paymentLoading.value = false;
      } else {
        updateInsurancePolicy();
      }
    } catch (e) {
      paymentLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Future<void> updateInsurancePolicy() async {
    _renewPolicyRequest = RenewPolicyRequest(
      policyBrokerID: policy.value!.policyBrokerID,
      policyStartDate: startDate.value!.toIso8601String(),
      policyEndDate: endDate.value!.toIso8601String(),
      renewalDate: endDate.value!.add(Duration(days: 1)).toString(),
    );
    // data.policyStartDate = startDate.value!.toIso8601String();
    // data.policyEndDate = endDate.value!.toIso8601String();
    // data.renewalDate = endDate.value!.add(Duration(days: 1)).toString();
    try {
      final response = await pibroRepository.updatePolicy(_renewPolicyRequest);
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
        paymentLoading.value = false;
      } else {
        bookPolicy();
      }
    } catch (e) {
      paymentLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Future<void> bookPolicy() async {
    try {
      final response = await pibroRepository.bookPolicy(_renewPolicyRequest);
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
        paymentLoading.value = false;
      } else {
        postPolicy();
      }
    } catch (e) {
      paymentLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Future<void> postPolicy() async {
    try {
      final response = await pibroRepository.postPolicy(_renewPolicyRequest);
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
        paymentLoading.value = false;
      } else {
        createClientNote();
      }
    } catch (e) {
      paymentLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Future<void> createClientNote() async {
    clientNoteRequest.policyBrokerID = policy.value!.policyBrokerID;
    clientNoteRequest.startDate = startDate.value!.toIso8601String();
    clientNoteRequest.endDate = endDate.value!.toIso8601String();
    clientNoteRequest.renewalDate =
        endDate.value!.add(Duration(days: 1)).toString();
    clientNoteRequest.sumInsured = policy.value!.sumInsured;
    clientNoteRequest.invoiceDate = createReceiptRequest.transactionDate;
    clientNoteRequest.premiumDue = double.parse(policyPremiumAmount);
    // clientNoteRequest.premiumDue = createReceiptRequest.amount!.toDouble();

    try {
      final response =
          await pibroRepository.createClientNote(clientNoteRequest);
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
        paymentLoading.value = false;
      } else {
        clientNoteRequest.invoiceNumber = response.messageResponse.message;
        bookClientNote(clientNoteRequest);
      }
    } catch (e) {
      paymentLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Future<void> bookClientNote(ClientNoteRequest data) async {
    try {
      final response = await pibroRepository.bookClientNote(data);
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
        paymentLoading.value = false;
      } else {
        postClientNote(data);
      }
    } catch (e) {
      paymentLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Future<void> postClientNote(ClientNoteRequest data) async {
    try {
      final response = await pibroRepository.postClientNote(data);
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
        paymentLoading.value = false;
      } else {
        Get.offNamed(AppRoutes.paymentConfirmation);
      }
    } catch (e) {
      paymentLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Future<void> savePageAsPdf() async {
    try {
      // 1. Capture the widget as an image
      final Uint8List? imageBytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 10),
      );

      if (imageBytes == null) {
        showSnackbarMessage(
            message: 'Failed to capture widget.', isSuccess: false);
        return;
      }

      // 2. Create a PDF document
      final pdf = pw.Document();
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          },
        ),
      );

      // 3. Get the temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          'invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = '${tempDir.path}/$fileName';
      final File file = File(filePath);

      // 4. Save the PDF to the temporary file
      await file.writeAsBytes(await pdf.save());

      // 5. Share the file
      final xFile = XFile(filePath);

      await Share.shareXFiles(
        [xFile],
        text: 'Here is the exported invoice!',
        subject: 'Invoice PDF',
      );
    } catch (e) {
      showSnackbarMessage(
          message: 'Failed to export invoice as PDF: $e', isSuccess: false);
    }
  }

  init() {
    policy.value = Get.arguments as PolicyData;
    // getInsuranceBusinessClass();
    // getInsuranceRiskTypeID();

    policyItems.value = policy.value!.itemsToInsure!;

    startDate.value = DateTime.now();
    endDate.value = DateTime.now().add(Duration(days: 364));
    startDateController.text = formatDate(startDate.value.toString());
    endDateController.text = formatDate(
      endDate.value.toString(),
    );
    renewalDateController.text = formatDate(
      endDate.value!.add(Duration(days: 1)).toString(),
    );
  }

  @override
  void onInit() {
    init();
    super.onInit();
  }

  @override
  void dispose() {
    clearInputData();
    super.dispose();
  }
}
