import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/config/view/service_config_screen.dart';
import 'package:pibro/core/main_screen/view/main_screen.dart';
import 'package:pibro/core/splash/splash_screen.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/pibro_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  PibroLogger.init();
  await initializeDateFormatting('en_US', null);
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
      locale: AppConstants.engLocale,
      getPages: AppRoutes.routes,
      supportedLocales: const <Locale>[AppConstants.engLocale],
      fallbackLocale: AppConstants.engLocale,
      translations: AppStrings(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final scale = mediaQueryData.textScaler.clamp(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.1,
        );
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: scale,
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
              : SplashScreen(),
    );
  }
}
 