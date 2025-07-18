import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/shared/widget/rotated_container.dart';

class ContainerWithCount extends StatelessWidget {
  const ContainerWithCount({
    super.key,
    required this.text,
    required this.image,
    required this.count,
    this.onTap,
    this.loading = false,
  });

  final String text;
  final String image;
  final String count;
  final Function()? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      width: 130,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            child: GestureDetector(
              onTap: onTap,
              child: RotatedContainer(
                text: text,
                image: image,
                isRotated: false,
                borderColor: AppColors.white,
                backgroundColor: AppColors.tileColor,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: loading
                    ? Transform.scale(
                        scale: 0.3,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                          strokeWidth: 4,
                        ),
                      )
                    : Text(
                        count,
                        style: Styles.boldTextStyle(size: 14),
                      ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
          )
        ],
      ),
    );
  }
}
