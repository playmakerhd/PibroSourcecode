import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/response/quotes_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
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
      // Get entity ID from storage (works for both Lead and Customer)
      final loginData = decryptData(StorageKeys.loginData);
      String? entityID;

      if (loginData != null) {
        final data = jsonDecode(loginData);
        entityID = data['customerID'] as String?;
      }

      if (entityID == null || entityID.isEmpty) {
        showSnackbarMessage(message: 'User not logged in', isSuccess: false);
        quoteLoading.value = false;
        return;
      }

      // Use new Sales Quotation API
      final response = await pibroRepository.getSalesQuotationsByEntityID(
        entityID: entityID,
        pageNum: 1,
        size: 1000,
      );

      // Convert Sales Quotation response to QuoteInfo format for backward compatibility
      quotes.value = response.isEmpty
          ? []
          : response
              .map((item) => _convertSalesQuotationToQuoteInfo(item))
              .toList();

      quoteLoading.value = false;
    } catch (e) {
      quoteLoading.value = false;
      showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr, isSuccess: false);
    }
  }

  // Convert Sales Quotation response to QuoteInfo format
  QuoteInfo _convertSalesQuotationToQuoteInfo(Map<String, dynamic> salesQuote) {
    // Extract values with null safety
    final invoiceNumber = salesQuote['InvoiceNumber'] ?? '';
    final sumInsured = salesQuote['SumInsured'] ?? 0.0;
    final premiumDue = salesQuote['PremiumDue'] ?? 0.0;
    final invoiceDate = salesQuote['InvoiceDate'] ?? '';
    final riskTypeID = salesQuote['RiskTypeID'] ?? '';
    final noteStatus = salesQuote['NoteStatus'] ?? 'Pending';
    final itemsToInsure = salesQuote['ItemsToInsure'] as List? ?? [];

    // Convert items to RequestDetails format
    final requestDetails = itemsToInsure.map((item) {
      final sumInsuredValue = item['SumInsured'];
      final valueDouble =
          sumInsuredValue is num ? sumInsuredValue.toDouble() : 0.0;

      return RequestDetails(
        caseID: invoiceNumber,
        subject: item['ItemsDescription'] ?? '',
        message: item['ItemsDescription'] ?? '',
        screenShotURL: item['PolicyItems'] ?? '',
        caseIDDetail: 0,
        value: valueDouble,
      );
    }).toList();

    return QuoteInfo(
      caseId: invoiceNumber, // Use InvoiceNumber as caseId (e.g., QN/11)
      customerId: salesQuote['CustomerID'] ?? '',
      productId: riskTypeID,
      supportManager: salesQuote['VendorID'] ?? '',
      supportAssignedTo: salesQuote['VendorID'] ?? '',
      supportRequestMethod: salesQuote['BusinessClassID'] ?? '',
      supportStatus: noteStatus,
      supportType: 'Quote',
      supportDate: invoiceDate,
      supportKeywords:
          'Quote, ${salesQuote['BusinessClassID'] ?? ''}, $riskTypeID',
      supportDescription: salesQuote['PremiumDescription'] ?? '',
      supportScreenShotURL: sumInsured.toString(), // Store sum insured here
      supportResolution: premiumDue.toString(), // Store premium here
      supportEnquiryDate: salesQuote['StartDate'] ?? '',
      supportEnquiryLapseDate: salesQuote['EndDate'] ?? '',
      requestDetails: requestDetails,
      quoteRequest: true,
      supportApproved: salesQuote['QuotationCleared'] ?? false,
    );
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
      if (descTxt.isEmpty) {
        descTxt = (it.subject ?? it.message ?? 'Item').toString();
      }

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

      // *** CRITICAL: Include document/attachment data from screenShotURL ***
      if (it.screenShotURL?.isNotEmpty ?? false) {
        itemMap['screenShotURL'] = it.screenShotURL!;
        print(
            '📎 Including document for item: $descTxt -> ${it.screenShotURL!.length} chars');
      }

      items.add(itemMap);
    }

    // Dates: fall back safely if API didn’t set them
    final dates = getQuoteDates(q); // [start, end, renewal] as strings
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
      'businessClassName': getQuoteClass(q),
      // canonical BCID for later create-policy flows
      'businessClassID': businessClassId,
      'startDate': startStr,
      'endDate': endStr,
      'renewalDate': renewalStr,
      'preferredInsurer': preferredInsurer,
      'items': items,
      'riskTypeID': q.productId?.toString(),
    };

    // Persist & navigate - but only if this is NOT from a fresh quote submission
    // Check if we have fresh quote data from get_quote_controller first
    final existingEnquiry = GetStorage().read(StorageKeys.lastEnquiry) as Map?;
    final hasFreshQuoteData =
        existingEnquiry != null && existingEnquiry['_source'] == 'fresh_quote';

    // Only overwrite if we don't have fresh quote data, OR if the fresh quote
    // data lacks the riskTypeID from the selected quote (ensure consistency)
    if (!hasFreshQuoteData ||
        (hasFreshQuoteData &&
            (existingEnquiry['riskTypeID']?.toString().isEmpty ?? true) &&
            ctx['riskTypeID']?.toString().isNotEmpty == true)) {
      print(
          "💾 Writing quote data to storage (no fresh quote detected or updating riskTypeID)");
      print("📋 Items being stored: ${items.length} items");
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        print(
            "   Item $i: ${item['itemsDescription']} - Has document: ${item.containsKey('screenShotURL')}");
      }
      GetStorage().write(StorageKeys.lastEnquiry, ctx);
    } else {
      print(
          "🚫 Skipping storage write - fresh quote data present with valid riskTypeID");
    }
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
      await pibroRepository.sendToBroker(payload);
      showSnackbarMessage(
          message: 'Quote sent to broker successfully', isSuccess: true);
      // Optionally: navigate to another page or clear the form
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
