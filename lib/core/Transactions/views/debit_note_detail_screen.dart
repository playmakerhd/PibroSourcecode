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
import 'package:pibro/network/models/response/debit_note_list_response.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class DebitNoteDetailScreen extends StatelessWidget {
  const DebitNoteDetailScreen({super.key});

  // capture only the scrollable content, not the bottom bar
  static final ScreenshotController _shot = ScreenshotController();

  Future<File?> _exportToPdf(BuildContext context, DebitNote n) async {
    try {
      // 1) Capture
      final Uint8List? bytes = await _shot.capture();
      if (bytes == null) {
        showSnackbarMessage(
            message: 'Failed to capture content', isSuccess: false);
        return null;
      }

      // 2) Build PDF
      final pdf = pw.Document();
      final img = pw.MemoryImage(bytes);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (_) => pw.Center(child: pw.Image(img)),
        ),
      );

      // 3) Save to temp
      final dir = await getTemporaryDirectory();
      final name =
          'debit_note_${(n.invoiceNumber ?? 'note').replaceAll('/', '-')}.pdf';
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      showSnackbarMessage(message: 'Failed to create PDF: $e', isSuccess: false);
      return null;
    }
  }

  Future<void> _onExportPressed(BuildContext context, DebitNote n) async {
    final file = await _exportToPdf(context, n);
    if (file != null) {
      showSnackbarMessage(message: 'Saved PDF: ${file.path}', isSuccess: true);
    }
  }

  Future<void> _onSharePressed(BuildContext context, DebitNote n) async {
    final file = await _exportToPdf(context, n);
    if (file != null) {
      await Share.shareXFiles([XFile(file.path)], text: 'Debit note');
    }
  }

  @override
  Widget build(BuildContext context) {
    final DebitNote n = Get.arguments as DebitNote;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: MediaQuery.removePadding(
        context: context,
        child: Screenshot(
          controller: _shot,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const CommonHeader(title: 'Debit Note'),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: queryWidth(context) * 0.05, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailRow(title: 'Invoice No:', value: n.invoiceNumber ?? '-'),
                    DetailRow(
                        title: 'Policy Broker ID:', value: n.policyBrokerID ?? '-'),
                    DetailRow(
                        title: 'Start Date:', value: formatDate(n.startDate ?? '')),
                    DetailRow(
                        title: 'End Date:', value: formatDate(n.endDate ?? '')),
                    DetailRow(
                        title: 'Sum Insured:',
                        value: (n.sumInsured ?? 0).toString()),
                    DetailRow(
                        title: 'Premium Due:',
                        value: (n.premiumDue ?? 0).toString()),
                    const SizedBox(height: 8),
                    DetailRow(title: 'Note Type ID:', value: n.noteTypeID ?? '-'),
                    DetailRow(
                        title: 'Actual Policy Broker ID:',
                        value: n.actualPolicyBrokerID ?? '-'),
                    DetailRow(title: 'Vendor:', value: n.vendorID ?? '-'),
                    DetailRow(
                        title: 'Endorsement ID:', value: n.endorsementID ?? '-'),
                    DetailRow(
                        title: 'Business Class:', value: n.businessClassID ?? '-'),
                    DetailRow(title: 'Risk Type ID:', value: n.riskTypeID ?? '-'),
                    const SizedBox(height: 80), // leave room above bottom bar
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
                  onPressed: () => _onExportPressed(context, n),
                  isExpanded: true,
                  bgColor: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PolicyButton(
                  text: 'Share',
                  onPressed: () => _onSharePressed(context, n),
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
