import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/utils/view_utils.dart';

class PolicyCertificateController extends GetxController {
  final PibroRepository _repo = PibroRepository(appApiProvider: ApiProvider());

  final RxBool certificateLoading = false.obs;

  /// Downloads insurance certificate PDF from backend and saves to
  /// application documents folder. Shows a snackbar with saved path.
  Future<void> downloadInsuranceCertificate({
    String? policyBrokerID,
    String? customerID,
  }) async {
    // Delegate to fetch + save flow
    certificateLoading.value = true;
    try {
      final bytes = await fetchInsuranceCertificateBytes(
        policyBrokerID: policyBrokerID,
        customerID: customerID,
      );

      if (bytes == null || bytes.isEmpty) {
        showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr,
          isSuccess: false,
        );
        return;
      }

      var policyBrokerID0 =
          (policyBrokerID ?? _safeString(_tryGetField('policyBrokerID')))
              .trim();

      // Sanitize the policyBrokerID to avoid accidental path separators
      policyBrokerID0 = policyBrokerID0.replaceAll(RegExp(r'[\/]+'), '_');

      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'insurance_certificate_${policyBrokerID0}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$fileName');

      // Ensure the parent directory exists before writing
      try {
        await file.parent.create(recursive: true);
      } catch (_) {
        // ignore errors creating directories - write will fail later if not possible
      }

      await file.writeAsBytes(bytes);

      showSnackbarMessage(
        message: '${AppStrings.insuranceCertificateSaved.tr}\n${file.path}',
        isSuccess: true,
      );
    } catch (e, st) {
      print('Error downloading insurance certificate: $e\n$st');
      showSnackbarMessage(
        message: AppStrings.genericErrorMessage.tr,
        isSuccess: false,
      );
    } finally {
      certificateLoading.value = false;
    }
  }

  /// Fetches the certificate bytes (does not save). Returns null on error.
  Future<Uint8List?> fetchInsuranceCertificateBytes({
    String? policyBrokerID,
    String? customerID,
  }) async {
    try {
      certificateLoading.value = true;

      final policyBrokerID0 =
          (policyBrokerID ?? _safeString(_tryGetField('policyBrokerID')))
              .trim();
      final customerID0 =
          (customerID ?? _safeString(_tryGetField('customerID'))).trim();

      if (policyBrokerID0.isEmpty || customerID0.isEmpty) {
        return null;
      }

      final resp = await _repo.viewInsuranceCertificate(
        policyBrokerID: policyBrokerID0,
        customerID: customerID0,
      );

      final status = resp.messageResponse.status;
      final msg = resp.messageResponse.message;

      if (status.toLowerCase() != 'success' || msg.isEmpty) return null;

      final cleanedBase64 = _stripDataPrefix(msg);
      final bytes = base64Decode(cleanedBase64);
      return Uint8List.fromList(bytes);
    } catch (e, st) {
      print('Error fetching insurance certificate bytes: $e\n$st');
      return null;
    } finally {
      certificateLoading.value = false;
    }
  }

  dynamic _tryGetField(String key) {
    try {
      return '';
    } catch (_) {
      return '';
    }
  }

  String _safeString(dynamic v) => v == null ? '' : '$v';

  String _stripDataPrefix(String input) {
    final prefix = RegExp(r'^data:.*;base64,', caseSensitive: false);
    return input.replaceFirst(prefix, '');
  }
}
