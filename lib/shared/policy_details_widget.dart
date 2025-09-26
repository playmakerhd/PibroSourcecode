import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/core/policy/controller/policy_detail_controller.dart';
import 'package:pibro/core/policy/views/insurers_screen.dart';
import 'package:pibro/core/policy/views/items_insured_screen.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:pibro/network/models/response/customer_policy_response.dart';
import 'package:pibro/shared/item_row.dart';
import 'package:pibro/utils/app_utils.dart';

class PolicyDetailsWidget extends StatelessWidget {
  const PolicyDetailsWidget({super.key, required this.data});

  final PolicyData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        children: [
          // Policy Certificate section - right aligned with label and icon
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Policy Certificate:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Builder(builder: (ctx) {
                  // Use a unique controller tag to avoid conflicts
                  final ctl = Get.isRegistered<PolicyDetailController>(
                          tag: 'policy_cert')
                      ? Get.find<PolicyDetailController>(tag: 'policy_cert')
                      : Get.put(PolicyDetailController(), tag: 'policy_cert');
                  return Tooltip(
                    message: AppStrings.insuranceCertificate.tr,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Show bottom sheet immediately, then fetch bytes
                          showModalBottomSheet(
                            context: ctx,
                            isScrollControlled: true,
                            isDismissible: true,
                            enableDrag: true,
                            builder: (bc) {
                              return SizedBox(
                                height: queryHeight(context) * 0.85,
                                child: _CertificateBottomSheet(
                                  controller: ctl,
                                  policyBrokerID: data.policyBrokerID,
                                  customerID: data.customerID ?? '',
                                ),
                              );
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Icon(
                              Icons.picture_as_pdf,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          ItemRow(
            title: AppStrings.policyNumber.tr,
            value: data.policyBrokerID,
          ),

          ItemRow(
            title: AppStrings.insuranceClass.tr,
            value: data.businessClassID!,
          ),
          ItemRow(
            title: AppStrings.product.tr,
            value: data.riskTypeID!,
          ),
          ItemRow(
            title: AppStrings.startDate.tr,
            value: formatDate(data.policyStartDate!),
          ),
          ItemRow(
            title: AppStrings.endDate.tr,
            value: formatDate(data.policyEndDate!),
          ),
          ItemRow(
            title: AppStrings.renewalDate.tr,
            value: formatDate(data.renewalDate!),
          ),
          ItemRow(
            title: AppStrings.sumInsured.tr,
            value: formatAmount(data.sumInsured!),
          ),
          ItemRow(
            title: AppStrings.premium.tr,
            value: formatAmount(data.premiumAmount!),
          ),
          ItemRow(
            title: AppStrings.accountHandler.tr,
            value: data.approvedBy ?? '',
          ),
          ItemRow(
            title: AppStrings.status.tr,
            value: getPolicyStatus(data.policyEndDate!, data.approved).status,
            valueColor:
                getPolicyStatus(data.policyEndDate!, data.approved).color,
          ),
          ItemRow(
            title: AppStrings.itemInsured.tr,
            value: AppStrings.view.tr,
            onTap: () => Get.to(
              () => ItemsInsuredScreen(itemsInsured: data.itemsToInsure!),
            ),
          ),
          ItemRow(
            title: AppStrings.insurer.tr,
            value: AppStrings.view.tr,
            onTap: () => Get.to(
              () => InsurersScreen(
                writers: data.insurancePolicyUnderwriters!,
              ),
            ),
          ),
          SizedBox(
            height: queryHeight(context) * 0.1,
          )
        ],
      ),
    );
  }
}

class _CertificateBottomSheet extends StatefulWidget {
  final PolicyDetailController controller;
  final String policyBrokerID;
  final String customerID;

  const _CertificateBottomSheet({
    required this.controller,
    required this.policyBrokerID,
    required this.customerID,
  });

  @override
  State<_CertificateBottomSheet> createState() =>
      _CertificateBottomSheetState();
}

class _CertificateBottomSheetState extends State<_CertificateBottomSheet> {
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  Uint8List? _pdfBytes;
  bool _shareLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCertificate();
  }

  Future<void> _fetchCertificate() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = null;
      });

      final bytes = await widget.controller.fetchInsuranceCertificateBytes(
        policyBrokerID: widget.policyBrokerID,
        customerID: widget.customerID,
      );

      if (bytes == null) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Failed to load certificate';
        });
      } else {
        // Basic validation: check for PDF header '%PDF'
        final bool looksLikePdf = _looksLikePdf(bytes);
        // Debug log: size and header
        print(
            'Policy certificate fetched: ${bytes.length} bytes, header: ${bytes.length >= 4 ? bytes.sublist(0, 4) : bytes}');

        if (!looksLikePdf) {
          setState(() {
            isLoading = false;
            hasError = true;
            errorMessage =
                'Server returned data that does not look like a PDF document.';
          });
        } else {
          setState(() {
            isLoading = false;
            _pdfBytes = bytes;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Error loading certificate: $e';
      });
    }
  }

  bool _looksLikePdf(Uint8List bytes) {
    if (bytes.length < 4) return false;
    // PDF files start with '%PDF' (0x25 0x50 0x44 0x46)
    return bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title takes remaining space and can ellipsize if needed
              // Expanded(
              //   // child: Text(
              //   //   'Policy Certificate',
              //   //   style: Theme.of(context).textTheme.titleLarge,
              //   //   selectionColor: AppColors.primaryColor,
              //   //   overflow: TextOverflow.ellipsis,
              //   //   maxLines: 1,
              //   // ),
              // ),

              // Buttons grouped on the right; allow them to size themselves
              Flexible(
                child: Row(
                  // mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => ElevatedButton.icon(
                          onPressed: isLoading || hasError || _pdfBytes == null
                              ? null
                              : () async {
                                  // Use system file picker to let user choose save location
                                  await _saveWithFilePicker();
                                },
                          icon: widget.controller.certificateLoading.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: Text(widget.controller.certificateLoading.value
                              ? 'Saving...'
                              : 'Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        )),
                    const SizedBox(width: 8),
                    // Share button placed next to Save
                    ElevatedButton.icon(
                      onPressed: isLoading || hasError || _pdfBytes == null
                          ? null
                          : () async {
                              await _sharePdf();
                            },
                      icon: _shareLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.share),
                      label: Text(_shareLoading ? 'Preparing...' : 'Share'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // PDF preview area
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading certificate...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load certificate',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            if (errorMessage != null)
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchCertificate,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Certificate loaded successfully - show PDF preview if bytes available
    if (_pdfBytes != null && _pdfBytes!.isNotEmpty) {
      return PdfPreview(
        build: (format) async => _pdfBytes!,
        allowPrinting: false,
        allowSharing: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        useActions: false,
        pdfFileName: 'policy_certificate.pdf',
        padding: const EdgeInsets.all(8),
        scrollViewDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Policy Certificate PDF',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Certificate is ready - tap "Save Certificate" to download',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _saveWithFilePicker() async {
    if (_pdfBytes == null) return;

    try {
      widget.controller.certificateLoading.value = true;

      // Generate default filename
      final defaultName =
          'insurance_certificate_${widget.policyBrokerID}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Let user pick save location
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Insurance Certificate',
        fileName: defaultName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: _pdfBytes,
      );

      if (outputFile != null) {
        // File was saved successfully by FilePicker
        showSnackbarMessage(
          message: '${AppStrings.insuranceCertificateSaved.tr}\n$outputFile',
          isSuccess: true,
        );
        Navigator.of(context).pop();
      } else {
        // User cancelled
        showSnackbarMessage(
          message: 'Save cancelled',
          isSuccess: false,
        );
      }
    } catch (e) {
      print('Error saving certificate with file picker: $e');
      showSnackbarMessage(
        message: 'Error saving certificate: $e',
        isSuccess: false,
      );
    } finally {
      widget.controller.certificateLoading.value = false;
    }
  }

  Future<void> _sharePdf() async {
    if (_pdfBytes == null) return;

    try {
      setState(() {
        _shareLoading = true;
      });

      // Write bytes to a temporary file and share
      final tempDir = await getTemporaryDirectory();

      // Sanitize policyBrokerID so it cannot create nested folders or invalid paths
      final rawId = widget.policyBrokerID;
      final safeId = rawId
          .replaceAll(RegExp(r'[\\/]+'), '_') // replace slashes
          .replaceAll(
              RegExp(r'[^A-Za-z0-9_.-]'), '_') // remove other unsafe chars
          .trim();

      final fileName =
          'insurance_certificate_${safeId.isEmpty ? 'policy' : safeId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final tempFile = File('${tempDir.path}/$fileName');

      // Ensure parent directory exists (tempDir normally exists, but be defensive)
      try {
        await tempFile.parent.create(recursive: true);
      } catch (_) {}

      await tempFile.writeAsBytes(_pdfBytes!, flush: true);

      // Use share_plus to open system share sheet
      await Share.shareXFiles([XFile(tempFile.path)],
          text: 'Insurance Certificate');
    } catch (e) {
      print('Error sharing certificate: $e');
      showSnackbarMessage(
        message: 'Error sharing certificate: $e',
        isSuccess: false,
      );
    } finally {
      setState(() {
        _shareLoading = false;
      });
    }
  }
}
