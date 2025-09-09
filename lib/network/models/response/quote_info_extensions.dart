import 'package:pibro/network/models/response/quotes_response.dart';

extension QuoteInfoX on QuoteInfo {
  /// ISO or raw string from API (Start)
  String get startDateRaw => (supportEnquiryDate ?? '').toString();

  /// ISO or raw string from API (End)
  String get endDateRaw => (supportEnquiryLapseDate ?? '').toString();

  /// Renewal date is not a dedicated field from backend; it is embedded
  /// in SupportDescription as: "Renewal Date: <value>"
  String get renewalDateRaw => _extractFromDescription('Renewal Date');

  String _extractFromDescription(String label) {
    final s = (supportDescription ?? '').toString();
    if (s.isEmpty) return '';
    final re = RegExp('$label\\s*[:\\-]?\\s*([^,\\n]+)', caseSensitive: false);
    final m = re.firstMatch(s);
    return (m?.group(1) ?? '').trim();
  }
}
