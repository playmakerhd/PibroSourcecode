import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/landing/controller/landing_controller.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/utils/view_utils.dart';

class SplashScreen extends StatefulWidget {
  final bool forceRefresh;

  const SplashScreen({super.key, this.forceRefresh = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isDataLoaded = false;
  bool _canNavigate = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    // Clean up any pending operations
    super.dispose();
  }

  Future<void> _initializeData() async {
    print(
        'SplashScreen: _initializeData called, forceRefresh: ${widget.forceRefresh}');

    // If force refresh is requested, delete existing controller to ensure fresh data
    if (widget.forceRefresh) {
      print(
          'SplashScreen: Force refresh requested, deleting existing controller');
      try {
        Get.delete<LandingController>(force: true);
      } catch (_) {
        // Controller might not exist, that's fine
      }
    }

    // Ensure API provider and repository are registered for DI/testability
    if (!Get.isRegistered<ApiProvider>()) {
      Get.put(ApiProvider());
    }
    if (!Get.isRegistered<PibroRepository>()) {
      Get.put(PibroRepository(appApiProvider: Get.find<ApiProvider>()));
    }

    // Initialize controller and wait for data (inject repository)
    print('SplashScreen: Creating/getting LandingController via DI');
    final controller = Get.isRegistered<LandingController>()
        ? Get.find<LandingController>()
        : Get.put(
            LandingController(pibroRepository: Get.find<PibroRepository>()));

    // Force refetch if coming from configuration
    if (widget.forceRefresh) {
      print('SplashScreen: Resetting cached company info');
      controller.companyInfo.value = null; // Reset cached data
    }

    print(
        'SplashScreen: Calling fetchCompanyInfo with forceRefresh: ${widget.forceRefresh}');
    await controller.fetchCompanyInfo(forceRefresh: widget.forceRefresh);
    print('SplashScreen: fetchCompanyInfo completed');

    if (!mounted) return;

    setState(() {
      _isDataLoaded = true;
    });

    // If splash animation already finished, navigate now
    if (_canNavigate) {
      _navigateToLanding();
    }
  }

  void _onSplashEnd() {
    if (!mounted) return;

    try {
      setState(() {
        _canNavigate = true;
      });

      // If data already loaded, navigate now
      if (_isDataLoaded) {
        _navigateToLanding();
      }
    } catch (e) {
      // Ignore errors if widget is being disposed
      print('Error in _onSplashEnd: $e');
    }
  }

  void _navigateToLanding() {
    Get.offNamed(AppRoutes.landing);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.scale(
      backgroundImage: Image.asset(
        AppImages.splash,
        fit: BoxFit.cover,
      ),
      backgroundColor: Colors.white,
      childWidget: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: 25,
          width: queryWidth(context),
          child: Center(
            child: Text(
              'powered by @ Powersoft Integrated Solutions Ltd',
              style: Styles.boldTextStyle(size: 11, color: AppColors.white),
            ),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 3000),
      animationDuration: const Duration(milliseconds: 1000),
      onAnimationEnd: _onSplashEnd,
      nextScreen: const SizedBox.shrink(),
    );
  }
}
