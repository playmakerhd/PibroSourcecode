import 'package:flutter/material.dart';
import 'package:flutter_tawkto/flutter_tawk.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/home/controller/home_controller.dart';
import 'package:pibro/internalization/app_strings.dart';

class TawkScreen extends StatelessWidget {
  const TawkScreen({super.key, required this.tawkUrl});

  final String tawkUrl;

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.chat.tr,
          style: Styles.semiBoldTextStyle(size: 18),
        ),
        centerTitle: true,
      ),
      body: Tawk(
        directChatLink: tawkUrl,
        visitor: TawkVisitor(
          name: controller.user.value!.customerName!,
          email: controller.user.value!.customerEmail!,
        ),
      ),
    );
  }
}
