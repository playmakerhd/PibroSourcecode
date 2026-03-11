import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formats numbers with commas as user types
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final _formatter = NumberFormat('#,###.##', 'en_US');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    if (n.text.isEmpty) return n;
    final cleaned = n.text.replaceAll(RegExp(r'[^\d.]'), '');
    if (cleaned.isEmpty) return o;
    if (cleaned == '.') {
      return TextEditingValue(
          text: '0.', selection: TextSelection.collapsed(offset: 2));
    }
    final parts = cleaned.split('.');
    if (parts.length > 2) return o;
    final num = double.tryParse(cleaned);
    if (num == null) return o;
    String formatted = _formatter.format(num);
    if (cleaned.endsWith('.') && !formatted.contains('.')) formatted += '.';
    return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length));
  }
}

/// Format number with commas for display
String formatNumberWithCommas(num value) =>
    NumberFormat('#,###.##', 'en_US').format(value);
