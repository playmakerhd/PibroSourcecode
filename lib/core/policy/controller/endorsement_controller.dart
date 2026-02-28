import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/core/policy/views/payment_screen.dart';
import 'package:pibro/network/models/request/create_receipt_request.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/utils/api_utils.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/validators.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:pibro/utils/number_input_formatter.dart';
import 'package:pibro/shared/custom_input/custom_input.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pibro/utils/sales_quotation_utils.dart';

class EndorsementController extends GetxController {
  final PibroRepository repo = PibroRepository(appApiProvider: ApiProvider());

  // Data
  Rxn<PolicyData> policy = Rxn<PolicyData>();
  RxList<ItemToInsure> policyItems = RxList<ItemToInsure>([]);
  RxList<ItemToInsure> newItems = RxList<ItemToInsure>([]);

  // Dates
  Rxn<DateTime> startDate = Rxn<DateTime>();
  Rxn<DateTime> endDate = Rxn<DateTime>();
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();
  final renewalDateCtrl = TextEditingController();

  // Forms
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> addItemFormKey = GlobalKey<FormState>();

  // Add item inputs
  final valueCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  // Attachments - switch to selectedImage to match quote/renewal pattern
  RxString selectedImage = ''.obs;
  RxBool isPickingFile = false.obs;

  // Flags
  RxBool loading = false.obs;
  RxBool paymentLoading = false.obs;

  // Contest fields
  RxBool contestLoading = false.obs;
  final TextEditingController contestSubjectController =
      TextEditingController();
  final TextEditingController contestMessageController =
      TextEditingController();

  // Payment
  String _accessToken = '';
  final ScreenshotController screenshotController = ScreenshotController();
  late InAppWebViewController webViewController;

  Future<void> savePageAsPdf() async {
    try {
      final Uint8List? imageBytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 10),
      );

      if (imageBytes == null) {
        showSnackbarMessage(
            message: 'Failed to capture widget.', isSuccess: false);
        return;
      }

      final pdf = pw.Document();
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(image));
          },
        ),
      );

      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          'endorsement_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = '${tempDir.path}/$fileName';
      final File file = File(filePath);

      await file.writeAsBytes(await pdf.save());

      final xFile = XFile(filePath);
      await Share.shareXFiles([xFile],
          text: 'Endorsement PDF', subject: 'Endorsement');
    } catch (e) {
      print(e);
      showSnackbarMessage(
          message: 'Failed to export invoice as PDF: $e', isSuccess: false);
    }
  }

  // Additional premium returned by endorse API
  RxDouble additionalPremium = 0.0.obs;
  RxBool sendToBrokerLoading = false.obs;

  // Quote number for premium demand note
  String? quoteNumber;

  // Persist for confirmation
  String? lastPaymentReference;
  String? lastPaymentDate;
  double? lastPaymentAmount;

  @override
  void onInit() {
    final args = Get.arguments;
    if (args is PolicyData) {
      policy.value = args;
      policyItems.value = args.itemsToInsure ?? [];
    }
    // Start date comes from the selected policy (read-only). If missing, default to today.
    final parsedStart = DateTime.tryParse(policy.value?.policyStartDate ?? '');
    startDate.value = parsedStart ?? DateTime.now();
    // Default end date is current policy end date (editable)
    final parsedEnd = DateTime.tryParse(policy.value?.policyEndDate ?? '');
    endDate.value = parsedEnd ?? DateTime.now().add(const Duration(days: 364));

    // Populate controllers from the policy dates
    startDateCtrl.text = formatDate(startDate.value!.toIso8601String());
    endDateCtrl.text = formatDate(endDate.value!.toIso8601String());
    renewalDateCtrl.text = formatDate(
        endDate.value!.add(const Duration(days: 1)).toIso8601String());

    super.onInit();
  }

  Future<bool> sendEndorsementToBroker() async {
    sendToBrokerLoading.value = true;
    try {
      // Start from the standard policy send-to-broker payload so CustomerId/contact get populated
      final base = ApiUtils.sendPolicyToBroker(policy.value!);
      final itemList = (policyItems + newItems).map((it) {
        // Use toBrokerJson so fields expected by the broker API are present
        final m = it.toBrokerJson();
        // Ensure Subject holds the item description as requested
        m['Subject'] = it.itemsDescription ?? '';
        // Ensure ScreenShotURL is present (policyItems holds attachment data)
        m['ScreenShotURL'] = it.policyItems ?? '';
        // Ensure Value is present
        m['Value'] = it.sumInsured ?? 0;
        return m;
      }).toList();

      base['SupportType'] = 'Endorsement';
      base['SupportKeywords'] =
          'Endorsement, ${policy.value!.businessClassID}, ${policy.value!.riskTypeID}';
      base['SupportDescription'] =
          'PolicyBrokerID: ${policy.value!.policyBrokerID}, New Start Date: ${startDate.value?.toIso8601String() ?? ''}, New End Date: ${endDate.value?.toIso8601String() ?? ''}, Renewal Date: ${endDate.value?.add(const Duration(days: 1)).toIso8601String() ?? ''}';
      base['SupportEnquiryDate'] = startDate.value?.toIso8601String() ?? '';
      base['SupportEnquiryLapseDate'] = endDate.value?.toIso8601String() ?? '';
      base['RequestDetails'] = itemList;

      final resp = await repo.sendToBroker(base);
      if (resp.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: resp.messageResponse.message, isSuccess: false);
        return false;
      }
      return true;
    } catch (e) {
      showSnackbarMessage(message: _err(e), isSuccess: false);
      return false;
    } finally {
      sendToBrokerLoading.value = false;
    }
  }

  @override
  void dispose() {
    valueCtrl.dispose();
    locationCtrl.dispose();
    descCtrl.dispose();
    startDateCtrl.dispose();
    endDateCtrl.dispose();
    renewalDateCtrl.dispose();
    super.dispose();
  }

  void clearInputData() {
    valueCtrl.clear();
    locationCtrl.clear();
    descCtrl.clear();
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

  void addOrUpdateItem({ItemToInsure? data, bool isNew = false}) {
    if (addItemFormKey.currentState!.validate()) {
      if (data != null) {
        // Update existing
        (isNew == true ? newItems : policyItems).remove(data);
        data.itemsDescription = descCtrl.text;
        data.sumInsured =
            double.tryParse(valueCtrl.text.replaceAll(',', '')) ?? 0;
        data.itemLocation = locationCtrl.text;
        data.policyItems = selectedImage.value;
        (isNew == true ? newItems : policyItems).add(data);
      } else {
        final it = ItemToInsure(
          companyID: policy.value!.companyID,
          departmentID: policy.value!.departmentID,
          divisionID: policy.value!.divisionID,
          policyBrokerID: policy.value!.policyBrokerID,
          manualNumbering: '1',
          brokingSlipItemCount: 0,
          itemsDescription: descCtrl.text,
          sumInsured: double.tryParse(valueCtrl.text.replaceAll(',', '')) ?? 0,
          itemLocation: locationCtrl.text,
          policyItems: selectedImage.value,
        );
        (isNew == true ? newItems : policyItems).add(it);
      }
      clearInputData();
      safeBack();
    }
  }

  // ============== Items ==============
  void showAddOrUpdateItemSheet({ItemToInsure? data, bool isNew = false}) {
    if (data != null) {
      descCtrl.text = data.itemsDescription ?? '';
      valueCtrl.text = formatNumberWithCommas(data.sumInsured ?? 0);
      locationCtrl.text = data.itemLocation ?? '';
      selectedImage.value = data.policyItems ?? '';
    }
    // Show bottom sheet and await dismissal so we can clear inputs afterwards
    showAppBottomSheet(
      height: 600,
      isDismissible: false,
      willPop: false,
      child: Form(
        key: addItemFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  clearInputData();
                  safeBack();
                },
                child: const Icon(Icons.clear,
                    size: 30, color: AppColors.primaryColor),
              ),
            ),
            CustomInput(
              controller: valueCtrl,
              label: AppStrings.value.tr,
              hint: '',
              validator: (v) =>
                  Validators.requiredValidator(v, AppStrings.value.tr),
              inputType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
            ),
            CustomInput(
              controller: locationCtrl,
              label: AppStrings.location.tr,
              hint: '',
              validator: (v) =>
                  Validators.requiredValidator(v, AppStrings.location.tr),
            ),
            CustomInput(
              controller: descCtrl,
              label: AppStrings.description.tr,
              hint: '',
              maxLines: 3,
              validator: (v) =>
                  Validators.requiredValidator(v, AppStrings.description.tr),
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
                      SizedBox(width: 30),
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
                  const SizedBox(height: 8),
                  Text(
                    'File size should not exceed 20MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: PolicyButton(
                text: AppStrings.save.tr,
                onPressed: () => addOrUpdateItem(data: data, isNew: isNew),
                height: 50,
                width: queryWidth(null) * 0.5,
                bgColor: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Sheet dismissed - clear inputs to ensure next open is clean
      clearInputData();
    });
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
                        onTap: () => safeBack(),
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

  void removeItem(ItemToInsure it, {required bool isNew}) {
    (isNew ? newItems : policyItems).remove(it);
  }

  // ============== Flow ==============
  void onEndDatePicked(DateTime d) {
    endDate.value = d;
    endDateCtrl.text = formatDate(d.toIso8601String());
    renewalDateCtrl.text =
        formatDate(d.add(const Duration(days: 1)).toIso8601String());
  }

  Future<void> continueEndorse() async {
    if (!formKey.currentState!.validate()) return;

    // Compose items to send (existing + new)
    final allItems = <ItemToInsure>[
      ...policyItems,
      ...newItems,
    ];

    loading.value = true;
    try {
      final body = ApiUtils.endorsementPayload(
        policy: policy.value!,
        startDate: startDate.value!,
        endDate: endDate.value!,
        items: allItems,
      );

      final resp = await repo.endorsePolicy(body);
      if (resp.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: resp.messageResponse.message, isSuccess: false);
        loading.value = false;
        return;
      }

      // Message holds the additional premium (string); keep as double
      final addPrem = double.tryParse(resp.messageResponse.message) ?? 0.0;
      additionalPremium.value = addPrem;

      // Create sales quotation for premium demand note
      await _createSalesQuotationForEndorsement(allItems);

      // Go to summary
      Get.toNamed('/endorse-summary', arguments: {
        'policy': policy.value,
        'startDate': startDate.value,
        'endDate': endDate.value,
        'additionalPremium': addPrem,
        'items': allItems,
      });
    } catch (e) {
      showSnackbarMessage(message: _err(e), isSuccess: false);
    } finally {
      loading.value = false;
    }
  }

  // ============== Payment ==============
  int _chargeAmountKobo(double amount) {
    final usualCharge = amount * 0.015;
    final extraCharge = amount > 2500 ? (usualCharge + 100) : usualCharge;
    final capped = extraCharge > 2000 ? 2000 : extraCharge;
    return ((amount + capped) * 100).round();
  }

  Future<void> getPaymentTokenAndInit(double amount) async {
    paymentLoading.value = true;
    try {
      final tokenResp = await repo.getPaymentToken();
      if (tokenResp.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: tokenResp.messageResponse.message, isSuccess: false);
        paymentLoading.value = false;
        return;
      }
      _accessToken = tokenResp.messageResponse.message;

      final init =
          await repo.initializePayment(_accessToken, _chargeAmountKobo(amount));
      if (!init.initData.status) {
        showSnackbarMessage(
            message: init.initData.message ?? 'Payment init failed',
            isSuccess: false);
        paymentLoading.value = false;
        return;
      }

      // Use Paystack page
      Get.to(() =>
          PaymentScreen(paystackUrl: init.initData.data!.authorizationUrl!));
    } catch (e) {
      showSnackbarMessage(message: _err(e), isSuccess: false);
      paymentLoading.value = false;
    }
  }

  void checkPaymentStatus(String url) {
    if (url.contains("powersoftrd.com/EnterpriseDemo")) {
      safeBack();
      verifyPayment(url.substring(url.length - 10));
    }
  }

  Future<void> verifyPayment(String reference) async {
    try {
      final response = await repo.verifyPayment(_accessToken, reference);
      final data = response.verificationData.data;
      final status = data?.status?.toLowerCase();
      if (status != 'success') {
        showSnackbarMessage(
            message: response.verificationData.message ?? 'Payment failed',
            isSuccess: false);
        paymentLoading.value = false;
        return;
      }

      lastPaymentReference = data?.reference;
      lastPaymentDate = data?.paidAt ?? DateTime.now().toIso8601String();
      lastPaymentAmount = (data?.amount ?? 0) / 100.0;

      // Prefer the computed additional premium for endorsements when creating receipts
      // (this excludes gateway fees). Fallback to the provider-paid amount if missing.
      int? receiptAmount;
      if (additionalPremium.value > 0) {
        receiptAmount = additionalPremium.value.round();
      } else {
        receiptAmount = lastPaymentAmount?.round();
        print(
            '⚠️ RECEIPT: additionalPremium missing; falling back to provider amount for receipt.');
      }

      final receiptReq = CreateReceiptRequest()
        ..checkNumber = lastPaymentReference
        ..transactionDate = lastPaymentDate
        ..systemDate = DateTime.now().toIso8601String()
        ..amount = receiptAmount?.toDouble()
        ..channel = 'Card';

      // Log the full receipt payload
      print('📋 CREATE_RECEIPT_PAYLOAD: ${jsonEncode({
            'checkNumber': receiptReq.checkNumber,
            'transactionDate': receiptReq.transactionDate,
            'systemDate': receiptReq.systemDate,
            'amount': receiptReq.amount,
            'channel': receiptReq.channel,
          })}');

      // Create receipt
      final createResp = await repo.createReceipt(receiptReq);
      if (createResp.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: createResp.messageResponse.message, isSuccess: false);
        paymentLoading.value = false;
        return;
      }
      receiptReq.receiptID = createResp.messageResponse.message;

      // Post receipt
      final postResp = await repo.postReceipt(receiptReq);
      if (postResp.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: postResp.messageResponse.message, isSuccess: false);
        paymentLoading.value = false;
        return;
      }

      // Create DBN for endorsement
      final noteBody = ApiUtils.endorsementNotePayload(
        policy: policy.value!,
        startDate: startDate.value!,
        endDate: endDate.value!,
        invoiceDate: DateTime.now(),
        sumInsured: policy.value!.sumInsured ?? 0.0,
        premiumDue: additionalPremium.value,
        receiptId: receiptReq.receiptID!,
      );

      final noteResp = await repo.createClientNoteEndorsement(noteBody);
      if (noteResp.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: noteResp.messageResponse.message, isSuccess: false);
        paymentLoading.value = false;
        return;
      }

      // Post the endorsement client note
      final invoiceNumber = noteResp.messageResponse.message;
      final postNoteResp = await repo.postClientNoteEndorsement(invoiceNumber);
      if (postNoteResp.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: postNoteResp.messageResponse.message, isSuccess: false);
        paymentLoading.value = false;
        return;
      }

      await closeSalesQuotationIfPossible(
        repo: repo,
        quoteNumber: quoteNumber,
      );

      // Done → confirmation
      Get.offNamed('/endorse-confirmation', arguments: {
        'policyId': policy.value!.policyBrokerID,
        'paymentReference': lastPaymentReference ?? '',
        'paymentDate': lastPaymentDate ?? '',
        'paymentAmount': lastPaymentAmount ?? 0,
        'additionalPremium': additionalPremium.value,
        'paymentMethod': receiptReq.channel ?? 'Card',
      });
    } catch (e) {
      showSnackbarMessage(message: _err(e), isSuccess: false);
    } finally {
      paymentLoading.value = false;
    }
  }

  void showContestModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.greyColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Contest Payment',
                      style: Styles.semiBoldTextStyle(
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    controller: contestSubjectController,
                    hint: 'Subject',
                    label: 'Subject',
                    height: 35,
                  ),
                  const SizedBox(height: 12),
                  CustomInput(
                    controller: contestMessageController,
                    hint: 'Message',
                    label: 'Message',
                    maxLines: 3,
                    height: 75,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PolicyButton(
                        text: 'Cancel',
                        onPressed: () => safeBack(),
                        width: 80,
                        height: 35,
                        bgColor: AppColors.primaryColor,
                      ),
                      Obx(
                        () => PolicyButton(
                          text: 'Submit',
                          onPressed:
                              contestLoading.value ? () {} : submitContest,
                          loading: contestLoading.value,
                          width: 80,
                          height: 35,
                          bgColor: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> submitContest() async {
    if (contestSubjectController.text.trim().isEmpty ||
        contestMessageController.text.trim().isEmpty) {
      showSnackbarMessage(
        message: 'Please fill in both subject and message',
        isSuccess: false,
      );
      return;
    }

    contestLoading.value = true;
    try {
      final response = await repo.sendToBroker(_createContestPayload());
      if (response.messageResponse.status != AppConstants.responseSuccess) {
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
      } else {
        safeBack(); // Close modal
        contestSubjectController.clear();
        contestMessageController.clear();
        showSnackbarMessage(
            message: 'Contest submitted successfully', isSuccess: true);
      }
      contestLoading.value = false;
    } catch (e) {
      contestLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  Map<String, dynamic> _createContestPayload() {
    // Create contest payload for endorsement
    final originalDescription =
        "Endorsement Request - Policy: ${policy.value?.policyBrokerID}, Start Date: ${startDateCtrl.text}, End Date: ${endDateCtrl.text}, Additional Premium: ${additionalPremium.value}";
    final contestDescription =
        "$originalDescription\n\nCONTEST DETAILS:\nSubject: ${contestSubjectController.text.trim()}\nMessage: ${contestMessageController.text.trim()}";

    return {
      "CompanyID": policy.value?.companyID ?? "",
      "DivisionID": policy.value?.divisionID ?? "",
      "DepartmentID": policy.value?.departmentID ?? "",
      "CaseId": "",
      "CustomerId": policy.value?.customerID ?? "",
      "ProductId": policy.value?.riskTypeID ?? "",
      "SupportDate": DateTime.now().toIso8601String(),
      "SupportKeywords":
          "Contest Endorsement, ${policy.value?.businessClassID}, ${policy.value?.riskTypeID}, Sum Insured: ${policy.value?.sumInsured ?? 0}, Premium: ${additionalPremium.value}",
      "SupportDescription": contestDescription,
      "SupportScreenShotURL": "",
      "SupportEnquiryDate": policy.value?.policyStartDate,
      "SupportEnquiryLapseDate": policy.value?.policyEndDate,
      "SupportPriority": 64,
      "SupportApproved": true,
      "SupportApprovedBy": "Admin",
      "SupportAssigned": true,
      "SupportType": "Contest Endorsement",
      "SupportStatus": "Pending",
      "ContactName": policy.value?.customerName ?? "",
      "ContactPhone": "",
      "ContactEmail": "",
      "QuoteRequest": true,
      "RequestDetails": policyItems.map((item) => item.toJson()).toList(),
    };
  }

  String _err(Object e) {
    final s = e.toString();
    final i = s.indexOf('Exception:');
    return i >= 0 ? s.substring(i + 10).trim() : s;
  }

  /// Create sales quotation for endorsement to enable premium demand note
  Future<void> _createSalesQuotationForEndorsement(
      List<ItemToInsure> allItems) async {
    try {
      print(
          '🔍 ENDORSEMENT: Creating sales quotation for premium demand note...');

      // Prepare items in the format expected by createSalesQuotation
      final items = allItems.map((item) {
        return {
          'description': item.itemsDescription ?? '',
          'ItemsDescription': item.itemsDescription ?? '',
          'Value': item.sumInsured ?? 0.0,
          'value': item.sumInsured ?? 0.0,
          'location': item.itemLocation ?? '',
          'ItemLocation': item.itemLocation ?? '',
          'ScreenShotURL': item.policyItems ?? '',
          'screenShotURL': item.policyItems ?? '',
          // Map vehicle-specific detail fields for motor insurance
          'RegNo': item.detailMemo1 ?? '',
          'EngineNo': item.detailMemo2 ?? '',
          'ChasisId': item.detailMemo3 ?? '',
          'VehicleMake': item.detailMemo4 ?? '',
        };
      }).toList();

      // Get vendor ID from policy underwriters
      String? vendorID;
      if (policy.value?.insurancePolicyUnderwriters?.isNotEmpty == true) {
        vendorID = policy.value?.insurancePolicyUnderwriters?.first.vendorID;
      }

      print('🔍 ENDORSEMENT: Vendor ID: ${vendorID ?? "ADIC (default)"}');
      print('🔍 ENDORSEMENT: Items count: ${items.length}');

      final payload = ApiUtils.createSalesQuotation(
        businessClassID: policy.value?.businessClassID ?? '',
        riskTypeID: policy.value?.riskTypeID ?? '',
        startDate: startDate.value?.toIso8601String() ?? '',
        endDate: endDate.value?.toIso8601String() ?? '',
        renewalDate:
            endDate.value?.add(const Duration(days: 1)).toIso8601String() ?? '',
        itemsToInsure: items,
        vendorID: vendorID,
        premiumDescription:
            'Quotation on policy endorsement on ${policy.value?.policyBrokerID ?? ''}',
      );

      final createRes = await repo.createSalesQuotation(payload);

      if (createRes.messageResponse.status == AppConstants.responseSuccess) {
        quoteNumber = createRes.messageResponse.message;
        print('✅ ENDORSEMENT: Sales quotation created: $quoteNumber');
      } else {
        print(
            '❌ ENDORSEMENT: Failed to create sales quotation: ${createRes.messageResponse.message}');
      }
    } catch (e) {
      print('❌ ENDORSEMENT: Error creating sales quotation: $e');
      // Non-fatal: premium demand note just won't be available
    }
  }

  /// Fetches premium demand note PDF bytes for the endorsement quote.
  /// Returns null on error.
  Future<Uint8List?> fetchPremiumDemandNoteBytes() async {
    try {
      if (quoteNumber == null || quoteNumber!.isEmpty) {
        print('❌ ENDORSEMENT_DEMAND_NOTE: No quote number available');
        showSnackbarMessage(
          message: 'No quote number available for premium demand note',
          isSuccess: false,
        );
        return null;
      }

      print('🔍 ENDORSEMENT_DEMAND_NOTE: Fetching for Quote ID: $quoteNumber');

      final resp = await repo.viewPremiumDemandNoteReport(
        quoteID: quoteNumber!,
      );

      final status = resp.messageResponse.status;
      final msg = resp.messageResponse.message; // Base64 PDF

      if (status.toLowerCase() != 'success' || msg.isEmpty) {
        print(
            '❌ ENDORSEMENT_DEMAND_NOTE: API returned failure or empty message');
        return null;
      }

      // Decode base64 to bytes
      final cleanedBase64 =
          msg.startsWith('data:') ? msg.substring(msg.indexOf(',') + 1) : msg;
      final bytes = base64Decode(cleanedBase64);

      print(
          '✅ ENDORSEMENT_DEMAND_NOTE: Successfully fetched ${bytes.length} bytes');
      return Uint8List.fromList(bytes);
    } catch (e) {
      print('❌ ENDORSEMENT_DEMAND_NOTE: Error: $e');
      showSnackbarMessage(
        message: 'Error loading premium demand note: $e',
        isSuccess: false,
      );
      return null;
    }
  }
}
