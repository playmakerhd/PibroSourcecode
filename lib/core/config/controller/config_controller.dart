import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/config/model/config_model.dart';
import 'package:pibro/core/config/model/config_environment.dart';
import 'package:pibro/utils/app_utils.dart';

class ConfigController extends GetxController {
  final GlobalKey<FormState> configFormKey = GlobalKey<FormState>();

  final TextEditingController serviceURLController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();

  // Dropdown properties
  var availableEnvironments = <ConfigEnvironment>[].obs;
  var selectedEnvironment = Rxn<ConfigEnvironment>();
  var isLoadingEnvironments = false.obs;

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
    loadExistingConfig();
    fetchEnvironments();
  }

  void loadExistingConfig() {
    if (decryptData(StorageKeys.configData) != null) {
      ConfigData configData = ConfigData.fromJson(
          convertToJsonStringQuotes(StorageKeys.configData));
      serviceURLController.text = configData.url!;
      tokenController.text = configData.token!;
    }
  }

  Future<void> fetchEnvironments() async {
    isLoadingEnvironments.value = true;
    try {
      final jsonString =
          await rootBundle.loadString('assets/config/environments.json');
      final List<dynamic> data = jsonDecode(jsonString);
      availableEnvironments.value =
          data.map((e) => ConfigEnvironment.fromJson(e)).toList();
    } catch (e) {
      print('Error loading environments: $e');
      // Don't show error message, just allow manual entry
      availableEnvironments.value = [];
    } finally {
      isLoadingEnvironments.value = false;
    }
  }

  void onEnvironmentSelected(ConfigEnvironment? environment,
      {bool autoSave = true}) {
    if (environment != null) {
      selectedEnvironment.value = environment;
      serviceURLController.text = environment.url;
      tokenController.text = environment.token;
      if (autoSave) {
        saveConfigData();
      }
    }
  }

  void clearSelection() {
    selectedEnvironment.value = null;
    serviceURLController.clear();
    tokenController.clear();
  }

  @override
  void dispose() {
    serviceURLController.dispose();
    tokenController.dispose();
    super.dispose();
  }
}
