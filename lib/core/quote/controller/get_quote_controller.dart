import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/policy/model/item_data.dart';
import 'package:pibro/core/policy/views/items_to_insure_screen.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/response/business_policy_response.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';
import 'package:pibro/network/models/response/insurance_risk_type_response.dart';
import 'package:pibro/network/models/response/vendor_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/shared/custom_input/custom_input.dart';

import 'package:pibro/utils/api_utils.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/validators.dart';
import 'package:pibro/utils/view_utils.dart';

class GetQuoteController extends GetxController {
  PibroRepository pibroRepository =
      PibroRepository(appApiProvider: ApiProvider());
  RxBool businessLoading = false.obs;
  RxBool riskTypeLoading = false.obs;
  RxBool submitLoading = false.obs;
  RxBool isPickingFile = false.obs;

  Rxn<DateTime> startDate = Rxn<DateTime>();
  final TextEditingController startDateController = TextEditingController();
  Rxn<DateTime> endDate = Rxn<DateTime>();
  final TextEditingController endDateController = TextEditingController();
  final GlobalKey<FormState> addItemFormKey = GlobalKey<FormState>();

  final TextEditingController regNoController = TextEditingController();
  final TextEditingController chasisIdController = TextEditingController();
  final TextEditingController engineNoController = TextEditingController();
  final TextEditingController vehicleMakeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  RxString selectedImage = ''.obs;

  RxList<ItemData> items = RxList<ItemData>([]);
  RxList<BusinessPolicy> businessPolicies = RxList<BusinessPolicy>([]);
  Rxn<BusinessPolicy> selectedBusinessPolicy = Rxn<BusinessPolicy>();
  RxList<RiskTypeID> riskTypeIDs = RxList<RiskTypeID>([]);
  Rxn<RiskTypeID> selectedRiskTypeID = Rxn<RiskTypeID>();

  RxList<ItemToInsure> policyItems = RxList<ItemToInsure>([]);
  RxList<ItemToInsure> newPolicyItems = RxList<ItemToInsure>([]);

  Future<void> getInsuranceBusinessClass() async {
    businessLoading.value = true;
    try {
      final response = await pibroRepository.getInsuranceBusinessClass();
      businessPolicies.value = response.businessPolicies;
      businessLoading.value = false;
    } catch (e) {
      businessLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  void selectBusinessClass(dynamic value) {
    selectedBusinessPolicy.value = value;
    getInsuranceRiskTypeID((value as BusinessPolicy).businessClassID!);
    selectedRiskTypeID.value = null;
  }

  void selectRiskType(dynamic value) {
    selectedRiskTypeID.value = value;
  }

  Future<void> getInsuranceRiskTypeID(String id) async {
    riskTypeLoading.value = true;
    try {
      final response = await pibroRepository.getInsuranceRiskType(id);
      riskTypeIDs.clear();
      riskTypeIDs.value = response.riskTypeIDs;
      riskTypeLoading.value = false;
    } catch (e) {
      riskTypeLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  void navigateToItemsToInsure() {
    Get.to(() => ItemsToInsureScreen(controller: this));
  }

  // Vendors (Preferred Insurer)
  final RxList<VendorInfo> vendors = <VendorInfo>[].obs;
  final Rxn<VendorInfo> selectedVendor = Rxn<VendorInfo>();
  final RxBool vendorsLoading = false.obs;

  Future<void> loadVendors() async {
    vendorsLoading.value = true;
    try {
      final res = await pibroRepository.getVendors();
      vendors.assignAll(res.vendors);
    } catch (e, st) {
      // PibroLogger.e('loadVendors error', e, st);
      vendors.clear();
    } finally {
      vendorsLoading.value = false;
    }
  }

  void selectVendor(VendorInfo? v) {
    selectedVendor.value = v;
    if (v != null) {
      GetStorage().write(StorageKeys.preferredInsurer, {
        "vendorID": v.vendorID,
        "vendorName": v.vendorName,
      });
    }
  }

  /// Landing-page flow:
  /// - If user is logged in: create enquiry now, fetch it, branch to summary/confirmation.
  /// - If not logged in: persist pending quote + set flag, navigate to signup/login.
  Future<void> submit() async {
    print('🔍 SUBMIT: Starting submit process...');
    submitLoading.value = true;

    // Add minimum loading duration for better UX
    final loadingStartTime = DateTime.now();

    try {
      print('🔍 SUBMIT: Checking login status...');
      final loggedIn = decryptData(StorageKeys.loginData) != null;
      print('🔍 SUBMIT: User logged in: $loggedIn');

      // Stash quote draft so we can resume after auth
      final startIso = (startDate.value ?? DateTime.now()).toIso8601String();
      final endIso =
          (endDate.value ?? DateTime.now().add(const Duration(days: 364)))
              .toIso8601String();
      final renewalIso =
          (endDate.value ?? DateTime.now().add(const Duration(days: 364)))
              .add(const Duration(days: 1))
              .toIso8601String();

      final draft = {
        "businessClassID": selectedBusinessPolicy.value?.businessClassID,
        "businessClassName": selectedBusinessPolicy.value?.businessClassName,
        "riskTypeID": selectedRiskTypeID.value?.riskTypeID,
        "riskName": selectedRiskTypeID.value?.riskName,

        // ✅ Persist machine-friendly ISO dates
        "startDate": startIso,
        "endDate": endIso,
        "renewalDate": renewalIso,

        // (Optional) keep UI text for redisplay
        "startDateText": startDateController.text,
        "endDateText": endDateController.text,
        "renewalDateText": formatDate(renewalIso),

        "items": items
            .map((it) => isMotorQuote(
                    selectedBusinessPolicy.value?.businessClassID ?? '')
                ? it.toMotorJson()
                : it.toJson())
            .toList(),
        "preferredInsurer": {
          "vendorID": selectedVendor.value?.vendorID,
          "vendorName": selectedVendor.value?.vendorName
        },
      };

      print('🔍 SUBMIT: Saving draft with ${items.length} items...');
      GetStorage().write(StorageKeys.pendingQuote, draft);

      // Ensure minimum loading duration (500ms)
      final elapsed = DateTime.now().difference(loadingStartTime);
      if (elapsed.inMilliseconds < 500) {
        await Future.delayed(
            Duration(milliseconds: 500 - elapsed.inMilliseconds));
      }

      if (loggedIn) {
        print(
            '🔍 SUBMIT: User logged in, calling _createEnquiryAndNavigate...');
        await _createEnquiryAndNavigate();
      } else {
        print('🔍 SUBMIT: User not logged in, navigating to signup...');
        GetStorage().write(StorageKeys.quoteFlowFlag, true);
        // go to login/signup; use your existing route name
        Get.offNamed(AppRoutes.signup);
      }
    } catch (e, st) {
      print('❌ SUBMIT: Error in submit: $e');
      //PibroLogger.e('submit() error', e, st);
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    } finally {
      print('🔍 SUBMIT: Setting submitLoading to false');
      submitLoading.value = false;
    }
  }

  /// Called post-auth (login/signup) when quoteFlowFlag is set.
  Future<void> resumeAfterAuth() async {
    submitLoading.value = true;
    await _createEnquiryAndNavigate();
  }

  Future<void> _createEnquiryAndNavigate() async {
    print('🔍 API: Starting _createEnquiryAndNavigate...');
    try {
      // Create enquiry (reuse your ApiUtils.createQuote)
      final draft = GetStorage().read(StorageKeys.pendingQuote) as Map? ?? {};
      if (draft.isEmpty) {
        print('❌ API: No draft found');
        showSnackbarMessage(message: 'Nothing to submit', isSuccess: false);
        return;
      }

      print('🔍 API: Creating enquiry with draft data...');
      final v = draft['preferredInsurer'] as Map?;
      final payload = ApiUtils.createQuote(
        // product / risk type (ProductId)
        draft['riskName'] ?? '',
        // businessClassID (canonical) -> stored into SupportRequestMethod
        (draft['businessClassID'] ?? '').toString(),
        // businessClassName (human friendly)
        (draft['businessClassName'] ?? '').toString(),
        draft['startDate'] ?? '',
        draft['endDate'] ?? '',
        draft['renewalDate'] ?? '',
        List<Map<String, dynamic>>.from(draft['items'] ?? const []),
        vendorID: v?['vendorID']?.toString(),
        vendorName: v?['vendorName']?.toString(),
      );

      print('🔍 API: Sending to broker...');
      final createRes = await pibroRepository.sendToBroker(payload);
      if (createRes.messageResponse.status != AppConstants.responseSuccess) {
        print(
            '❌ API: sendToBroker failed: ${createRes.messageResponse.message}');
        showSnackbarMessage(
            message: createRes.messageResponse.message, isSuccess: false);
        return;
      }

      final caseId = createRes.messageResponse.message;
      print('🔍 API: Got case ID: $caseId, fetching enquiry...');

      final byId = await pibroRepository.getCustomerEnquiryById(caseId);
      final quote = byId.quote;
      if (quote == null) {
        print('❌ API: Could not fetch enquiry');
        showSnackbarMessage(
            message: 'Could not fetch enquiry', isSuccess: false);
        return;
      }

      // Fix premium parsing from API response
      final premiumString = quote.supportResolution ?? '0';
      final sumInsuredString = quote.supportScreenShotURL ?? '0';

      print('🔍 ENQUIRY: Raw premium from API: $premiumString');
      print('🔍 ENQUIRY: Raw sumInsured from API: $sumInsuredString');

      final premium = double.tryParse(premiumString.replaceAll(',', '')) ?? 0.0;
      final sumInsured =
          double.tryParse(sumInsuredString.replaceAll(',', '')) ?? 0.0;

      print('🔍 ENQUIRY: Parsed premium: $premium');
      print('🔍 ENQUIRY: Parsed sumInsured: $sumInsured');

      final enquiryData = {
        "caseId": caseId,
        "premium": premium, // Store as number, not string
        "sumInsured": sumInsured, // Store as number, not string
        "riskName": draft['riskName'],
        // Ensure we persist the canonical product/risk type id so downstream
        // payment and create-policy flows can read it even when this is
        // marked as a fresh_quote.
        "riskTypeID":
            (draft['riskTypeID'] ?? draft['riskName'] ?? '').toString(),
        // Ensure we include the canonical businessClassID so downstream flows
        // that read StorageKeys.lastEnquiry (fresh_quote) have the ID available.
        "businessClassID": (draft['businessClassID'] ?? '').toString(),
        "businessClassName": draft['businessClassName'],
        "startDate": draft['startDate'],
        "endDate": draft['endDate'],
        "renewalDate": draft['renewalDate'],
        "preferredInsurer": draft['preferredInsurer'],
        "items": draft['items'],
        "_source": "fresh_quote", // Flag to identify this as fresh quote data
      };

      print('🔍 ENQUIRY: Storing enquiry data: $enquiryData');
      GetStorage().write(StorageKeys.lastEnquiry, enquiryData);

      // Branch
      if (premium <= 0) {
        Get.offNamed(AppRoutes.quoteConfirmation);
      } else {
        Get.offNamed(AppRoutes.quoteSummary);
      }
    } catch (e, st) {
      print('❌ ENQUIRY: Error in _createEnquiryAndNavigate: $e');
      print('📍 STACK TRACE: $st');
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    } finally {
      GetStorage().remove(StorageKeys.quoteFlowFlag);
      submitLoading.value = false;
    }
  }

  void pickImage() async {
    if (isPickingFile.value) return;

    isPickingFile.value = true;

    try {
      const int _maxBytes = 20 * 1024 * 1024; // 20MB
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        final f = result.files.single;
        if (f.size > _maxBytes) {
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

  void addOrUpdateItem(ItemData? data) {
    if (addItemFormKey.currentState!.validate()) {
      if (data != null) {
        removeItemFromList(data);
        if (isMotorQuote(selectedBusinessPolicy.value!.businessClassID!)) {
          data.regNo = regNoController.text;
          data.chasisId = chasisIdController.text;
          data.engineNo = engineNoController.text;
          data.vehicleMake = vehicleMakeController.text;
        }
        data.description = descriptionController.text;
        data.value = valueController.text;
        data.location = locationController.text;
        data.subject = selectedRiskTypeID.value!.riskName;
        if (selectedImage.value.isNotEmpty) {
          data.screenShotURL = selectedImage.value;
        }
        addData(data);
      } else {
        addData(
          isMotorQuote(selectedBusinessPolicy.value!.businessClassID!)
              ? ItemData(
                  regNo: regNoController.text,
                  chasisId: chasisIdController.text,
                  engineNo: engineNoController.text,
                  vehicleMake: vehicleMakeController.text,
                  description: descriptionController.text,
                  location: locationController.text,
                  value: valueController.text,
                  subject: selectedRiskTypeID.value!.riskName,
                  screenShotURL: selectedImage.value,
                )
              : ItemData(
                  description: descriptionController.text,
                  location: locationController.text,
                  value: valueController.text,
                  subject: selectedRiskTypeID.value!.riskName,
                  screenShotURL: selectedImage.value,
                ),
        );
      }
      _closeSheet();
    }
  }

  addData(ItemData data) {
    items.add(data);
  }

  void removeItemFromList(ItemData itemData) {
    items.value = items.where((item) => item != itemData).toList();
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

  _closeSheet() {
    clearInputData();
    Get.back();
  }

  void populateInputFields(ItemData data) {
    descriptionController.text = data.description!;
    valueController.text = data.value!;
    locationController.text = data.location!;
    selectedImage.value = data.screenShotURL!;
    if (isMotorQuote(selectedBusinessPolicy.value!.businessClassID!)) {
      regNoController.text = data.regNo!;
      chasisIdController.text = data.chasisId!;
      engineNoController.text = data.engineNo!;
      vehicleMakeController.text = data.vehicleMake!;
    }
  }

  void previewItemAttachment(ItemData item) {
    final raw = (item.screenShotURL ?? '');
    if (raw.isEmpty) return;
    final b64 = raw.contains(',') ? raw.split(',').last : raw;
    final isPdf = b64.startsWith('JVBERi0'); // "%PDF-" in base64

    try {
      final bytes = base64Decode(b64); // Validate base64 first

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

  void showAddOrUpdateSheet(ItemData? data) {
    if (data != null) {
      populateInputFields(data);
    }
    showAppBottomSheet(
      height: 600,
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
            if (isMotorQuote(
                selectedBusinessPolicy.value!.businessClassID!)) ...[
              CustomInput(
                controller: regNoController,
                label: AppStrings.regId.tr,
                hint: '',
                validator: (value) =>
                    Validators.requiredValidator(value, AppStrings.regId.tr),
              ),
              CustomInput(
                controller: chasisIdController,
                label: AppStrings.chasisId.tr,
                hint: '',
                validator: (value) =>
                    Validators.requiredValidator(value, AppStrings.chasisId.tr),
              ),
              CustomInput(
                controller: engineNoController,
                label: AppStrings.engineNo.tr,
                hint: '',
                validator: (value) =>
                    Validators.requiredValidator(value, AppStrings.engineNo.tr),
              ),
              CustomInput(
                controller: vehicleMakeController,
                label: AppStrings.vehicleMake.tr,
                hint: '',
                validator: (value) => Validators.requiredValidator(
                    value, AppStrings.vehicleMake.tr),
              ),
            ],
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
                        child: Text(
                          "Add Image/PDF",
                          style: Styles.linkTextStyle(),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Obx(() {
                        if (selectedImage.value.isEmpty)
                          return const SizedBox();

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
                              return Container(
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
                            child: Container(
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
            PolicyButton(
              text: AppStrings.save.tr,
              onPressed: () => addOrUpdateItem(data),
              height: 40,
              width: queryWidth(null) * 0.5,
              bgColor: AppColors.primaryColor,
            ),
          ],
        ),
      ),
      willPop: false,
    );
  }

  bool isMotorQuote(String id) {
    return id == 'MOT' ||
        id == 'MOTOR' ||
        id == 'MOTORS' ||
        id == 'MOTOR INSURANCE' ||
        id == 'PM' ||
        id == 'PRIVATE MOTOR';
  }

  @override
  void onInit() {
    getInsuranceBusinessClass();
    loadVendors(); // populate dropdown early
    super.onInit();
  }

  @override
  void dispose() {
    clearInputData();
    super.dispose();
  }
}
