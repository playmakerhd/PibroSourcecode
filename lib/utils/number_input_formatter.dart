import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formats numbers with commas as user types
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final _formatter = NumberFormat('#,###', 'en_US');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    if (n.text.isEmpty) return n;
    final digits = n.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return o;
    final num = int.tryParse(digits);
    if (num == null) return o;
    final formatted = _formatter.format(num);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Format number with commas for display
String formatNumberWithCommas(num value) =>
    NumberFormat('#,###.##', 'en_US').format(value);
