import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/quote/controller/quote_controller.dart';
import 'package:pibro/network/models/response/quotes_response.dart';
import 'package:pibro/shared/empty_data.dart';
import 'package:pibro/shared/item_row_container.dart';
import 'package:pibro/shared/widget/item_row_container_column.dart';
import 'package:pibro/utils/api_utils.dart';
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
                      final QuoteInfo quote = controller.quotes[index];
                      // Determine status color: Completed -> green, Pending -> orange (yellow), otherwise default orange
                      final String statusText =
                          (quote.supportStatus ?? '').toString();
                      Color statusColor = Colors.orange;
                      if (statusText.toLowerCase() == 'completed') {
                        statusColor = AppColors.activeGreen;
                      } else if (statusText.toLowerCase() == 'pending') {
                        statusColor =
                            Colors.orange;
                      }

                      return GestureDetector(
                        onTap: () => controller.navigateToQuoteDetails(quote),
                        child: ItemRowContainer(
                          isLarge: true,
                          child: ItemRowContainerColumn(
                            id: quote.caseId!,
                            amount: 'N${formatAmount(getQuoteSum(quote)).toString()}',
                            dates: formatDate(quote.supportDate!),
                            type: quote.productId!,
                            // status text and color
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
