import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/core/policy/controller/endorsement_controller.dart';
import 'package:pibro/core/policy/widget/items_insured_list.dart';
import 'package:pibro/core/policy/widget/policy_button.dart';
import 'package:pibro/internalization/app_strings.dart';
import 'package:pibro/shared/common_header.dart';
import 'package:pibro/shared/custom_input/custom_input.dart';
import 'package:pibro/utils/validators.dart';
import 'package:pibro/utils/view_utils.dart';

class EndorsementScreen extends StatelessWidget {
  const EndorsementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(EndorsementController());
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: queryBottomInset(context) + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonHeader(title: 'Endorse Policy'),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: queryWidth(context) * 0.05),
                child: Form(
                  key: c.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DetailRow(
                      //     title: '${AppStrings.policyNumber.tr}:',
                      //     value: c.policy.value!.policyBrokerID),
                      // DetailRow(
                      //     title: '${AppStrings.insuranceClass.tr}:',
                      //     value: c.policy.value!.businessClassID ?? '-'),
                      // DetailRow(
                      //     title: '${AppStrings.product.tr}:',
                      //     value: c.policy.value!.riskTypeID ?? '-'),
                      const SizedBox(height: 20),
                      CustomInput(
                        controller: c.startDateCtrl,
                        label: 'Start Date',
                        hint: '',
                        readonly: true,
                      ),
                      CustomInput(
                        controller: c.endDateCtrl,
                        label: 'Set the new end date',
                        hint: '',
                        readonly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 0)),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365 * 5)),
                            initialDate: c.endDate.value ??
                                DateTime.now().add(const Duration(days: 364)),
                          );
                          if (picked != null) c.onEndDatePicked(picked);
                        },
                        validator: (v) =>
                            Validators.requiredValidator(v, 'End date'),
                      ),
                      CustomInput(
                        controller: c.renewalDateCtrl,
                        label: 'Renewal Date',
                        hint: '',
                        readonly: true,
                      ),
                      const SizedBox(height: 18),
                      Text('Modify Item(s) to Insure',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 10),

                      // Existing + New items, editable
                      Obx(() => ItemsInsuredList(
                            list: c.policyItems.toList(),
                            edit: (it) => c.showAddOrUpdateItemSheet(
                                data: it, isNew: false),
                            view: (it) => c.previewItemAttachment(it),
                          )),
                      const SizedBox(height: 8),
                      Obx(() => ItemsInsuredList(
                            list: c.newItems.toList(),
                            edit: (it) => c.showAddOrUpdateItemSheet(
                                data: it, isNew: true),
                            delete: (it) => c.removeItem(it, isNew: true),
                            view: (it) => c.previewItemAttachment(it),
                          )),

                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => c.showAddOrUpdateItemSheet(isNew: true),
                          child: Container(
                            height: 40,
                            width: 40,
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Obx(() => PolicyButton(
                              width: 170,
                              text: c.loading.value
                                  ? 'Please wait...'
                                  : AppStrings.continueText.tr,
                              onPressed: c.loading.value
                                  ? () {}
                                  : () => c.continueEndorse(),
                              isExpanded: false,
                              bgColor: AppColors.primaryColor,
                            )),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
