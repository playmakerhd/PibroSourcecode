import 'package:get/get.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/response/company_info_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';

class LandingController extends GetxController {
  PibroRepository pibroRepository =
      PibroRepository(appApiProvider: ApiProvider());

  Rxn<CompanyInfo> companyInfo = Rxn<CompanyInfo>();
  RxBool isLoading = false.obs;

  Future<void> fetchCompanyInfo({bool forceRefresh = false}) async {
    print(
        'LandingController: fetchCompanyInfo called, forceRefresh: $forceRefresh, current companyInfo: ${companyInfo.value?.companyName}');

    if (companyInfo.value == null || forceRefresh) {
      print('LandingController: Starting fetch - loading: true');
      isLoading.value = true;
      try {
        print('LandingController: Making API call to getCompanyInformation');
        final response = await pibroRepository.getCompanyInformation();
        print(
            'LandingController: API call successful, company name: ${response.companyInfo?.companyName}');
        companyInfo.value = response.companyInfo;
        isLoading.value = false;
      } catch (e) {
        print('LandingController: API call failed with error: $e');
        isLoading.value = false;
        // Silently fail - will show default text
      }
    } else {
      print(
          'LandingController: Using cached company info: ${companyInfo.value?.companyName}');
    }
  }

  String getWelcomeText() {
    if (companyInfo.value?.companyName != null &&
        companyInfo.value!.companyName!.isNotEmpty) {
      return 'WELCOME TO\n${companyInfo.value!.companyName}\nSELF SERVICE';
    }
    return 'WELCOME TO\nPOWER INSURANCE BROKERAGE FALLBACK \nSELF SERVICE';
  }
}
