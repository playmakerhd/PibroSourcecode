import 'package:flutter/material.dart';
import 'package:pibro/core/landing/widget/contact_details.dart';
import 'package:pibro/core/landing/widget/landing_container.dart';
import 'package:pibro/utils/view_utils.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LandingContainer(
      child: Padding(
        padding: EdgeInsets.only(bottom: queryHeight(context) * 0.25),
        child: ContactDetails(),
      ),
    );
  }
}
