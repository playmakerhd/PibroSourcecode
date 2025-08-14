import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/config/model/config_model.dart';
import 'package:pibro/utils/app_utils.dart';

class ConfigController extends GetxController {
  final GlobalKey<FormState> configFormKey = GlobalKey<FormState>();

  final TextEditingController serviceURLController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();

  void saveConfigData() {
    saveConfig(
      configFormKey,
      url: serviceURLController.text.trim(),
      token: tokenController.text.trim(),
    );
    serviceURLController.clear();
    tokenController.clear();
  }

  @override
  void onInit() {
    super.onInit();
    if (decryptData(StorageKeys.configData) != null) {
      ConfigData configData = ConfigData.fromJson(
          convertToJsonStringQuotes(StorageKeys.configData));
      serviceURLController.text = configData.url!;
      tokenController.text = configData.token!;
    }
  }

  @override
  void dispose() {
    serviceURLController.dispose();
    tokenController.dispose();
    super.dispose();
  }
}
