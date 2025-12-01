import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/models/platform_user/platform_user.dart'
    hide CustomerTransaction;
import 'package:pibro/network/models/response/customer_transactions_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/utils/view_utils.dart';

class CustomerTransactionsController extends GetxController {
  final repo = PibroRepository(appApiProvider: ApiProvider());

  final RxBool loading = false.obs;
  final RxBool shareLoading = false.obs;
  final RxBool statementLoading = false.obs;
  final RxBool exportLoading = false.obs;
  final RxList<CustomerTransaction> items = <CustomerTransaction>[].obs;

  final Rxn<DateTime> from = Rxn<DateTime>();
  final Rxn<DateTime> to = Rxn<DateTime>();

  int _page = 1;
  final int _size = 20;
  bool _hasMore = true;

  String get customerID =>
      PlatformUser.fromJson(GetStorage().read(StorageKeys.profileData) ?? {})
          .customerID ??
      '';

  @override
  void onInit() {
    super.onInit();
    // default: this month
    final now = DateTime.now();
    from.value = DateTime(now.year, now.month, 1);
    to.value = now;
    refreshList();
  }

  Future<void> refreshList() async {
    _page = 1;
    _hasMore = true;
    items.clear();
    await _fetchPage();
  }

  Future<void> loadMore() async {
    if (loading.value || !_hasMore) return;
    _page += 1;
    await _fetchPage();
  }

  Future<void> _fetchPage() async {
    loading.value = true;
    try {
      final pf =
          (from.value ?? DateTime.now().subtract(const Duration(days: 30)))
              .toIso8601String();
      final pt = (to.value ?? DateTime.now()).toIso8601String();

      final res = await repo.getCustomerTransactions(
        page: _page,
        size: _size,
        periodFromIso: pf,
        periodToIso: pt,
      );

      if (res.transactions.length < _size) _hasMore = false;
      items.addAll(res.transactions);
    } catch (_) {
      // global error handler shows snackbar
      _hasMore = false;
    } finally {
      loading.value = false;
    }
  }

  /// Call this with the selected transaction's number and type.
  Future<void> shareTransactionReport({
    required String transactionNumber,
    required String reportType,
  }) async {
    if (transactionNumber.isEmpty || reportType.isEmpty) {
      showSnackbarMessage(
        message: 'Invalid transaction selection.',
        isSuccess: false,
      );
      return;
    }

    // Map transaction type to proper report type
    final mappedReportType = _mapTransactionTypeToReportType(reportType);

    print(
        '🔍 SHARE_REPORT: Original reportType: "$reportType", Mapped: "$mappedReportType"');

    shareLoading.value = true;
    try {
      final resp = await repo.viewCustomerTransactionReport(
        transactionNumber: transactionNumber,
        reportType: mappedReportType,
      );

      print(
          '🔍 SHARE_REPORT: API Response - Status: "${resp.messageResponse.status}", Message length: ${resp.messageResponse.message.length}');

      final status = resp.messageResponse.status;
      final msg = resp.messageResponse.message; // Base64 string

      if (status.toLowerCase() != 'success' || (msg).isEmpty) {
        print(
            '❌ SHARE_REPORT: API failed - Status: "$status", Message: "${msg.length > 100 ? '${msg.substring(0, 100)}...' : msg}"');
        showSnackbarMessage(
          message: AppStrings.genericErrorMessage.tr,
          isSuccess: false,
        );
        shareLoading.value = false;
        return;
      }

      // Some backends prefix Base64 with data-uri; strip if present
      final cleanedBase64 = _stripDataPrefix(msg);
      final bytes = base64Decode(cleanedBase64);

      final dir = await getTemporaryDirectory();
      // Sanitize transaction number for filename (replace invalid characters)
      final sanitizedTxnNumber =
          transactionNumber.replaceAll(RegExp(r'[/\\:*?"<>|]'), '_');
      final fileName =
          'txn_${sanitizedTxnNumber}_${mappedReportType}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$fileName');

      print('🔍 SHARE_REPORT: Creating file at: ${file.path}');

      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Transaction $transactionNumber ($reportType)',
        text: 'Please find the report attached.',
      );
    } catch (e) {
      print('❌ SHARE_REPORT: Exception: $e');
      showSnackbarMessage(
        message:
            'Unable to share transaction report: ${e.toString().contains('SocketException') ? 'Network error' : 'API error'}',
        isSuccess: false,
      );
    } finally {
      shareLoading.value = false;
    }
  }

  String _stripDataPrefix(String input) {
    // Handles cases like: data:application/pdf;base64,<base64...>
    final prefix = RegExp(r'^data:.*;base64,', caseSensitive: false);
    return input.replaceFirst(prefix, '');
  }

  /// Map transaction types from the database to proper report types expected by the API
  String _mapTransactionTypeToReportType(String transactionType) {
    final type = transactionType.toLowerCase().trim();

    // Common mappings based on typical transaction report types
    switch (type) {
      case 'receipt':
        return 'Receipt';
      case 'service online':
        return 'Debit Note'; // or could be 'Invoice' depending on your backend
      case 'debit note':
        return 'Debit Note';
      case 'invoice':
        return 'Invoice';
      case 'credit note':
        return 'Credit Note';
      default:
        // Return the original value if no mapping found
        print('⚠️ UNMAPPED_REPORT_TYPE: "$transactionType" - using as-is');
        return transactionType;
    }
  }

  /// Fetches customer statement PDF bytes for the selected date range.
  /// If no dates selected, defaults to past 6 months.
  /// Returns null on error.
  Future<Uint8List?> fetchCustomerStatementBytes() async {
    try {
      statementLoading.value = true;

      // Use selected dates or default to past 6 months
      final now = DateTime.now();
      final periodFrom = from.value ?? now.subtract(const Duration(days: 180));
      final periodTo = to.value ?? now;

      final resp = await repo.viewCustomerStatementReport(
        customerID: customerID,
        periodFrom: periodFrom.toIso8601String(),
        periodTo: periodTo.toIso8601String(),
      );

      final status = resp.messageResponse.status;
      final msg = resp.messageResponse.message; // Base64 PDF

      if (status.toLowerCase() != 'success' || msg.isEmpty) return null;

      // Decode base64 to bytes
      final cleanedBase64 = _stripDataPrefix(msg);
      final bytes = base64Decode(cleanedBase64);
      return Uint8List.fromList(bytes);
    } catch (e) {
      print('❌ CUSTOMER_STATEMENT: Error: $e');
      return null;
    } finally {
      statementLoading.value = false;
    }
  }
}
