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
                      // Search Bar and DEMO Button Row
                      Obx(() {
                        if (controller.isLoadingEnvironments.value) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  AppStrings.loadingEnvironments.tr,
                                  style: Styles.regularTextStyle(
                                    color: AppColors.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (controller.availableEnvironments.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          children: [
                            // Search bar and DEMO button
                            Row(
                              children: [
                                // Search TextField
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.greyColor,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextField(
                                      controller: controller.searchController,
                                      style: Styles.regularTextStyle(),
                                      decoration: InputDecoration(
                                        hintText:
                                            AppStrings.searchEnvironments.tr,
                                        hintStyle: Styles.regularTextStyle(
                                          color: AppColors.hintColor,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: AppColors.hintColor,
                                        ),
                                        suffixIcon: Obx(() {
                                          if (controller
                                              .searchQuery.value.isEmpty) {
                                            return const SizedBox.shrink();
                                          }
                                          return IconButton(
                                            icon: Icon(
                                              Icons.clear,
                                              color: AppColors.hintColor,
                                            ),
                                            onPressed: () {
                                              controller.searchController
                                                  .clear();
                                            },
                                          );
                                        }),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // DEMO Button
                                GestureDetector(
                                  onTap: controller.onDemoSelected,
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        AppStrings.demo.tr,
                                        style: Styles.semiBoldTextStyle(
                                          color: AppColors.white,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }),

                      // Filtered Environment List (shown only when searching)
                      Obx(() {
                        final filtered = controller.filteredEnvironments;
                        if (controller.searchQuery.value.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        if (filtered.isEmpty) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: AppColors.hintColor,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  AppStrings.noEnvironmentsFound.tr,
                                  style: Styles.regularTextStyle(
                                    color: AppColors.hintColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.greyColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: AppColors.greyColor,
                            ),
                            itemBuilder: (context, index) {
                              final env = filtered[index];
                              return ListTile(
                                onTap: () {
                                  controller.onEnvironmentSelected(env);
                                },
                                title: Text(
                                  env.name,
                                  style: Styles.semiBoldTextStyle(
                                    size: 15,
                                  ),
                                ),
                                subtitle: env.description != null
                                    ? Text(
                                        env.description!,
                                        style: Styles.regularTextStyle(
                                          size: 12,
                                          color: AppColors.hintColor,
                                        ),
                                      )
                                    : null,
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppColors.hintColor,
                                ),
                              );
                            },
                          ),
                        );
                      }),
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
                      // Manual Entry Button
                      GestureDetector(
                        onTap: () {
                          // Show manual entry dialog
                          final tempUrlController = TextEditingController();
                          final tempTokenController = TextEditingController();
                          final dialogFormKey = GlobalKey<FormState>();

                          showDialog(
                            context: context,
                            builder: (context) => _ManualEntryDialog(
                              urlController: tempUrlController,
                              tokenController: tempTokenController,
                              formKey: dialogFormKey,
                              onSave: () {
                                if (dialogFormKey.currentState!.validate()) {
                                  controller.saveManualConfig(
                                    tempUrlController.text.trim(),
                                    tempTokenController.text.trim(),
                                  );
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ).then((_) {
                            // Clean up temp controllers
                            tempUrlController.dispose();
                            tempTokenController.dispose();
                          });
                        },
                        child: ProfileButton(
                          text: AppStrings.enterManually.tr,
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
class _QRScannerBottomSheet extends StatefulWidget {
  final void Function(String) onScanned;

  const _QRScannerBottomSheet({required this.onScanned});

  @override
  State<_QRScannerBottomSheet> createState() => _QRScannerBottomSheetState();
}

class _QRScannerBottomSheetState extends State<_QRScannerBottomSheet> {
  late final MobileScannerController _controller;
  bool _scanned = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    // MobileScanner widget will automatically start the controller
    // Do not call _controller.start() manually to avoid "controllerAlreadyInitialized" error
  }

  @override
  void dispose() {
    _stopScanner();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _stopScanner() async {
    try {
      await _controller.stop();
    } catch (e) {
      // ignore stop errors but log
      // ignore: avoid_print
      print('Error stopping scanner: $e');
    }
  }

  void _handleDetected(BarcodeCapture capture) async {
    if (_scanned) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final first = barcodes.first;
    if (first.rawValue == null) return;
    _scanned = true;
    final code = first.rawValue!;
    // stop scanner immediately to prevent duplicates
    await _stopScanner();
    try {
      widget.onScanned(code);
    } catch (e) {
      // ignore callback errors but log
      // ignore: avoid_print
      print('Error in onScanned callback: $e');
    }
    if (mounted) Navigator.of(context).pop();
  }

  // Permission handling: MobileScanner version in this project
  // doesn't expose onPermissionSet / MobileScannerPermission type.
  // We attempt to start the camera and show errors via _errorMessage.

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
                    controller: _controller,
                    onDetect: _handleDetected,
                    errorBuilder: (context, error) {
                      // Display error inside scanner area
                      return Center(
                        child: Text(
                          'Scanner error: ${error.toString()}',
                          style: Styles.regularTextStyle(color: Colors.red),
                        ),
                      );
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
                  if (_errorMessage != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 120,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.red.withOpacity(0.1),
                        child: Text(
                          _errorMessage!,
                          style: Styles.regularTextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
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
            onTap: () async {
              await _stopScanner();
              if (mounted) Navigator.of(context).pop();
            },
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

/// Manual Entry Dialog Widget
class _ManualEntryDialog extends StatelessWidget {
  final TextEditingController urlController;
  final TextEditingController tokenController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;

  const _ManualEntryDialog({
    required this.urlController,
    required this.tokenController,
    required this.formKey,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.manualConfiguration.tr,
                      style: Styles.semiBoldTextStyle(
                        size: 18,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.hintColor,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Service URL Input
                CustomInput(
                  hint: AppStrings.enterServiceUrl.tr,
                  controller: urlController,
                  validator: (value) =>
                      Validators.requiredValidator(value, 'Service URL'),
                  isReducedBorderRadius: true,
                ),
                // Token Input
                CustomInput(
                  hint: AppStrings.enterToken.tr,
                  controller: tokenController,
                  validator: (value) =>
                      Validators.requiredValidator(value, 'Token'),
                  isReducedBorderRadius: true,
                ),
                const SizedBox(height: 20),
                // Save Button
                GestureDetector(
                  onTap: onSave,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        AppStrings.save.tr,
                        style: Styles.semiBoldTextStyle(
                          color: AppColors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
