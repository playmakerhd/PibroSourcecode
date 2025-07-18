import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/support/view/tawk_screen.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/response/company_data_response.dart';
import 'package:pibro/network/models/response/company_info_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/image_factory.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SupportController extends GetxController {
  PibroRepository pibroRepository =
      PibroRepository(appApiProvider: ApiProvider());
  RxBool contactUsLoading = false.obs;
  RxBool faqLoading = false.obs;
  RxBool chatLoading = false.obs;
  Rxn<CompanyInfo> companyInfo = Rxn<CompanyInfo>();
  RxList<CompanyData> companyFAQs = RxList<CompanyData>([]);
  RxList<CompanyData> companyChat = RxList<CompanyData>([]);

  void navigateToAboutUs() {
    Get.toNamed(AppRoutes.aboutUs);
    fetchContactDetails();
  }

  void navigateToContactUs() {
    Get.toNamed(AppRoutes.contactUs);
    fetchContactDetails();
  }

  Future<void> fetchContactDetails() async {
    if (companyInfo.value == null) {
      contactUsLoading.value = true;
      try {
        final response = await pibroRepository.getCompanyInformation();
        companyInfo.value = response.companyInfo;
        contactUsLoading.value = false;
      } catch (e) {
        contactUsLoading.value = false;
        showSnackbarMessage(
            message: AppStrings.genericErrorMessage.tr, isSuccess: false);
      }
    }
  }

  Future<void> navigateToFAQ() async {
    Get.toNamed(AppRoutes.faq);
    if (companyFAQs.isEmpty) {
      faqLoading.value = true;
      try {
        final response = await pibroRepository.getCompanyFaq();
        companyFAQs.value = response.companyData;
        faqLoading.value = false;
      } catch (e) {
        faqLoading.value = false;
        showSnackbarMessage(
            message: AppStrings.genericErrorMessage.tr, isSuccess: false);
      }
    }
  }

  Future<void> navigateToChat() async {
    showChatSheet();
    if (companyChat.isEmpty) {
      chatLoading.value = true;
      try {
        final response = await pibroRepository.getCompanyChat();
        companyChat.value = response.companyData;
        chatLoading.value = false;
      } catch (e) {
        chatLoading.value = false;
        showSnackbarMessage(
            message: AppStrings.genericErrorMessage.tr, isSuccess: false);
      }
    }
  }

  IconData getSocialIcon(String socialID) {
    switch (socialID.toLowerCase()) {
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'twitter':
        return FontAwesomeIcons.twitter;
      default:
        return Icons.web;
    }
  }

  void showChatSheet() {
    showAppBottomSheet(
      height: 220,
      child: Padding(
        padding: EdgeInsets.only(top: 40),
        child: Obx(
          () => chatLoading.value && companyChat.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: AppColors.tileColor,
                      size: 40,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: companyChat.indexed.map(((int, CompanyData) chat) {
                    final (index, item) = chat;
                    return ChatWidget(
                      title: item.systemMessage!,
                      image: index == 0
                          ? AppImages.liveChat
                          : AppImages.whatsappChat,
                      onTap: () {
                        // Get.back();
                        if (index == 0) {
                          Get.to(() => TawkScreen(
                                tawkUrl: item.description!,
                              ));
                        } else {
                          launchAnyUrl(item.description!);
                        }
                      },
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }
}

class ChatWidget extends StatelessWidget {
  const ChatWidget({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
  });

  final String title;
  final String image;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ImageFactory.getImage(image).render(
            height: 70,
            width: 70,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            title,
            style: Styles.boldTextStyle(size: 14),
          )
        ],
      ),
    );
  }
}
