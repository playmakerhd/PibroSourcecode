import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/widget/back_arrow.dart';
import 'package:pibro/shared/widget/rotated_container.dart';
import 'package:pibro/utils/image_factory.dart';
import 'package:pibro/utils/view_utils.dart';

class QuoteScreen extends StatelessWidget {
  const QuoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: queryHeight(context),
        width: queryWidth(context),
        padding: EdgeInsetsDirectional.symmetric(
            horizontal: queryWidth(context) * 0.05),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.quoteBg),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: queryHeight(context) * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BackArrow(),
                          SizedBox(
                            height: 30,
                          ),
                          ImageFactory.getImage(AppImages.pibro)
                              .render(height: 30),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: queryHeight(context) * 0.05),
                    child: ImageFactory.getImage(AppImages.quote).render(),
                  ),
                  Text(
                    AppStrings.getQuote.tr,
                    style: Styles.boldTextStyle(size: 20),
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotatedContainer(
                        text: AppStrings.lifeInsurance.tr,
                        image: AppImages.lifeInsurance,
                        onPressed: () => Get.toNamed(AppRoutes.getQuote),
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      RotatedContainer(
                        text: AppStrings.nonLifeInsurance.tr,
                        image: AppImages.nonLifeInsurance,
                        onPressed: () => Get.toNamed(AppRoutes.getQuote),
                      ),
                    ],
                  ),
                  RotatedContainer(
                    text: AppStrings.reInsurance.tr,
                    image: AppImages.reInsurance,
                    onPressed: () => Get.toNamed(AppRoutes.getQuote),
                  ),
                  SizedBox(
                    height: queryHeight(context) * 0.08,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
