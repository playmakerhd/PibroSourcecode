import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/response/quotes_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/utils/api_utils.dart' as api;
import 'package:pibro/utils/api_utils.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';

class QuoteController extends GetxController {
  PibroRepository pibroRepository =
      PibroRepository(appApiProvider: ApiProvider());
  RxBool quoteLoading = false.obs;
  RxList<QuoteInfo> quotes = RxList<QuoteInfo>([]);
  Rxn<QuoteInfo> selectedQuote = Rxn<QuoteInfo>();

  Future<void> getQuotes({String? status}) async {
    quoteLoading.value = true;
    try {
      final response = await pibroRepository.getQuotes();
      quotes.value = response.quotes.isEmpty
          ? []
          : response.quotes
              .where((quote) =>
                  quote.supportType == 'Quote' ||
                  quote.supportType == 'Policy Renewal')
              .toList();
      quoteLoading.value = false;
    } catch (e) {
      quoteLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  void navigateToQuoteDetails(QuoteInfo data) {
    selectedQuote.value = data;
    Get.toNamed(AppRoutes.quoteDetail);
  }

  /// Build the summary/payment context from the selected quote and navigate.
  void navigateToQuoteSummaryForPayment({QuoteInfo? quote}) {
    final q = quote ?? selectedQuote.value;
    if (q == null) {
      showSnackbarMessage(message: 'Select a quote first', isWarning: true);
      return;
    }

    // --- vendor from structured fields (preferred) ---
    String vendorId = (q.supportAssignedTo ?? '').toString().trim();
    String vendorName = (q.supportManager ?? '').toString().trim();

    // --- fallback: parse VendorID/Manager from SupportDescription ---
    final desc = (q.supportDescription ?? '').toString();
    if (vendorId.isEmpty && desc.isNotEmpty) {
      final m = RegExp(r'VendorID\s*[:\-]?\s*([^,\n]+)', caseSensitive: false)
          .firstMatch(desc);
      if (m != null) vendorId = (m.group(1) ?? '').trim();
    }
    if (vendorName.isEmpty && desc.isNotEmpty) {
      final m =
          RegExp(r'Vendor(Name)?\s*[:\-]?\s*([^,\n]+)', caseSensitive: false)
              .firstMatch(desc);
      if (m != null) {
        // group(2) contains the actual name when using the (Name)? capture
        vendorName =
            (m.groupCount >= 2 ? (m.group(2) ?? '') : (m.group(1) ?? ''))
                .trim();
      }
    }
    if (vendorName.isEmpty && vendorId.isNotEmpty) vendorName = vendorId;

    // --- optional fallback: previously picked preferredInsurer from storage ---
    if (vendorId.isEmpty) {
      final raw = GetStorage().read(StorageKeys.preferredInsurer);
      if (raw is Map && (raw['vendorID']?.toString().isNotEmpty ?? false)) {
        vendorId = raw['vendorID'].toString();
        vendorName = (raw['vendorName'] ?? vendorId).toString();
      } else if (raw is String) {
        try {
          final m = jsonDecode(raw);
          if (m is Map && (m['vendorID']?.toString().isNotEmpty ?? false)) {
            vendorId = m['vendorID'].toString();
            vendorName = (m['vendorName'] ?? vendorId).toString();
          }
        } catch (_) {}
      }
    }

    final preferredInsurer = <String, dynamic>{
      'vendorID': vendorId,
      'vendorName': vendorName,
    };

    // --- items: prefer fields from RequestDetails.message for Description & Location ---
    final items = <Map<String, dynamic>>[];
    final details = q.requestDetails ?? const <RequestDetails>[];
    for (final it in details) {
      final msg = (it.message ?? '').toString();

      // Description: try explicit fields then Message parsing then subject fallback
      String descTxt = (it.subject ?? '').toString();
      final md = RegExp(r'Description\s*[:\-\s]*([^,]+)', caseSensitive: false)
          .firstMatch(msg);
      if (md != null) descTxt = (md.group(1) ?? '').trim();
      if (descTxt.isEmpty)
        descTxt = (it.subject ?? it.message ?? 'Item').toString();

      // Location: parse from Message if present
      String loc = '';
      final ml = RegExp(r'Location\s*[:\-\s]*([^,]+)', caseSensitive: false)
          .firstMatch(msg);
      if (ml != null) loc = (ml.group(1) ?? '').trim();

      final val =
          double.tryParse('${it.value ?? 0}'.toString().replaceAll(',', '')) ??
              0.0;

      final itemMap = {
        'itemsDescription': descTxt,
        'sumInsured': val,
      };
      if (loc.isNotEmpty) itemMap['itemLocation'] = loc;
      items.add(itemMap);
    }

    // Dates: fall back safely if API didn’t set them
    final dates = api.getQuoteDates(q); // [start, end, renewal] as strings
    String startStr = dates.isNotEmpty ? dates[0] : '';
    String endStr = dates.length > 1 ? dates[1] : '';
    String renewalStr = dates.length > 2 ? dates[2] : '';

    // Build context (keep previous fields) — prefer numeric types where possible
    final premium =
        double.tryParse((q.supportResolution ?? '').replaceAll(',', '')) ?? 0.0;
    final sumInsured =
        double.tryParse((q.supportScreenShotURL ?? '').replaceAll(',', '')) ??
            0.0;

    // Primary source of truth for BusinessClassID is SupportRequestMethod
    String businessClassId = (q.supportRequestMethod ?? '').toString().trim();
    if (businessClassId.isEmpty) {
      businessClassId = (q.productId ?? '').toString().trim();
    }
    if (businessClassId.isEmpty && (q.supportDescription ?? '').isNotEmpty) {
      final m =
          RegExp(r'BusinessClassID\s*[:\-]?\s*([^,\n]+)', caseSensitive: false)
              .firstMatch(q.supportDescription!);
      if (m != null) businessClassId = (m.group(1) ?? '').trim();
    }

    final ctx = {
      'caseId': q.caseId,
      'premium': premium,
      'sumInsured': sumInsured,
      'riskName': q.productId,
      'businessClassName': (api.getQuoteClass(q) ?? q.supportType ?? ''),
      // canonical BCID for later create-policy flows
      'businessClassID': businessClassId,
      'startDate': startStr,
      'endDate': endStr,
      'renewalDate': renewalStr,
      'preferredInsurer': preferredInsurer,
      'items': items,
      'riskTypeID': q.productId?.toString(),
    };

    // Persist & navigate
    GetStorage().write(StorageKeys.lastEnquiry, ctx);
    Get.toNamed(AppRoutes.quoteSummary);
  }

  Future<void> createQuote(Map<String, dynamic> draft) async {
    try {
      // --- vendor: structured fields (preferred) ---
      final v = draft['preferredInsurer'] as Map?;
      final payload = ApiUtils.createQuote(
        // productId (risk type ID)
        draft['riskTypeID'] ?? draft['riskName'] ?? '',
        // pass both businessClassID and businessClassName (prefer ID)
        draft['businessClassID'] ?? draft['businessClassName'] ?? '',
        draft['businessClassName'] ?? draft['businessClassID'] ?? '',
        draft['startDate'] ?? '',
        draft['endDate'] ?? '',
        draft['renewalDate'] ?? '',
        List<Map<String, dynamic>>.from(draft['items'] ?? const []),
        vendorID: v?['vendorID']?.toString(),
        vendorName: v?['vendorName']?.toString(),
      );
      final createRes = await pibroRepository.sendToBroker(payload);
      if (createRes != null) {
        showSnackbarMessage(
            message: 'Quote sent to broker successfully', isSuccess: true);
        // Optionally: navigate to another page or clear the form
      } else {
        showSnackbarMessage(
            message: 'Failed to send quote to broker', isSuccess: false);
      }
    } catch (e) {
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  @override
  void onInit() {
    super.onInit();
    getQuotes();
  }
}
