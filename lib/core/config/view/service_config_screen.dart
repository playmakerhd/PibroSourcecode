import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart'; // For Styles.semiBoldTextStyle, etc.
import 'package:pibro/core/config/controller/config_controller.dart';
import 'package:pibro/core/profile/widget/profile_button.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/custom_input/custom_input.dart';
import 'package:pibro/utils/validators.dart';
import 'package:pibro/utils/view_utils.dart';

class ServiceConfigScreen extends StatelessWidget {
  const ServiceConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ConfigController controller = Get.put(ConfigController());
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SizedBox(
        height: queryHeight(context),
        width: queryWidth(context),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CommonHeader(
                title: AppStrings.configuration.tr,
                hasBackIcon: false,
              ),
              SizedBox(
                height: queryHeight(context) * 0.17,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: queryWidth(context) * 0.05),
                child: Form(
                  key: controller.configFormKey,
                  // autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      CustomInput(
                        hint: AppStrings.enterServiceUrl.tr,
                        controller: controller.serviceURLController,
                        validator: (value) =>
                            Validators.requiredValidator(value, 'Service URL'),
                        isReducedBorderRadius: true,
                      ),
                      CustomInput(
                        hint: AppStrings.enterToken.tr,
                        controller: controller.tokenController,
                        validator: (value) =>
                            Validators.requiredValidator(value, 'Token'),
                        isReducedBorderRadius: true,
                      ),
                      SizedBox(
                        height: queryHeight(context) * 0.05,
                      ),
                      // QR Scanner Button
                      GestureDetector(
                        onTap: () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => _QRScannerBottomSheet(
                              onScanned: (code) async {
                                // Expected format: "url|token"
                                final parts = code.split('|');
                                if (parts.length == 2) {
                                  controller.serviceURLController.text =
                                      parts[0];
                                  controller.tokenController.text = parts[1];
                                  showSnackbarMessage(
                                    message: 'QR code scanned successfully!',
                                    isSuccess: true,
                                  );
                                  // Automatically save after scanning
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));
                                  controller.saveConfigData();
                                } else {
                                  showSnackbarMessage(
                                    message:
                                        'Invalid QR code format. Expected: URL|Token',
                                    isSuccess: false,
                                  );
                                }
                              },
                            ),
                          );
                        },
                        child: Container(
                          height: 50,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.qr_code_scanner,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                AppStrings.scanQR.tr,
                                style: Styles.semiBoldTextStyle(
                                  color: AppColors.white,
                                  size: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.saveConfigData,
                        child: ProfileButton(
                          text: AppStrings.save.tr,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// QR Scanner Bottom Sheet Widget
class _QRScannerBottomSheet extends StatelessWidget {
  final void Function(String) onScanned;

  const _QRScannerBottomSheet({required this.onScanned});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: queryHeight(context) * 0.7,
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            "Scan QR Code",
            style: Styles.semiBoldTextStyle(
              size: 18,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Position the QR code within the frame",
            style: Styles.regularTextStyle(
              size: 13,
              color: AppColors.hintColor,
            ),
          ),
          const SizedBox(height: 20),
          // Scanner area
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  MobileScanner(
                    onDetect: (BarcodeCapture capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty &&
                          barcodes.first.rawValue != null) {
                        final code = barcodes.first.rawValue!;
                        print("Scanned value: $code");
                        onScanned(code);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  // Scanning frame overlay
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primaryColor,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          // Corner decorations
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.green,
                                    width: 4,
                                  ),
                                  left: BorderSide(
                                    color: AppColors.green,
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.green,
                                    width: 4,
                                  ),
                                  right: BorderSide(
                                    color: AppColors.green,
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.green,
                                    width: 4,
                                  ),
                                  left: BorderSide(
                                    color: AppColors.green,
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.green,
                                    width: 4,
                                  ),
                                  right: BorderSide(
                                    color: AppColors.green,
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Cancel button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "Cancel",
                  style: Styles.semiBoldTextStyle(
                    size: 15,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
