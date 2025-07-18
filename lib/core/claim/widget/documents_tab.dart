import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/core/claim/controller/lodge_claim_controller.dart';
import 'package:pibro/core/claim/widget/document_container.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/network/models/response/claim_document_response.dart';
import 'package:pibro/utils/app_utils.dart';
import 'package:pibro/utils/view_utils.dart';

class DocumentsTab extends StatelessWidget {
  const DocumentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final LodgeClaimController controller = Get.put(LodgeClaimController());
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.uploadClaimDocuments.tr,
            style: Styles.mediumTextStyle(),
          ),
          SizedBox(
            height: 10,
          ),
          Obx(
            () => controller.claimDocuments.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        AppStrings.noData.tr,
                        style: Styles.mediumTextStyle(size: 18),
                      ),
                    ),
                  )
                : SizedBox(
                    height: controller.claimDocuments.length * 124,
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: controller.claimDocuments.length,
                        itemBuilder: (context, index) {
                          final ClaimDocument claimDocument =
                              controller.claimDocuments[index];
                          return Container(
                            height: 110,
                            width: queryWidth(context),
                            margin: EdgeInsets.symmetric(
                              vertical: 7,
                              horizontal: 0,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 5,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.tileColor,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(
                                  AppConstants.snackBarRadius),
                            ),
                            child: DocumentContainer(
                              onTap: () => controller.showUploadSheet(
                                  claimDocument.documentName!, index),
                              title: claimDocument.documentName ?? '',
                              date: claimDocument.dateSubmited == null
                                  ? '--/--/--'
                                  : formatClaimDate(
                                      claimDocument.dateSubmited!),
                              document: claimDocument.claimsDocument,
                              status: claimDocument.docStatus!,
                              preview: claimDocument.claimsDocument != null
                                  ? () => controller.previewImage(
                                      claimDocument.documentName!,
                                      claimDocument.claimsDocument!)
                                  : null,
                            ),
                          );
                        }),
                  ),
          ),
        ],
      ),
    );
  }
}
