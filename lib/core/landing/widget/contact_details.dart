import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_images.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/support/controller/support_controller.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/widget/icon_text_row.dart';
import 'package:pibro/shared/widget/link_icon.dart';
import 'package:pibro/utils/app_utils.dart';

class ContactDetails extends StatelessWidget {
  const ContactDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final SupportController controller = Get.put(SupportController());
    return Obx(
      () => controller.contactUsLoading.value &&
              controller.companyInfo.value == null
          ? SizedBox()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Text(AppStrings.contactUs.tr.toUpperCase(),
                      style: Styles.boldTextStyle()),
                ),
                IconTextRow(
                  image: AppImages.location,
                  text:
                      '${controller.companyInfo.value!.companyAddress1}, ${controller.companyInfo.value!.companyAddress2}',
                ),
                GestureDetector(
                  onTap: () =>
                      launchPhone(controller.companyInfo.value!.companyPhone!),
                  child: IconTextRow(
                    image: AppImages.call,
                    text: controller.companyInfo.value!.companyPhone!,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      launchAnyUrl(controller.companyInfo.value!.companyEmail!),
                  child: IconTextRow(
                    image: AppImages.mail,
                    text: controller.companyInfo.value!.companyEmail!,
                  ),
                ),
                IconTextRow(
                  image: AppImages.website,
                  text: controller.companyInfo.value!.companyWebAddress!,
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: controller.companyInfo.value!.socialAccounts!
                      .where(
                          (item) => item.socialID!.toLowerCase() != 'whatsapp')
                      .map(
                    (account) {
                      return account.profileUrl != null
                          ? LinkIcon(
                              icon: controller.getSocialIcon(account.socialID!),
                              onTap: () => launchAnyUrl(account.profileUrl!),
                            )
                          : SizedBox();
                    },
                  ).toList(),
                ),
              ],
            ),
    );
  }
}
