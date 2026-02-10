import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:express_vet/activities/logistic/select_screen.dart';
import 'package:express_vet/activities/logistic/self_service_check_screen.dart';
import 'package:express_vet/activities/ticket/value_statics.dart';
import 'package:express_vet/utils/button.dart';

import '../../utils/alert_dialog.dart';
import '../../utils/app_bar.dart';
import '../../utils/app_colors.dart';
import '../../utils/check_input.dart';
import '../../utils/style.dart';

class SelfServiceScreen extends StatefulWidget {
  const SelfServiceScreen({super.key});

  @override
  State<SelfServiceScreen> createState() => _SelfServiceScreenState();
}

class _SelfServiceScreenState extends State<SelfServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final phoneSenderController = TextEditingController();
  final phoneReceivedController = TextEditingController();
  final provinceController = TextEditingController();
  final locationController = TextEditingController();
  final itemPriceController = TextEditingController();
  final amountController = TextEditingController();
  final unitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    phoneSenderController.text = ValueStatic.phone;
    amountController.text = "1";
  }

  @override
  void dispose() {
    provinceController.dispose();
    locationController.dispose();

    super.dispose();
  }

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
                    Text('sender_telephone'.tr, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: phoneSenderController,
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
                    Text('receiver_telephone'.tr, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: phoneReceivedController,
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
                      decoration: Style.inputText('010522522', iconLeft: Ionicons.call_outline),
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
                    Text('name_of_the_location'.tr, style: const TextStyle(color: Colors.grey)),
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
                                await Get.to(
                                  () => const SelectLogisticScreen(selectType: "province"),
                                  transition: Transition.rightToLeft,
                                  duration: const Duration(milliseconds: 350),
                                );
                                setState(() {});
                              },
                              controller: provinceController..text = ValueStatic.provinceName,
                              autofocus: false,
                              readOnly: true,
                              showCursor: false,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                  await Get.to(
                                    () => const SelectLogisticScreen(selectType: "location"),
                                    transition: Transition.rightToLeft,
                                    duration: const Duration(milliseconds: 350),
                                  );

                                  setState(() {});
                                }
                              },
                              controller: locationController..text = ValueStatic.locationName,
                              autofocus: false,
                              readOnly: true,
                              showCursor: false,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    Text('items_price'.tr, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: itemPriceController,
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
                        crossAxisAlignment: CrossAxisAlignment.baseline, // <--
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2.4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('amount'.tr, style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 5),
                                TextFormField(
                                  controller: amountController,
                                  autofocus: false,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                Text('unit'.tr, style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 5),
                                TextFormField(
                                  onTap: () async {
                                    await Get.to(
                                      () => const SelectLogisticScreen(selectType: "uom"),
                                      transition: Transition.rightToLeft,
                                      duration: const Duration(milliseconds: 350),
                                    );

                                    setState(() {});
                                  },
                                  controller: unitController..text = ValueStatic.uomName,
                                  autofocus: false,
                                  readOnly: true,
                                  showCursor: false,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        color: AppColors.whiteColor,
        width: double.infinity,
        child: globalButton(
          context: context,
          buttonText: 'save'.tr,
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Get.to(
                () => SelfServiceCheckScreen(
                  senderPhone: phoneSenderController.text,
                  receiverPhone: phoneReceivedController.text,
                  itemPrice: itemPriceController.text,
                  amount: amountController.text,
                ),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 350),
              );
            }
          },
        ),
      ),
    );
  }
}
