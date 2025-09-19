import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/policy/controller/renew_policy_controller.dart';
import 'package:pibro/core/policy/controller/endorsement_controller.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key, required this.paystackUrl});

  final String paystackUrl;

  @override
  Widget build(BuildContext context) {
    // Use whichever flow is active. Do NOT create new controllers here.
    final EndorsementController? endorseCtrl =
        Get.isRegistered<EndorsementController>()
            ? Get.find<EndorsementController>()
            : null;
    final RenewPolicyController? renewCtrl =
        Get.isRegistered<RenewPolicyController>()
            ? Get.find<RenewPolicyController>()
            : null;
    return Scaffold(
      appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              // Set payment loading to false for whichever controller is active
              if (endorseCtrl != null) {
                endorseCtrl.paymentLoading.value = false;
              } else if (renewCtrl != null) {
                renewCtrl.paymentLoading.value = false;
              }
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
          if (endorseCtrl != null) {
            endorseCtrl.webViewController = controller;
          } else if (renewCtrl != null) {
            renewCtrl.webViewController = controller;
          }
        },
        onUpdateVisitedHistory: (controller, url, androidIsReload) {
          if (url != null) {
            // Delegate to the active flow's handler
            if (endorseCtrl != null) {
              endorseCtrl.checkPaymentStatus(url.toString());
            } else if (renewCtrl != null) {
              renewCtrl.checkPaymentStatus(url.toString());
            }
          }
        },
      ),
    );
  }
}
