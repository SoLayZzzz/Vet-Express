// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../activities/ticket/value_statics.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/app_bar.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/button.dart';
import '../../../../../utils/check_input.dart';
import '../../../../../utils/style.dart';
import '../../data/model/request/car_rental_add_request_body.dart';
import '../controller/car_rental_controller.dart';

class RentalCarInfoScreen extends StatefulWidget {
  static String busId = '';
  static String carType = '';

  const RentalCarInfoScreen({super.key});

  @override
  State<RentalCarInfoScreen> createState() => _RentalCarInfoScreenState();
}

class _RentalCarInfoScreenState extends State<RentalCarInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final desFromController = TextEditingController();
  final desToController = TextEditingController();
  final goDateController = TextEditingController();
  final backDateController = TextEditingController();
  final amountController = TextEditingController();
  final remarkController = TextEditingController();

  int selected = 1;

  String goDate = '';
  String backDate = 'select_date'.tr;

  late final CarRentalController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.find<CarRentalController>();

    nameController.text = ValueStatic.username;
    phoneController.text = ValueStatic.phone;

    setNow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'rental_information'.tr),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '${'car_type'.tr} : ${RentalCarInfoScreen.carType}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('booking_name'.tr),
                          const Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: TextFormField(
                              controller: nameController,
                              autofocus: false,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.text,
                              style: const TextStyle(fontSize: 14),
                              validator: (String? value) {
                                return CheckInput().checkLength(
                                  value!,
                                  3,
                                  'name_is_required'.tr,
                                  'name_at_least_3'.tr,
                                );
                              },
                              decoration: Style.inputText('name'.tr),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('telephone_num'.tr),
                          const Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: TextFormField(
                              controller: phoneController,
                              autofocus: false,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                              decoration: Style.inputText('phone'.tr),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'journey_type'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Radio(
                            value: 1,
                            groupValue: selected,
                            fillColor: WidgetStateColor.resolveWith(
                              (states) => AppColors.primaryColor,
                            ),
                            onChanged: (value) {
                              selected = 1;
                              setState(() {});
                            },
                          ),
                          Text('one_way_rental'.tr),
                          const Spacer(),
                          Radio(
                            value: 2,
                            groupValue: selected,
                            fillColor: WidgetStateColor.resolveWith(
                              (states) => AppColors.primaryColor,
                            ),
                            onChanged: (value) {
                              selected = 2;
                              setState(() {});
                            },
                          ),
                          Text('round_trip_rental'.tr),
                          const Spacer(),
                          Radio(
                            value: 3,
                            groupValue: selected,
                            fillColor: WidgetStateColor.resolveWith(
                              (states) => AppColors.primaryColor,
                            ),
                            onChanged: (value) {
                              selected = 3;
                              setState(() {});
                            },
                          ),
                          Text('trip'.tr),
                          const SizedBox(width: 20),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'destination'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextFormField(
                              controller:
                                  desFromController
                                    ..text = ValueStatic.provinceRentalFromName,
                              autofocus: false,
                              readOnly: true,
                              showCursor: false,
                              maxLines: null,
                              onTap: () async {
                                await Get.toNamed(
                                  AppRoutes.carRentalSelectProvince,
                                  arguments: const {'selectType': 'From'},
                                );
                                setState(() {});
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 14),
                              validator: (String? value) {
                                return CheckInput().checkLength(
                                  value!,
                                  1,
                                  'location_is_required'.tr,
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
                          Text('to_rental'.tr),
                          const Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextFormField(
                              controller:
                                  desToController
                                    ..text = ValueStatic.provinceRentalToName,
                              autofocus: false,
                              readOnly: true,
                              showCursor: false,
                              maxLines: null,
                              onTap: () async {
                                await Get.toNamed(
                                  AppRoutes.carRentalSelectProvince,
                                  arguments: const {'selectType': 'To'},
                                );
                                setState(() {});
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 14),
                              validator: (String? value) {
                                return CheckInput().checkLength(
                                  value!,
                                  1,
                                  'location_is_required'.tr,
                                  '',
                                );
                              },
                              decoration: Style.inputText(
                                'province_city'.tr,
                                iconRight: Ionicons.chevron_forward_outline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'date_rental'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextFormField(
                              onTap: () async {
                                backDate = 'select_date'.tr;

                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  locale:
                                      Get.locale.toString() == 'km_KH'
                                          ? const Locale('km', 'KH')
                                          : Get.locale.toString() == 'en_US'
                                          ? const Locale('en', 'US')
                                          : const Locale('zh', 'CN'),
                                  initialDate: DateFormat(
                                    'yyyy-MM-dd',
                                  ).parse(goDate),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 90),
                                  ),
                                );

                                if (pickedDate != null) {
                                  final DateFormat formatter = DateFormat(
                                    'yyyy-MM-dd',
                                  );
                                  goDate = formatter.format(pickedDate);
                                  setState(() {});
                                }
                              },
                              controller: goDateController..text = goDate,
                              autofocus: false,
                              readOnly: true,
                              showCursor: false,
                              maxLines: null,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 14),
                              validator: (String? value) {
                                return CheckInput().checkLength(
                                  value!,
                                  1,
                                  'required'.tr,
                                  '',
                                );
                              },
                              decoration: Style.inputText(
                                goDate,
                                iconRight: Ionicons.chevron_forward_outline,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text('until'.tr),
                          const Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextFormField(
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  locale:
                                      Get.locale.toString() == 'km_KH'
                                          ? const Locale('km', 'KH')
                                          : Get.locale.toString() == 'en_US'
                                          ? const Locale('en', 'US')
                                          : const Locale('zh', 'CN'),
                                  initialDate: DateFormat(
                                    'yyyy-MM-dd',
                                  ).parse(goDate).add(const Duration(days: 0)),
                                  firstDate: DateFormat(
                                    'yyyy-MM-dd',
                                  ).parse(goDate).add(const Duration(days: 0)),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 90),
                                  ),
                                );

                                if (pickedDate != null) {
                                  final DateFormat formatter = DateFormat(
                                    'yyyy-MM-dd',
                                  );
                                  backDate = formatter.format(pickedDate);
                                  setState(() {});
                                }
                              },
                              controller: backDateController..text = backDate,
                              autofocus: false,
                              readOnly: true,
                              showCursor: false,
                              maxLines: null,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 14),
                              validator: (String? value) {
                                return CheckInput().checkLength(
                                  value!,
                                  1,
                                  'required'.tr,
                                  '',
                                );
                              },
                              decoration: Style.inputText(
                                '',
                                iconRight: Ionicons.chevron_forward_outline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'amount_of_car'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
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
                            '',
                          );
                        },
                        decoration: Style.inputText('amount'.tr),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'remark_optional'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.borderColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        height: 150,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: remarkController,
                            autofocus: false,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.fromLTRB(
                                10,
                                10,
                                10,
                                20,
                              ),
                              hintText: 'remark'.tr,
                              hintMaxLines: 6,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  color: AppColors.whiteColor,
                  width: double.infinity,
                  child: globalButton(
                    context: context,
                    buttonText: 'save'.tr,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (goDate != '' &&
                            backDate != 'select_date'.tr &&
                            ValueStatic.provinceRentalFromName != '' &&
                            ValueStatic.provinceRentalToName != '') {
                          final body = CarRentalAddRequestBody(
                            busTypeId: RentalCarInfoScreen.busId,
                            dateFrom: goDate,
                            dateTo: backDate,
                            name: nameController.text,
                            numberBus: amountController.text,
                            provinceFrom: ValueStatic.provinceRentalFromId,
                            provinceTo: ValueStatic.provinceRentalToId,
                            telephone: phoneController.text,
                            travelType: selected.toString(),
                            note: remarkController.text,
                          );

                          controller.saveRental(
                            context: context,
                            body: body,
                            successDetails: [
                              {'name'.tr: nameController.text},
                              {'phone'.tr: phoneController.text},
                              {'from'.tr: ValueStatic.provinceRentalFromId},
                              {'to'.tr: ValueStatic.provinceRentalToId},
                              {'departure_date'.tr: goDate},
                              {'return_date'.tr: backDate},
                              {'car_type'.tr: RentalCarInfoScreen.carType},
                              {'amount_of_car'.tr: amountController.text},
                            ],
                          );
                        } else {
                          alertDialogOneButton(
                            title: 'information'.tr,
                            description: 'plz_fill'.tr,
                            buttonText: 'yes'.tr,
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setNow() {
    DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    goDate = formatter.format(now);
  }
}
