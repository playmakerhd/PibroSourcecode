import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/transactions/controller/debit_notes_controller.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/item_row_container.dart';
import 'package:pibro/shared/title_value_row.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';

class DebitNoteListScreen extends StatelessWidget {
  const DebitNoteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DebitNotesController());
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(title: 'Debit Notes'),
          _DateFilter(
            onChanged: (from, to) {
              c.from.value = from;
              c.to.value = to;
            },
          ),
          Expanded(
            child: Obx(() {
              if (c.loading.value) {
                return Center(
                  child: LoadingAnimationWidget.waveDots(
                      color: AppColors.primaryColor, size: 50),
                );
              }
              final data = c.filtered.toList();
              if (data.isEmpty) {
                return const Center(child: Text('No debit notes'));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 20, bottom: 30),
                itemCount: data.length,
                itemBuilder: (_, i) {
                  final n = data[i];
                  return GestureDetector(
                    onTap: () =>
                        Get.toNamed('/debit-note-detail', arguments: n),
                    child: ItemRowContainer(
                      noHeight: true,
                      isLarge: true,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: queryWidth(context) * 0.04,
                            vertical: 10),
                        child: Column(
                          children: [
                            TitleValueRow(
                                title: 'Invoice No:',
                                value: n.invoiceNumber ?? '-'),
                            TitleValueRow(
                                title: 'Policy Broker ID:',
                                value: n.policyBrokerID ?? '-'),
                            TitleValueRow(
                                title: 'Start Date:',
                                value: formatDate(n.startDate ?? '')),
                            TitleValueRow(
                                title: 'End Date:',
                                value: formatDate(n.endDate ?? '')),
                            TitleValueRow(
                                title: 'Sum Insured(NGN):',
                                value: (n.sumInsured ?? 0).toString()),
                            TitleValueRow(
                                title: 'Premium Due(NGN):',
                                value: (n.premiumDue ?? 0).toString()),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
