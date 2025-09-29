import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
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
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/storage_keys.dart';

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
  bool isQuoteFlow = false;

  Rxn<DateTime> startDate = Rxn<DateTime>();
  final TextEditingController startDateController = TextEditingController();
  Rxn<DateTime> endDate = Rxn<DateTime>();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController renewalDateController = TextEditingController();
  final GlobalKey<FormState> addItemFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> renewFormKey = GlobalKey<FormState>();
  RxBool isPickingFile = false.obs;
  RxString selectedImage = ''.obs;

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

// To make reference available outside the sccope of verifyPayment
  String? lastPaymentReference;
  String? lastPaymentDate;
  int? lastPaymentAmount;

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
    renewPolicyLoading.value = true;
    try {
      // 1) Persist any pending items (edited server items + new local items)
      await sendItemsToBackend();

      // 2) Book policy using ONLY PolicyBrokerID
      final id = policy.value?.policyBrokerID ?? '';
      if (id.isEmpty) {
        showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr,
          isSuccess: false,
        );
        return;
      }

      final bookRes = await pibroRepository.bookPolicyById(id);
      if (bookRes.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
          message: bookRes.messageResponse.message,
          isSuccess: false,
        );
        return;
      }

      // 3) Post policy using ONLY PolicyBrokerID
      final postRes = await pibroRepository.postPolicyById(id);
      if (postRes.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
          message: postRes.messageResponse.message,
          isSuccess: false,
        );
        return;
      }

      // 4) Compute premium
      final prem = await pibroRepository.getPremiumAmount(
        GetPremiumAmountRequest(
          brokerId: id,
          startDate: startDateController.text,
          endDate: endDateController.text,
        ),
      );
      if (prem.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
          message: prem.messageResponse.message,
          isSuccess: false,
        );
        return;
      }
      policyPremiumAmount = prem.messageResponse.message;

      // 5) Pull fresh policy so the confirmation shows updated totals
      await _refreshPolicyFromServer();

      // 6) Navigate to confirmation
      Get.toNamed(AppRoutes.renewPolicyConfirmation);
    } catch (e) {
      showSnackbarMessage(
        message: AppStrings.genericErrorMessage.tr,
        isSuccess: false,
      );
    } finally {
      renewPolicyLoading.value = false;
    }
  }

  Future<void> _refreshPolicyFromServer() async {
    try {
      final all = await pibroRepository.getCustomerPolicies();
      final currentId = policy.value?.policyBrokerID;
      if (currentId == null || currentId.isEmpty) return;

      PolicyData? updated;
      for (final p in all.policies) {
        if (p.policyBrokerID == currentId) {
          updated = p;
          break;
        }
      }

      if (updated != null) {
        policy.value = updated;
        policyItems.value = updated.itemsToInsure ?? [];
        newPolicyItems.clear(); // local staged items are now on server
      }
    } catch (_) {
      // Non-fatal: if refresh fails, we'll still show the existing view
    }
  }

  void addOrUpdateItem({ItemToInsure? data, required bool isNew}) {
    if (addItemFormKey.currentState!.validate()) {
      if (data != null) {
        removeItemFromList(data, isNew ? newPolicyItems : policyItems);
        data.itemsDescription = descriptionController.text;
        data.sumInsured = double.parse(valueController.text);
        data.itemLocation = locationController.text;
        if (selectedImage.value.isNotEmpty) {
          data.policyItems = selectedImage.value; // raw base64
        }
        addData(data, isNew);
      } else {
        addData(
          ItemToInsure(
            companyID: policy.value!.companyID,
            departmentID: policy.value!.departmentID,
            divisionID: policy.value!.divisionID,
            policyBrokerID: policy.value!.policyBrokerID,
            manualNumbering: _nextManualNumbering(),
            brokingSlipItemCount: 0,
            excessAmount: 0.0,
            discount: 0.0,
            itemsDescription: descriptionController.text,
            sumInsured: double.parse(valueController.text),
            itemLocation: locationController.text,
            sectionTypeID: 'SECTIONA', // static per contract
            policyItems: selectedImage.value, // raw base64 (may be empty)
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
    selectedImage.value = '';
  }

  void pickImage() async {
    if (isPickingFile.value) return;
    isPickingFile.value = true;
    try {
      const int maxBytes = 20 * 1024 * 1024; // 20MB
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        final f = result.files.single;
        if (f.size > maxBytes) {
          showSnackbarMessage(
              message: 'Max file size is 20MB', isSuccess: false);
          selectedImage.value = '';
        } else {
          selectedImage.value = base64Encode(f.bytes!); // raw base64
        }
      } else {
        selectedImage.value = '';
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    } finally {
      isPickingFile.value = false;
    }
  }

  _closeSheet() {
    clearInputData();
    Get.back();
  }

  void populateInputFields(ItemToInsure data) {
    descriptionController.text = data.itemsDescription ?? '';
    valueController.text = (data.sumInsured ?? 0).toString();
    locationController.text = data.itemLocation ?? '';
  }

  void previewItemAttachment(ItemToInsure item) {
    final raw = (item.policyItems ?? '');
    if (raw.isEmpty) return;

    try {
      final b64 = raw.contains(',') ? raw.split(',').last : raw;
      final bytes = base64Decode(b64); // Validate base64 first
      final isPdf = b64.startsWith('JVBERi0');

      if (isPdf) {
        // PDF Preview - use a different bottom sheet approach to avoid layout issues
        Get.bottomSheet(
          Container(
            height: queryHeight(null) * 0.85,
            width: queryWidth(null),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppConstants.appRadius),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PDF Preview', style: Styles.mediumTextStyle()),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PdfPreview(
                    allowPrinting: false,
                    allowSharing: false,
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    build: (_) async => bytes,
                  ),
                ),
              ],
            ),
          ),
          isDismissible: true,
          enableDrag: true,
        );
      } else {
        // Image Preview - use the existing method
        showAppBottomSheet(
          height: queryHeight(null) * 0.85,
          isImagePreview: true,
          child: InteractiveViewer(
            child: Image.memory(bytes, fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Unable to display image'),
                  ],
                ),
              );
            }),
          ),
        );
      }
    } catch (e) {
      showSnackbarMessage(message: 'Invalid attachment data', isSuccess: false);
    }
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
                  inputType: TextInputType.number,
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
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: pickImage,
                        child: Text("Add Image/PDF",
                            style: Styles.linkTextStyle()),
                      ),
                      const SizedBox(width: 30),
                      Obx(() {
                        if (selectedImage.value.isEmpty) {
                          return const SizedBox();
                        }

                        // Safely handle base64 validation and display
                        try {
                          final b64 = selectedImage.value.contains(',')
                              ? selectedImage.value.split(',').last
                              : selectedImage.value;

                          // Validate base64 first
                          final bytes = base64Decode(b64);

                          // Check if it's a PDF after successful validation
                          final isPdf = b64.startsWith('JVBERi0');

                          if (isPdf) {
                            return const Expanded(
                              child: Row(children: [
                                Icon(Icons.picture_as_pdf),
                                SizedBox(width: 8),
                                Expanded(
                                    child: Text('PDF attached',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis))
                              ]),
                            );
                          }

                          // Display image safely
                          return Expanded(
                            child: Image.memory(bytes,
                                fit: BoxFit.cover, height: 100,
                                errorBuilder: (context, error, stackTrace) {
                              return SizedBox(
                                height: 100,
                                child: Row(children: [
                                  Icon(Icons.error, color: Colors.red),
                                  SizedBox(width: 8),
                                  Expanded(child: Text('Invalid image data')),
                                ]),
                              );
                            }),
                          );
                        } catch (e) {
                          return Expanded(
                            child: SizedBox(
                              height: 100,
                              child: Row(children: [
                                Icon(Icons.error, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(
                                    child: Text('Invalid attachment data')),
                              ]),
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "File size should not exceed 20MB",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
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
      final data = response.verificationData.data;
      final status = data?.status?.toLowerCase();

      if (status != 'success') {
        showSnackbarMessage(
          message: response.verificationData.message ??
              AppStrings.genericErrorMessage.tr,
          isSuccess: false,
        );
        paymentLoading.value = false;

        // Persist for screens/logs
        lastPaymentReference = data?.reference;
        lastPaymentDate = data?.paidAt ?? DateTime.now().toIso8601String();
        lastPaymentAmount = (data?.amount ?? 0) ~/ 100;
        return;
      }

      // Persist for confirmation screen
      lastPaymentReference = data?.reference;
      lastPaymentDate = data?.paidAt ?? DateTime.now().toIso8601String();
      lastPaymentAmount = (data?.amount ?? 0) ~/ 100;

      // Build receipt from payment
      createReceiptRequest.transactionDate = lastPaymentDate;
      createReceiptRequest.amount = lastPaymentAmount; // kobo → NGN
      createReceiptRequest.systemDate = DateTime.now().toIso8601String();
      createReceiptRequest.channel = "Online";

      // Create + Post receipt (await both); postReceipt will continue the flow
      await createReceipt(createReceiptRequest);
    } catch (e, st) {
      paymentLoading.value = false;
      print('verifyPayment error: $e\n$st');
      showSnackbarMessage(
        message: _extractServerMessage(e), // <- changed here
        isSuccess: false,
      );
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
        await postReceipt(createReceiptRequest); // <- ensure ordering
      }
    } catch (e) {
      paymentLoading.value = false;
      showSnackbarMessage(
        message: _extractServerMessage(e), // <- changed here
        isSuccess: false,
      );
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
        // Renewal path
        updateInsurancePolicy();
      }
    } catch (e) {
      paymentLoading.value = false;
      showSnackbarMessage(
        message: _extractServerMessage(e), // <- changed here
        isSuccess: false,
      );
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
      print(e);
      showSnackbarMessage(
        message: _extractServerMessage(e), // <- changed here
        isSuccess: false,
      );
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
        // ✅ Keep the in-memory policy in sync so UIs show NEW dates
        final String startIso = startDate.value!.toIso8601String();
        final String endIso = endDate.value!.toIso8601String();
        final String renewalIso =
            endDate.value!.add(const Duration(days: 1)).toIso8601String();

        policy.value?.policyStartDate = startIso;
        policy.value?.policyEndDate = endIso;
        policy.value?.renewalDate = renewalIso;
        policy.refresh();

        bookPolicy();
      }
    } catch (e) {
      paymentLoading.value = false;
      print(e);
      showSnackbarMessage(
        message: _extractServerMessage(e), // <- changed here
        isSuccess: false,
      );
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
      print(e);
      showSnackbarMessage(
        message: _extractServerMessage(e), // <- changed here
        isSuccess: false,
      );
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
      print(e);
      showSnackbarMessage(
        message: _extractServerMessage(e), // <- changed here
        isSuccess: false,
      );
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
      print(e);
      showSnackbarMessage(
        message: _extractServerMessage(e), // <- changed here
        isSuccess: false,
      );
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
      print(e);
      showSnackbarMessage(
        message: _extractServerMessage(e), // <- changed here
        isSuccess: false,
      );
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
        // ✅ Navigate here, once, after debit note is posted
        final String nStart = startDate.value!.toIso8601String();
        final String nEnd = endDate.value!.toIso8601String();
        final String nRenew =
            endDate.value!.add(const Duration(days: 1)).toIso8601String();

        if (isQuoteFlow) {
          Get.offNamed(
            AppRoutes.quoteConfirmation,
            arguments: {
              'policyId': policy.value?.policyBrokerID ?? '',
              'paymentReference': lastPaymentReference ?? '',
              'paymentDate': lastPaymentDate ?? '',
              'paymentMethod': 'Card',
              'paymentAmount': lastPaymentAmount ?? 0,
              // ✅ new date overrides
              'newStartDate': nStart,
              'newEndDate': nEnd,
              'newRenewalDate': nRenew,
            },
          );
        } else {
          Get.offNamed(
            AppRoutes.paymentConfirmation,
            arguments: {
              // You weren't passing args before; adding these is backward-compatible.
              'newStartDate': nStart,
              'newEndDate': nEnd,
              'newRenewalDate': nRenew,
            },
          );
        }
      }
    } catch (e) {
      paymentLoading.value = false;
      print(e);
      showSnackbarMessage(
        message: _extractServerMessage(e), // <- changed here
        isSuccess: false,
      );
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
      print(e);
      showSnackbarMessage(
          message: 'Failed to export invoice as PDF: $e', isSuccess: false);
    }
  }

  void init() {
    final args = Get.arguments;

    if (args is PolicyData) {
      // RENEWAL FLOW: a full PolicyData is passed via navigation
      policy.value = args;
      policyItems.value = policy.value!.itemsToInsure ?? [];
    } else {
      // QUOTE FLOW: build a minimal PolicyData from the persisted enquiry
      final enquiry = GetStorage().read(StorageKeys.lastEnquiry) as Map? ?? {};

      final double sumInsured = (enquiry['sumInsured'] is num)
          ? (enquiry['sumInsured'] as num).toDouble()
          : double.tryParse(enquiry['sumInsured']?.toString() ?? '0') ?? 0.0;

      final double premiumAmount = (enquiry['premium'] is num)
          ? (enquiry['premium'] as num).toDouble()
          : double.tryParse(enquiry['premium']?.toString() ?? '0') ?? 0.0;

      policy.value = PolicyData(
        // these three are REQUIRED by your model
        companyID: (enquiry['CompanyID'] ?? 'DEMO').toString(),
        divisionID: (enquiry['DivisionID'] ?? 'DEFAULT').toString(),
        departmentID: (enquiry['DepartmentID'] ?? 'DEFAULT').toString(),

        // minimal identifiers for the screens to render
        policyBrokerID: (enquiry['caseId'] ?? '').toString(),
        businessClassID:
            (enquiry['businessClassID'] ?? enquiry['businessClassName'] ?? '')
                .toString(),
        riskTypeID:
            (enquiry['riskTypeID'] ?? enquiry['riskName'] ?? '').toString(),

        // numeric fields parsed safely
        sumInsured: sumInsured,
        premiumAmount: premiumAmount,
        // itemsToInsure is intentionally omitted here (none in quote flow yet)
      );

      policyItems.clear();
    }

    // Date fields for subsequent flows (kept as before)
    startDate.value = DateTime.now();
    endDate.value = DateTime.now().add(const Duration(days: 364));
    startDateController.text = formatDate(startDate.value.toString());
    endDateController.text = formatDate(endDate.value.toString());
    renewalDateController.text =
        formatDate(endDate.value!.add(const Duration(days: 1)).toString());
  }

  /// Try multiple sources for robustness:
  /// - decryptData(StorageKeys.loginData)  (Map or JSON string)
  /// - GetStorage().read(StorageKeys.loginData)
  /// - GetStorage().read(StorageKeys.profileData)
  /// - GetStorage().read(StorageKeys.signupID)

// --- Error helpers: prefer server-sent messages over generic text ---
  String _extractServerMessage(Object e, {String? fallback}) {
    // Default fallback
    final fb = fallback ?? AppStrings.genericErrorMessage.tr;

    // 1) Try typical HTTP client shapes (e.g. Dio: e.response.data, http: custom)
    try {
      final dynamic de = e;

      // Custom error model with messageResponse?
      final dynamic mr = (de as dynamic).messageResponse;
      final dynamic mrMsg =
          mr is dynamic ? (mr.message ?? mr['message'] ?? mr['Message']) : null;
      if (mrMsg is String && mrMsg.trim().isNotEmpty) return mrMsg.trim();

      // Plain .message field on exception
      final dynamic m = (de as dynamic).message;
      if (m is String && m.trim().isNotEmpty) return m.trim();
    } catch (_) {}

    // 2) Well-known Dart exceptions
    if (e is SocketException) {
      return 'Network error. Please check your connection and try again.';
    }
    if (e is HttpException) return e.message;
    if (e is FormatException) return e.message;

    // 3) String/JSON payload
    final s = e.toString();
    if (s.isNotEmpty) {
      // Try to fish out JSON message from a stringified payload
      final fromString = _messageFromData(s);
      if (fromString != null && fromString.trim().isNotEmpty) {
        return fromString.trim();
      }
      // Trim "Exception:" noise
      final idx = s.indexOf('Exception:');
      if (idx >= 0 && idx + 10 < s.length) return s.substring(idx + 10).trim();
      return s;
    }

    return fb;
  }

  String? _messageFromData(dynamic data) {
    if (data == null) return null;

    // If server sent a string, try JSON decode then fall back to raw
    if (data is String) {
      final d = _tryJsonDecode(data);
      if (d is Map) return _messageFromMap(d) ?? data;
      return data;
    }
    if (data is Map) return _messageFromMap(data);

    return null;
  }

  String? _messageFromMap(Map map) {
    // Common keys
    final keys = const [
      'message',
      'Message',
      'error',
      'Error',
      'detail',
      'Detail',
      'errors',
      'Errors'
    ];
    for (final k in keys) {
      if (!map.containsKey(k)) continue;
      final v = map[k];
      if (v == null) continue;

      // direct string
      if (v is String && v.trim().isNotEmpty) return v.trim();

      // list of errors -> join first few
      if (v is List && v.isNotEmpty) {
        final parts = v
            .take(3)
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
        if (parts.isNotEmpty) return parts.join('\n');
      }

      // nested map { field: ["msg"] }
      if (v is Map && v.isNotEmpty) {
        final buf = <String>[];
        v.forEach((key, val) {
          if (val is List && val.isNotEmpty) {
            buf.add('${key.toString()}: ${val.first.toString()}');
          } else if (val != null) {
            buf.add('${key.toString()}: ${val.toString()}');
          }
        });
        if (buf.isNotEmpty) return buf.join('\n');
      }
    }
    return null;
  }

  String _nextManualNumbering() {
    int maxNum = 199; // start from 200 as baseline if none exists
    for (final it in [...policyItems, ...newPolicyItems]) {
      final n = int.tryParse(it.manualNumbering?.toString() ?? '') ?? 0;
      if (n > maxNum) maxNum = n;
    }
    return (maxNum + 1).toString();
  }

  dynamic _tryJsonDecode(String s) {
    try {
      return jsonDecode(s);
    } catch (_) {
      return null;
    }
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
