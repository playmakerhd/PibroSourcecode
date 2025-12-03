import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// A TextInputFormatter that formats numbers with thousand separators (commas)
/// while the user types, without interfering with the underlying numeric value.
///
/// Usage:
/// ```dart
/// TextFormField(
///   controller: myController,
///   keyboardType: TextInputType.number,
///   inputFormatters: [ThousandsSeparatorInputFormatter()],
/// )
/// ```
///
/// To get the numeric value from the controller:
/// ```dart
/// final numericValue = double.tryParse(myController.text.replaceAll(',', '')) ?? 0;
/// ```
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty input
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters (including existing commas)
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // If only non-digit characters were entered, return old value
    if (digitsOnly.isEmpty) {
      return oldValue;
    }

    // Parse the numeric value
    final numericValue = int.tryParse(digitsOnly);
    if (numericValue == null) {
      return oldValue;
    }

    // Format with commas
    final formattedValue = _formatter.format(numericValue);

    // Always place cursor at the end for simplicity
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}

/// A TextInputFormatter for decimal numbers with thousand separators.
/// Supports up to 2 decimal places.
///
/// Usage:
/// ```dart
/// TextFormField(
///   controller: myController,
///   keyboardType: TextInputType.numberWithOptions(decimal: true),
///   inputFormatters: [DecimalThousandsSeparatorInputFormatter()],
/// )
/// ```
///
/// To get the numeric value from the controller:
/// ```dart
/// final numericValue = double.tryParse(myController.text.replaceAll(',', '')) ?? 0.0;
/// ```
class DecimalThousandsSeparatorInputFormatter extends TextInputFormatter {
  final int decimalPlaces;

  DecimalThousandsSeparatorInputFormatter({this.decimalPlaces = 2});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty input
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all characters except digits and decimal point
    String filtered = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // Allow only one decimal point
    int decimalCount = '.'.allMatches(filtered).length;
    if (decimalCount > 1) {
      return oldValue;
    }

    // Split by decimal point
    List<String> parts = filtered.split('.');

    // Format the integer part with commas
    if (parts[0].isNotEmpty) {
      final numericValue = int.tryParse(parts[0]);
      if (numericValue != null) {
        parts[0] = NumberFormat('#,###', 'en_US').format(numericValue);
      }
    }

    // Limit decimal places
    if (parts.length > 1 && parts[1].length > decimalPlaces) {
      parts[1] = parts[1].substring(0, decimalPlaces);
    }

    // Reconstruct the value
    String formattedValue = parts[0];
    if (filtered.contains('.')) {
      formattedValue += '.';
      if (parts.length > 1) {
        formattedValue += parts[1];
      }
    }

    // Always place cursor at the end for simplicity
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
