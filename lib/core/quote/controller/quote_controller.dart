import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/response/quotes_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/utils/api_utils.dart' as api;
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

    // Premium & Sum Insured come from these two fields (already used in GetQuoteController)
    final premium =
        double.tryParse((q.supportResolution ?? '').replaceAll(',', '')) ?? 0.0;
    final sumInsured =
        double.tryParse((q.supportScreenShotURL ?? '').replaceAll(',', '')) ??
            0.0;

    // Dates: fall back safely if API didn’t set them
    final dates = api.getQuoteDates(q); // [start, end, renewal] as strings
    String startStr = dates.isNotEmpty ? dates[0] : '';
    String endStr = dates.length > 1 ? dates[1] : '';
    String renewalStr = dates.length > 2 ? dates[2] : '';
    String businessClassName;
    try {
      businessClassName = api.getQuoteClass(q); // from supportKeywords[1]
      if (businessClassName.trim().isEmpty) {
        businessClassName = q.supportType ?? ''; // fallback
      }
    } catch (_) {
      businessClassName = q.supportType ?? '';
    }

    // Preferred insurer (optional; safe defaults)
    final preferredInsurer = <String, dynamic>{
      'vendorID': (q.supportAssignedTo ?? '').toString(),
      'vendorName': (q.supportManager ?? '').toString(),
    };

    // Items: normalize from RequestDetails (subject/value primarily)
    final items = <Map<String, dynamic>>[];
    final details = q.requestDetails ?? const <RequestDetails>[];
    for (final it in details) {
      final desc = it.subject ?? it.message ?? 'Item';
      final val =
          double.tryParse('${it.value ?? 0}'.toString().replaceAll(',', '')) ??
              0.0;
      items.add({
        'itemsDescription': desc,
        'sumInsured': val,
        // itemLocation optional → CreatePolicyRequest builder already defaults
      });
    }
    final ctx = {
      'caseId': q.caseId,
      'premium': formatAmount(premium), // number
      'sumInsured': formatAmount(sumInsured), // number
      'riskName': q.productId,
      'businessClassName': businessClassName ?? '',
      'startDate': startStr,
      'endDate': endStr,
      'renewalDate': renewalStr,
      'preferredInsurer': preferredInsurer,
      'items': items,
      // Optional: IDs if you have them on the quote (kept blank if not present)
      'businessClassID': q.productId?.toString(),
      'riskTypeID': q.productId?.toString(),
    };

    // Persist for QuoteSummaryController & QuotePaymentController
    GetStorage().write(StorageKeys.lastEnquiry, ctx);

    // Go to the summary — it already shows details & has the Make Payment CTA wired.
    Get.toNamed(AppRoutes.quoteSummary);
  }

  @override
  void onInit() {
    super.onInit();
    getQuotes();
  }
}
