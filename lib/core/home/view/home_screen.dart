import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/home/controller/home_controller.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/shared/widget/container_with_count.dart';
import 'package:pibro/shared/widget/rotated_container.dart';
import 'package:pibro/utils/image_factory.dart';
import 'package:pibro/utils/view_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
@override
Widget build(BuildContext context) {
  final headerHeight = MediaQuery.of(context).padding.top + 240;
  final HomeController controller = Get.put(HomeController());
  return Scaffold(
    backgroundColor: AppColors.tileColor,
    body: SafeArea(
      bottom: false,
      child: Container(
        height: queryHeight(context),
        width: queryWidth(context),
        color: AppColors.white,
        child: ListView(
          children: [
            SizedBox(
              height: headerHeight + 60,
              child: Stack(
                children: [
                  Container(
                    height: headerHeight,
                    width: queryWidth(context),
                    padding: EdgeInsets.only(
                        top: 5, left: queryWidth(context) * 0.05),
                    decoration: BoxDecoration(
                      color: AppColors.tileColor,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.primaryColor,
                          width: 15,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => controller.profileLoading.value
                              ? LoadingAnimationWidget.waveDots(
                                  color: Colors.white,
                                  size: 50,
                                )
                              : Padding(
                                padding: EdgeInsets.symmetric(horizontal: queryWidth(context) * 0.05),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                          AppStrings.welcomeUser.trParams({
                                            'user': controller.user.value != null
                                                ? controller.user.value!.customerName!
                                                    .capitalize!
                                                : 'Bayo Atekoja'
                                          }),
                                          style: Styles.boldTextStyle(
                                            size: 18,
                                            color: AppColors.white,
                                          ),
                                        ),
                                    ),
                                    GestureDetector(
                                        onTap: () => Get.toNamed(
                                            AppRoutes.transactionsHub),
                                        child: Icon(Icons.receipt_long,
                                            color: AppColors.white, size: 30),
                                      ),
                                  ],
                                ),
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: ImageFactory.getImage(AppImages.dashboard)
                                .render(height: 110),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: SizedBox(
                      width: queryWidth(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(
                            () => ContainerWithCount(
                              onTap: () => controller.navigateToPolicyScreens(
                                  status: AppStrings.active.tr),
                              text: AppStrings.activePolicies
                                  .trParams({'break': '\n'}),
                              image: AppImages.activePolicy,
                              count: controller
                                  .getPolicyListCount(AppStrings.active.tr)
                                  .value,
                              loading: controller.loading.value,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Obx(
                            () => ContainerWithCount(
                              onTap: () => controller.navigateToPolicyScreens(
                                  status: AppStrings.expired.tr),
                              text: AppStrings.expiredPolicies
                                  .trParams({'break': '\n'}),
                              image: AppImages.expiredPolicy,
                              count: controller
                                  .getPolicyListCount(AppStrings.expired.tr)
                                  .value,
                              loading: controller.loading.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RotatedContainer(
                      text: AppStrings.quote.tr,
                      image: AppImages.getQuote,
                      borderColor: AppColors.tileColor,
                      onPressed: controller.navigateToQuoteScreen,
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    RotatedContainer(
                      text: AppStrings.renewPolicy.tr,
                      image: AppImages.renewPolicy,
                      borderColor: AppColors.tileColor,
                      onPressed: controller.clickRenewPolicyInHomeScreen,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 60, bottom: 60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotatedContainer(
                        text: AppStrings.claims.tr,
                        image: AppImages.claim,
                        borderColor: AppColors.tileColor,
                        onPressed: controller.navigateToClaimScreen,
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      RotatedContainer(
                        text: AppStrings.policies.tr,
                        image: AppImages.policy,
                        borderColor: AppColors.tileColor,
                        onPressed: controller.navigateToPolicyScreens,
                      ),
                    ],
                  ),
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