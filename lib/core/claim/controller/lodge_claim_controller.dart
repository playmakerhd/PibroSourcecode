// ignore_for_file: strict_top_level_inference, sized_box_for_whitespace

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/claim/widget/documents_tab.dart';
import 'package:pibro/core/claim/widget/insurers_tab.dart';
import 'package:pibro/core/claim/widget/main_tab.dart';
import 'package:pibro/core/profile/widget/profile_button.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/request/claim_request.dart';
import 'package:pibro/network/models/response/business_policy_response.dart';
import 'package:pibro/network/models/response/claim_document_response.dart';
import 'package:pibro/network/models/response/customer_policy_claims_response.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/shared/custom_button.dart';
import 'package:pibro/utils/api_utils.dart';
import 'package:printing/printing.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/image_factory.dart';
import 'package:pibro/utils/view_utils.dart';

class LodgeClaimController extends GetxController {
  PibroRepository pibroRepository =
      PibroRepository(appApiProvider: ApiProvider());
  RxInt tabIndex = 1.obs;
  RxBool policyLoading = false.obs;
  RxBool submitLoading = false.obs;
  RxBool prefillLoading =
      false.obs; // shows loader only while pre-filling edit form
  RxBool sendToBrokerLoading = false.obs;
  RxBool updateLoading = false.obs;
  RxBool isPickingFile = false.obs;
  RxBool isUploading = false.obs;
  RxList<BusinessPolicy> businessPolicies = RxList<BusinessPolicy>([]);
  Rxn<BusinessPolicy> selectedBusinessPolicy = Rxn<BusinessPolicy>();
  Rxn<DateTime> occurenceDate = Rxn<DateTime>();
  final TextEditingController occurenceDateController = TextEditingController();
  final TextEditingController narrationController = TextEditingController();
  Rxn<DateTime> lodgementDate = Rxn<DateTime>();
  final TextEditingController lodgementDateController = TextEditingController();
  final TextEditingController policyHolderController = TextEditingController();
  final TextEditingController leadInsurerController = TextEditingController();
  final TextEditingController typesOfBusinessController =
      TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final GlobalKey<FormState> claimFormKey = GlobalKey<FormState>();
  RxList<PolicyData> policies = RxList<PolicyData>([]);

  Rxn<PolicyData> selectedPolicy = Rxn<PolicyData>();
  Rxn<PolicyClaim> selectedClaim = Rxn<PolicyClaim>();
  bool isEdit = false;

  List<Widget> tabScreens = const [
    MainTab(),
    DocumentsTab(),
    InsurersTab(),
  ];

  String brokerClaimID = '';
  Rxn<File> selectedFile = Rxn<File>();
  String policeReportDate = '';
  String photographOfIncidentDate = '';
  // RxBool saveAndContinue_ = false.obs;
  RxList<ClaimDocument> claimDocuments = RxList<ClaimDocument>([]);
  List<ClaimDocument> claimDocumentsToSend = [];

  void updateIndex(int index) {
    if (tabIndex.value > 1 || isEdit || selectedClaim.value != null) {
      tabIndex.value = index;
    }
  }

  // void saveAndContinue() {
  //   submit();
  //   if (claimFormKey.currentState!.validate()) {
  //     tabIndex.value++;
  //   }
  // }

  Future<void> getCustomerPolicies() async {
    policyLoading.value = true;
    try {
      final response = await pibroRepository.getCustomerPolicies();
      policies.value = response.policies;



      if (isEdit) {
        PolicyData policyData = policies.firstWhere((element) =>
            element.policyBrokerID == selectedClaim.value!.policyBrokerID);
        selectPolicy(policyData);

        // Wait for claim details to hydrate the form before removing the loader
        await getClaim(selectedClaim.value!.brokerClaimID!);
        prefillLoading.value = false; // stop loader after fields are populated
      }
      policyLoading.value = false;
    } catch (e) {
      prefillLoading.value = false; // fail-safe
      policyLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  void selectPolicy(dynamic value) {
    selectedPolicy.value = value;
    policyHolderController.text = selectedPolicy.value!.customerName ?? '';
    if (selectedPolicy.value!.insurancePolicyUnderwriters!.isNotEmpty) {
      InsurancePolicyUnderwriter? writer = selectedPolicy
          .value!.insurancePolicyUnderwriters!
          .reduce((current, next) {
        return (current.apportionment! > next.apportionment!) ? current : next;
      });
      leadInsurerController.text = writer.vendorName!;
    }
    typesOfBusinessController.text = selectedPolicy.value!.businessClassID!;
    productController.text = selectedPolicy.value!.riskTypeID!;
    startDateController.text =
        formatClaimDate(selectedPolicy.value!.policyStartDate!);
    endDateController.text =
        formatClaimDate(selectedPolicy.value!.policyEndDate!);
    if (isEdit) {
      occurenceDate.value = DateTime.parse(selectedClaim.value!.accidentDate!);
      lodgementDate.value =
          DateTime.parse(selectedClaim.value!.customerReportDate!);
      narrationController.text = selectedClaim.value!.accidentDetails!;
      occurenceDateController.text =
          formatClaimDate(selectedClaim.value!.accidentDate!);
      lodgementDateController.text =
          formatClaimDate(selectedClaim.value!.customerReportDate!);
    }
  }

  Future<void> submit() async {
    if (claimFormKey.currentState!.validate()) {
      // saveAndContinue_.value = saveAndContinue;
      submitLoading.value = true;
      try {
        final ClaimRequest requestData = ClaimRequest(
          accidentDate: occurenceDate.value!.toIso8601String(),
          accidentDetails: narrationController.text,
          customerReportDate: lodgementDate.value!.toIso8601String(),
          policy: selectedPolicy.value!,
        );
        final response = await pibroRepository.createClaim(requestData);
        if (response.messageResponse.status != AppConstants.responseSuccess) {
          submitLoading.value = false;
          showSnackbarMessage(
              message: response.messageResponse.message, isSuccess: false);
        } else {
          brokerClaimID = response.messageResponse.message;
          requestData.claimsID = response.messageResponse.message;
          claimsRecalc(requestData);
        }
      } catch (e) {
        submitLoading.value = false;
        showSnackbarMessage(
            message: AppStrings.genericErrorMessage.tr, isSuccess: false);
      }
    }
  }

  Future<void> sendToBroker() async {
    sendToBrokerLoading.value = true;
    try {
      final response = await pibroRepository
          .sendClaimToBroker(ApiUtils.sendClaimToBroker(selectedClaim.value!));
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        sendToBrokerLoading.value = false;
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
      } else {
        submitClaim();
      }
    } catch (e) {
      sendToBrokerLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Future<void> submitClaim() async {
    try {
      final response = await pibroRepository
          .submitClaim(selectedClaim.value!.brokerClaimID!);
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
      } else {
        // Update submitClaim flag locally to immediately hide the button
        selectedClaim.value!.submitClaim = true;
        selectedClaim.refresh();
        getClaim(selectedClaim.value!.brokerClaimID!, isSendToBroker: true);
      }
      sendToBrokerLoading.value = false;
    } catch (e) {
      sendToBrokerLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Future<void> claimsRecalc(ClaimRequest requestData) async {
    try {
      final response = await pibroRepository.claimRecalc(requestData);
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
      } else {
        // if (saveAndContinue) {
        getClaim(requestData.claimsID);
        // } else {
        //   submitLoading.value = false;
        //   showSuccessDialog();
        // }
      }
    } catch (e) {
      submitLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Future<void> getClaim(String id, {bool isSendToBroker = false}) async {
    try {
      final response = await pibroRepository.getClaim(id);
      selectedClaim.value = response.policyClaim;
      claimDocuments.value = response.policyClaim.claimsDocuments!;
      if (!isEdit && !isSendToBroker) {
        tabIndex.value++;
      }
      if (isSendToBroker) {
        sendToBrokerLoading.value = false;
        _showSuccessDialog();
      }
      submitLoading.value = false;
    } catch (e) {
      sendToBrokerLoading.value = false;
      submitLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
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
                  AppStrings.submitClaim.tr,
                  style: Styles.semiBoldTextStyle(
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  AppStrings.claimSuccess.tr,
                  style: Styles.mediumTextStyle(
                    size: 12,
                    color: AppColors.primaryColor,
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

  void pickImage() async {
    if (isPickingFile.value) return;

    isPickingFile.value = true;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        // Check file size (5MB limit)
        const int maxSizeInBytes = 20 * 1024 * 1024; // 20MB
        if (file.size > maxSizeInBytes) {
          showSnackbarMessage(
            message: 'File size must be less than 5MB',
            isSuccess: false,
          );
          isPickingFile.value = false;
          return;
        }

        selectedFile.value = File(file.path!);
      } else {
        selectedFile.value = null;
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
      showSnackbarMessage(
        message: 'Error selecting file. Please try again.',
        isSuccess: false,
      );
    } finally {
      isPickingFile.value = false;
    }
  }

  closeSheet() {
    isPickingFile.value = false;
    selectedFile.value = null;
    Get.back();
  }

  previewImage(String title, String image) {
    showAppBottomSheet(
      isDismissible: true,
      willPop: true,
      isImagePreview: true,
      child: Column(
        children: [
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: queryWidth(null) * 0.05),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppConstants.appRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Styles.semiBoldTextStyle(
                        size: 16, color: AppColors.white),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                GestureDetector(
                  onTap: Get.back,
                  child: Icon(
                    Icons.clear,
                    color: AppColors.faintGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 300,
            margin: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: queryWidth(null) * 0.05,
            ),
            width: queryWidth(null),
            child: Builder(
              builder: (context) {
                try {
                  final b64 =
                      image.contains(',') ? image.split(',').last : image;
                  final bytes = base64Decode(b64);
                  final isPdf = b64.startsWith('JVBERi0');

                  if (isPdf) {
                    return Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: PdfPreview(
                          allowPrinting: false,
                          allowSharing: false,
                          canChangePageFormat: false,
                          canChangeOrientation: false,
                          canDebug: false,
                          scrollViewDecoration: BoxDecoration(),
                          build: (_) async => bytes,
                        ),
                      ),
                    );
                  } else {
                    return Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                      height: 300,
                      width: queryWidth(null),
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 48, color: Colors.red),
                              SizedBox(height: 16),
                              Text('Unable to display image'),
                            ],
                          ),
                        );
                      },
                    );
                  }
                } catch (e) {
                  return Container(
                    height: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 48, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Invalid attachment data'),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  showUploadSheet(String title, int index) {
    selectedFile.value = null;
    showAppBottomSheet(
      isDismissible: false,
      willPop: false,
      child: Column(
        children: [
          Text(
            title,
            style: Styles.mediumTextStyle(size: 18),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.blue,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                  Radius.circular(AppConstants.snackBarRadius)),
              child: SizedBox(
                height: 250,
                width: queryWidth(null),
                child: Obx(
                  () => selectedFile.value != null
                      ? Stack(
                          children: [
                            Builder(
                              builder: (context) {
                                try {
                                  // Check if it's a PDF file
                                  final fileName =
                                      selectedFile.value!.path.toLowerCase();
                                  final isPdf = fileName.endsWith('.pdf');

                                  if (isPdf) {
                                    return FutureBuilder<Uint8List>(
                                      future: selectedFile.value!.readAsBytes(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                AppConstants.snackBarRadius),
                                            child: PdfPreview(
                                              allowPrinting: false,
                                              allowSharing: false,
                                              canChangePageFormat: false,
                                              canChangeOrientation: false,
                                              canDebug: false,
                                              scrollViewDecoration:
                                                  BoxDecoration(),
                                              build: (_) async =>
                                                  snapshot.data!,
                                            ),
                                          );
                                        } else {
                                          return Container(
                                            height: 250,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.picture_as_pdf,
                                                    size: 64,
                                                    color: Colors.red),
                                                SizedBox(height: 16),
                                                Text('Loading PDF...'),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  } else {
                                    // Display image
                                    return Image.file(
                                      selectedFile.value!,
                                      fit: BoxFit.cover,
                                      height: 250,
                                      width: queryWidth(null),
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          height: 250,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.error,
                                                  size: 48, color: Colors.red),
                                              SizedBox(height: 16),
                                              Text('Unable to display file'),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }
                                } catch (e) {
                                  return Container(
                                    height: 250,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error,
                                            size: 48, color: Colors.red),
                                        SizedBox(height: 16),
                                        Text('Unable to preview file'),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: CustomButton(
                                height: 30,
                                width: 100,
                                text: AppStrings.update.tr,
                                fontSize: 12,
                                onPressed: pickImage,
                                color: AppColors.blue,
                                borderRadius: AppConstants.snackBarRadius,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageFactory.getImage(AppImages.upload).render(
                              height: 100,
                              width: 100,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomButton(
                              height: 50,
                              text: AppStrings.browseFiles.tr,
                              onPressed: pickImage,
                              color: AppColors.blue,
                              width: 180,
                              borderRadius: 10,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                height: 50,
                text: AppStrings.close.tr,
                onPressed: closeSheet,
                color: AppColors.blue,
                width: 100,
                borderRadius: 10,
              ),
              SizedBox(
                width: 10,
              ),
              Obx(
                () => CustomButton(
                  height: 50,
                  loading: isUploading.value,
                  text: AppStrings.upload.tr,
                  onPressed: () => updateDocument(index),
                  color: AppColors.blue,
                  width: 100,
                  borderRadius: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> updateDocument(int index) async {
    isPickingFile.value = false;
    isUploading.value = true;
    if (selectedFile.value != null) {
      claimDocuments[index].claimsDocument =
          await convertFileToBase64(selectedFile.value!);
      claimDocuments[index].docStatus = false;
      claimDocumentsToSend = claimDocumentsToSend.isNotEmpty
          ? claimDocumentsToSend
          : claimDocuments.map((element) => element.copy()).toList();
      claimDocumentsToSend[index].dateSubmited = DateTime.now().toString();
      uploadDoc(index);
      // Get.forceAppUpdate();
      // Get.back();
    }
  }

  updateDocStatus() {
    claimDocumentsToSend.map((element) {
      if (element.claimsDocument != null &&
          element.claimsDocument!.isNotEmpty) {
        element.docStatus = true;
        element.dateSubmited = DateTime.now().toIso8601String();
      } else {
        element.docStatus = false;
        element.dateSubmited = null;
      }
      return element;
    }).toList();
  }

  removeUploadedDocumentIfFails() {
    claimDocuments.value = claimDocuments.map((element) {
      if (element.dateSubmited == null ||
          element.dateSubmited!.isEmpty ||
          element.docStatus == false) {
        element.claimsDocument = null;
        element.dateSubmited = null;
      }
      return element;
    }).toList();
    Get.forceAppUpdate();
  }

  Future<void> uploadDoc(int index) async {
    updateLoading.value = true;
    updateDocStatus();
    try {
      final response =
          await pibroRepository.uploadClaimDoc(claimDocumentsToSend[index]);
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        removeUploadedDocumentIfFails();
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
      } else {
        claimDocuments.value = claimDocumentsToSend;
        claimDocumentsToSend = [];
        Get.forceAppUpdate();
        Get.back();
      }
      updateLoading.value = false;
      isUploading.value = false;
    } catch (e) {
      updateLoading.value = false;
      isUploading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  // Future<void> uploadDoc() async {
  //   updateLoading.value = true;
  //   updateDocStatus();
  //   print(claimDocumentsToSend[2].dateSubmited);
  //   print(claimDocumentsToSend[3].dateSubmited);
  //   try {
  //     final response =
  //         await pibroRepository.uploadClaimDoc(claimDocumentsToSend);
  //     if (response.messageResponse.status != AppConstants.responseSuccess) {
  //       removeUploadedDocumentIfFails();
  //       showSnackbarMessage(
  //           message: response.messageResponse.message, isSuccess: false);
  //     } else {
  //       claimDocuments.value = claimDocumentsToSend;
  //       claimDocumentsToSend = [];
  //     }
  //     updateLoading.value = false;
  //   } catch (e) {
  //     updateLoading.value = false;
  //     showSnackbarMessage(
  //         message: AppStrings.genericErrorMessage.tr, isSuccess: false);
  //   }
  // }

  Future<void> updateClaim() async {
    updateLoading.value = true;
    updateDocStatus();
    final ClaimRequest requestData = ClaimRequest(
      accidentDate: selectedClaim.value!.accidentDate!,
      accidentDetails: selectedClaim.value!.accidentDetails!,
      customerReportDate: selectedClaim.value!.customerReportDate!,
      policy: selectedPolicy.value!,
      claimsID: selectedClaim.value!.brokerClaimID!,
      claimDocuments: claimDocumentsToSend,
    );
    try {
      final response = await pibroRepository.updateClaim(requestData);
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
          message: response.messageResponse.message,
          isSuccess: false,
        );
        removeUploadedDocumentIfFails();
      } else {
        claimDocuments.value = claimDocumentsToSend;
        claimDocumentsToSend = [];
      }
      updateLoading.value = false;
    } catch (e) {
      updateLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  void showSuccessDialog() {
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
                  AppStrings.submitClaim.tr,
                  style: Styles.semiBoldTextStyle(
                    color: AppColors.white,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  AppStrings.claimSuccess.tr,
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

  @override
  void onInit() {
    if (Get.arguments != null) {
      if (Get.arguments is PolicyData) {
        policies.add(Get.arguments);
        selectPolicy(Get.arguments);
        lodgementDate.value = DateTime.now();
        lodgementDateController.text =
            formatClaimDate(DateTime.now().toIso8601String());
      } else {
        selectedClaim.value = Get.arguments;
        isEdit = true;
        prefillLoading.value = true; // start loader right away for edit prefill
        getCustomerPolicies();
      }
    } else {
      lodgementDate.value = DateTime.now();
      lodgementDateController.text =
          formatClaimDate(DateTime.now().toIso8601String());
      getCustomerPolicies();
    }

    super.onInit();
  }
}
