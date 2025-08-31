import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:logger/web.dart';

class PibroLogger {
  static late Logger _logger;
   static void logRequest(String message) => _out('[REQ] $message');
  static void logResponse(String message) => _out('[RES] $message');

  // Use this for very long JSONs to avoid truncation in consoles
  static void long(String tag, String message) {
    final pattern = RegExp('.{1,800}', dotAll: true);
    for (final match in pattern.allMatches(message)) {
      _out('$tag ${match.group(0)}');
    }
  }

  static void _out(String message) {
    // Always write to dev.log so it shows in both Debug & Release Logcat
    dev.log(message, name: 'PIBRO');

    // Also mirror to debugPrint in debug/profile
    if (!kReleaseMode) {
      debugPrint(message);
    }
  }
  static void init() {
    _logger = Logger(
      filter: AppLogFilter(),
      printer: PrettyPrinter(
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
    );
  }

  static Logger get logger => _logger;

  static void logHttp(
      {String? url,
      String? headers,
      String? requestData,
      String? code,
      String? body}) {
    _logger.d("URL: $url"
        "\nREQUEST HEADERS: $headers"
        "\nREQUEST DATA: $requestData"
        "\nSTATUS CODE: $code"
        "\nRESPONSE BODY: $body");
  }
}

class AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return !kReleaseMode;
  }
}
