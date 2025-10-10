import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/models/response/quotes_response.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/empty_data.dart';
import 'package:pibro/shared/item_row_container.dart';
import 'package:pibro/shared/title_value_row.dart';
import 'package:pibro/utils/api_utils.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:printing/printing.dart';

class QuoteItemsScreen extends StatelessWidget {
  const QuoteItemsScreen({super.key, required this.itemsInsured});

  final List<RequestDetails> itemsInsured;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CommonHeader(
            title: AppStrings.itemInsured.tr,
          ),
          Expanded(
            child: itemsInsured.isEmpty
                ? EmptyData()
                : ListView.builder(
                    itemCount: itemsInsured.length,
                    itemBuilder: (BuildContext context, int index) {
                      RequestDetails item = itemsInsured[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ItemRowContainer(
                          isPolicy: item.screenShotURL != null,
                          isPolicyRenew: item.screenShotURL == null,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TitleValueRow(
                                  title: '${AppStrings.description.tr}:',
                                  value: getQuoteItemsData(item)[2],
                                ),
                                TitleValueRow(
                                  title: '${AppStrings.location.tr}:',
                                  value: getQuoteItemsData(item)[1],
                                ),
                                TitleValueRow(
                                  title: '${AppStrings.value.tr}(NGN):',
                                  value: (() {
                                    final raw = getQuoteItemsData(item)[0];
                                    // Strip non-numeric characters except dot and minus
                                    final cleaned = raw.replaceAll(
                                        RegExp(r'[^0-9\.\-]'), '');
                                    final parsed =
                                        double.tryParse(cleaned) ?? 0.0;
                                    return formatAmount(parsed);
                                  })(),
                                ),
                                // Always show something in the image area for consistent layout
                                if (item.screenShotURL != null &&
                                    item.screenShotURL!.trim().isNotEmpty)
                                  Builder(
                                    builder: (context) {
                                      try {
                                        final b64 =
                                            item.screenShotURL!.contains(',')
                                                ? item.screenShotURL!
                                                    .split(',')
                                                    .last
                                                : item.screenShotURL!;

                                        // Validate base64 first
                                        final bytes = base64Decode(b64);

                                        // Check if it's a PDF
                                        final isPdf = b64.startsWith('JVBERi0');

                                        if (isPdf) {
                                          return Container(
                                            height: 100,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.grey[300]!),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: PdfPreview(
                                                allowPrinting: false,
                                                allowSharing: false,
                                                canChangePageFormat: false,
                                                canChangeOrientation: false,
                                                canDebug: true,
                                                scrollViewDecoration:
                                                    BoxDecoration(),
                                                build: (_) async => bytes,
                                              ),
                                            ),
                                          );
                                        } else {
                                          // Display image
                                          return Image.memory(
                                            bytes,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return SizedBox(
                                                height: 100,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.error,
                                                        color: Colors.red),
                                                    SizedBox(width: 8),
                                                    Text('Invalid image'),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      } catch (e) {
                                        return SizedBox(
                                          height: 100,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.error,
                                                  color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Invalid attachment'),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  )
                                else
                                  // Placeholder for consistent layout when no image
                                  Container(
                                    height: 100,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[100],
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported_outlined,
                                            color: Colors.grey[400],
                                            size: 32,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'No attachment',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
          )
        ],
      ),
    );
  }
}
