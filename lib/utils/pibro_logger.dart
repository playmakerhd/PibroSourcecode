import 'package:flutter/foundation.dart';
import 'package:logger/web.dart';

class PibroLogger {
  static late Logger _logger;

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
