import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pibro/constants/app_colors.dart';

/// Reusable PDF preview widget
class PdfPreviewWidget extends StatelessWidget {
  final String base64Data;
  final double? height;
  final String? errorMessage;

  const PdfPreviewWidget({
    super.key,
    required this.base64Data,
    this.height,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final bytes = base64Decode(base64Data);
      return Container(
        height: height ?? 200,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.greyColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: PdfPreview(
          build: (format) => bytes,
          allowPrinting: false,
          allowSharing: false,
          canChangePageFormat: false,
          canChangeOrientation: false,
          canDebug: false,
          pdfPreviewPageDecoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      return Container(
        height: height ?? 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'Invalid PDF data',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}

/// PDF preview in a bottom sheet
class PdfPreviewBottomSheet extends StatelessWidget {
  final String base64Data;
  final String title;

  const PdfPreviewBottomSheet({
    super.key,
    required this.base64Data,
    required this.title,
  });

  static void show(BuildContext context, String base64Data, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PdfPreviewBottomSheet(
        base64Data: base64Data,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: PdfPreviewWidget(
              base64Data: base64Data,
              errorMessage: 'Could not load PDF preview',
            ),
          ),
        ],
      ),
    );
  }
}
