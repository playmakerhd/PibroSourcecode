import 'dart:convert';

class QLog {
  static String _ts() => DateTime.now().toIso8601String();

  static void d(String tag, String msg, [Map<String, dynamic>? data]) {
    final ctx = (data == null || data.isEmpty) ? '' : '\n${_pretty(data)}';
    // Consistent single print so logs don’t get interleaved
    // Look for: [QPAY][TAG]
    // Example: [QPAY][VERIFY] Payment status=success
    // ------------------------------------------------------------------------
    print('[QPAY][$tag] $_ts()  $msg$ctx');
  }

  static void e(String tag, Object err, StackTrace st,
      [Map<String, dynamic>? data]) {
    final ctx = (data == null || data.isEmpty) ? '' : '\n${_pretty(data)}';
    print('[QPAY][$tag][ERROR] $_ts()  $err\n$st$ctx');
  }

  static String _pretty(Map<String, dynamic> m) {
    try {
      return const JsonEncoder.withIndent('  ').convert(m);
    } catch (_) {
      return m.toString();
    }
  }
}
