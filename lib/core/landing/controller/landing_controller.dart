import 'package:get/get.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/response/company_info_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';

class LandingController extends GetxController {
  final PibroRepository pibroRepository =
      PibroRepository(appApiProvider: ApiProvider());

  final Rxn<CompanyInfo> companyInfo = Rxn<CompanyInfo>();
  final RxBool isLoading = false.obs;

  Future<void> fetchCompanyInfo({bool forceRefresh = false}) async {
    if (companyInfo.value != null && !forceRefresh) return;

    isLoading.value = true;
    try {
      final response = await pibroRepository.getCompanyInformation();
      companyInfo.value = response.companyInfo;
    } catch (_) {
      // Fallback to default text when API fails quietly.
    } finally {
      isLoading.value = false;
    }
  }

  String getWelcomeText() {
    if (companyInfo.value?.companyName != null &&
        companyInfo.value!.companyName!.isNotEmpty) {
      return 'WELCOME TO\n${companyInfo.value!.companyName}\nSELF SERVICE';
    }
    return 'WELCOME TO\nPOWER INSURANCE BROKERAGE\nSELF SERVICE';
  }
}
