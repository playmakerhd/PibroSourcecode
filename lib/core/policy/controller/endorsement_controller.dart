import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
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
import 'package:pibro/shared/custom_input/custom_input.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/shared/widget/attachment_manager.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
  // Attachments
  final attachmentManager = AttachmentManager();

  // Flags
  RxBool loading = false.obs;
  RxBool paymentLoading = false.obs;

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

  // Persist for confirmation
  String? lastPaymentReference;
  String? lastPaymentDate;
  int? lastPaymentAmount;

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

  // ============== Items ==============
  void showAddOrUpdateItemSheet({ItemToInsure? data, bool isNew = false}) {
    if (data != null) {
      descCtrl.text = data.itemsDescription ?? '';
      valueCtrl.text = (data.sumInsured ?? 0).toString();
      locationCtrl.text = data.itemLocation ?? '';
    }
    showAppBottomSheet(
      height: 520,
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
                onTap: Get.back,
                child: const Icon(Icons.clear,
                    size: 28, color: AppColors.primaryColor),
              ),
            ),
            CustomInput(
              controller: valueCtrl,
              label: 'Value',
              hint: '',
              validator: (v) => Validators.requiredValidator(v, 'Value'),
            ),
            CustomInput(
              controller: locationCtrl,
              label: 'Location',
              hint: '',
              validator: (v) => Validators.requiredValidator(v, 'Location'),
            ),
            CustomInput(
              controller: descCtrl,
              label: 'Description',
              hint: '',
              maxLines: 3,
              validator: (v) => Validators.requiredValidator(v, 'Description'),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: attachmentManager.pickFiles,
                        child: Text('Add Image/PDF',
                            style: TextStyle(color: AppColors.primaryColor)),
                      ),
                      const SizedBox(width: 30),
                      Obx(() {
                        if (!attachmentManager.hasFiles)
                          return const SizedBox();
                        try {
                          final b64 =
                              attachmentManager.selectedFiles[0].contains(',')
                                  ? attachmentManager.selectedFiles[0]
                                      .split(',')
                                      .last
                                  : attachmentManager.selectedFiles[0];
                          final bytes = base64Decode(b64);
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
                text: 'Save',
                onPressed: () {
                  if (!addItemFormKey.currentState!.validate()) return;
                  if (data != null) {
                    // Update existing
                    (isNew ? newItems : policyItems).remove(data);
                    data.itemsDescription = descCtrl.text;
                    data.sumInsured = double.tryParse(valueCtrl.text) ?? 0;
                    data.itemLocation = locationCtrl.text;
                    (isNew ? newItems : policyItems).add(data);
                  } else {
                    final it = ItemToInsure(
                      companyID: policy.value!.companyID,
                      departmentID: policy.value!.departmentID,
                      divisionID: policy.value!.divisionID,
                      policyBrokerID: policy.value!.policyBrokerID,
                      manualNumbering: '1',
                      brokingSlipItemCount: 0,
                      itemsDescription: descCtrl.text,
                      sumInsured: double.tryParse(valueCtrl.text) ?? 0,
                      itemLocation: locationCtrl.text,
                    );
                    (isNew ? newItems : policyItems).add(it);
                  }
                  descCtrl.clear();
                  valueCtrl.clear();
                  locationCtrl.clear();
                  Get.back();
                },
                isExpanded: false,
                height: 50,
                width: queryWidth(null) * 0.5,
                bgColor: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
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
      Get.back();
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
      lastPaymentAmount = (data?.amount ?? 0) ~/ 100;

      final receiptReq = CreateReceiptRequest()
        ..checkNumber = lastPaymentReference
        ..transactionDate = lastPaymentDate
        ..systemDate = DateTime.now().toIso8601String()
        ..amount = lastPaymentAmount
        ..channel = 'Card';

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

  String _err(Object e) {
    final s = e.toString();
    final i = s.indexOf('Exception:');
    return i >= 0 ? s.substring(i + 10).trim() : s;
  }
}
