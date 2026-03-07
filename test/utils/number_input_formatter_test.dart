import 'package:flutter_test/flutter_test.dart';
import 'package:pibro/utils/number_input_formatter.dart';

void main() {
  group('ThousandsSeparatorInputFormatter', () {
    final formatter = ThousandsSeparatorInputFormatter();

    test('formats numbers with commas', () {
      expect(
          formatter
              .formatEditUpdate(
                  TextEditingValue.empty, const TextEditingValue(text: '1000'))
              .text,
          '1,000');
      expect(
          formatter
              .formatEditUpdate(TextEditingValue.empty,
                  const TextEditingValue(text: '1000000'))
              .text,
          '1,000,000');
    });

    test('handles edge cases', () {
      expect(
          formatter
              .formatEditUpdate(TextEditingValue.empty, TextEditingValue.empty)
              .text,
          '');
      expect(
          formatter
              .formatEditUpdate(const TextEditingValue(text: '100'),
                  const TextEditingValue(text: '100a'))
              .text,
          '100');
    });
  });

  group('formatNumberWithCommas', () {
    test('formats numbers for display', () {
      expect(formatNumberWithCommas(1000), '1,000');
      expect(formatNumberWithCommas(1234567.89), '1,234,567.89');
    });
  });
}
