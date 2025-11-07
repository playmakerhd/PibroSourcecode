import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/support/controller/support_controller.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/widget/back_arrow.dart';
import 'package:pibro/utils/image_factory.dart';
import 'package:pibro/utils/view_utils.dart';

class LandingContainer extends StatelessWidget {
  const LandingContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final SupportController controller = Get.put(SupportController());
    return Scaffold(
      body: Container(
        height: queryHeight(context),
        width: queryWidth(context),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.contactUsBg),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: queryWidth(context) * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => controller.contactUsLoading.value &&
                          controller.companyInfo.value == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: AppColors.green,
                              size: 40,
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: queryHeight(context) * 0.02,
                                  bottom: queryHeight(context) * 0.02),
                              child: BackArrow(
                                color: AppColors.green,
                              ),
                            ),
                            controller.companyInfo.value!.companyLogoUrl !=
                                        null &&
                                    controller.companyInfo.value!
                                        .companyLogoUrl!.isNotEmpty
                                ? Image.network(
                                    controller
                                        .companyInfo.value!.companyLogoUrl!,
                                    height: 30,
                                  )
                                : ImageFactory.getImage(
                                    AppImages.fbnLogo,
                                  ).render(
                                    height: 30,
                                  ),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Column(
                                children: [
                                  Obx(
                                    () => Text(
                                      controller.companyInfo.value!.companyName!
                                          .toUpperCase(),
                                      style: Styles.mediumTextStyle(
                                        color: AppColors.green,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    AppStrings.piblSubtitle.tr,
                                    style: Styles.regularTextStyle(
                                      color: AppColors.green,
                                      size: 12,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
