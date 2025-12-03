import 'package:flutter_test/flutter_test.dart';
import 'package:pibro/utils/number_input_formatter.dart';
import 'package:flutter/services.dart';

void main() {
  group('ThousandsSeparatorInputFormatter', () {
    late ThousandsSeparatorInputFormatter formatter;

    setUp(() {
      formatter = ThousandsSeparatorInputFormatter();
    });

    test('formats number with thousands separator', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '1000');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '1,000');
    });

    test('formats large number with multiple separators', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '1000000');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '1,000,000');
    });

    test('handles empty input', () {
      const oldValue = TextEditingValue(text: '1,000');
      const newValue = TextEditingValue.empty;

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '');
    });

    test('removes existing commas and reformats', () {
      const oldValue = TextEditingValue(text: '1,000');
      const newValue = TextEditingValue(text: '1,0005');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '10,005');
    });

    test('handles single digit input', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '5');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '5');
    });

    test('handles three digit input without separator', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '999');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '999');
    });

    test('rejects non-numeric input', () {
      const oldValue = TextEditingValue(text: '100');
      const newValue = TextEditingValue(text: '100a');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      // Should return old value when invalid input is detected
      expect(result.text, oldValue.text);
    });

    test('value can be parsed back to double', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '1234567');

      final result = formatter.formatEditUpdate(oldValue, newValue);
      final parsedValue = double.parse(result.text.replaceAll(',', ''));

      expect(result.text, '1,234,567');
      expect(parsedValue, 1234567.0);
    });
  });

  group('DecimalThousandsSeparatorInputFormatter', () {
    late DecimalThousandsSeparatorInputFormatter formatter;

    setUp(() {
      formatter = DecimalThousandsSeparatorInputFormatter();
    });

    test('formats decimal number with thousands separator', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '1000.50');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '1,000.50');
    });

    test('allows decimal point without digits', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '1000.');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '1,000.');
    });

    test('limits decimal places to 2', () {
      const oldValue = TextEditingValue(text: '100.5');
      const newValue = TextEditingValue(text: '100.555');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '100.55');
    });

    test('prevents multiple decimal points', () {
      const oldValue = TextEditingValue(text: '100.5');
      const newValue = TextEditingValue(text: '100.5.5');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, oldValue.text);
    });

    test('handles empty input', () {
      const oldValue = TextEditingValue(text: '1,000.50');
      const newValue = TextEditingValue.empty;

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '');
    });

    test('value can be parsed back to double', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '1234567.89');

      final result = formatter.formatEditUpdate(oldValue, newValue);
      final parsedValue = double.parse(result.text.replaceAll(',', ''));

      expect(result.text, '1,234,567.89');
      expect(parsedValue, 1234567.89);
    });
  });
}
