import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pibro/utils/view_utils.dart';

/// Reusable bottom sheet widget to display Premium Demand Note PDF
/// with preview, save, and share options.
///
/// Usage:
/// ```dart
/// showPremiumDemandNoteSheet(
///   context: context,
///   fetchPdfBytes: () => controller.fetchPremiumDemandNoteBytes(),
///   quoteID: 'QN/20',
/// );
/// ```
void showPremiumDemandNoteSheet({
  required BuildContext context,
  required Future<Uint8List?> Function() fetchPdfBytes,
  required String quoteID,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: _PremiumDemandNoteBottomSheet(
        fetchPdfBytes: fetchPdfBytes,
        quoteID: quoteID,
      ),
    ),
  );
}

class _PremiumDemandNoteBottomSheet extends StatefulWidget {
  final Future<Uint8List?> Function() fetchPdfBytes;
  final String quoteID;

  const _PremiumDemandNoteBottomSheet({
    required this.fetchPdfBytes,
    required this.quoteID,
  });

  @override
  State<_PremiumDemandNoteBottomSheet> createState() =>
      _PremiumDemandNoteBottomSheetState();
}

class _PremiumDemandNoteBottomSheetState
    extends State<_PremiumDemandNoteBottomSheet> {
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  Uint8List? _pdfBytes;
  bool _saveLoading = false;
  bool _shareLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }

  Future<void> _fetchPdf() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = null;
      });

      final bytes = await widget.fetchPdfBytes();

      if (bytes == null) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Failed to load premium demand note';
        });
      } else {
        // Basic validation: check for PDF header '%PDF'
        final bool looksLikePdf = _looksLikePdf(bytes);
        print(
            'Premium demand note fetched: ${bytes.length} bytes, header: ${bytes.length >= 4 ? bytes.sublist(0, 4) : bytes}');

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
        errorMessage = 'Error loading premium demand note: $e';
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
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isLoading || hasError || _pdfBytes == null
                          ? null
                          : () async {
                              await _saveWithFilePicker();
                            },
                      icon: _saveLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_saveLoading ? 'Saving...' : 'Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
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
                        backgroundColor: AppColors.primaryColor,
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
              'Loading premium demand note...',
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
            const Text(
              'Failed to load premium demand note',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPdf,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // PDF loaded successfully - show PDF preview if bytes available
    if (_pdfBytes != null && _pdfBytes!.isNotEmpty) {
      return PdfPreview(
        build: (format) async => _pdfBytes!,
        allowPrinting: false,
        allowSharing: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        useActions: false,
        pdfFileName:
            'premium_demand_note_${widget.quoteID.replaceAll('/', '_')}.pdf',
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
            'Premium Demand Note PDF',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Document is ready - tap "Save" to download',
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
      setState(() {
        _saveLoading = true;
      });

      // Generate default filename
      final defaultName =
          'premium_demand_note_${widget.quoteID.replaceAll('/', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Let user pick save location
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Premium Demand Note',
        fileName: defaultName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: _pdfBytes,
      );

      if (outputFile != null) {
        // File was saved successfully by FilePicker
        showSnackbarMessage(
          message: 'Premium demand note saved to:\n$outputFile',
          isSuccess: true,
        );
        Navigator.of(context).pop();
      } else {
        // User cancelled
        showSnackbarMessage(
          message: 'Save cancelled',
          isWarning: true,
        );
      }
    } catch (e) {
      print('Error saving premium demand note with file picker: $e');
      showSnackbarMessage(
        message: 'Error saving premium demand note: $e',
        isSuccess: false,
      );
    } finally {
      setState(() {
        _saveLoading = false;
      });
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

      final fileName =
          'premium_demand_note_${widget.quoteID.replaceAll('/', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final tempFile = File('${tempDir.path}/$fileName');

      try {
        await tempFile.parent.create(recursive: true);
      } catch (_) {}

      await tempFile.writeAsBytes(_pdfBytes!, flush: true);

      // Use share_plus to open system share sheet
      await Share.shareXFiles([XFile(tempFile.path)],
          text: 'Premium Demand Note - ${widget.quoteID}');
    } catch (e) {
      print('Error sharing premium demand note: $e');
      showSnackbarMessage(
        message: 'Error sharing premium demand note: $e',
        isSuccess: false,
      );
    } finally {
      setState(() {
        _shareLoading = false;
      });
    }
  }
}
