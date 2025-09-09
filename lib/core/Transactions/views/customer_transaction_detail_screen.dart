import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/policy/widget/detail_row.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/network/models/response/customer_transactions_response.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class CustomerTransactionDetailScreen extends StatelessWidget {
  const CustomerTransactionDetailScreen({super.key});

  static final ScreenshotController _shot = ScreenshotController();

  Future<File?> _exportToPdf(
      BuildContext context, CustomerTransaction t) async {
    try {
      final Uint8List? bytes = await _shot.capture();
      if (bytes == null) {
        showSnackbarMessage(
            message: 'Failed to capture content', isSuccess: false);
        return null;
      }
      final pdf = pw.Document();
      final img = pw.MemoryImage(bytes);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (_) => pw.Center(child: pw.Image(img)),
        ),
      );

      final dir = await getTemporaryDirectory();
      final name =
          'transaction_${(t.transactionNumber ?? 'txn').replaceAll('/', '-')}.pdf';
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      showSnackbarMessage(message: 'Failed to create PDF: $e', isSuccess: false);
      return null;
    }
  }

  Future<void> _onExportPressed(
      BuildContext context, CustomerTransaction t) async {
    final file = await _exportToPdf(context, t);
    if (file != null) {
      showSnackbarMessage(message: 'Saved PDF: ${file.path}', isSuccess: true);
    }
  }

  Future<void> _onSharePressed(
      BuildContext context, CustomerTransaction t) async {
    final file = await _exportToPdf(context, t);
    if (file != null) {
      await Share.shareXFiles([XFile(file.path)],
          text: 'Customer transaction');
    }
  }

  @override
  Widget build(BuildContext context) {
    final CustomerTransaction t = Get.arguments as CustomerTransaction;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: MediaQuery.removePadding(
        context:context,
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
                    DetailRow(title: 'Key Field:', value: t.keyField ?? '-'),
                    DetailRow(title: 'Customer ID:', value: t.customerID ?? '-'),
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
              Expanded(
                child: PolicyButton(
                  text: 'Export PDF',
                  onPressed: () => _onExportPressed(context, t),
                  isExpanded: true,
                  bgColor: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PolicyButton(
                  text: 'Share',
                  onPressed: () => _onSharePressed(context, t),
                  isExpanded: true,
                  bgColor: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
