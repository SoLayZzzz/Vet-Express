import 'package:express_vet/components/input_text_field.dart';
import 'package:express_vet/utils/platform_insets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:express_vet/value_statics.dart';
import 'package:express_vet/utils/button.dart';
import 'package:express_vet/utils/alert_dialog.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/utils/check_input.dart';
import 'package:express_vet/routes/app_routes.dart';
import '../controller/self_service_controller.dart';

class SelfServiceScreen extends GetView<SelfServiceController> {
  SelfServiceScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final useSafeArea = PlatformInsets.useSafeArea;
    final iosBottomInset = PlatformInsets.iosBottomInset();
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
                    const SizedBox(height: 10),
                    InputTextField(
                      label: 'sender_telephone'.tr,
                      
                      hint: 'phone_number'.tr,
                      controller:
                          controller.uiState.value.phoneSenderController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [PhoneNumberFormatter()],
                      iconLeft: Ionicons.call_outline,
                      validator: (String? value) {
                        return CheckInput().checkLength(
                          (value ?? '').replaceAll(' ', ''),
                          9,
                          'phone_number_is_incorrect'.tr,
                          'phone_number_is_incorrect'.tr,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    InputTextField(
                      label: 'receiver_telephone'.tr,
                      hint: 'phone_number'.tr,
                      controller:
                          controller.uiState.value.phoneReceivedController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [PhoneNumberFormatter()],
                      iconLeft: Ionicons.call_outline,
                      validator: (String? value) {
                        return CheckInput().checkLength(
                          (value ?? '').replaceAll(' ', ''),
                          9,
                          'phone_number_is_required'.tr,
                          'phone_number_is_incorrect'.tr,
                        );
                      },
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
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'name_of_the_location'.tr,
                            style: TextStyle(color: AppColors.mainTitle),
                          ),
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(color: AppColors.redColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
       child: InputTextField(
                              hint: '${'province_city'.tr} ',
                              controller:
                                  controller.uiState.value.provinceController,
                              readOnly: true,
                              showCursor: false,
                              keyboardType: TextInputType.phone,
                              iconRight: Ionicons.chevron_forward_outline,
                              iconRightSize: 16,  
                              iconRightColor: AppColors.placeholderColor,
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                await Get.toNamed(
                                  AppRoutes.selfServiceSelect,
                                  arguments: {'selectType': 'province'},
                                );
                                controller.syncSelectionFieldsFromValueStatic();
                                _formKey.currentState?.validate();
                              },
                              validator: (String? value) {
                                return CheckInput().checkLength(
                                  value!,
                                  2,
                                  'province_is_required'.tr,
                                  '',
                                );
                              },
                            ),
    ),

    const SizedBox(width: 15),

    Expanded(
      child: InputTextField(
                              hint: '${'location'.tr} ',
                              controller:
                                  controller.uiState.value.locationController,
                              readOnly: true,
                              showCursor: false,
                              keyboardType: TextInputType.phone,
                              // iconRight: Ionicons.chevron_forward_outline,
                               iconRight: Ionicons.chevron_forward_outline,
                              iconRightSize: 16,  
                              iconRightColor: AppColors.placeholderColor,
                              onTap: () async {
                                FocusScope.of(context).unfocus();
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
                                  _formKey.currentState?.validate();
                                }
                              },
                              validator: (String? value) {
                                return CheckInput().checkLength(
                                  value!,
                                  2,
                                  'location_is_required'.tr,
                                  '',
                                );
                              },
                            ),
    ),
  ],
),
                    // SizedBox(
                    //   child: Row(
                    //     // crossAxisAlignment: CrossAxisAlignment.start,
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       SizedBox(
                    //         width: MediaQuery.of(context).size.width / 2.3,
                    //         child: InputTextField(
                    //           hint: '${'province_city'.tr} ',
                    //           controller:
                    //               controller.uiState.value.provinceController,
                    //           readOnly: true,
                    //           showCursor: false,
                    //           keyboardType: TextInputType.phone,
                    //           iconRight: Ionicons.chevron_forward_outline,
                    //           iconRightColor: AppColors.placeholderColor,
                    //           onTap: () async {
                    //             FocusScope.of(context).unfocus();
                    //             await Get.toNamed(
                    //               AppRoutes.selfServiceSelect,
                    //               arguments: {'selectType': 'province'},
                    //             );
                    //             controller.syncSelectionFieldsFromValueStatic();
                    //             _formKey.currentState?.validate();
                    //           },
                    //           validator: (String? value) {
                    //             return CheckInput().checkLength(
                    //               value!,
                    //               2,
                    //               'province_is_required'.tr,
                    //               '',
                    //             );
                    //           },
                    //         ),
                    //       ),
                    //       // const Spacer(),
                    //       SizedBox(
                    //         width: MediaQuery.of(context).size.width / 2.3,
                    //         child: InputTextField(
                    //           hint: '${'location'.tr} ',
                    //           controller:
                    //               controller.uiState.value.locationController,
                    //           readOnly: true,
                    //           showCursor: false,
                    //           keyboardType: TextInputType.phone,
                    //           iconRight: Ionicons.chevron_forward_outline,
                    //           onTap: () async {
                    //             FocusScope.of(context).unfocus();
                    //             if (ValueStatic.provinceName == "" ||
                    //                 ValueStatic.provinceName.isEmpty) {
                    //               alertDialogOneButton(
                    //                 title: 'information'.tr,
                    //                 description: 'please_select_province'.tr,
                    //                 buttonText: 'yes'.tr,
                    //               );
                    //             } else {
                    //               await Get.toNamed(
                    //                 AppRoutes.selfServiceSelect,
                    //                 arguments: {'selectType': 'location'},
                    //               );

                    //               controller
                    //                   .syncSelectionFieldsFromValueStatic();
                    //               _formKey.currentState?.validate();
                    //             }
                    //           },
                    //           validator: (String? value) {
                    //             return CheckInput().checkLength(
                    //               value!,
                    //               2,
                    //               'location_is_required'.tr,
                    //               '',
                    //             );
                    //           },
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(height: 20),
                    Text(
                      'items_information'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InputTextField(
                      label: 'items_price'.tr,
                      controller: controller.uiState.value.itemPriceController,
                      keyboardType: TextInputType.phone,
                      suffixText: '\$',
                      validator: (String? value) {
                        return CheckInput().checkLength(
                          value!,
                          1,
                          'items_price_is_required'.tr,
                          'phone_number_is_incorrect'.tr,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    //
                    Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: InputTextField(
                              label: 'amount'.tr,
                              hint: 'amount'.tr,
                              controller:
                                  controller.uiState.value.amountController,
                              keyboardType: TextInputType.phone,
                              iconRight: Ionicons.chevron_forward_outline,
                              iconRightColor: Colors.transparent,
                              validator: (String? value) {
                                return CheckInput().checkLength(
                                  value!,
                                  1,
                                  'amount_is_required'.tr,
                                  'phone_number_is_incorrect'.tr,
                                );
                              },
                            ),
    ),

    const SizedBox(width: 15),

    Expanded(
     child: InputTextField(
                              label: 'unit'.tr,
                              hint: 'unit'.tr,
                              controller:
                                  controller.uiState.value.unitController,
                              readOnly: true,
                              showCursor: false,
                              keyboardType: TextInputType.phone,
                              // iconRight: Ionicons.chevron_forward_outline,
                               iconRight: Ionicons.chevron_forward_outline,
                              iconRightSize: 16,  
                              iconRightColor: AppColors.placeholderColor,
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                await Get.toNamed(
                                  AppRoutes.selfServiceSelect,
                                  arguments: {'selectType': 'uom'},
                                );

                                controller
                                    .syncSelectionFieldsFromValueStatic();
                                _formKey.currentState?.validate();
                              },
                              validator: (String? value) {
                                return CheckInput().checkLength(
                                  value!,
                                  1,
                                  'unit_is_required'.tr,
                                  '',
                                );
                              },
                            ),
    ),
  ],
),
                    // SizedBox(
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       SizedBox(
                    //         width: MediaQuery.of(context).size.width / 2.4,
                    //         child: InputTextField(
                    //           label: 'amount'.tr,
                    //           hint: 'amount'.tr,
                    //           controller:
                    //               controller.uiState.value.amountController,
                    //           keyboardType: TextInputType.phone,
                    //           iconRight: Ionicons.chevron_forward_outline,
                    //           iconRightColor: Colors.transparent,
                    //           validator: (String? value) {
                    //             return CheckInput().checkLength(
                    //               value!,
                    //               1,
                    //               'amount_is_required'.tr,
                    //               'phone_number_is_incorrect'.tr,
                    //             );
                    //           },
                    //         ),
                    //       ),
                    //       const Spacer(),
                    //       SizedBox(
                    //         width: MediaQuery.of(context).size.width / 2.4,
                    //         child: InputTextField(
                    //           label: 'unit'.tr,
                    //           hint: 'unit'.tr,
                    //           controller:
                    //               controller.uiState.value.unitController,
                    //           readOnly: true,
                    //           showCursor: false,
                    //           keyboardType: TextInputType.phone,
                    //           iconRight: Ionicons.chevron_forward_outline,
                    //           onTap: () async {
                    //             FocusScope.of(context).unfocus();
                    //             await Get.toNamed(
                    //               AppRoutes.selfServiceSelect,
                    //               arguments: {'selectType': 'uom'},
                    //             );

                    //             controller
                    //                 .syncSelectionFieldsFromValueStatic();
                    //             _formKey.currentState?.validate();
                    //           },
                    //           validator: (String? value) {
                    //             return CheckInput().checkLength(
                    //               value!,
                    //               1,
                    //               'unit_is_required'.tr,
                    //               '',
                    //             );
                    //           },
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: useSafeArea,
        bottom: useSafeArea,
        left: useSafeArea,
        right: useSafeArea,
        child: Container(
          // padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
           padding: EdgeInsets.fromLTRB(
                      15,
                      10,
                      15,
                      10 + iosBottomInset,
                    ),
          color: AppColors.whiteColor,
          width: double.infinity,
          child: globalButton(
            context: context,
            buttonText: 'save'.tr,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Get.toNamed(
                  AppRoutes.selfServiceCheck,
                  arguments: {
                    'senderPhone': controller
                        .uiState
                        .value
                        .phoneSenderController
                        .text
                        .replaceAll(' ', ''),
                    'receiverPhone': controller
                        .uiState
                        .value
                        .phoneReceivedController
                        .text
                        .replaceAll(' ', ''),
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
