import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:express_vet/value_statics.dart';
import 'package:express_vet/utils/button.dart';

import 'package:express_vet/utils/alert_dialog.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/utils/check_input.dart';
import 'package:express_vet/utils/style.dart';
import 'package:express_vet/routes/app_routes.dart';

import '../controller/self_service_controller.dart';

class SelfServiceScreen extends GetView<SelfServiceController> {
  SelfServiceScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'self_service'.tr),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'phone_number'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'sender_telephone'.tr,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller:
                          controller.uiState.value.phoneSenderController,
                      autofocus: false,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 14),
                      validator: (String? value) {
                        return CheckInput().checkLength(
                          value!,
                          9,
                          'phone_number_is_incorrect'.tr,
                          'phone_number_is_incorrect'.tr,
                        );
                      },
                      decoration: Style.inputText(
                        'phone_number'.tr,
                        iconLeft: Ionicons.call_outline,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'receiver_telephone'.tr,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller:
                          controller.uiState.value.phoneReceivedController,
                      autofocus: false,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 14),
                      validator: (String? value) {
                        return CheckInput().checkLength(
                          value!,
                          9,
                          'phone_number_is_required'.tr,
                          'phone_number_is_incorrect'.tr,
                        );
                      },
                      decoration: Style.inputText(
                        '010522522',
                        iconLeft: Ionicons.call_outline,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'destination'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'name_of_the_location'.tr,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2.4,
                            child: TextFormField(
                              onTap: () async {
                                await Get.toNamed(
                                  AppRoutes.selfServiceSelect,
                                  arguments: {'selectType': 'province'},
                                );
                                controller.syncSelectionFieldsFromValueStatic();
                              },
                              controller:
                                  controller.uiState.value.provinceController,
                              autofocus: false,
                              readOnly: true,
                              showCursor: false,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 14),
                              validator: (String? value) {
                                return CheckInput().checkLength(
                                  value!,
                                  2,
                                  'province_is_required'.tr,
                                  '',
                                );
                              },
                              decoration: Style.inputText(
                                'province_city'.tr,
                                iconRight: Ionicons.chevron_forward_outline,
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2.4,
                            child: TextFormField(
                              onTap: () async {
                                //print(ValueStatic.provinceName);
                                if (ValueStatic.provinceName == "" ||
                                    ValueStatic.provinceName.isEmpty) {
                                  alertDialogOneButton(
                                    title: 'information'.tr,
                                    description: 'please_select_province'.tr,
                                    buttonText: 'yes'.tr,
                                  );
                                } else {
                                  await Get.toNamed(
                                    AppRoutes.selfServiceSelect,
                                    arguments: {'selectType': 'location'},
                                  );

                                  controller
                                      .syncSelectionFieldsFromValueStatic();
                                }
                              },
                              controller:
                                  controller.uiState.value.locationController,
                              autofocus: false,
                              readOnly: true,
                              showCursor: false,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 14),
                              validator: (String? value) {
                                return CheckInput().checkLength(
                                  value!,
                                  2,
                                  'location_is_required'.tr,
                                  '',
                                );
                              },
                              decoration: Style.inputText(
                                'location'.tr,
                                iconRight: Ionicons.chevron_forward_outline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'items_information'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'items_price'.tr,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: controller.uiState.value.itemPriceController,
                      autofocus: false,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 14),
                      validator: (String? value) {
                        return CheckInput().checkLength(
                          value!,
                          1,
                          'items_price_is_required'.tr,
                          'phone_number_is_incorrect'.tr,
                        );
                      },
                      decoration: Style.inputText('', suffixText: '\$'),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2.4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'amount'.tr,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 5),
                                TextFormField(
                                  controller:
                                      controller.uiState.value.amountController,
                                  autofocus: false,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(fontSize: 14),
                                  validator: (String? value) {
                                    return CheckInput().checkLength(
                                      value!,
                                      1,
                                      'amount_is_required'.tr,
                                      'phone_number_is_incorrect'.tr,
                                    );
                                  },
                                  decoration: Style.inputText('amount'.tr),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2.4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'unit'.tr,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 5),
                                TextFormField(
                                  onTap: () async {
                                    await Get.toNamed(
                                      AppRoutes.selfServiceSelect,
                                      arguments: {'selectType': 'uom'},
                                    );

                                    controller
                                        .syncSelectionFieldsFromValueStatic();
                                  },
                                  controller:
                                      controller.uiState.value.unitController,
                                  autofocus: false,
                                  readOnly: true,
                                  showCursor: false,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(fontSize: 14),
                                  validator: (String? value) {
                                    return CheckInput().checkLength(
                                      value!,
                                      1,
                                      'unit_is_required'.tr,
                                      '',
                                    );
                                  },
                                  decoration: Style.inputText(
                                    'unit'.tr,
                                    iconRight: Ionicons.chevron_forward_outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          color: AppColors.whiteColor,
          width: double.infinity,
          child: globalButton(
            context: context,
            buttonText: 'save'.tr,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Get.toNamed(
                  AppRoutes.selfServiceCheck,
                  arguments: {
                    'senderPhone':
                        controller.uiState.value.phoneSenderController.text,
                    'receiverPhone':
                        controller.uiState.value.phoneReceivedController.text,
                    'itemPrice':
                        controller.uiState.value.itemPriceController.text,
                    'amount': controller.uiState.value.amountController.text,
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
