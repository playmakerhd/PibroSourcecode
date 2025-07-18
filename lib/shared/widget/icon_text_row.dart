import 'package:flutter/material.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/utils/image_factory.dart';

class IconTextRow extends StatelessWidget {
  const IconTextRow({super.key, required this.image, required this.text});

  final String text;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          ImageFactory.getImage(
            image,
          ).render(
            width: 25,
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Text(
              text,
              style: Styles.mediumTextStyle(),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
