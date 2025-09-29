import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/core/quote/controller/get_quote_controller.dart';
import 'package:pibro/core/quote/views/quote_payment_screen.dart';
import 'package:pibro/navigation/routes.dart';
import 'package:pibro/network/api/api_provider.dart';
import 'package:pibro/network/models/platform_user/platform_user.dart';
import 'package:pibro/network/models/request/client_note_request.dart';
import 'package:pibro/network/models/request/create_poilcy_request.dart';
import 'package:pibro/network/models/request/create_receipt_request.dart';
import 'package:pibro/network/models/request/renew_policy_requesst.dart';
import 'package:pibro/network/models/request/update_enquiry_status_request.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:pibro/utils/qlog.dart';
import 'package:intl/intl.dart';

class QuotePaymentController extends GetxController {
  // Flexible date parser for ISO and pretty formats
  DateTime _parseDateFlex(dynamic v, {DateTime? fallback}) {
    if (v is DateTime) return v;
    final s = (v ?? '').toString().trim();
    if (s.isEmpty) return fallback ?? DateTime.now();
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    try {
      return DateFormat('MMM d, y').parse(s);
    } catch (_) {}
    try {
      return DateFormat('MM-dd-yyyy').parse(s);
    } catch (_) {}
    return fallback ?? DateTime.now();
  }

  final PibroRepository repo = PibroRepository(appApiProvider: ApiProvider());
  final RxBool paymentLoading = false.obs;

  // Correlation id across the whole payment run
  final String sessionId = 'QP-${DateTime.now().millisecondsSinceEpoch}';

  // Paystack/session
  String _accessToken = '';
  String? lastPaymentReference;
  String? lastPaymentDate;
  int? lastPaymentAmount;

  // Quote context
  late final Map<String, dynamic> ctx;
  late final double premium;
  late final double sumInsured;
  late final String businessClassID;
  late final String riskTypeID;
  late final String businessClassName;
  late final String riskName;
  late final DateTime startDate;
  late final DateTime endDate;
  late final DateTime renewalDate;
  late final Map<String, dynamic> preferredInsurer; // {vendorID, vendorName}
  late final List<Map<String, dynamic>> items;

  // Working models
  final CreateReceiptRequest receiptReq = CreateReceiptRequest();
  final ClientNoteRequest clientNoteReq = ClientNoteRequest();

  @override
  void onInit() {
    super.onInit();
    _hydrateContext();
  }

  // ----------------- Public API -----------------

  Future<void> beginPayment() async {
    QLog.d('BEGIN', 'Start beginPayment', {
      'sessionId': sessionId,
      'premium': premium,
      'sumInsured': sumInsured,
      'businessClassID': businessClassID,
      'riskTypeID': riskTypeID,
      'itemsCount': items.length,
    });

    if (premium <= 0) {
      showSnackbarMessage(
          message: 'No premium due for this quote.', isSuccess: false);
      QLog.d('BEGIN', 'Aborted: premium <= 0');
      return;
    }
    await _getPaymentToken();
  }

  void checkPaymentStatus(String url) {
    // Called by QuotePaymentScreen on navigation events
    QLog.d('WEBVIEW', 'Visited URL', {'sessionId': sessionId, 'url': url});
    if (url.contains("powersoftrd.com/EnterpriseDemo")) {
      Get.back(); // close webview
      final ref = url.substring(url.length - 10);
      QLog.d('WEBVIEW', 'Trigger verifyPayment with reference',
          {'reference': ref});
      verifyPayment(ref);
    }
  }

  // ----------------- Flow steps -----------------

  Future<void> _getPaymentToken() async {
    paymentLoading.value = true;
    QLog.d('TOKEN', 'Fetching payment token', {'sessionId': sessionId});
    try {
      final response = await repo.getPaymentToken();
      QLog.d('TOKEN', 'Token response', {
        'status': response.messageResponse.status,
        'message': response.messageResponse.message,
      });

      if (response.messageResponse.status != AppConstants.responseSuccess) {
        paymentLoading.value = false;
        showSnackbarMessage(
            message: response.messageResponse.message, isSuccess: false);
        return;
      }
      _accessToken = response.messageResponse.message;

      QLog.d('INIT', 'Initializing payment', {
        'sessionId': sessionId,
        'amount': premium,
        'charge': _getChargeAmount(premium.toString()),
      });

      final init = await repo.initializePayment(
          _accessToken, _getChargeAmount(premium.toString()));
      QLog.d('INIT', 'Init response', {
        'status': init.initData.status,
        'message': init.initData.message,
        'authUrl': init.initData.data?.authorizationUrl,
        'reference': init.initData.data?.reference,
      });

      if (!init.initData.status) {
        paymentLoading.value = false;
        showSnackbarMessage(
            message: init.initData.message ?? 'Unable to initialize payment.',
            isSuccess: false);
        return;
      }

      final authUrl = init.initData.data?.authorizationUrl;
      final reference = init.initData.data?.reference;
      if (authUrl == null ||
          authUrl.isEmpty ||
          reference == null ||
          reference.isEmpty) {
        paymentLoading.value = false;
        QLog.d('INIT', 'Missing authUrl/reference from init', {
          'authUrl': authUrl,
          'reference': reference,
        });
        showSnackbarMessage(
            message: 'Unable to start payment session. Please try again.',
            isSuccess: false);
        return;
      }

      receiptReq.checkNumber = reference;
      QLog.d('INIT', 'Launching webview', {'url': authUrl});
      Get.to(() => QuotePaymentScreen(paystackUrl: authUrl));
    } catch (e, st) {
      paymentLoading.value = false;
      QLog.e('TOKEN_INIT', e, st);
      showSnackbarMessage(message: _extractServerMessage(e), isSuccess: false);
    }
  }

  Future<void> verifyPayment(String reference) async {
    paymentLoading.value = true;
    QLog.d('VERIFY', 'Verifying payment',
        {'sessionId': sessionId, 'reference': reference});
    try {
      final r = await repo.verifyPayment(_accessToken, reference);
      final data = r.verificationData.data;
      final status = data?.status?.toLowerCase();

      QLog.d('VERIFY', 'Verification response', {
        'status': status,
        'message': r.verificationData.message,
        'paidAt': data?.paidAt,
        'amount': data?.amount,
      });

      lastPaymentReference = data?.reference;
      lastPaymentDate = data?.paidAt ?? DateTime.now().toIso8601String();
      lastPaymentAmount = (data?.amount ?? 0) ~/ 100;

      if (status != 'success') {
        paymentLoading.value = false;
        showSnackbarMessage(
          message: r.verificationData.message ?? 'Payment not successful.',
          isSuccess: false,
        );
        return;
      }

      receiptReq.transactionDate = lastPaymentDate;
      receiptReq.amount = lastPaymentAmount;
      receiptReq.systemDate = DateTime.now().toIso8601String();

      await _createReceiptAndContinue();
    } catch (e, st) {
      paymentLoading.value = false;
      QLog.e('VERIFY', e, st);
      showSnackbarMessage(message: _extractServerMessage(e), isSuccess: false);
    }
  }

  Future<void> _createReceiptAndContinue() async {
    print('🧾 RECEIPT: Starting receipt creation process');
    print('   SessionID: $sessionId');
    print('   Check Number: ${receiptReq.checkNumber}');
    print('   Transaction Date: ${receiptReq.transactionDate}');
    print('   Amount: ${receiptReq.amount}');
    print('   System Date: ${receiptReq.systemDate}');
    print(
        '   Current Receipt ID: ${receiptReq.receiptID ?? "EMPTY (will be generated)"}');

    // Validate and populate missing receipt request fields
    if (receiptReq.checkNumber == null || receiptReq.checkNumber!.isEmpty) {
      print('❌ RECEIPT: Check number is missing');
      paymentLoading.value = false;
      showSnackbarMessage(
          message: 'Payment reference is missing', isSuccess: false);
      return;
    }

    if (receiptReq.amount == null || receiptReq.amount! <= 0) {
      print('❌ RECEIPT: Amount is missing or zero');
      paymentLoading.value = false;
      showSnackbarMessage(
          message: 'Payment amount is invalid', isSuccess: false);
      return;
    }

    if (receiptReq.transactionDate == null ||
        receiptReq.transactionDate!.isEmpty) {
      print('❌ RECEIPT: Transaction date is missing');
      paymentLoading.value = false;
      showSnackbarMessage(
          message: 'Transaction date is missing', isSuccess: false);
      return;
    }

    // Populate missing fields
    if (receiptReq.systemDate == null || receiptReq.systemDate!.isEmpty) {
      receiptReq.systemDate = DateTime.now().toIso8601String();
      print('📅 RECEIPT: System date set to: ${receiptReq.systemDate}');
    }

    if (receiptReq.documentNumber == null ||
        receiptReq.documentNumber!.isEmpty) {
      receiptReq.documentNumber =
          receiptReq.checkNumber; // Use payment reference as document number
      print('📄 RECEIPT: Document number set to: ${receiptReq.documentNumber}');
    }

    if (receiptReq.documentDate == null || receiptReq.documentDate!.isEmpty) {
      receiptReq.documentDate =
          receiptReq.transactionDate; // Use transaction date as document date
      print('📅 RECEIPT: Document date set to: ${receiptReq.documentDate}');
    }

    if (receiptReq.channel == null || receiptReq.channel!.isEmpty) {
      receiptReq.channel = 'online';
      print('🌐 RECEIPT: Channel set to: ${receiptReq.channel}');
    }

    // IMPORTANT: receiptID should be null/empty for CREATE call
    receiptReq.receiptID = null;
    print('🆔 RECEIPT: Receipt ID cleared for CREATE call');

    print('✅ RECEIPT: All required fields populated for CREATE');
    print('   Check Number: ${receiptReq.checkNumber}');
    print('   Amount: ${receiptReq.amount}');
    print('   Transaction Date: ${receiptReq.transactionDate}');
    print('   System Date: ${receiptReq.systemDate}');
    print('   Document Number: ${receiptReq.documentNumber}');
    print('   Document Date: ${receiptReq.documentDate}');
    print('   Channel: ${receiptReq.channel}');
    print('   Receipt ID (for CREATE): ${receiptReq.receiptID}');
    QLog.d('RECEIPT', 'Creating receipt', {
      'sessionId': sessionId,
      'checkNumber': receiptReq.checkNumber,
      'transactionDate': receiptReq.transactionDate,
      'amount': receiptReq.amount,
    });
    try {
      final created = await repo.createReceipt(receiptReq);
      QLog.d('RECEIPT', 'Create response', {
        'status': created.messageResponse.status,
        'message': created.messageResponse.message,
      });
      if (created.messageResponse.status != AppConstants.responseSuccess) {
        paymentLoading.value = false;
        showSnackbarMessage(
            message: created.messageResponse.message, isSuccess: false);
        return;
      }
      receiptReq.receiptID = created.messageResponse.message;

      QLog.d('RECEIPT', 'Posting receipt', {'receiptID': receiptReq.receiptID});
      final posted = await repo.postReceipt(receiptReq);
      QLog.d('RECEIPT', 'Post response', {
        'status': posted.messageResponse.status,
        'message': posted.messageResponse.message,
      });
      if (posted.messageResponse.status != AppConstants.responseSuccess) {
        paymentLoading.value = false;
        showSnackbarMessage(
            message: posted.messageResponse.message, isSuccess: false);
        return;
      }

      await _createBookPostPolicyThenDebit();
    } catch (e, st) {
      paymentLoading.value = false;
      QLog.e('RECEIPT', e, st);
      showSnackbarMessage(message: _extractServerMessage(e), isSuccess: false);
    }
  }

  Future<void> _createBookPostPolicyThenDebit() async {
    QLog.d('POLICY', 'Preparing policy payload', {
      'sessionId': sessionId,
      'vendor': preferredInsurer,
      'businessClassID': businessClassID,
      'riskTypeID': riskTypeID,
      'start': startDate.toIso8601String(),
      'end': endDate.toIso8601String(),
      'renewal': renewalDate.toIso8601String(),
      'itemsCount': items.length,
    });
    try {
      final customerId = _extractCustomerId();
      if (customerId.isEmpty) {
        paymentLoading.value = false;
        QLog.d('POLICY', 'Missing CustomerID');
        showSnackbarMessage(
            message: 'Missing Customer ID. Please login again.',
            isSuccess: false);
        return;
      }

      // Build items (prefer explicit fields, then parse from Message, then fallback to Subject)
      final policyItems = <CreatePolicyItem>[];
      for (int i = 0; i < items.length; i++) {
        final m = items[i];
        final msg = (m['Message'] ?? m['message'] ?? '').toString();

        String desc = (m['ItemsDescription'] ??
                m['itemsDescription'] ??
                m['description'] ??
                '')
            .toString();
        if (desc.trim().isEmpty && msg.isNotEmpty) {
          final md =
              RegExp(r'Description\s*[:\-\s]*([^,]+)', caseSensitive: false)
                  .firstMatch(msg);
          if (md != null) desc = (md.group(1) ?? '').trim();
        }
        if (desc.trim().isEmpty) {
          desc = (m['Subject'] ?? m['subject'] ?? 'Item ${i + 1}').toString();
        }

        String location =
            (m['ItemLocation'] ?? m['itemLocation'] ?? m['location'] ?? '')
                .toString();
        if (location.trim().isEmpty && msg.isNotEmpty) {
          final ml = RegExp(r'Location\s*[:\-\s]*([^,]+)', caseSensitive: false)
              .firstMatch(msg);
          if (ml != null) location = (ml.group(1) ?? '').trim();
        }
        if (location.trim().isEmpty) {
          location = 'Not specified';
        }

        final sum = double.tryParse(
              '${m['Value'] ?? m['value'] ?? m['SumInsured'] ?? m['sumInsured'] ?? 0}'
                  .toString()
                  .replaceAll(',', ''),
            ) ??
            0.0;

        // Extract base64 attachment data from ScreenShotURL
        final attachmentData =
            (m['ScreenShotURL'] ?? m['screenShotURL'] ?? '').toString();

        print('🔨 Creating PolicyItem $i:');
        print('   Description: $desc');
        print('   Location: $location');
        print('   Sum: $sum');
        print('   Has attachment: ${attachmentData.isNotEmpty}');
        if (attachmentData.isNotEmpty) {
          print('   Attachment size: ${attachmentData.length} chars');
        }

        policyItems.add(CreatePolicyItem(
          manualNumbering: '${i + 1}',
          itemsDescription: desc,
          sumInsured: sum,
          itemLocation: location,
          policyBrokerID: "",
          sectionTypeID: "SECTIONA",
          brokingSlipItemCount: 0,
          policyItems: attachmentData.isNotEmpty
              ? attachmentData
              : null, // Pass base64 data
        ));
      }

      // Vendor (from context)
      var vendorID = (preferredInsurer['vendorID'] ?? '').toString().trim();
      var vendorName = (preferredInsurer['vendorName'] ?? '').toString().trim();

      // Fallback to stored pick if still empty (defensive)
      if (vendorID.isEmpty) {
        final raw = GetStorage().read(StorageKeys.preferredInsurer);
        if (raw is Map && (raw['vendorID']?.toString().isNotEmpty ?? false)) {
          vendorID = raw['vendorID'].toString();
          vendorName = (raw['vendorName'] ?? vendorID).toString();
        } else if (raw is String) {
          try {
            final m = jsonDecode(raw);
            if (m is Map && (m['vendorID']?.toString().isNotEmpty ?? false)) {
              vendorID = m['vendorID'].toString();
              vendorName = (m['vendorName'] ?? vendorID).toString();
            }
          } catch (_) {}
        }
      }

      if (vendorID.isEmpty) {
        paymentLoading.value = false;
        showSnackbarMessage(
          message: 'Please select a preferred insurer before payment.',
          isWarning: true,
        );
        return;
      }

      final req = CreatePolicyRequest(
        customerID: customerId,
        employeeID: 'Admin',
        approvedBy: 'Admin',
        vendorID: vendorID,
        businessClassID: businessClassID,
        riskTypeID: riskTypeID,
        policyStartDate: startDate.toIso8601String(),
        policyEndDate: endDate.toIso8601String(),
        renewalDate: renewalDate.toIso8601String(),
        insurancePremiumMethodsID: 'BASIC',
        items: policyItems,
        underwriters: [
          CreatePolicyUnderwriter(
            vendorID: vendorID,
            vendorName: vendorName,
            apportionment: 100,
          ),
        ],
      );

      QLog.d('POLICY', 'Creating policy');
      final created = await repo.createInsurancePolicyClient(req.toJson());
      QLog.d('POLICY', 'Create response', {
        'status': created.messageResponse.status,
        'message': created.messageResponse.message,
      });
      if (created.messageResponse.status != AppConstants.responseSuccess) {
        paymentLoading.value = false;
        showSnackbarMessage(
            message: created.messageResponse.message, isSuccess: false);
        return;
      }
      final newPolicyId = created.messageResponse.message;

      final bookReq = RenewPolicyRequest(policyBrokerID: newPolicyId);

      QLog.d('POLICY', 'Booking policy', {'policyId': newPolicyId});
      final booked = await repo.bookPolicy(bookReq);
      QLog.d('POLICY', 'Book response', {
        'status': booked.messageResponse.status,
        'message': booked.messageResponse.message,
      });
      if (booked.messageResponse.status != AppConstants.responseSuccess) {
        paymentLoading.value = false;
        showSnackbarMessage(
            message: booked.messageResponse.message, isSuccess: false);
        return;
      }

      QLog.d('POLICY', 'Posting policy', {'policyId': newPolicyId});
      final posted = await repo.postPolicy(bookReq);
      QLog.d('POLICY', 'Post response', {
        'status': posted.messageResponse.status,
        'message': posted.messageResponse.message,
      });
      if (posted.messageResponse.status != AppConstants.responseSuccess) {
        paymentLoading.value = false;
        showSnackbarMessage(
            message: posted.messageResponse.message, isSuccess: false);
        return;
      }

      // Debit note: create → book → post
      clientNoteReq.policyBrokerID = newPolicyId;
      clientNoteReq.startDate = startDate.toIso8601String();
      clientNoteReq.endDate = endDate.toIso8601String();
      clientNoteReq.renewalDate = renewalDate.toIso8601String();
      clientNoteReq.sumInsured = sumInsured;
      clientNoteReq.invoiceDate = receiptReq.transactionDate;
      clientNoteReq.premiumDue = premium;

      QLog.d('DEBIT', 'Creating client note');
      final cn = await repo.createClientNote(clientNoteReq);
      QLog.d('DEBIT', 'Create CN response', {
        'status': cn.messageResponse.status,
        'message': cn.messageResponse.message,
      });
      if (cn.messageResponse.status != AppConstants.responseSuccess) {
        paymentLoading.value = false;
        showSnackbarMessage(
            message: cn.messageResponse.message, isSuccess: false);
        return;
      }
      clientNoteReq.invoiceNumber = cn.messageResponse.message;

      QLog.d('DEBIT', 'Booking client note');
      final bookCn = await repo.bookClientNote(clientNoteReq);
      QLog.d('DEBIT', 'Book CN response', {
        'status': bookCn.messageResponse.status,
        'message': bookCn.messageResponse.message,
      });
      if (bookCn.messageResponse.status != AppConstants.responseSuccess) {
        paymentLoading.value = false;
        showSnackbarMessage(
            message: bookCn.messageResponse.message, isSuccess: false);
        return;
      }

      QLog.d('DEBIT', 'Posting client note');
      final postCn = await repo.postClientNote(clientNoteReq);
      QLog.d('DEBIT', 'Post CN response', {
        'status': postCn.messageResponse.status,
        'message': postCn.messageResponse.message,
      });
      if (postCn.messageResponse.status != AppConstants.responseSuccess) {
        paymentLoading.value = false;
        showSnackbarMessage(
            message: postCn.messageResponse.message, isSuccess: false);
        return;
      }
      // 🔄 NEW: Update enquiry status AFTER Debit Note has been posted
      try {
        // Try to get CaseID from the current quote context first
        String caseId = '';
        try {
          final dynamic fromArgs = (Get.arguments as Map?) ?? {};
          if (fromArgs is Map && fromArgs.containsKey('caseId')) {
            caseId = (fromArgs['caseId'] ?? '').toString();
          }
        } catch (_) {}

        if (caseId.isEmpty) {
          // Fallback: read from persisted lastEnquiry
          final raw = GetStorage().read(StorageKeys.lastEnquiry);
          if (raw is Map) {
            caseId = (raw['caseId'] ?? '').toString();
          } else if (raw is String && raw.isNotEmpty) {
            try {
              final m = Map<String, dynamic>.from(jsonDecode(raw));
              caseId = (m['caseId'] ?? '').toString();
            } catch (_) {}
          }
        }

        if (caseId.isNotEmpty) {
          final upd = await repo.updateCustomerEnquiryStatus(
            UpdateEnquiryStatusRequest(caseID: caseId),
          );
          QLog.d('ENQUIRY_STATUS', 'UpdateCustomerEnquiryStatus', {
            'caseId': caseId,
            'status': upd.messageResponse.status,
            'message': upd.messageResponse.message,
          });
        } else {
          QLog.d('ENQUIRY_STATUS',
              'Skipped UpdateCustomerEnquiryStatus — CaseID not found');
        }
      } catch (e, st) {
        // Never block user on this; just log
        QLog.e('ENQUIRY_STATUS', e, st);
      }

      paymentLoading.value = false;

      QLog.d('DONE', 'Navigating to Quote Confirmation', {
        'policyId': newPolicyId,
        'ref': lastPaymentReference,
        'date': lastPaymentDate,
        'amount': lastPaymentAmount,
      });

      Get.offNamed(AppRoutes.quoteConfirmation, arguments: {
        'policyId': newPolicyId,
        'paymentReference': lastPaymentReference ?? '',
        'paymentDate': lastPaymentDate ?? '',
        'paymentMethod': 'Card',
        'paymentAmount': lastPaymentAmount ?? 0,
      });
    } catch (e, st) {
      paymentLoading.value = false;
      QLog.e('POLICY/DEBIT', e, st);
      showSnackbarMessage(message: _extractServerMessage(e), isSuccess: false);
    }
  }

  // ----------------- Context & utils -----------------

  void _hydrateContext() {
    final Map<String, dynamic> fromArgs =
        (Get.arguments as Map?)?.map((k, v) => MapEntry(k.toString(), v)) ?? {};
    dynamic raw = GetStorage().read(StorageKeys.lastEnquiry);
    Map<String, dynamic> fromStore = {};
    if (raw is Map) {
      fromStore = Map<String, dynamic>.from(raw);
    } else if (raw is String) {
      try {
        fromStore = Map<String, dynamic>.from(jsonDecode(raw));
      } catch (_) {}
    }
    ctx = fromArgs.isNotEmpty ? fromArgs : fromStore;

    // Add debug logging to trace premium value
    print('🔍 PAYMENT_CTX: Raw storage data: $raw');
    print('🔍 PAYMENT_CTX: Parsed context: $ctx');
    print('🔍 PAYMENT_CTX: Premium field value: ${ctx['premium']}');

    startDate = _parseDateFlex(ctx['startDate']);
    endDate = _parseDateFlex(
      ctx['endDate'],
      fallback: startDate.add(const Duration(days: 364)),
    );
    renewalDate = _parseDateFlex(
      ctx['renewalDate'],
      fallback: endDate.add(const Duration(days: 1)),
    );

    QLog.d('PAYMENT_DATES', 'Using dates', {
      'start': startDate.toIso8601String(),
      'end': endDate.toIso8601String(),
      'renewal': renewalDate.toIso8601String(),
    });

    // Fix premium parsing - handle both numeric and string values
    final premiumRaw = ctx['premium'] ?? ctx['Premium'] ?? 0;
    print(
        '🔍 PAYMENT_CTX: Raw premium value: $premiumRaw (type: ${premiumRaw.runtimeType})');

    if (premiumRaw is num) {
      premium = premiumRaw.toDouble();
    } else {
      premium = double.tryParse(premiumRaw.toString().replaceAll(',', '')) ?? 0;
    }

    print('🔍 PAYMENT_CTX: Parsed premium: $premium');

    final sumInsuredRaw = ctx['sumInsured'] ?? ctx['SumInsured'] ?? 0;
    if (sumInsuredRaw is num) {
      sumInsured = sumInsuredRaw.toDouble();
    } else {
      sumInsured =
          double.tryParse(sumInsuredRaw.toString().replaceAll(',', '')) ?? 0;
    }

    businessClassName = '${ctx['businessClassName'] ?? ''}';
    riskName = '${ctx['riskName'] ?? ''}';

    businessClassID = (ctx['businessClassID']?.toString().isNotEmpty ?? false)
        ? ctx['businessClassID'].toString()
        : (Get.isRegistered<GetQuoteController>()
            ? (Get.find<GetQuoteController>()
                    .selectedBusinessPolicy
                    .value
                    ?.businessClassID ??
                '')
            : '');
    riskTypeID = (ctx['riskTypeID']?.toString().isNotEmpty ?? false)
        ? ctx['riskTypeID'].toString()
        : (Get.isRegistered<GetQuoteController>()
            ? (Get.find<GetQuoteController>()
                    .selectedRiskTypeID
                    .value
                    ?.riskTypeID ??
                '')
            : '');

    // Defensive fallback: if riskTypeID is still empty, use riskName as fallback
    if (riskTypeID.isEmpty &&
        (ctx['riskName']?.toString().isNotEmpty ?? false)) {
      riskTypeID = ctx['riskName'].toString();
      print('🔄 FALLBACK: Using riskName as riskTypeID: $riskTypeID');
    }

    // Debug logging for payment flow
    print('💳 QuotePaymentController Context:');
    print('   - riskTypeID: $riskTypeID');
    print('   - riskName: ${ctx['riskName']}');
    print('   - hasContext: ${ctx.isNotEmpty}');

    preferredInsurer = _normalizeVendor(ctx['preferredInsurer']);
    items = _normalizeItems(ctx['items']);

    // Debug logging for document tracking
    print('📋 Payment Controller - Items received: ${items.length}');
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final hasDoc = item.containsKey('screenShotURL') &&
          (item['screenShotURL']?.toString().isNotEmpty ?? false);
      print(
          '   Item $i: ${item['itemsDescription'] ?? 'No desc'} - Document: $hasDoc');
      if (hasDoc) {
        final docLength = item['screenShotURL'].toString().length;
        print('     Document size: $docLength characters');
      }
    }

    QLog.d('CTX', 'Hydrated context', {
      'sessionId': sessionId,
      'premium': premium,
      'sumInsured': sumInsured,
      'businessClassID': businessClassID,
      'riskTypeID': riskTypeID,
      'start': startDate.toIso8601String(),
      'end': endDate.toIso8601String(),
      'renewal': renewalDate.toIso8601String(),
      'preferredInsurer': preferredInsurer,
      'itemsCount': items.length,
    });
  }

  List<Map<String, dynamic>> _normalizeItems(dynamic v) {
    final out = <Map<String, dynamic>>[];
    void addOne(dynamic x) {
      if (x is Map) {
        out.add(Map<String, dynamic>.from(x));
      } else if (x is String) {
        try {
          final m = jsonDecode(x);
          if (m is Map) out.add(Map<String, dynamic>.from(m));
        } catch (_) {}
      }
    }

    if (v is List)
      for (final it in v) {
        addOne(it);
      }
    else if (v is String) {
      try {
        final l = jsonDecode(v);
        if (l is List) for (final it in l) {
          addOne(it);
        }
      } catch (_) {}
    }
    return out;
  }

  Map<String, dynamic> _normalizeVendor(dynamic v) {
    if (v is Map) return Map<String, dynamic>.from(v);
    if (v is String) {
      try {
        final m = jsonDecode(v);
        if (m is Map) return Map<String, dynamic>.from(m);
        return {'vendorName': v};
      } catch (_) {
        return {'vendorName': v};
      }
    }
    return <String, dynamic>{};
  }

  int _getChargeAmount(String amount) {
    final amountToDouble = double.tryParse(amount) ?? 0.0;
    final usualCharge = amountToDouble * 0.015;
    final extraCharge =
        (amountToDouble > 2500 ? (usualCharge + 100) : usualCharge);
    return ((amountToDouble + (extraCharge > 2000 ? 2000 : extraCharge)) * 100)
        .round();
  }

  // Map<String, dynamic> _toMap(dynamic raw) {
  //   if (raw is Map) return Map<String, dynamic>.from(raw);
  //   if (raw is String) {
  //     try {
  //       final m = jsonDecode(raw);
  //       if (m is Map) return Map<String, dynamic>.from(m);
  //     } catch (_) {}
  //   }
  //   return <String, dynamic>{};
  // }

  // String _pickCustomerId(Map<String, dynamic> m) {
  //   for (final k in const [
  //     'customerID',
  //     'CustomerID',
  //     'customerId',
  //     'CustomerId',
  //     'username',
  //     'Username'
  //   ]) {
  //     final v = m[k];
  //     if (v != null && v.toString().trim().isNotEmpty) return v.toString();
  //   }
  //   return '';
  // }

  String _extractCustomerId() {
    print('🔍 EXTRACT_CUSTOMER_ID: Starting customer ID extraction');

    try {
      final profileData = GetStorage().read(StorageKeys.profileData);
      print('📱 EXTRACT_CUSTOMER_ID: Raw profile data: $profileData');

      if (profileData == null) {
        print('❌ EXTRACT_CUSTOMER_ID: Profile data is null');
        return '';
      }

      final user = PlatformUser.fromJson(profileData);
      print('✅ EXTRACT_CUSTOMER_ID: User parsed successfully');
      print('   Customer ID: ${user.customerID}');
      print('   Customer Name: ${user.customerName}');
      print('   Customer Full Name: ${user.customerFullName}');
      print('   Customer First Name: ${user.customerFirstName}');
      print('   Customer Last Name: ${user.customerLastName}');
      print('   Customer Email: ${user.customerEmail}');

      return user.customerID ?? '';
    } catch (e, st) {
      print('❌ EXTRACT_CUSTOMER_ID: Error extracting customer ID: $e');
      print('📍 STACK TRACE: $st');
      return '';
    }
  }

  String _extractServerMessage(Object e, {String? fallback}) {
    final fb = fallback ?? 'Something went wrong. Please try again.';
    try {
      final dynamic de = e;
      final dynamic resp = (de as dynamic).response;
      final dynamic data = resp is dynamic ? resp.data : null;
      final msgFromResp = _messageFromData(data);
      if (msgFromResp != null && msgFromResp.trim().isNotEmpty) {
        return msgFromResp;
      }

      final dynamic mr = (de as dynamic).messageResponse;
      final dynamic mrMsg =
          mr is dynamic ? (mr.message ?? mr['message'] ?? mr['Message']) : null;
      if (mrMsg is String && mrMsg.trim().isNotEmpty) return mrMsg.trim();

      final dynamic m = (de as dynamic).message;
      if (m is String && m.trim().isNotEmpty) return m.trim();
    } catch (_) {}

    if (e is SocketException) {
      return 'Network error. Please check your connection and try again.';
    }
    if (e is HttpException) return e.message;
    if (e is FormatException) return e.message;

    final s = e.toString();
    if (s.isNotEmpty) {
      final fromString = _messageFromData(s);
      if (fromString != null && fromString.trim().isNotEmpty) {
        return fromString.trim();
      }
      final idx = s.indexOf('Exception:');
      if (idx >= 0 && idx + 10 < s.length) return s.substring(idx + 10).trim();
      return s;
    }
    return fb;
  }

  String? _messageFromData(dynamic data) {
    if (data == null) return null;
    if (data is String) {
      try {
        final d = jsonDecode(data);
        if (d is Map) return _messageFromMap(d) ?? data;
      } catch (_) {}
      return data;
    }
    if (data is Map) return _messageFromMap(data);
    return null;
  }

  String? _messageFromMap(Map map) {
    final keys = const [
      'message',
      'Message',
      'error',
      'Error',
      'detail',
      'Detail',
      'errors',
      'Errors'
    ];
    for (final k in keys) {
      if (!map.containsKey(k)) continue;
      final v = map[k];
      if (v == null) continue;
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is List && v.isNotEmpty) {
        final parts = v
            .take(3)
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
        if (parts.isNotEmpty) return parts.join('\n');
      }
      if (v is Map && v.isNotEmpty) {
        final buf = <String>[];
        v.forEach((key, val) {
          if (val is List && val.isNotEmpty) {
            buf.add('${key.toString()}: ${val.first.toString()}');
          } else if (val != null) {
            buf.add('${key.toString()}: ${val.toString()}');
          }
        });
        if (buf.isNotEmpty) return buf.join('\n');
      }
    }
    return null;
  }
}
