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
    _startSplashTimer();
    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _startSplashTimer() {
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      _onSplashEnd();
    });
  }

  Future<void> _initializeData() async {
    // If force refresh is requested, delete existing controller to ensure fresh data
    if (widget.forceRefresh) {
      try {
        Get.delete<LandingController>(force: true);
      } catch (_) {
        // Controller might not exist, that's fine
      }
      try {
        Get.delete<PibroRepository>(force: true);
      } catch (_) {
        // Dependency might not exist, that's fine
      }
      try {
        Get.delete<ApiProvider>(force: true);
      } catch (_) {
        // Dependency might not exist, that's fine
      }
    }

    // Ensure API provider and repository are registered for DI/testability
    if (widget.forceRefresh || !Get.isRegistered<ApiProvider>()) {
      Get.put(ApiProvider());
    }
    if (widget.forceRefresh || !Get.isRegistered<PibroRepository>()) {
      Get.put(PibroRepository(appApiProvider: Get.find<ApiProvider>()));
    }

    // Initialize controller and wait for data (inject repository)
    final controller = Get.isRegistered<LandingController>()
        ? Get.find<LandingController>()
        : Get.put(
            LandingController(pibroRepository: Get.find<PibroRepository>()));

    // Force refetch if coming from configuration
    if (widget.forceRefresh) {
      controller.companyInfo.value = null; // Reset cached data
    }

    await controller.fetchCompanyInfo(forceRefresh: widget.forceRefresh);

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
      debugPrint('SplashScreen _onSplashEnd error: $e');
    }
  }

  void _navigateToLanding() {
    if (!mounted) return;

    // Add a small delay to ensure GetX bindings are fully initialized
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      try {
        Get.offNamed(AppRoutes.landing);
      } catch (e, stackTrace) {
        debugPrint('SplashScreen navigation error: $e');
        debugPrint('$stackTrace');
        // Retry navigation after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Get.offAllNamed(AppRoutes.landing);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: queryWidth(context),
        height: queryHeight(context),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.splash),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
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
      ),
    );
  }
}
