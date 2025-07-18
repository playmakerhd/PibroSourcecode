import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/landing/views/landing_screen.dart';
import 'package:pibro/utils/view_utils.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
      onAnimationEnd: () => debugPrint("On Scale End"),
      nextScreen: LandingScreen(),
    );
  }
}
