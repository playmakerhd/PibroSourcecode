import 'package:flutter/material.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/shared/widget/title_text_column.dart';

class AboutUsDetails extends StatelessWidget {
  const AboutUsDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Text('ABOUT US', style: Styles.boldTextStyle()),
        ),
        TitleTextColumn(
          text:
              'To be a premier provider of business solutions in the world with customer satisfaction and prompt deliveries.',
          title: 'Mission',
        ),
        TitleTextColumn(
          title: 'Vision',
          text:
              'To be a leading figure in our chosen fields delivering innovative and time  driven software  solutions.',
        ),
        TitleTextColumn(
          title: 'Values',
          text: 'Act like an owner, be a great team, erve family farmers.',
        ),
      ],
    );
  }
}
