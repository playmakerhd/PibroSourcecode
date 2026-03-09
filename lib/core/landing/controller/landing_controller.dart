import 'package:get/get.dart';
import 'package:pibro/network/models/response/company_info_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';

class LandingController extends GetxController {
  // Use constructor injection to allow providing a mocked repository in tests.
  final PibroRepository pibroRepository;

  LandingController({required this.pibroRepository});

  final Rxn<CompanyInfo> companyInfo = Rxn<CompanyInfo>();
  final Rxn<String> errorMessage = Rxn<String>();
  final RxBool isLoading = false.obs;

  Future<void> fetchCompanyInfo({bool forceRefresh = false}) async {
    if (companyInfo.value != null && !forceRefresh) return;

    isLoading.value = true;
    try {
      final response = await pibroRepository.getCompanyInformation();
      companyInfo.value = response.companyInfo;
      // clear any previous error on success
      errorMessage.value = null;
    } catch (e, st) {
      // Fallback to default text when API fails, but log for observability
      errorMessage.value = e.toString();
      // Use print as a minimum; replace with app logger if available
      print('LandingController.fetchCompanyInfo error: $e');
      print(st);
    } finally {
      isLoading.value = false;
    }
  }

  String getWelcomeText() {
    final name = companyInfo.value?.companyName?.trim();
    if (name != null && name.isNotEmpty) {
      return 'WELCOME TO\n${name.toUpperCase()}\nSELF SERVICE';
    }
    return 'WELCOME TO\nPOWER INSURANCE BROKERAGE\nSELF SERVICE';
  }
}
