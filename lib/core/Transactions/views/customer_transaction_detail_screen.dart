import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/policy/widget/detail_row.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/core/Transactions/controller/customer_transactions_controller.dart';
import 'package:pibro/network/models/response/customer_transactions_response.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:screenshot/screenshot.dart';
import 'package:file_picker/file_picker.dart';

class CustomerTransactionDetailScreen extends StatelessWidget {
  const CustomerTransactionDetailScreen({super.key});

  static final ScreenshotController _shot = ScreenshotController();
  static final RxBool _exportLoading = false.obs;

  Future<void> _exportToPdf(BuildContext context, CustomerTransaction t) async {
    _exportLoading.value = true;
    try {
      final Uint8List? bytes = await _shot.capture();
      if (bytes == null) {
        showSnackbarMessage(
            message: 'Failed to capture content', isSuccess: false);
        return;
      }
      final pdf = pw.Document();
      final img = pw.MemoryImage(bytes);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (_) => pw.Center(child: pw.Image(img)),
        ),
      );

      final pdfBytes = await pdf.save();

      // Generate default filename
      final rawId = (t.transactionNumber ?? 'txn').toString();
      final safeId = rawId.replaceAll(RegExp(r'[\/]+'), '_');
      final defaultName =
          'transaction_${safeId}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Let user pick save location
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Transaction PDF',
        fileName: defaultName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: pdfBytes,
      );

      if (outputFile != null) {
        // File was saved successfully by FilePicker
        showSnackbarMessage(
          message: 'Transaction PDF saved\n$outputFile',
          isSuccess: true,
        );
      } else {
        // User cancelled
        showSnackbarMessage(
          message: 'Save cancelled',
          isWarning: true,
        );
      }
    } catch (e) {
      showSnackbarMessage(
          message: 'Failed to create PDF: $e', isSuccess: false);
    } finally {
      _exportLoading.value = false;
    }
  }

  Future<void> _onExportPressed(
      BuildContext context, CustomerTransaction t) async {
    await _exportToPdf(context, t);
  }

  Future<void> _onSharePressed(
      BuildContext context, CustomerTransaction t) async {
    // Use the existing controller to share the transaction report
    final ctrl = Get.put(CustomerTransactionsController());
    await ctrl.shareTransactionReport(
      transactionNumber: t.transactionNumber ?? '',
      reportType: t.transactionType ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final CustomerTransaction t = Get.arguments as CustomerTransaction;
    final ctrl = Get.put(CustomerTransactionsController());
    return Scaffold(
      backgroundColor: AppColors.white,
      body: MediaQuery.removePadding(
        context: context,
        child: Screenshot(
          controller: _shot,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const CommonHeader(title: 'Transaction Details'),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: queryWidth(context) * 0.05, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailRow(
                        title: 'Transaction No:',
                        value: t.transactionNumber ?? '-'),
                    DetailRow(
                        title: 'Transaction Date:',
                        value: formatDate(t.transactionDate ?? '')),
                    DetailRow(
                        title: 'Amount:',
                        value: (t.transactionAmount ?? 0).toString()),
                    const SizedBox(height: 8),
                    DetailRow(
                        title: 'Transaction Type:',
                        value: t.transactionType ?? '-'),
                    //  DetailRow(title: 'Key Field:', value: t.keyField ?? '-'),
                    DetailRow(
                        title: 'Customer ID:', value: t.customerID ?? '-'),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            queryWidth(context) * 0.05,
            8,
            queryWidth(context) * 0.05,
            16,
          ),
          child: Row(
            children: [
              Obx(() => PolicyButton(
                    text: 'Export PDF',
                    onPressed: () => _onExportPressed(context, t),
                    isExpanded: true,
                    bgColor: AppColors.primaryColor,
                    loading: _exportLoading.value,
                  )),
              const SizedBox(width: 12),
              Obx(() => PolicyButton(
                    text: 'Share',
                    onPressed: () => _onSharePressed(context, t),
                    isExpanded: true,
                    bgColor: AppColors.primaryColor,
                    loading: ctrl.shareLoading.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
