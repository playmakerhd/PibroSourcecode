import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/policy/controller/renew_policy_controller.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key, required this.paystackUrl});

  final String paystackUrl;

  @override
  Widget build(BuildContext context) {
    final RenewPolicyController renewPolicyController =
        Get.put(RenewPolicyController());
    return Scaffold(
      appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              renewPolicyController.paymentLoading.value = false;
              Get.back();
            },
            child: Icon(Icons.arrow_back),
          ),
          title: Text(
            'Pay with Paystack',
            style: Styles.boldTextStyle(size: 20),
          )),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(paystackUrl))),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
        ),
        onWebViewCreated: (controller) {
          renewPolicyController.webViewController = controller;
        },
        onUpdateVisitedHistory: (controller, url, androidIsReload) {
          if (url != null) {
            renewPolicyController.checkPaymentStatus(url.toString());
          }
        },
      ),
    );
  }
}
