import 'package:flutter/material.dart';
import 'package:pibro/core/landing/widget/about_us_details.dart';
import 'package:pibro/core/landing/widget/landing_container.dart';
import 'package:pibro/utils/view_utils.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LandingContainer(
      child: Padding(
        padding: EdgeInsets.only(bottom: queryHeight(context) * 0.05),
        child: AboutUsDetails(),
      ),
    );
  }
}
