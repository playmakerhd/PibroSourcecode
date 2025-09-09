import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pibro/constants/storage_keys.dart';
import 'package:pibro/network/models/platform_user/platform_user.dart' hide CustomerTransaction;
import 'package:pibro/network/models/response/customer_transactions_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/network/api/api_provider.dart';

class CustomerTransactionsController extends GetxController {
  final repo = PibroRepository(appApiProvider: ApiProvider());

  final RxBool loading = false.obs;
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
}
