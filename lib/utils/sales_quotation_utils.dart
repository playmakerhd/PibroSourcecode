import 'dart:convert';

import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/network/models/response/sales_quotation_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';

typedef QuoteLogFn = void Function(String message);

Future<bool> closeSalesQuotationIfPossible({
  required PibroRepository repo,
  required String? quoteNumber,
  QuoteLogFn? logFn,
}) async {
  final log = logFn ?? (message) => print(message);
  final qId = (quoteNumber ?? '').trim();
  if (qId.isEmpty) {
    log('QUOTE_STATUS: Skipping update - quote number missing');
    return false;
  }

  try {
    final raw = await repo.getSalesQuotationByID(qId);
    final json = _coerceQuoteJson(raw);
    if (json == null) {
      log('QUOTE_STATUS: Could not parse sales quotation payload for $qId');
      return false;
    }

    final quote = SalesQuotationResponse.fromJson(json);
    final alreadyClosed =
        (quote.session ?? '').trim().toUpperCase() == 'CLOSED';
    if (alreadyClosed) {
      log('QUOTE_STATUS: Quote already closed ($qId)');
      return true;
    }

    quote.session = 'CLOSED';
    final update = await repo.updateSalesQuotation(quote.toJson());
    final status = update.messageResponse.status;
    log('QUOTE_STATUS: updateSalesQuotation($qId) => $status');
    if (status != AppConstants.responseSuccess) {
      log('QUOTE_STATUS: Failed to close quote $qId: ${update.messageResponse.message}');
      return false;
    }

    return true;
  } catch (e) {
    log('QUOTE_STATUS: Error closing sales quotation $qId - $e');
    return false;
  }
}

Map<String, dynamic>? _coerceQuoteJson(dynamic raw) {
  if (raw is Map<String, dynamic>) return Map<String, dynamic>.from(raw);
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }

  try {
    final body = (raw as dynamic).response?.body;
    if (body is String && body.isNotEmpty) {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } else if (body != null && body is List<int>) {
      final decoded = jsonDecode(utf8.decode(body));
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    }
  } catch (_) {}

  return null;
}
