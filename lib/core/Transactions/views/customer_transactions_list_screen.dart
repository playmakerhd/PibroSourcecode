import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/Transactions/controller/customer_transactions_controller.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/item_row_container.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';
import 'package:pibro/constants/app_styles.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

/// tiny helper to choose amount color from transaction number prefix
Color amountColorFromTxn(BuildContext context, String? txnNo) {
  final s = (txnNo ?? '').toUpperCase().trim();
  if (s.startsWith('RN') || s.startsWith('INV'))
    return Colors.red; // Receipt -> outflow
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
              c.setStatementDatesSelected(true);
              c.refreshList();
            },
          ),
          // Print Customer Statement Button
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: queryWidth(context) * 0.05, vertical: 10),
            child: GestureDetector(
              onTap: () {
                // Show bottom sheet immediately
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  enableDrag: true,
                  builder: (bc) {
                    return SizedBox(
                      height: queryHeight(context) * 0.85,
                      child: _CustomerStatementBottomSheet(
                        controller: c,
                      ),
                    );
                  },
                );
              },
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.print,
                        color: AppColors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Print Customer Statement',
                        style: Styles.semiBoldTextStyle(
                            size: 15, color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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

  // Switch between 1, 2, 3, or 4 to try different UI options
  final int _selectedOption = 3;

  @override
  Widget build(BuildContext context) {
    switch (_selectedOption) {
      case 1:
        return _Option1GradientCards(
          from: from,
          to: to,
          onFromChanged: (date) {
            setState(() => from = date);
            widget.onChanged(from, to);
          },
          onToChanged: (date) {
            setState(() => to = date);
            widget.onChanged(from, to);
          },
        );
      case 2:
        return _Option2ModernChips(
          from: from,
          to: to,
          onFromChanged: (date) {
            setState(() => from = date);
            widget.onChanged(from, to);
          },
          onToChanged: (date) {
            setState(() => to = date);
            widget.onChanged(from, to);
          },
        );
      case 3:
        return _Option3NeumorphicStyle(
          from: from,
          to: to,
          onFromChanged: (date) {
            setState(() => from = date);
            widget.onChanged(from, to);
          },
          onToChanged: (date) {
            setState(() => to = date);
            widget.onChanged(from, to);
          },
        );
      case 4:
        return _Option4MinimalBorders(
          from: from,
          to: to,
          onFromChanged: (date) {
            setState(() => from = date);
            widget.onChanged(from, to);
          },
          onToChanged: (date) {
            setState(() => to = date);
            widget.onChanged(from, to);
          },
        );
      default:
        return _Option1GradientCards(
          from: from,
          to: to,
          onFromChanged: (date) {
            setState(() => from = date);
            widget.onChanged(from, to);
          },
          onToChanged: (date) {
            setState(() => to = date);
            widget.onChanged(from, to);
          },
        );
    }
  }
}

/// OPTION 1: Gradient Cards with Elevated Shadow
class _Option1GradientCards extends StatelessWidget {
  final DateTime? from;
  final DateTime? to;
  final Function(DateTime?) onFromChanged;
  final Function(DateTime?) onToChanged;

  const _Option1GradientCards({
    required this.from,
    required this.to,
    required this.onFromChanged,
    required this.onToChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: queryWidth(context) * 0.05, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _GradientDateCard(
              label: 'From',
              date: from,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  initialDate: from ?? DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.primaryColor,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: AppColors.primaryColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                onFromChanged(picked);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _GradientDateCard(
              label: 'To',
              date: to,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  initialDate: to ?? DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.primaryColor,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: AppColors.primaryColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                onToChanged(picked);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientDateCard extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _GradientDateCard({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: Styles.mediumTextStyle(
                      size: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ],
              ),
              Text(
                date == null
                    ? 'Select date'
                    : formatDate(date!.toIso8601String()),
                style: Styles.semiBoldTextStyle(
                  size: 14,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// OPTION 2: Modern Chips Style with Icons
class _Option2ModernChips extends StatelessWidget {
  final DateTime? from;
  final DateTime? to;
  final Function(DateTime?) onFromChanged;
  final Function(DateTime?) onToChanged;

  const _Option2ModernChips({
    required this.from,
    required this.to,
    required this.onFromChanged,
    required this.onToChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: queryWidth(context) * 0.05, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _ChipDatePicker(
              label: 'From',
              date: from,
              icon: Icons.event_available,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  initialDate: from ?? DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.primaryColor,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: AppColors.primaryColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                onFromChanged(picked);
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),
          Expanded(
            child: _ChipDatePicker(
              label: 'To',
              date: to,
              icon: Icons.event_busy,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  initialDate: to ?? DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.primaryColor,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: AppColors.primaryColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                onToChanged(picked);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipDatePicker extends StatelessWidget {
  final String label;
  final DateTime? date;
  final IconData icon;
  final VoidCallback onTap;

  const _ChipDatePicker({
    required this.label,
    required this.date,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: date != null
              ? AppColors.primaryColor.withOpacity(0.08)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: date != null
                ? AppColors.primaryColor.withOpacity(0.3)
                : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: date != null
                          ? AppColors.primaryColor
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      icon,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: Styles.mediumTextStyle(
                      size: 11,
                      color: AppColors.hintColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                date == null ? 'Select' : formatDate(date!.toIso8601String()),
                style: Styles.semiBoldTextStyle(
                  size: 13,
                  color: date != null
                      ? AppColors.primaryColor
                      : Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// OPTION 3: Neumorphic/Soft UI Style
class _Option3NeumorphicStyle extends StatelessWidget {
  final DateTime? from;
  final DateTime? to;
  final Function(DateTime?) onFromChanged;
  final Function(DateTime?) onToChanged;

  const _Option3NeumorphicStyle({
    required this.from,
    required this.to,
    required this.onFromChanged,
    required this.onToChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: queryWidth(context) * 0.05, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _NeumorphicDateBox(
              label: 'From',
              date: from,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  initialDate: from ?? DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.primaryColor,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: AppColors.primaryColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                onFromChanged(picked);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _NeumorphicDateBox(
              label: 'To',
              date: to,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  initialDate: to ?? DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.primaryColor,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: AppColors.primaryColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                onToChanged(picked);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NeumorphicDateBox extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _NeumorphicDateBox({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: const Offset(-4, -4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.grey.shade300,
              offset: const Offset(4, 4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: Styles.mediumTextStyle(
                      size: 10,
                      color: AppColors.hintColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: date != null
                          ? AppColors.primaryColor.withOpacity(0.1)
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400.withOpacity(0.5),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.calendar_month,
                      size: 16,
                      color: date != null
                          ? AppColors.primaryColor
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              Text(
                date == null
                    ? 'Tap to select'
                    : formatDate(date!.toIso8601String()),
                style: Styles.semiBoldTextStyle(
                  size: 13,
                  color: AppColors.primaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// OPTION 4: Minimal with Bottom Border Accent
class _Option4MinimalBorders extends StatelessWidget {
  final DateTime? from;
  final DateTime? to;
  final Function(DateTime?) onFromChanged;
  final Function(DateTime?) onToChanged;

  const _Option4MinimalBorders({
    required this.from,
    required this.to,
    required this.onFromChanged,
    required this.onToChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: queryWidth(context) * 0.05, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _MinimalDateField(
              label: 'From',
              date: from,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  initialDate: from ?? DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.primaryColor,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: AppColors.primaryColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                onFromChanged(picked);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _MinimalDateField(
              label: 'To',
              date: to,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  initialDate: to ?? DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.primaryColor,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: AppColors.primaryColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                onToChanged(picked);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MinimalDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _MinimalDateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color:
                  date != null ? AppColors.primaryColor : AppColors.inputGrey,
              width: date != null ? 2.5 : 1.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: Styles.regularTextStyle(
                      size: 12,
                      color: date != null
                          ? AppColors.primaryColor
                          : AppColors.hintColor,
                    ),
                  ),
                  Icon(
                    Icons.date_range,
                    size: 18,
                    color: date != null
                        ? AppColors.primaryColor
                        : AppColors.hintColor,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                date == null
                    ? 'Select date'
                    : formatDate(date!.toIso8601String()),
                style: Styles.semiBoldTextStyle(
                  size: 15,
                  color: date != null
                      ? AppColors.primaryColor
                      : AppColors.hintColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet that displays customer statement PDF with preview, save and share options
class _CustomerStatementBottomSheet extends StatefulWidget {
  final CustomerTransactionsController controller;

  const _CustomerStatementBottomSheet({
    required this.controller,
  });

  @override
  State<_CustomerStatementBottomSheet> createState() =>
      _CustomerStatementBottomSheetState();
}

class _CustomerStatementBottomSheetState
    extends State<_CustomerStatementBottomSheet> {
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  Uint8List? _pdfBytes;
  bool _shareLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStatement();
  }

  Future<void> _fetchStatement() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = null;
      });

      final bytes = await widget.controller.fetchCustomerStatementBytes();

      if (bytes == null) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Failed to load customer statement';
        });
      } else {
        // Basic validation: check for PDF header '%PDF'
        final bool looksLikePdf = _looksLikePdf(bytes);
        print(
            'Customer statement fetched: ${bytes.length} bytes, header: ${bytes.length >= 4 ? bytes.sublist(0, 4) : bytes}');

        if (!looksLikePdf) {
          setState(() {
            isLoading = false;
            hasError = true;
            errorMessage =
                'Server returned data that does not look like a PDF document.';
          });
        } else {
          setState(() {
            isLoading = false;
            _pdfBytes = bytes;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Error loading statement: $e';
      });
    }
  }

  bool _looksLikePdf(Uint8List bytes) {
    if (bytes.length < 4) return false;
    // PDF files start with '%PDF' (0x25 0x50 0x44 0x46)
    return bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => ElevatedButton.icon(
                          onPressed: isLoading || hasError || _pdfBytes == null
                              ? null
                              : () async {
                                  await _saveWithFilePicker();
                                },
                          icon: widget.controller.statementLoading.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: Text(widget.controller.statementLoading.value
                              ? 'Saving...'
                              : 'Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        )),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: isLoading || hasError || _pdfBytes == null
                          ? null
                          : () async {
                              await _sharePdf();
                            },
                      icon: _shareLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.share),
                      label: Text(_shareLoading ? 'Preparing...' : 'Share'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // PDF preview area
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading customer statement...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load statement',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            if (errorMessage != null)
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchStatement,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Statement loaded successfully - show PDF preview if bytes available
    if (_pdfBytes != null && _pdfBytes!.isNotEmpty) {
      return PdfPreview(
        build: (format) async => _pdfBytes!,
        allowPrinting: false,
        allowSharing: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        useActions: false,
        pdfFileName: 'customer_statement.pdf',
        padding: const EdgeInsets.all(8),
        scrollViewDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Customer Statement PDF',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Statement is ready - tap "Save" to download',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _saveWithFilePicker() async {
    if (_pdfBytes == null) return;

    try {
      widget.controller.statementLoading.value = true;

      // Generate default filename
      final defaultName =
          'customer_statement_${widget.controller.customerID}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Let user pick save location
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Customer Statement',
        fileName: defaultName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: _pdfBytes,
      );

      if (outputFile != null) {
        // File was saved successfully by FilePicker
        showSnackbarMessage(
          message: 'Customer statement saved to:\n$outputFile',
          isSuccess: true,
        );
        Navigator.of(context).pop();
      } else {
        // User cancelled
        showSnackbarMessage(
          message: 'Save cancelled',
          isWarning: true,
        );
      }
    } catch (e) {
      print('Error saving statement with file picker: $e');
      showSnackbarMessage(
        message: 'Error saving statement: $e',
        isSuccess: false,
      );
    } finally {
      widget.controller.statementLoading.value = false;
    }
  }

  Future<void> _sharePdf() async {
    if (_pdfBytes == null) return;

    try {
      setState(() {
        _shareLoading = true;
      });

      // Write bytes to a temporary file and share
      final tempDir = await getTemporaryDirectory();

      final fileName =
          'customer_statement_${widget.controller.customerID}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final tempFile = File('${tempDir.path}/$fileName');

      // Ensure parent directory exists
      try {
        await tempFile.parent.create(recursive: true);
      } catch (_) {}

      await tempFile.writeAsBytes(_pdfBytes!, flush: true);

      // Use share_plus to open system share sheet
      await Share.shareXFiles([XFile(tempFile.path)],
          text: 'Customer Statement');
    } catch (e) {
      print('Error sharing statement: $e');
      showSnackbarMessage(
        message: 'Error sharing statement: $e',
        isSuccess: false,
      );
    } finally {
      setState(() {
        _shareLoading = false;
      });
    }
  }
}
