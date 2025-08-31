import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<void> printQuote(Map<String, dynamic> quoteData) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Quote Summary',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              _buildDetailRow('Insurance Class:',
                  '${quoteData['businessClassName'] ?? ''}'),
              _buildDetailRow('Product:', '${quoteData['riskName'] ?? ''}'),
              _buildDetailRow(
                  'New Start Date:', '${quoteData['startDate'] ?? ''}'),
              _buildDetailRow('New End Date:', '${quoteData['endDate'] ?? ''}'),
              _buildDetailRow(
                  'New Renewal Date:', '${quoteData['renewalDate'] ?? ''}'),
              _buildDetailRow(
                  'Sum Insured(NGN):', '${quoteData['sumInsured'] ?? 0}'),
              _buildDetailRow(
                  'Premium Due(NGN):', '${quoteData['premium'] ?? 0}'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  static pw.Widget _buildDetailRow(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(value),
        ],
      ),
    );
  }
}
