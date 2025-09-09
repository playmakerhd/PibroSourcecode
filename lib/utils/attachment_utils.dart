import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

/// Returns true if the provided string looks like a non-empty base64 payload.
bool hasDisplayableBase64(String? s) {
  if (s == null) return false;
  final t = s.trim();
  return t.isNotEmpty && t.toLowerCase() != 'null';
}

/// Decodes a base64 string. If the string contains a comma (data URI), only
/// the payload after the last comma is decoded.
Uint8List decodeBase64Data(String b64) {
  final payload = b64.contains(',') ? b64.split(',').last : b64;
  return base64Decode(payload);
}

/// Returns true if the base64 payload decodes to a PDF (starts with "%PDF-").
bool isPdfBase64(String? s) {
  if (!hasDisplayableBase64(s)) return false;
  final bytes = decodeBase64Data(s!);
  if (bytes.length < 5) return false;
  final hdr = String.fromCharCodes(bytes.sublist(0, 5));
  return hdr == '%PDF-';
}

/// Small convenience widget that displays either an image (decoded from the
/// base64) or a placeholder for PDFs. For inline PDF viewing add a PDF
/// viewer package (for example: `syncfusion_flutter_pdfviewer`) and replace the
/// PDF branch accordingly.
Widget buildAttachmentWidget(String? base64, {double? height}) {
  if (!hasDisplayableBase64(base64)) return const SizedBox.shrink();

  if (isPdfBase64(base64)) {
    // Option A (recommended): Inline PDF viewer using a package like
    // `syncfusion_flutter_pdfviewer`. Add the dependency to pubspec.yaml and
    // replace the return below with:
    //
    // return SizedBox(
    //   height: height ?? 240,
    //   child: SfPdfViewer.memory(decodeBase64Data(base64!)),
    // );
    //
    // Option B: fallback UI that instructs caller to open the PDF externally.
    return Container(
      height: height ?? 240,
      alignment: Alignment.center,
      child: const Text('PDF attachment (tap to open with a PDF viewer)'),
    );
  }

  // Image path (what existing code was doing, but guarded)
  return Image.memory(
    decodeBase64Data(base64!),
    height: height,
    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
  );
}
