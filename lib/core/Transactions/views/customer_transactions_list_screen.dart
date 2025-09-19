import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/transactions/controller/customer_transactions_controller.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/item_row_container.dart';
import 'package:pibro/shared/title_value_row.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:pibro/constants/app_styles.dart';

/// tiny helper to choose amount color from transaction number prefix
Color amountColorFromTxn(BuildContext context, String? txnNo) {
  final s = (txnNo ?? '').toUpperCase().trim();
  if (s.startsWith('RN')) return Colors.red; // Receipt -> outflow
  if (s.startsWith('DBN')) return Colors.green; // Debit Note -> inflow
  return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;
}

class CustomerTransactionsListScreen extends StatelessWidget {
  const CustomerTransactionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CustomerTransactionsController());
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(title: 'Customer Transactions'),
          _DateFilter(
            onChanged: (from, to) {
              c.from.value = from;
              c.to.value = to;
              c.refreshList();
            },
          ),
          Expanded(
            child: Obx(() {
              if (c.loading.value && c.items.isEmpty) {
                return Center(
                  child: LoadingAnimationWidget.waveDots(
                      color: AppColors.primaryColor, size: 50),
                );
              }
              if (c.items.isEmpty) {
                return const Center(child: Text('No transactions'));
              }
              return NotificationListener<ScrollNotification>(
                onNotification: (sn) {
                  if (sn.metrics.pixels >= sn.metrics.maxScrollExtent - 200) {
                    c.loadMore();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 20, bottom: 100),
                  itemCount: c.items.length + 1,
                  itemBuilder: (_, i) {
                    if (i == c.items.length) {
                      return c.loading.value
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: LoadingAnimationWidget.waveDots(
                                    color: AppColors.primaryColor, size: 40),
                              ),
                            )
                          : const SizedBox.shrink();
                    }
                    final t = c.items[i];
                    return GestureDetector(
                      onTap: () => Get.toNamed('/customer-transaction-detail',
                          arguments: t),
                      child: ItemRowContainer(
                        noHeight: true,
                        isLarge: true,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: queryWidth(context) * 0.04,
                              vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LEFT: Transaction No + Date
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.transactionNumber ?? '-',
                                      style: Styles.mediumTextStyle(size: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      formatDate(t.transactionDate ?? ''),
                                      style: Styles.regularTextStyle(
                                          size: 12, color: AppColors.hintColor),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // RIGHT: Amount + Currency (right-aligned)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatAmount((t.transactionAmount ?? 0)),
                                      style: Styles.mediumTextStyle(
                                        size: 14,
                                        color: amountColorFromTxn(
                                            context, t.transactionNumber),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      t.currencyID ?? '-',
                                      style: Styles.regularTextStyle(
                                          size: 14, color: AppColors.hintColor),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DateFilter extends StatefulWidget {
  final void Function(DateTime?, DateTime?) onChanged;
  const _DateFilter({required this.onChanged});

  @override
  State<_DateFilter> createState() => _DateFilterState();
}

class _DateFilterState extends State<_DateFilter> {
  DateTime? from;
  DateTime? to;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: queryWidth(context) * 0.05, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  initialDate: from ?? DateTime.now(),
                );
                setState(() => from = picked);
                widget.onChanged(from, to);
              },
              child: _DateBox(
                  label: 'From',
                  value:
                      from == null ? '' : formatDate(from!.toIso8601String())),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  initialDate: to ?? DateTime.now(),
                );
                setState(() => to = picked);
                widget.onChanged(from, to);
              },
              child: _DateBox(
                  label: 'To',
                  value: to == null ? '' : formatDate(to!.toIso8601String())),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String value;
  const _DateBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ItemRowContainer(
      noHeight: true,
      noHorizontalMargin: true,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TitleValueRow(title: label, value: value.isEmpty ? '-' : value),
      ),
    );
  }
}
