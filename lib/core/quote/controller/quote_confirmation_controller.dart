import 'package:get/get.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/config/model/config_model.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/utils/app_utils.dart';

class QuoteConfirmationController extends GetxController {
// ... existing code
  void onOkPressed() {
    // Check if user is logged in by looking for a token.
    // Adjust this logic if you have a different way of checking auth status.
    ConfigData configData =
        ConfigData.fromJson(convertToJsonStringQuotes(StorageKeys.configData));
    final token = configData.token;
    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(AppRoutes.quoteList);
    } else {
      Get.offAllNamed(AppRoutes.main);
    }
  }
}
