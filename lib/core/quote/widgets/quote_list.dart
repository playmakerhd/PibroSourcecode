import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/quote/controller/quote_controller.dart';
import 'package:pibro/network/models/response/sales_quotation_response.dart';
import 'package:pibro/shared/empty_data.dart';
import 'package:pibro/shared/item_row_container.dart';
import 'package:pibro/shared/widget/item_row_container_column.dart';
import 'package:pibro/utils/app_utils.dart';

class QuoteList extends StatelessWidget {
  const QuoteList({super.key});

  @override
  Widget build(BuildContext context) {
    final QuoteController controller = Get.put(QuoteController());
    return Expanded(
      child: Obx(
        () => controller.quoteLoading.value && controller.quotes.isEmpty
            ? LoadingAnimationWidget.staggeredDotsWave(
                color: AppColors.primaryColor,
                size: 100,
              )
            : controller.quotes.isEmpty
                ? EmptyData()
                : ListView.builder(
                    itemCount: controller.quotes.length,
                    padding: EdgeInsets.only(top: 30, bottom: 20),
                    itemBuilder: (BuildContext context, int index) {
                      final SalesQuotationResponse quote =
                          controller.quotes[index];
                      final sessionValue =
                          (quote.session ?? '').trim().toUpperCase();
                      final bool isCompleted = sessionValue == 'CLOSED';
                      final String statusText =
                          isCompleted ? 'Completed' : 'Pending';
                      final Color statusColor =
                          isCompleted ? AppColors.activeGreen : Colors.orange;

                      // Format invoice date from API
                      String formattedDate = 'N/A';
                      try {
                        if (quote.invoiceDate != null &&
                            quote.invoiceDate!.isNotEmpty) {
                          formattedDate = formatDate(quote.invoiceDate!);
                        }
                      } catch (e) {
                        formattedDate = quote.invoiceDate ?? 'N/A';
                      }

                      // Calculate total sum insured from items
                      double totalSumInsured = quote.sumInsured ?? 0.0;

                      return GestureDetector(
                        onTap: () => controller.navigateToQuoteDetails(quote),
                        child: ItemRowContainer(
                          isLarge: true,
                          child: ItemRowContainerColumn(
                            id: quote.invoiceNumber ?? 'N/A',
                            amount:
                                'N${formatAmount(totalSumInsured).toString()}',
                            dates: formattedDate,
                            type: quote.riskTypeID ?? 'Unknown',
                            status: statusText,
                            color: statusColor,
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
