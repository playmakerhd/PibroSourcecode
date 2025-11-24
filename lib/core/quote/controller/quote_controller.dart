import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/response/sales_quotation_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/utils/api_utils.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';

class QuoteController extends GetxController {
  PibroRepository pibroRepository =
      PibroRepository(appApiProvider: ApiProvider());
  RxBool quoteLoading = false.obs;
  RxList<SalesQuotationResponse> quotes = RxList<SalesQuotationResponse>([]);
  Rxn<SalesQuotationResponse> selectedQuote = Rxn<SalesQuotationResponse>();

  Future<void> getQuotes({String? status}) async {
    quoteLoading.value = true;
    try {
      // Get entity ID from storage (works for both Lead and Customer)
      final loginData = decryptData(StorageKeys.loginData);
      String? entityID;

      if (loginData != null) {
        if (loginData is Map) {
          // Try different case variations of customerID
          entityID = loginData['customerID'] as String? ??
              loginData['CustomerID'] as String? ??
              loginData['customerId'] as String?;
          print(
              '📋 LoginData (Map): customerID=$entityID, entityType=${loginData['entityType']}');
        } else if (loginData is String) {
          print('📋 LoginData is String, attempting to parse...');
          try {
            final data = jsonDecode(loginData);
            if (data is Map) {
              entityID = data['customerID'] as String? ??
                  data['CustomerID'] as String? ??
                  data['customerId'] as String?;
            }
          } catch (e) {
            print('⚠️ Failed to parse loginData string: $e');
            // Fallback: handle Map-style string e.g. {customerID: lead/22, ...}
            entityID = _extractEntityIdFromRawString(loginData);
            if (entityID != null) {
              print('🔁 Extracted entityID using fallback parser: $entityID');
            }
          }
        }
      }

      if (entityID == null || entityID.isEmpty) {
        quoteLoading.value = false;
        print('⚠️ No entity ID found - user may not be logged in');
        return;
      }

      print('✅ Using entityID: $entityID');

      // Use Sales Quotation API - directly parse to SalesQuotationResponse
      final response = await pibroRepository.getSalesQuotationsByEntityID(
        entityID: entityID,
        pageNum: 1,
        size: 1000,
      );

      // Map API response directly to SalesQuotationResponse model
      quotes.value = response.isEmpty
          ? []
          : response
              .map((item) => SalesQuotationResponse.fromJson(item))
              .toList();

      quoteLoading.value = false;
    } catch (e) {
      quoteLoading.value = false;
      print('❌ Error fetching quotes: $e');
      // Don't show snackbar during initialization to avoid controller errors
      // Error will be visible via empty state in UI
    }
  }

  void navigateToQuoteDetails(SalesQuotationResponse data) {
    selectedQuote.value = data;
    Get.toNamed(AppRoutes.quoteDetail);
  }

  /// Build the summary/payment context from the selected quote and navigate.
  void navigateToQuoteSummaryForPayment({SalesQuotationResponse? quote}) {
    final q = quote ?? selectedQuote.value;
    if (q == null) {
      showSnackbarMessage(message: 'Select a quote first', isWarning: true);
      return;
    }

    // Direct vendor information from API response
    String vendorId = (q.vendorID ?? '').trim();
    String vendorName = vendorId; // Use vendorID as name if name not available

    // Fallback to storage if vendorId is empty
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

    // Build items list directly from ItemsToInsure
    final items = <Map<String, dynamic>>[];
    final itemsToInsure = q.itemsToInsure ?? [];
    for (final item in itemsToInsure) {
      final itemMap = {
        'itemsDescription': item.itemsDescription ?? 'Item',
        'sumInsured': item.sumInsured ?? 0.0,
      };

      if (item.itemLocation?.isNotEmpty ?? false) {
        itemMap['itemLocation'] = item.itemLocation!;
      }

      // Include document/attachment data if present
      if (item.policyItems?.isNotEmpty ?? false) {
        itemMap['screenShotURL'] = item.policyItems!;
        print(
            '📎 Including document for item: ${item.itemsDescription} -> ${item.policyItems!.length} chars');
      }

      items.add(itemMap);
    }

    // Direct date extraction from API response
    String startStr = q.startDate ?? '';
    String endStr = q.endDate ?? '';
    String renewalStr = q.renewaldate ?? '';

    // Direct values from API response
    final premium = q.premiumDue ?? 0.0;
    final sumInsured = q.sumInsured ?? 0.0;
    final businessClassId = q.businessClassID ?? '';
    final riskTypeID = q.riskTypeID ?? '';

    final ctx = {
      'caseId': q.invoiceNumber,
      'premium': premium,
      'sumInsured': sumInsured,
      'riskName': riskTypeID,
      'businessClassName': businessClassId,
      'businessClassID': businessClassId,
      'startDate': startStr,
      'endDate': endStr,
      'renewalDate': renewalStr,
      'preferredInsurer': preferredInsurer,
      'items': items,
      'riskTypeID': riskTypeID,
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
    // Defer the API call slightly to ensure navigation context is ready
    Future.delayed(Duration(milliseconds: 100), () {
      getQuotes();
    });
  }

  String? _extractEntityIdFromRawString(String raw) {
    final match = RegExp(r'customerID\s*:\s*([^,}]+)', caseSensitive: false)
        .firstMatch(raw);
    return match?.group(1)?.trim();
  }
}
