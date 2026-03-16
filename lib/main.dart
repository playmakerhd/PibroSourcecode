import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/config/view/service_config_screen.dart';
import 'package:pibro/core/landing/controller/landing_controller.dart';
import 'package:pibro/core/main_screen/view/main_screen.dart';
import 'package:pibro/core/services/firebase_messaging_service.dart';
import 'package:pibro/core/splash/splash_screen.dart';
import 'package:pibro/firebase_options.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/pibro_logger.dart';

class AppBinding extends Bindings {
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

    if (!Get.isRegistered<LandingController>()) {
      Get.lazyPut<LandingController>(
        () => LandingController(pibroRepository: Get.find<PibroRepository>()),
        fenix: true,
      );
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize other services first
  await GetStorage.init();
  PibroLogger.init();
  await initializeDateFormatting('en_US', null);

  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.runtimeType.toString() == 'LateInitializationError' &&
        details.exception.toString().contains('_controller@')) {
      PibroLogger.logger.w(
        'Suppressed GetX snackbar controller error: ${details.exception}',
      );
      return;
    }
    FlutterError.presentError(details);
  };

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initialize Firebase Cloud Messaging
    await FirebaseMessagingService().initialize();

    PibroLogger.logger.i('Firebase initialized successfully');
  } catch (e) {
    PibroLogger.logger.e('Failed to initialize Firebase: $e');
    // Continue app execution even if Firebase fails
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final orientations = <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ];
    SystemChrome.setPreferredOrientations(orientations);
    return GetMaterialApp(
      title: AppConstants.appName,
      initialBinding: AppBinding(),
      locale: AppConstants.engLocale,
      getPages: AppRoutes.routes,
      supportedLocales: const <Locale>[AppConstants.engLocale],
      fallbackLocale: AppConstants.engLocale,
      translations: AppStrings(),
      debugShowCheckedModeBanner: false,
      // Disable automatic snackbar closing on navigation to prevent LateInitializationError
      popGesture: true,
      defaultTransition: Transition.cupertino,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        useMaterial3: true,
        fontFamily: AppConstants.fontFamily,
      ),
      home: decryptData(StorageKeys.configData) == null
          ? ServiceConfigScreen()
          : GetStorage().read(StorageKeys.profileData) != null
              // : decryptData(StorageKeys.profileData) != null
              ? MainScreen()
              : const SplashScreen(),
    );
  }
}
