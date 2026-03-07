import 'package:get/get.dart';
import 'package:pibro/core/landing/controller/landing_controller.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/repository/pibro_repository.dart';

class LandingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiProvider>()) {
      Get.lazyPut<ApiProvider>(() => ApiProvider(), fenix: true);
    }

    if (!Get.isRegistered<PibroRepository>()) {
      Get.lazyPut<PibroRepository>(
        () => PibroRepository(appApiProvider: Get.find<ApiProvider>()),
        fenix: true,
      );
    }

    Get.lazyPut<LandingController>(
      () => LandingController(pibroRepository: Get.find<PibroRepository>()),
      fenix: true,
    );
  }
}
