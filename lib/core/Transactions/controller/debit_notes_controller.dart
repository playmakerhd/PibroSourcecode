import 'package:get/get.dart';
import 'package:pibro/network/models/response/debit_note_list_response.dart';
import 'package:pibro/network/repository/pibro_repository.dart';
import 'package:pibro/network/api/api_provider.dart';

class DebitNotesController extends GetxController {
  final repo = PibroRepository(appApiProvider: ApiProvider());

  RxBool loading = false.obs;
  RxList<DebitNote> notes = <DebitNote>[].obs;

  // Client-side date filtering
  Rxn<DateTime> from = Rxn<DateTime>();
  Rxn<DateTime> to = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    loading.value = true;
    try {
      final res = await repo.getClientNotesByCustomer();
      notes.assignAll(res.notes);
    } catch (_) {
      // handled by global snackbar in BaseProvider
    } finally {
      loading.value = false;
    }
  }

  Iterable<DebitNote> get filtered {
    if (from.value == null && to.value == null) return notes;
    final f = from.value;
    final t = to.value;
    bool inRange(DateTime d) {
      final after = f == null || !d.isBefore(f);
      final before = t == null || !d.isAfter(t);
      return after && before;
    }

    DateTime? parse(String? s) => s == null ? null : DateTime.tryParse(s);
    return notes.where((n) {
      final d = parse(n.invoiceDate) ?? parse(n.startDate) ?? parse(n.endDate);
      return d == null ? true : inRange(d);
    });
  }
}
