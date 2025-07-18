import 'package:get/get.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/response/quotes_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
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

  @override
  void onInit() {
    super.onInit();
    getQuotes();
  }
}
