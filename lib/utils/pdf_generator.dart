import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf_;
import 'package:pibro/constants/pdf_styles.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
// import 'package:document_file_save_plus/document_file_save_plus.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_io/io.dart' as io;
import 'package:path_provider/path_provider.dart';

class PaymentReportPDFGenerator {
  final BuildContext buildContext;

  final double width = pdf_.PdfPageFormat.a4.width;

  PaymentReportPDFGenerator({
    required this.buildContext,
  });

  Future<Uint8List> generatePDF(BuildContext buildContext) async {
    final pdf = pw.Document();
    final fonts = await PdfStyles.collectFonts();
    final List<pw.Widget> children = [];
    // int len = selectedReports.length;
    // int size = 13;

    // if (len > size) {
    //   for (var i = 0; i < len; i += size) {
    //     int end = (i + size < len) ? i + size : len;
    //     children.add(PaymentReportCardPdf(
    //       selectedReports: selectedReports.sublist(i, end),
    //       platformUser: platformUser,
    //       fonts: fonts,
    //     ));
    //   }
    // } else {
    //   children.add(PaymentReportCardPdf(
    //     selectedReports: selectedReports,
    //     platformUser: platformUser,
    //     fonts: fonts,
    //   ));
    // }

    // String calculateTotal() {
    //   double sum = selectedReports.fold(
    //       0, (previous, current) => previous + current.economicalProposal!);
    //   return NumberFormat.currency(symbol: "€").format(sum);
    // }

    // pw.Widget totalContent() {
    //   return pw.Align(
    //     alignment: pw.Alignment.centerRight,
    //     child: pw.Padding(
    //       padding: const pw.EdgeInsets.all(10),
    //       child: pw.Column(
    //         crossAxisAlignment: pw.CrossAxisAlignment.start,
    //         children: [
    //           pw.SizedBox(height: 19),
    //           pw.Padding(
    //             padding: const pw.EdgeInsets.only(bottom: 5),
    //             child: pw.Text(
    //               'Total',
    //               style: PdfStyles.getTextStyle(fonts['workSansRegular'],
    //                   size: 13, color: PdfStyles.colorPrimary),
    //               maxLines: 1,
    //               overflow: pw.TextOverflow.clip,
    //             ),
    //           ),
    //           pw.Text(
    //             calculateTotal(),
    //             style: PdfStyles.getTextStyle(fonts['workSansRegular'],
    //                 size: 18, color: PdfStyles.colorPrimary),
    //             maxLines: 1,
    //             overflow: pw.TextOverflow.clip,
    //           ),
    //           pw.SizedBox(height: 19),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    pdf.addPage(pw.MultiPage(
        maxPages: 3,
        pageFormat: pdf_.PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Wrap(children: [
              pw.Text('Pdf Report'),
            ]),
          ];
        }));

    return Uint8List.fromList(await pdf.save());
  }

  void _downloadPaymentReportPdf(BuildContext context) {
    PaymentReportPDFGenerator(
            // selectedReports: selectedReports,
            // platformUser: platformUser,
            buildContext: context)
        .generatePDF(context)
        .then((file) => {
              if (!kIsWeb)
                downloadMobileFile(file,
                    "Payment_report${DateTime.now().toIso8601String()}.pdf")
              else
                downloadWebFileFromBytes(file,
                    "Payment_report${DateTime.now().toIso8601String()}.pdf")
            });
  }

  void downloadWebFileFromBytes(Uint8List bytes, String? fileName) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = fileName;
    anchorElement.click();
  }

  Future<void> downloadMobileFile(Uint8List bodyBytes, String name) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _downloadPdfAndroid(bodyBytes, name);
    } else {
      _downloadPdfIOS(bodyBytes, name);
    }
  }

  Future<void> _downloadPdfIOS(Uint8List bodyBytes, String name) async {
    final path = (await getApplicationDocumentsDirectory()).path;
    var bytes = bodyBytes;

    final mime = lookupMimeType('', headerBytes: bytes);

    if (mime == null) return;

    String filePath = '$path/$name';
    File file = File(filePath);
    await file.writeAsBytes(bytes);

    // DocumentFileSavePlus().saveFile(bytes.buffer.asUint8List(), name, mime);
  }

  Future<void> _downloadPdfAndroid(Uint8List bodyBytes, String name) async {
    final path = (await getExternalStorageDirectory())?.path;
    var bytes = bodyBytes;

    final mime = lookupMimeType('', headerBytes: bytes);

    if (mime == null) return;

    String filePath = '$path/$name';
    File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    //open
    OpenFilex.open(filePath);
  }
}
