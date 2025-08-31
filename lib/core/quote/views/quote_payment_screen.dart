import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/quote/controller/quote_payment_controller.dart';

class QuotePaymentScreen extends StatelessWidget {
  const QuotePaymentScreen({super.key, required this.paystackUrl});

  final String paystackUrl;

  QuotePaymentController? get _qc => Get.isRegistered<QuotePaymentController>()
      ? Get.find<QuotePaymentController>()
      : null;

  void _stopLoadingAndPop() {
    final qc = _qc;
    if (qc != null) qc.paymentLoading.value = false;
    Get.back();
  }

  void _notifyPaymentStatus(String url) {
    final qc = _qc;
    if (qc != null) {
      qc.checkPaymentStatus(url);
    } else {
      // No controller registered: close and surface error
      Get.back();
      Get.showSnackbar(GetSnackBar(
        message: 'Payment session not available. Please try again.',
        duration: const Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: _stopLoadingAndPop,
          child: const Icon(Icons.arrow_back),
        ),
        title: Text('Pay with Paystack', style: Styles.boldTextStyle(size: 20), textAlign: TextAlign.center,)
      ,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(paystackUrl))),
        initialSettings:  InAppWebViewSettings(javaScriptEnabled: true),
        onUpdateVisitedHistory: (controller, url, androidIsReload) {
          if (url != null) _notifyPaymentStatus(url.toString());
        },
      ),
    );
  }
}
