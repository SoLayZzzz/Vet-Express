import 'package:date_format_field/date_format_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:express_vet/value_statics.dart';
import 'package:express_vet/utils/alert_dialog.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/button.dart';
import '../controller/passenger_deatail_controller.dart';
import '../../../../../api/travel_package.dart';
import '../../../../auth/data/model/response/nationality_response.dart';
import '../../../../../models/boarding_point.dart' as boarding;
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/contains.dart';
import '../../../../../utils/style.dart';
import 'coupon_screen.dart';
import '../../../../../base/web_view_screen.dart';

class PassengerDetailScreen extends GetView<PassengerDetailController> {
  PassengerDetailScreen({super.key});
  final FocusNode inputFocusNode = FocusNode();

  void _callGetData(BuildContext context, {required bool isConfirm}) {
    controller.getData(
      context: context,
      isConfirm: isConfirm,
      luckyDraw: controller.luckyDraw,
      genderOneWay: controller.genderOneWay,
      nationalOneWay: controller.nationalOneWay,
      genderTwoWay: controller.genderTwoWay,
      nationalTwoWay: controller.nationalTwoWay,
      dobOneWayControllers: controller.dobOneWay,
      dobTwoWayControllers: controller.dobTwoWay,
      passportOneWayControllers: controller.passportOneWay,
      passportTwoWayControllers: controller.passportTwoWay,
      nameOneWayControllers: controller.nameOneWay,
      nameTwoWayControllers: controller.nameTwoWay,
      packageCode: controller.codeController.text,
      couponCode: controller.couponController.text,
      isLoaded: controller.isLoaded,
      markLoaded: () {
        controller.isLoaded = true;
      },
    );
  }

  Widget _seatDivider() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Image.asset("assets/images/img_line.png"),
    );
  }

  Future<void> _showPointSelectionDialog({
    required BuildContext context,
    required String dialogTitle,
    required List<boarding.Body> items,
    required int selectedIndex,
    required ValueChanged<int> onSelectedIndexChanged,
    required ValueChanged<String> onSelectedNameChanged,
    required ValueChanged<String> onSelectedAddressChanged,
    required VoidCallback onClearSelection,
    required ValueChanged<boarding.Body> onValueStaticSelected,
    bool Function(boarding.Body item)? isDisabled,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(dialogContext).size.width,
              child: Material(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      child: Text(
                        dialogTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = items[index];
                            final disabled = isDisabled?.call(item) ?? false;
                            return CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              value: selectedIndex == index,
                              activeColor: Colors.transparent,
                              checkColor: Colors.green,
                              title: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xffC6C6C6),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${item.name}",
                                      style: const TextStyle(
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text("${item.address}"),
                                  ],
                                ),
                              ),
                              onChanged:
                                  disabled
                                      ? null
                                      : (bool? value) {
                                        if (value ?? false) {
                                          onSelectedIndexChanged(index);
                                          onSelectedNameChanged(
                                            item.name ?? '',
                                          );
                                          onSelectedAddressChanged(
                                            item.address ?? '',
                                          );
                                          onValueStaticSelected(item);
                                        } else {
                                          onClearSelection();
                                        }
                                        controller.update();
                                        Navigator.pop(dialogContext);
                                      },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _pointPicker({
    required BuildContext context,
    required InputDecoration decoration,
    required String dialogTitle,
    required List<boarding.Body> items,
    required int selectedIndex,
    required ValueChanged<int> onSelectedIndexChanged,
    required String selectedName,
    required ValueChanged<String> onSelectedNameChanged,
    required String selectedAddress,
    required ValueChanged<String> onSelectedAddressChanged,
    required String defaultName,
    required VoidCallback onClearSelection,
    required ValueChanged<boarding.Body> onValueStaticSelected,
    bool Function(boarding.Body item)? isDisabled,
  }) {
    return InputDecorator(
      decoration: decoration,
      child:
          (items.length != 1)
              ? InkWell(
                onTap: () {
                  _showPointSelectionDialog(
                    context: context,
                    dialogTitle: dialogTitle,
                    items: items,
                    selectedIndex: selectedIndex,
                    onSelectedIndexChanged: onSelectedIndexChanged,
                    onSelectedNameChanged: onSelectedNameChanged,
                    onSelectedAddressChanged: onSelectedAddressChanged,
                    onClearSelection: onClearSelection,
                    onValueStaticSelected: onValueStaticSelected,
                    isDisabled: isDisabled,
                  );
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textColor,
                            ),
                          ),
                          if (selectedName != defaultName)
                            const SizedBox(height: 8),
                          if (selectedName != defaultName)
                            Text(
                              selectedAddress,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: AppColors.textColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.borderColor,
                    ),
                  ],
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${(items[0].name)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${items[0].address}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _travelInformationSection({
    required BuildContext context,
    required List<dynamic> selectedSeats,
    required int companyType,
    required List<TextEditingController> nameControllers,
    required List<String> gender,
    required List<int?> nationalityIds,
    required List<int> national,
    required List<TextEditingController> dobDisplayControllers,
    required List<TextEditingController> dobValueControllers,
    required List<TextEditingController> passportControllers,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      color: AppColors.whiteColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'information_of_travel'.tr,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.titleColor,
            ),
          ),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: selectedSeats.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      '${'seat_number'.tr} ${(selectedSeats[index]).toString()}',
                      style: const TextStyle(color: AppColors.textColor),
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (companyType == 4)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'name_pro'.tr,
                                  style: const TextStyle(
                                    color: AppColors.textColor,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: AppColors.redColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: nameControllers[index],
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 15,
                              ),
                              hintText: 'name_pro'.tr,
                              enabledBorder: Style.outlineInputBorder(),
                              focusedBorder: Style.outlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (companyType == 4) const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'gender'.tr,
                                style: const TextStyle(
                                  color: AppColors.textColor,
                                ),
                              ),
                              const TextSpan(
                                text: ' *',
                                style: TextStyle(color: AppColors.redColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                gender.removeAt(index);
                                gender.insert(index, '1');
                                controller.update();
                              },
                              child: Container(
                                height: 45,
                                width: MediaQuery.of(context).size.width / 3.5,
                                decoration:
                                    gender[index] == "1"
                                        ? BoxDecoration(
                                          color:
                                              ValueStatic.ticketType == '3'
                                                  ? AppColors.airBusColor
                                                  : AppColors.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        )
                                        : BoxDecoration(
                                          color: AppColors.whiteColor,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            color: AppColors.borderColor,
                                          ),
                                        ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Ionicons.male_outline,
                                        color:
                                            gender[index] == "1"
                                                ? AppColors.whiteColor
                                                : AppColors.textColor,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'male'.tr,
                                        style: TextStyle(
                                          color:
                                              gender[index] == "1"
                                                  ? AppColors.whiteColor
                                                  : AppColors.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                gender.removeAt(index);
                                gender.insert(index, '2');
                                controller.update();
                              },
                              child: Container(
                                height: 45,
                                width: MediaQuery.of(context).size.width / 3.5,
                                decoration:
                                    gender[index] == "2"
                                        ? BoxDecoration(
                                          color:
                                              ValueStatic.ticketType == '3'
                                                  ? AppColors.airBusColor
                                                  : AppColors.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        )
                                        : BoxDecoration(
                                          color: AppColors.whiteColor,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            color: AppColors.borderColor,
                                          ),
                                        ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Ionicons.female_outline,
                                        color:
                                            gender[index] == "2"
                                                ? AppColors.whiteColor
                                                : AppColors.textColor,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'female'.tr,
                                        style: TextStyle(
                                          color:
                                              gender[index] == "2"
                                                  ? AppColors.whiteColor
                                                  : AppColors.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'nationality'.tr,
                                style: const TextStyle(
                                  color: AppColors.textColor,
                                ),
                              ),
                              const TextSpan(
                                text: ' *',
                                style: TextStyle(color: AppColors.redColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: FutureBuilder<NationalityResponse>(
                          future: controller.futureNationality,
                          builder: (context, data) {
                            if (data.hasData) {
                              if ((data.data?.header?.result) == true &&
                                  (data.data?.header?.statusCode) == 200) {
                                if ((data.data?.body)!.status == true &&
                                    (data.data?.body)!.data!.isNotEmpty) {
                                  return Column(
                                    children: [
                                      InputDecorator(
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                          border: Style.outlineInputBorder(),
                                          enabledBorder:
                                              Style.outlineInputBorder(),
                                          focusedBorder:
                                              Style.outlineInputBorder(),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton2<String>(
                                            iconStyleData: const IconStyleData(
                                              iconEnabledColor:
                                                  AppColors.borderColor,
                                            ),
                                            isExpanded: true,
                                            hint: Text(
                                              'select_nation'.tr,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            items:
                                                data.data?.body!.data
                                                    ?.map(
                                                      (
                                                        item,
                                                      ) => DropdownMenuItem<
                                                        String
                                                      >(
                                                        value: item.name,
                                                        child: Text(
                                                          "${item.name}",
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                            value:
                                                nationalityIds[index] != null
                                                    ? data.data?.body!.data
                                                        ?.firstWhere(
                                                          (item) =>
                                                              item.id ==
                                                              nationalityIds[index],
                                                        )
                                                        .name
                                                    : null,
                                            onChanged: (value) {
                                              nationalityIds[index] =
                                                  data.data?.body!.data
                                                      ?.firstWhere(
                                                        (item) =>
                                                            item.name == value,
                                                      )
                                                      .id;
                                              national[index] =
                                                  nationalityIds[index]!;
                                              controller.update();
                                            },
                                            dropdownStyleData:
                                                const DropdownStyleData(
                                                  width: double.infinity,
                                                ),
                                            menuItemStyleData:
                                                const MenuItemStyleData(
                                                  height: 40,
                                                ),
                                            dropdownSearchData: DropdownSearchData(
                                              searchController:
                                                  controller
                                                      .nationalityController,
                                              searchInnerWidgetHeight: 50,
                                              searchInnerWidget: Container(
                                                height: 60,
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                  bottom: 4,
                                                  right: 8,
                                                  left: 8,
                                                ),
                                                child: TextFormField(
                                                  expands: true,
                                                  maxLines: null,
                                                  controller:
                                                      controller
                                                          .nationalityController,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 8,
                                                        ),
                                                    hintText:
                                                        'search_nation'.tr,
                                                    hintStyle: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                    border:
                                                        Style.outlineInputBorder(),
                                                    enabledBorder:
                                                        Style.outlineInputBorder(),
                                                    focusedBorder:
                                                        Style.outlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                              searchMatchFn: (
                                                item,
                                                searchValue,
                                              ) {
                                                return item.value
                                                    .toString()
                                                    .toLowerCase()
                                                    .contains(
                                                      searchValue.toLowerCase(),
                                                    );
                                              },
                                            ),
                                            onMenuStateChange: (isOpen) {
                                              if (!isOpen) {
                                                controller.nationalityController
                                                    .clear();
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              }
                            } else if (data.hasError) {
                              return const Text('');
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (companyType == 4)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'dob'.tr,
                                  style: const TextStyle(
                                    color: AppColors.textColor,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: AppColors.redColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: DateFormatField(
                            controller: dobDisplayControllers[index],
                            addCalendar: false,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 15,
                              ),
                              hintText: 'dd-MM-yyyy',
                              enabledBorder: Style.outlineInputBorder(),
                              focusedBorder: Style.outlineInputBorder(),
                            ),
                            initialDate: DateFormat(
                              'yyyy-MM-dd',
                            ).parse(DateTime.now().toString()),
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 50000),
                            ),
                            lastDate: DateTime.now(),
                            type: DateFormatType.type4,
                            onComplete: (date) {
                              if (date != null) {
                                if (date.isAfter(DateTime.now())) {
                                  dobDisplayControllers[index].text = '';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please input a date not greater than today.',
                                      ),
                                    ),
                                  );
                                } else {
                                  dobDisplayControllers[index].text =
                                      DateFormat('dd-MM-yyyy').format(date);
                                  dobValueControllers[index].text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(date);
                                  controller.update();
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  if (companyType == 4) const SizedBox(height: 15),
                  if (companyType == 4)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'passport'.tr,
                                  style: const TextStyle(
                                    color: AppColors.textColor,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: AppColors.redColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: passportControllers[index],
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 15,
                              ),
                              hintText: 'Passport number',
                              enabledBorder: Style.outlineInputBorder(),
                              focusedBorder: Style.outlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (companyType == 4) const SizedBox(height: 20),
                ],
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return _seatDivider();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.initialLoadFuture ??= controller
        .initPassengerDetail(context)
        .then((res) {
          controller.phoneNumberController.text = ValueStatic.phone;
          controller.usernameController.text = ValueStatic.username;
          controller.emailController.text = ValueStatic.email;

          controller.createGenderListOneWay(controller.genderOneWay);
          controller.createNationalListOneWay(controller.nationalOneWay);
          controller.createGenderListTwoWay(controller.genderTwoWay);
          controller.createNationalListTwoWay(controller.nationalTwoWay);
          controller.createDobOneWay(controller.dobOneWay);
          controller.createDobOneWayList(controller.dobOneWayList);
          controller.createPassportOneWay(controller.passportOneWay);
          controller.createNameOneWay(controller.nameOneWay);
          controller.createDobTwoWay(controller.dobTwoWay);
          controller.createDobTwoWayList(controller.dobTwoWayList);
          controller.createPassportTwoWay(controller.passportTwoWay);
          controller.createNameTwoWay(controller.nameTwoWay);

          controller.boardingListOneway(controller.boardingPointOneway);
          controller.dropOffListOneway(controller.dropOffPointOneway);
          controller.boardingListTwoWay(controller.boardingPointTwoWay);
          controller.dropOffListTwoWay(controller.dropOffPointTwoWay);
        });

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBarVET().appBar(context, 'passenger'.tr),
        body: SafeArea(
          child: FutureBuilder<void>(
            future: controller.initialLoadFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: CircularProgressIndicator(
                    value: null,
                    color:
                        ValueStatic.ticketType == '3'
                            ? AppColors.airBusColor
                            : AppColors.primaryColor,
                    strokeWidth: 3.0,
                  ),
                );
              }

              return GetBuilder<PassengerDetailController>(
                dispose: (_) {
                  controller.disposeResources(inputFocusNode: inputFocusNode);
                },
                builder: (_) {
                  return Column(
                    children: [
                      Expanded(
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: <Widget>[
                            //* Contact Info
                            SliverToBoxAdapter(
                              child: Container(
                                margin: const EdgeInsets.only(top: 15.0),
                                padding: const EdgeInsets.all(15),
                                color: AppColors.whiteColor,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'contact_information'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.titleColor,
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 20.0,
                                        bottom: 10.0,
                                      ),
                                      child: TextField(
                                        controller:
                                            controller.usernameController,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textColor,
                                        ),
                                        decoration: Style.inputText(
                                          'name-signup'.tr,
                                          iconLeft: Ionicons.person_outline,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10.0,
                                      ),
                                      child: TextField(
                                        controller:
                                            controller.phoneNumberController,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textColor,
                                        ),
                                        onChanged: (value) {
                                          if (value != ValueStatic.phone) {
                                            controller.isPhone = true;
                                            controller.isTravelPackageOk =
                                                false;
                                            controller.isTravelPackage = false;
                                            controller
                                                .codeController
                                                .text
                                                .isEmpty;
                                            controller.update();
                                          } else {
                                            controller.isPhone = false;
                                            controller.update();
                                          }
                                        },
                                        decoration: Style.inputText(
                                          'telephone_num'.tr,
                                          iconLeft: Ionicons.call_outline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            //* One way display
                            SliverList(
                              delegate: SliverChildListDelegate([
                                Container(
                                  margin: const EdgeInsets.only(top: 15.0),
                                  padding: const EdgeInsets.all(15),
                                  color: AppColors.whiteColor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //* destination
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: ValueStatic.desfrom,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppColors.titleColor,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'to'.tr,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppColors.titleColor,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ValueStatic.desTo,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppColors.titleColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      //* departure date
                                      Text(
                                        'departure_date:'.tr +
                                            ValueStatic.goDate,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textColor,
                                        ),
                                      ),

                                      //* boarding point
                                      FutureBuilder<boarding.CarPointResponse>(
                                        future:
                                            controller
                                                .futureBoardingPointOneWay,
                                        builder: (context, data) {
                                          if (data.hasData) {
                                            if ((data.data?.header?.result) ==
                                                    true &&
                                                (data
                                                        .data
                                                        ?.header
                                                        ?.statusCode) ==
                                                    200) {
                                              if ((data.data?.body)!
                                                  .isNotEmpty) {
                                                if (data.data?.body?.length ==
                                                    1) {
                                                  ValueStatic
                                                          .boardingPointOneWayId =
                                                      (data.data?.body?[0].id)
                                                          .toString();
                                                  ValueStatic
                                                          .boardingPointOneWay =
                                                      (data.data?.body?[0].name)
                                                          .toString();
                                                }

                                                if (ValueStatic
                                                    .dropOffPointOneWayId
                                                    .isNotEmpty) {
                                                  _callGetData(
                                                    context,
                                                    isConfirm: false,
                                                  );
                                                }

                                                return Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 10,
                                                            bottom: 5,
                                                          ),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'boarding_point'.tr,
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  AppColors
                                                                      .titleColor,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          (data
                                                                      .data
                                                                      ?.body
                                                                      ?.length !=
                                                                  1)
                                                              ? const Text(
                                                                "*",
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                              )
                                                              : const SizedBox(),
                                                        ],
                                                      ),
                                                    ),
                                                    _pointPicker(
                                                      context: context,
                                                      decoration:
                                                          Style.inputText(''),
                                                      dialogTitle:
                                                          'boarding_point'.tr,
                                                      items:
                                                          data.data?.body ?? [],
                                                      selectedIndex:
                                                          controller
                                                              .isSelectedIndexBoardingOneWay,
                                                      onSelectedIndexChanged: (
                                                        value,
                                                      ) {
                                                        controller
                                                                .isSelectedIndexBoardingOneWay =
                                                            value;
                                                      },
                                                      selectedName:
                                                          controller
                                                              .selectedBoardingPointOneWay,
                                                      onSelectedNameChanged: (
                                                        value,
                                                      ) {
                                                        controller
                                                                .selectedBoardingPointOneWay =
                                                            value;
                                                      },
                                                      selectedAddress:
                                                          controller
                                                              .selectedBoardingPointAddressOneWay,
                                                      onSelectedAddressChanged: (
                                                        value,
                                                      ) {
                                                        controller
                                                                .selectedBoardingPointAddressOneWay =
                                                            value;
                                                      },
                                                      defaultName:
                                                          'select_boarding'.tr,
                                                      onClearSelection: () {
                                                        controller
                                                            .isSelectedIndexBoardingOneWay = -1;
                                                        controller
                                                                .selectedBoardingPointOneWay =
                                                            'select_boarding'
                                                                .tr;
                                                        controller
                                                            .selectedBoardingPointAddressOneWay = '';
                                                        ValueStatic
                                                            .boardingPointOneWayId = '';
                                                      },
                                                      onValueStaticSelected: (
                                                        item,
                                                      ) {
                                                        ValueStatic
                                                                .boardingPointOneWayId =
                                                            (item.id)
                                                                .toString();
                                                        ValueStatic
                                                                .boardingPointOneWay =
                                                            (item.name)
                                                                .toString();
                                                      },
                                                      isDisabled: (item) {
                                                        return (item.isAllow ??
                                                                1) ==
                                                            0;
                                                      },
                                                    ),
                                                  ],
                                                );
                                              }
                                            }
                                          } else if (data.hasError) {
                                            return const Text('');
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),

                                      //* drop off point
                                      FutureBuilder<boarding.CarPointResponse>(
                                        future:
                                            controller.futureDropOffPointOneWay,
                                        builder: (context, data) {
                                          if (data.hasData) {
                                            if ((data.data?.header?.result) ==
                                                    true &&
                                                (data
                                                        .data
                                                        ?.header
                                                        ?.statusCode) ==
                                                    200) {
                                              if ((data.data?.body)!
                                                  .isNotEmpty) {
                                                if (data.data?.body?.length ==
                                                    1) {
                                                  ValueStatic
                                                          .dropOffPointOneWayId =
                                                      (data.data?.body?[0].id)
                                                          .toString();
                                                  ValueStatic
                                                          .dropOffPointOneWay =
                                                      (data.data?.body?[0].name)
                                                          .toString();
                                                }

                                                if (ValueStatic
                                                    .boardingPointOneWayId
                                                    .isNotEmpty) {
                                                  _callGetData(
                                                    context,
                                                    isConfirm: false,
                                                  );
                                                }

                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 10,
                                                            bottom: 5,
                                                          ),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'drop_off_point'.tr,
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  AppColors
                                                                      .titleColor,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          (data
                                                                      .data
                                                                      ?.body
                                                                      ?.length !=
                                                                  1)
                                                              ? const Text(
                                                                "*",
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                              )
                                                              : const SizedBox(),
                                                        ],
                                                      ),
                                                    ),
                                                    _pointPicker(
                                                      context: context,
                                                      decoration:
                                                          Style.inputText(''),
                                                      dialogTitle:
                                                          'drop_off_point'.tr,
                                                      items:
                                                          data.data?.body ?? [],
                                                      selectedIndex:
                                                          controller
                                                              .isSelectedIndexDropOffOneWay,
                                                      onSelectedIndexChanged: (
                                                        value,
                                                      ) {
                                                        controller
                                                                .isSelectedIndexDropOffOneWay =
                                                            value;
                                                      },
                                                      selectedName:
                                                          controller
                                                              .selectedDropPointOneWay,
                                                      onSelectedNameChanged: (
                                                        value,
                                                      ) {
                                                        controller
                                                                .selectedDropPointOneWay =
                                                            value;
                                                      },
                                                      selectedAddress:
                                                          controller
                                                              .selectedDropPointAddressOneWay,
                                                      onSelectedAddressChanged: (
                                                        value,
                                                      ) {
                                                        controller
                                                                .selectedDropPointAddressOneWay =
                                                            value;
                                                      },
                                                      defaultName:
                                                          'select_drop'.tr,
                                                      onClearSelection: () {
                                                        controller
                                                            .isSelectedIndexDropOffOneWay = -1;
                                                        controller
                                                                .selectedDropPointOneWay =
                                                            'select_drop'.tr;
                                                        controller
                                                            .selectedDropPointAddressOneWay = '';
                                                        ValueStatic
                                                            .dropOffPointOneWayId = '';
                                                      },
                                                      onValueStaticSelected: (
                                                        item,
                                                      ) {
                                                        ValueStatic
                                                                .dropOffPointOneWayId =
                                                            (item.id)
                                                                .toString();
                                                        ValueStatic
                                                                .dropOffPointOneWay =
                                                            (item.name)
                                                                .toString();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              }
                                            }
                                          } else if (data.hasError) {
                                            return const Text('');
                                          }

                                          return Center(
                                            child: SizedBox(
                                              height: 30.0,
                                              width: 30.0,
                                              child: CircularProgressIndicator(
                                                value: null,
                                                color:
                                                    ValueStatic.ticketType ==
                                                            '3'
                                                        ? AppColors.airBusColor
                                                        : AppColors
                                                            .primaryColor,
                                                strokeWidth: 3.0,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                //* customer info
                                _travelInformationSection(
                                  context: context,
                                  selectedSeats: ValueStatic.oneWaySelectedSeat,
                                  companyType: ValueStatic.companyTypeOneWay,
                                  nameControllers: controller.nameOneWay,
                                  gender: controller.genderOneWay,
                                  nationalityIds: controller.nationalityIds,
                                  national: controller.nationalOneWay,
                                  dobDisplayControllers:
                                      controller.dobOneWayList,
                                  dobValueControllers: controller.dobOneWay,
                                  passportControllers:
                                      controller.passportOneWay,
                                ),
                              ]),
                            ),

                            //* Two way display
                            if (ValueStatic.journeyType == 2)
                              SliverList(
                                delegate: SliverChildListDelegate([
                                  Container(
                                    margin: const EdgeInsets.only(top: 15.0),
                                    padding: const EdgeInsets.all(15),
                                    color: AppColors.whiteColor,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: ValueStatic.desTo,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: AppColors.titleColor,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'to'.tr,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ValueStatic.desfrom,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'departure_date:'.tr +
                                              ValueStatic.backDate,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: AppColors.titleColor,
                                          ),
                                        ),

                                        //* boarding point two way
                                        FutureBuilder<
                                          boarding.CarPointResponse
                                        >(
                                          future:
                                              controller
                                                  .futureBoardingPointTwoWay,
                                          builder: (context, data) {
                                            if (data.hasData) {
                                              if ((data.data?.header?.result) ==
                                                      true &&
                                                  (data
                                                          .data
                                                          ?.header
                                                          ?.statusCode) ==
                                                      200) {
                                                if ((data.data?.body)!
                                                    .isNotEmpty) {
                                                  if (data.data?.body?.length ==
                                                      1) {
                                                    ValueStatic
                                                            .boardingPointTwoWayId =
                                                        (data.data?.body?[0].id)
                                                            .toString();
                                                    ValueStatic
                                                            .boardingPointTwoWay =
                                                        (data
                                                                .data
                                                                ?.body?[0]
                                                                .name)
                                                            .toString();
                                                  }

                                                  if (ValueStatic
                                                      .dropOffPointOneWayId
                                                      .isNotEmpty) {
                                                    _callGetData(
                                                      context,
                                                      isConfirm: false,
                                                    );
                                                  }

                                                  return Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 10,
                                                              bottom: 5,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'boarding_point'
                                                                  .tr,
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 14,
                                                                color:
                                                                    AppColors
                                                                        .titleColor,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            (data
                                                                        .data
                                                                        ?.body
                                                                        ?.length !=
                                                                    1)
                                                                ? const Text(
                                                                  "*",
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .red,
                                                                  ),
                                                                )
                                                                : const SizedBox(),
                                                          ],
                                                        ),
                                                      ),
                                                      InputDecorator(
                                                        decoration: InputDecoration(
                                                          isDense: true,
                                                          contentPadding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 12,
                                                              ),
                                                          enabledBorder:
                                                              Style.outlineInputBorder(),
                                                          border: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color:
                                                                  ValueStatic.ticketType ==
                                                                          '3'
                                                                      ? AppColors
                                                                          .airBusColor
                                                                      : AppColors
                                                                          .primaryColor,
                                                            ),
                                                            borderRadius:
                                                                const BorderRadius.all(
                                                                  Radius.circular(
                                                                    5,
                                                                  ),
                                                                ),
                                                          ),
                                                        ),
                                                        child:
                                                            (data
                                                                        .data
                                                                        ?.body
                                                                        ?.length !=
                                                                    1)
                                                                ? _pointPicker(
                                                                  context:
                                                                      context,
                                                                  decoration: InputDecoration(
                                                                    isDense:
                                                                        true,
                                                                    contentPadding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          12,
                                                                    ),
                                                                    enabledBorder:
                                                                        Style.outlineInputBorder(),
                                                                    border: OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                        color:
                                                                            ValueStatic.ticketType ==
                                                                                    '3'
                                                                                ? AppColors.airBusColor
                                                                                : AppColors.primaryColor,
                                                                      ),
                                                                      borderRadius:
                                                                          const BorderRadius.all(
                                                                            Radius.circular(
                                                                              5,
                                                                            ),
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  dialogTitle:
                                                                      'boarding_point'
                                                                          .tr,
                                                                  items:
                                                                      data
                                                                          .data
                                                                          ?.body ??
                                                                      [],
                                                                  selectedIndex:
                                                                      controller
                                                                          .isSelectIndexBoardingTwoWay,
                                                                  onSelectedIndexChanged: (
                                                                    value,
                                                                  ) {
                                                                    controller
                                                                            .isSelectIndexBoardingTwoWay =
                                                                        value;
                                                                  },
                                                                  selectedName:
                                                                      controller
                                                                          .selectBoardingPointTwoWay,
                                                                  onSelectedNameChanged: (
                                                                    value,
                                                                  ) {
                                                                    controller
                                                                            .selectBoardingPointTwoWay =
                                                                        value;
                                                                  },
                                                                  selectedAddress:
                                                                      controller
                                                                          .selectBoardingPointAddressTwoWay,
                                                                  onSelectedAddressChanged: (
                                                                    value,
                                                                  ) {
                                                                    controller
                                                                            .selectBoardingPointAddressTwoWay =
                                                                        value;
                                                                  },
                                                                  defaultName:
                                                                      'select_boarding'
                                                                          .tr,
                                                                  onClearSelection: () {
                                                                    controller
                                                                        .isSelectIndexBoardingTwoWay = -1;
                                                                    controller
                                                                            .selectBoardingPointTwoWay =
                                                                        'select_boarding'
                                                                            .tr;
                                                                    controller
                                                                        .selectBoardingPointAddressTwoWay = '';
                                                                    ValueStatic
                                                                        .boardingPointTwoWayId = '';
                                                                  },
                                                                  onValueStaticSelected: (
                                                                    item,
                                                                  ) {
                                                                    ValueStatic
                                                                            .boardingPointTwoWayId =
                                                                        (item.id)
                                                                            .toString();
                                                                    ValueStatic
                                                                            .boardingPointTwoWay =
                                                                        (item.name)
                                                                            .toString();
                                                                  },
                                                                )
                                                                : Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      "${(data.data?.body?[0].name)}",
                                                                      style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontSize:
                                                                            14,
                                                                        color:
                                                                            AppColors.textColor,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Text(
                                                                      "${data.data?.body?[0].address}",
                                                                      style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        fontSize:
                                                                            14,
                                                                        color:
                                                                            AppColors.textColor,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                      ),
                                                    ],
                                                  );
                                                }
                                              }
                                            } else if (data.hasError) {
                                              return const Text('');
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),

                                        //* drop off two way
                                        FutureBuilder<
                                          boarding.CarPointResponse
                                        >(
                                          future:
                                              controller
                                                  .futureDropOffPointTwoWay,
                                          builder: (context, data) {
                                            if (data.hasData) {
                                              if ((data.data?.header?.result) ==
                                                      true &&
                                                  (data
                                                          .data
                                                          ?.header
                                                          ?.statusCode) ==
                                                      200) {
                                                if ((data.data?.body)!
                                                    .isNotEmpty) {
                                                  if (data.data?.body?.length ==
                                                      1) {
                                                    ValueStatic
                                                            .dropOffPointTwoWayId =
                                                        (data.data?.body?[0].id)
                                                            .toString();
                                                    ValueStatic
                                                            .dropOffPointTwoWay =
                                                        (data
                                                                .data
                                                                ?.body?[0]
                                                                .name)
                                                            .toString();
                                                  }

                                                  if (ValueStatic
                                                      .boardingPointOneWayId
                                                      .isNotEmpty) {
                                                    _callGetData(
                                                      context,
                                                      isConfirm: false,
                                                    );
                                                  }

                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 10,
                                                              bottom: 5,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'drop_off_point'
                                                                  .tr,
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 14,
                                                                color:
                                                                    AppColors
                                                                        .titleColor,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            (data
                                                                        .data
                                                                        ?.body
                                                                        ?.length !=
                                                                    1)
                                                                ? const Text(
                                                                  "*",
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .red,
                                                                  ),
                                                                )
                                                                : const SizedBox(),
                                                          ],
                                                        ),
                                                      ),
                                                      InputDecorator(
                                                        decoration: InputDecoration(
                                                          isDense: true,
                                                          contentPadding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 12,
                                                              ),
                                                          enabledBorder:
                                                              Style.outlineInputBorder(),
                                                          border: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color:
                                                                  ValueStatic.ticketType ==
                                                                          '3'
                                                                      ? AppColors
                                                                          .airBusColor
                                                                      : AppColors
                                                                          .primaryColor,
                                                            ),
                                                            borderRadius:
                                                                const BorderRadius.all(
                                                                  Radius.circular(
                                                                    5,
                                                                  ),
                                                                ),
                                                          ),
                                                        ),
                                                        child:
                                                            (data
                                                                        .data
                                                                        ?.body
                                                                        ?.length !=
                                                                    1)
                                                                ? _pointPicker(
                                                                  context:
                                                                      context,
                                                                  decoration: InputDecoration(
                                                                    isDense:
                                                                        true,
                                                                    contentPadding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          12,
                                                                    ),
                                                                    enabledBorder:
                                                                        Style.outlineInputBorder(),
                                                                    border: OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                        color:
                                                                            ValueStatic.ticketType ==
                                                                                    '3'
                                                                                ? AppColors.airBusColor
                                                                                : AppColors.primaryColor,
                                                                      ),
                                                                      borderRadius:
                                                                          const BorderRadius.all(
                                                                            Radius.circular(
                                                                              5,
                                                                            ),
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  dialogTitle:
                                                                      'drop_off_point'
                                                                          .tr,
                                                                  items:
                                                                      data
                                                                          .data
                                                                          ?.body ??
                                                                      [],
                                                                  selectedIndex:
                                                                      controller
                                                                          .isSelectIndexDropOffTwoWay,
                                                                  onSelectedIndexChanged: (
                                                                    value,
                                                                  ) {
                                                                    controller
                                                                            .isSelectIndexDropOffTwoWay =
                                                                        value;
                                                                  },
                                                                  selectedName:
                                                                      controller
                                                                          .selectDropPointTwoWay,
                                                                  onSelectedNameChanged: (
                                                                    value,
                                                                  ) {
                                                                    controller
                                                                            .selectDropPointTwoWay =
                                                                        value;
                                                                  },
                                                                  selectedAddress:
                                                                      controller
                                                                          .selectDropPointAddressTwoWay,
                                                                  onSelectedAddressChanged: (
                                                                    value,
                                                                  ) {
                                                                    controller
                                                                            .selectDropPointAddressTwoWay =
                                                                        value;
                                                                  },
                                                                  defaultName:
                                                                      'select_drop'
                                                                          .tr,
                                                                  onClearSelection: () {
                                                                    controller
                                                                        .isSelectIndexDropOffTwoWay = -1;
                                                                    controller
                                                                            .selectDropPointTwoWay =
                                                                        'select_drop'
                                                                            .tr;
                                                                    controller
                                                                        .selectDropPointAddressTwoWay = '';
                                                                    ValueStatic
                                                                        .dropOffPointTwoWayId = '';
                                                                  },
                                                                  onValueStaticSelected: (
                                                                    item,
                                                                  ) {
                                                                    ValueStatic
                                                                            .dropOffPointTwoWayId =
                                                                        (item.id)
                                                                            .toString();
                                                                    ValueStatic
                                                                            .dropOffPointTwoWay =
                                                                        (item.name)
                                                                            .toString();
                                                                  },
                                                                )
                                                                : Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      "${(data.data?.body?[0].name)}",
                                                                      style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontSize:
                                                                            14,
                                                                        color:
                                                                            AppColors.textColor,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Text(
                                                                      "${data.data?.body?[0].address}",
                                                                      style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        fontSize:
                                                                            14,
                                                                        color:
                                                                            AppColors.textColor,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                      ),
                                                    ],
                                                  );
                                                }
                                              }
                                            } else if (data.hasError) {
                                              return const Text('');
                                            }
                                            return Center(
                                              child: SizedBox(
                                                height: 30.0,
                                                width: 30.0,
                                                child: CircularProgressIndicator(
                                                  value: null,
                                                  color:
                                                      ValueStatic.ticketType ==
                                                              '3'
                                                          ? AppColors
                                                              .airBusColor
                                                          : AppColors
                                                              .primaryColor,
                                                  strokeWidth: 3.0,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  //* customer info
                                  _travelInformationSection(
                                    context: context,
                                    selectedSeats:
                                        ValueStatic.twoWaySelectedSeat,
                                    companyType: ValueStatic.companyTypeTwoWay,
                                    nameControllers: controller.nameTwoWay,
                                    gender: controller.genderTwoWay,
                                    nationalityIds:
                                        controller.nationalityIdsTwoWay,
                                    national: controller.nationalTwoWay,
                                    dobDisplayControllers:
                                        controller.dobTwoWayList,
                                    dobValueControllers: controller.dobTwoWay,
                                    passportControllers:
                                        controller.passportTwoWay,
                                  ),
                                ]),
                              ),

                            //* Summary
                            SliverToBoxAdapter(
                              child: Container(
                                margin: const EdgeInsets.only(top: 15.0),
                                padding: const EdgeInsets.all(15),
                                color: AppColors.whiteColor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //* summary
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'summary'.tr,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: AppColors.titleColor,
                                          ),
                                        ),
                                        Icon(
                                          Ionicons.chevron_down,
                                          size: 18,
                                          color: AppColors.textColor,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // * travel package
                                    // * check the phone number
                                    if (ValueStatic.phone ==
                                        controller.phoneNumberController.text)
                                      ///one way
                                      if (ValueStatic.journeyType == 1)
                                        ///check the number of seat one way(can apply only when user book one seat)
                                        ValueStatic.oneWaySelectedSeat.length ==
                                                1
                                            ? Column(
                                              children: [
                                                //* checkbox apply package
                                                Row(
                                                  children: [
                                                    //* checkbox
                                                    Container(
                                                      width: 25,
                                                      height: 25,
                                                      margin:
                                                          const EdgeInsets.only(
                                                            top: 5,
                                                          ),
                                                      child: Transform.scale(
                                                        scale: 1.5,
                                                        child: Checkbox(
                                                          tristate: false,
                                                          activeColor:
                                                              Colors.grey[300],
                                                          fillColor:
                                                              WidgetStateColor.resolveWith(
                                                                (
                                                                  states,
                                                                ) => controller
                                                                    .getColor(
                                                                      states,
                                                                    ),
                                                              ),
                                                          checkColor:
                                                              ValueStatic.ticketType ==
                                                                      '3'
                                                                  ? AppColors
                                                                      .airBusColor
                                                                  : AppColors
                                                                      .primaryColor,
                                                          side: const BorderSide(
                                                            color:
                                                                Colors
                                                                    .transparent, //your desired color here
                                                          ),
                                                          value:
                                                              controller
                                                                  .isTravelPackage,
                                                          onChanged:
                                                              (controller.status ==
                                                                      1)
                                                                  ? null // disable checkbox when promo code applied
                                                                  : (
                                                                    value,
                                                                  ) async {
                                                                    ///user click apply and set isTravelPackage==true
                                                                    if (value !=
                                                                        null) {
                                                                      controller
                                                                              .isTravelPackage =
                                                                          value;
                                                                      controller
                                                                          .update();
                                                                    }

                                                                    ///user not click or un_click apply
                                                                    if (value ==
                                                                        false) {
                                                                      controller
                                                                          .codeController
                                                                          .text = '';
                                                                      controller
                                                                          .update();
                                                                    }

                                                                    ///user apply with the same phone number
                                                                    if (value! &&
                                                                        !controller
                                                                            .isPhone) {
                                                                      ///check user have travel package or not
                                                                      final travelPackage =
                                                                          await TravelPackage().getBuyList(
                                                                            context,
                                                                          );

                                                                      /// when user don't have travel package, it will alert dialog
                                                                      if (travelPackage
                                                                          .body!
                                                                          .isEmpty) {
                                                                        ///when user don't have travel package, set isNoPackage = true;
                                                                        controller.isNoPackage =
                                                                            true;
                                                                        controller
                                                                            .update();

                                                                        ///alert dialog no package
                                                                        alertDialogTravelPackage(
                                                                          title:
                                                                              "information".tr,
                                                                          description:
                                                                              "no_package".tr,
                                                                          buttonText:
                                                                              'yes'.tr,
                                                                          onButtonPressed: () {
                                                                            Navigator.pop(
                                                                              context,
                                                                            );

                                                                            ///when user don't have travel package, set isTravelPackage = false; then un_tick the checkbox
                                                                            controller.isTravelPackage =
                                                                                false;
                                                                            controller.update();
                                                                          },
                                                                        );
                                                                      }
                                                                      ///when user have travel package
                                                                      else {
                                                                        ///when user have travel package, set isNoPackage = false;
                                                                        controller.isNoPackage =
                                                                            false;
                                                                        controller
                                                                            .update();

                                                                        ///get the first index package code
                                                                        String?
                                                                        packageCoded =
                                                                            travelPackage.body?[0].packageCode;
                                                                        controller
                                                                            .codeController
                                                                            .text = packageCoded!;

                                                                        ///set the first index package code to inputCodeController
                                                                        controller
                                                                            .codeController
                                                                            .text = packageCoded;
                                                                        controller.packageTypeOneWay =
                                                                            travelPackage.body![0].type!;
                                                                        controller
                                                                            .update();

                                                                        if (ValueStatic.vehicleTypeOneWay ==
                                                                                2 &&
                                                                            controller.packageTypeOneWay ==
                                                                                2) {
                                                                          alertDialogTravelPackage(
                                                                            title:
                                                                                "information".tr,
                                                                            description:
                                                                                "First-class seats are not available for travel packages with a student grade A.",
                                                                            buttonText:
                                                                                'yes'.tr,
                                                                            onButtonPressed: () {
                                                                              Navigator.pop(
                                                                                context,
                                                                              );

                                                                              ///when user don't have travel package, set isTravelPackage = false; then un_tick the checkbox
                                                                              controller.codeController.text = '';
                                                                              controller.isTravelPackage = false;
                                                                              controller.update();
                                                                            },
                                                                          );
                                                                        } else {
                                                                          ///check travel package apply available or unavailable
                                                                          controller.checkPackageContext =
                                                                              context;
                                                                          controller.checkPackageCode =
                                                                              controller.codeController.text;
                                                                          controller.checkPackageJourneyId =
                                                                              ValueStatic.journeyIdGo;
                                                                          controller.checkPackageTravelDate =
                                                                              ValueStatic.goDate;
                                                                          final ok =
                                                                              await controller.checkPackageApply();

                                                                          ///travel package code is ok
                                                                          if (ok) {
                                                                            ///save that this travel package code that apply is OK, set isTravelPackageOk = true;
                                                                            controller.isTravelPackageOk =
                                                                                true;

                                                                            // disable promo code
                                                                            controller.status =
                                                                                0;
                                                                            controller.couponController.text =
                                                                                '';
                                                                            controller.update();
                                                                          }
                                                                          ///travel package code is unavailable
                                                                          else {
                                                                            ///save when this travel package code that apply is unavailable, set isTravelPackageOk = false;
                                                                            ///(sometime package code is expired, invalid, or already apply in this date)
                                                                            controller.isTravelPackageOk =
                                                                                false;
                                                                            controller.update();

                                                                            ///alert dialog travel package code is unavailable
                                                                            alertDialogTravelPackage(
                                                                              title:
                                                                                  'information'.tr,
                                                                              description:
                                                                                  controller.state.msgPackage.value,
                                                                              buttonText:
                                                                                  'yes'.tr,
                                                                              onButtonPressed: () {
                                                                                Navigator.pop(
                                                                                  context,
                                                                                );

                                                                                ///when user apply code and the code is unavailable, set isTravelPackage = false; then un_tick the checkbox
                                                                                controller.isTravelPackage = false;
                                                                                controller.update();
                                                                              },
                                                                            );
                                                                          }
                                                                        }
                                                                      }
                                                                    }
                                                                  },
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      'apply_package'.tr,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 20),

                                                ///apply package code with same phone number
                                                if (controller
                                                        .isTravelPackage &&
                                                    !controller.isPhone)
                                                  ///user have package and show the package code in the text_field(view only)
                                                  if (!controller.isNoPackage)
                                                    Column(
                                                      children: [
                                                        TextFormField(
                                                          controller:
                                                              controller
                                                                  .codeController,
                                                          autofocus: false,
                                                          enabled: false,
                                                          autovalidateMode:
                                                              AutovalidateMode
                                                                  .onUserInteraction,
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                AppColors
                                                                    .secondaryColor,
                                                          ),
                                                          decoration: const InputDecoration(
                                                            isDense: true,
                                                            contentPadding:
                                                                EdgeInsets.fromLTRB(
                                                                  10,
                                                                  15,
                                                                  10,
                                                                  15,
                                                                ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                    width: 1.0,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                    Radius.circular(
                                                                      5,
                                                                    ),
                                                                  ),
                                                            ),
                                                            border: OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                    width: 1.0,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                    Radius.circular(
                                                                      5,
                                                                    ),
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                      ],
                                                    ),
                                              ],
                                            )
                                            : const SizedBox.shrink(),

                                    //* coupon code
                                    if (ValueStatic.journeyType == 1)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Divider(),
                                          Row(
                                            children: [
                                              Image.asset(
                                                "assets/icons/icon_coupon.png",
                                                width: 24,
                                                height: 24,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'promo_code'.tr,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: AppColors.titleColor,
                                                ),
                                              ),
                                              const Spacer(),

                                              ///when status ==0 and isTravelPackageOk == false, it will show the button
                                              (controller.status == 0 &&
                                                      !controller
                                                          .isTravelPackageOk)
                                                  ? TextButton(
                                                    onPressed: () async {
                                                      final result = await Get.to(
                                                        () => SelectCouponScreen(
                                                          amount:
                                                              ValueStatic
                                                                  .totalPrice,
                                                          travelDate:
                                                              ValueStatic
                                                                  .goDate,
                                                        ),
                                                        transition:
                                                            Transition
                                                                .rightToLeft,
                                                        duration:
                                                            const Duration(
                                                              milliseconds:
                                                                  Constrains
                                                                      .duration,
                                                            ),
                                                      );

                                                      if (result != null) {
                                                        controller
                                                                .couponController
                                                                .text =
                                                            result['code'];
                                                        controller.status =
                                                            result['status'];
                                                        controller.balance =
                                                            result['balance'];

                                                        // ✅ force disable travel package
                                                        controller
                                                                .isTravelPackageOk =
                                                            false;
                                                        controller
                                                                .isTravelPackage =
                                                            false;
                                                        controller
                                                            .codeController
                                                            .text = '';
                                                        controller.update();
                                                      }
                                                    },
                                                    child: Text(
                                                      'enter_pro'.tr,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                        color:
                                                            AppColors.greyColor,
                                                      ),
                                                    ),
                                                  )
                                                  : SizedBox.shrink(),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          controller.status == 1
                                              ? TextFormField(
                                                controller:
                                                    controller.couponController,
                                                autofocus: false,
                                                enabled: false,
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                keyboardType:
                                                    TextInputType.text,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      AppColors.secondaryColor,
                                                ),
                                                decoration: const InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                        10,
                                                        15,
                                                        10,
                                                        15,
                                                      ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.grey,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                              Radius.circular(
                                                                5,
                                                              ),
                                                            ),
                                                      ),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Colors.grey,
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                          Radius.circular(5),
                                                        ),
                                                  ),
                                                ),
                                              )
                                              : SizedBox.shrink(),
                                          controller.status == 1
                                              ? SizedBox(height: 12)
                                              : SizedBox.shrink(),
                                          controller.status == 1
                                              ? RichText(
                                                text: TextSpan(
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: AppColors.textColor,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: "pro_available".tr,
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          " \$${controller.balance} ",
                                                    ),
                                                    TextSpan(text: "more".tr),
                                                  ],
                                                ),
                                              )
                                              : SizedBox.shrink(),

                                          controller.status == 1
                                              ? SizedBox(height: 6)
                                              : SizedBox.shrink(),

                                          const Divider(),
                                        ],
                                      ),

                                    // * travel package
                                    // * check the phone number
                                    if (ValueStatic.phone ==
                                        controller.phoneNumberController.text)
                                      ///round trip
                                      if (ValueStatic.journeyType == 2)
                                        ///check the number of seat round trip(can apply only when user book one seat for one way and one seat for two way)
                                        ValueStatic.oneWaySelectedSeat.length ==
                                                    1 &&
                                                ValueStatic
                                                        .twoWaySelectedSeat
                                                        .length ==
                                                    1
                                            ? Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 25,
                                                      height: 25,
                                                      margin:
                                                          const EdgeInsets.only(
                                                            top: 5,
                                                          ),
                                                      child: Transform.scale(
                                                        scale: 1.5,
                                                        child: Checkbox(
                                                          tristate: false,
                                                          activeColor:
                                                              Colors.grey[300],
                                                          fillColor:
                                                              WidgetStateColor.resolveWith(
                                                                (
                                                                  states,
                                                                ) => controller
                                                                    .getColor(
                                                                      states,
                                                                    ),
                                                              ),
                                                          checkColor:
                                                              ValueStatic.ticketType ==
                                                                      '3'
                                                                  ? AppColors
                                                                      .airBusColor
                                                                  : AppColors
                                                                      .primaryColor,
                                                          side: const BorderSide(
                                                            color:
                                                                Colors
                                                                    .transparent,
                                                          ),
                                                          value:
                                                              controller
                                                                  .isTravelPackage,
                                                          onChanged: (
                                                            value,
                                                          ) async {
                                                            if (value != null) {
                                                              controller
                                                                      .isTravelPackage =
                                                                  value;
                                                              controller
                                                                  .update();
                                                            }
                                                            if (value ==
                                                                false) {
                                                              controller
                                                                  .codeController
                                                                  .text = '';
                                                              controller
                                                                  .update();
                                                            }

                                                            if (value! &&
                                                                !controller
                                                                    .isPhone) {
                                                              final travelPackage =
                                                                  await TravelPackage()
                                                                      .getBuyList(
                                                                        context,
                                                                      );

                                                              if (travelPackage
                                                                  .body!
                                                                  .isEmpty) {
                                                                controller
                                                                        .isNoPackage =
                                                                    true;
                                                                controller
                                                                    .update();
                                                                alertDialogTravelPackage(
                                                                  title:
                                                                      "information"
                                                                          .tr,
                                                                  description:
                                                                      "no_package"
                                                                          .tr,
                                                                  buttonText:
                                                                      'yes'.tr,
                                                                  onButtonPressed: () {
                                                                    Navigator.pop(
                                                                      context,
                                                                    );
                                                                    controller
                                                                            .isTravelPackage =
                                                                        false;
                                                                    controller
                                                                        .update();
                                                                  },
                                                                );
                                                              }
                                                              ///when user have travel package
                                                              else {
                                                                ///when user have travel package, set isNoPackage = false;
                                                                controller
                                                                        .isNoPackage =
                                                                    false;
                                                                controller
                                                                    .update();

                                                                ///get the first index package code
                                                                String?
                                                                packageCoded =
                                                                    travelPackage
                                                                        .body?[0]
                                                                        .packageCode;
                                                                controller
                                                                        .codeController
                                                                        .text =
                                                                    packageCoded!;

                                                                ///set the first index package code to inputCodeController
                                                                controller
                                                                        .codeController
                                                                        .text =
                                                                    packageCoded;
                                                                controller
                                                                        .packageTypeTwoWay =
                                                                    travelPackage
                                                                        .body![0]
                                                                        .type!
                                                                        .toInt();
                                                                controller
                                                                    .update();

                                                                ///check package code student A
                                                                if (ValueStatic
                                                                            .vehicleTypeOneWay ==
                                                                        2 &&
                                                                    controller
                                                                            .packageTypeTwoWay ==
                                                                        2 &&
                                                                    ValueStatic
                                                                            .vehicleTypeTwoWay ==
                                                                        2) {
                                                                  alertDialogTravelPackage(
                                                                    title:
                                                                        "information"
                                                                            .tr,
                                                                    description:
                                                                        "First-class seats are not available for travel packages with a student grade A.",
                                                                    buttonText:
                                                                        'yes'
                                                                            .tr,
                                                                    onButtonPressed: () {
                                                                      Navigator.pop(
                                                                        context,
                                                                      );

                                                                      ///when user don't have travel package, set isTravelPackage = false; then un_tick the checkbox
                                                                      controller
                                                                          .codeController
                                                                          .text = '';
                                                                      controller
                                                                              .isTravelPackage =
                                                                          false;
                                                                      controller
                                                                          .update();
                                                                    },
                                                                  );
                                                                } else {
                                                                  controller
                                                                          .checkPackageContext =
                                                                      context;
                                                                  controller
                                                                          .checkPackageCode =
                                                                      controller
                                                                          .codeController
                                                                          .text;
                                                                  controller
                                                                          .checkPackageJourneyId =
                                                                      ValueStatic
                                                                          .journeyIdGo;
                                                                  controller
                                                                          .checkPackageTravelDate =
                                                                      ValueStatic
                                                                          .goDate;
                                                                  final ok =
                                                                      await controller
                                                                          .checkPackageApply();

                                                                  if (ok) {
                                                                    controller
                                                                            .isTravelPackageOk =
                                                                        true;
                                                                    controller
                                                                        .update();
                                                                  } else {
                                                                    controller
                                                                            .isTravelPackageOk =
                                                                        false;
                                                                    controller
                                                                        .update();

                                                                    alertDialogTravelPackage(
                                                                      title:
                                                                          'information'
                                                                              .tr,
                                                                      description:
                                                                          controller
                                                                              .state
                                                                              .msgPackage
                                                                              .value,
                                                                      buttonText:
                                                                          'yes'
                                                                              .tr,
                                                                      onButtonPressed: () {
                                                                        Navigator.pop(
                                                                          context,
                                                                        );
                                                                        controller.isTravelPackage =
                                                                            false;
                                                                        controller
                                                                            .update();
                                                                      },
                                                                    );
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      'apply_package'.tr,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 20),

                                                ///user apply package code with same phone number
                                                if (controller
                                                        .isTravelPackage &&
                                                    !controller.isPhone)
                                                  ///user have package and show the package code in the text_field(view only)
                                                  if (!controller.isNoPackage)
                                                    Column(
                                                      children: [
                                                        TextFormField(
                                                          controller:
                                                              controller
                                                                  .codeController,
                                                          autofocus: false,
                                                          enabled: false,
                                                          autovalidateMode:
                                                              AutovalidateMode
                                                                  .onUserInteraction,
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                AppColors
                                                                    .secondaryColor,
                                                          ),
                                                          decoration: const InputDecoration(
                                                            isDense: true,
                                                            contentPadding:
                                                                EdgeInsets.fromLTRB(
                                                                  10,
                                                                  15,
                                                                  10,
                                                                  15,
                                                                ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                    width: 1.0,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                    Radius.circular(
                                                                      5,
                                                                    ),
                                                                  ),
                                                            ),
                                                            border: OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                    width: 1.0,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                    Radius.circular(
                                                                      5,
                                                                    ),
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Divider(),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                              ],
                                            )
                                            : const SizedBox.shrink(),

                                    // * value of round trip
                                    if (ValueStatic.journeyType == 2)
                                      Builder(
                                        builder: (context) {
                                          final subTotal =
                                              (ValueStatic.totalPriceGo +
                                                  ValueStatic.totalPriceBack);
                                          final discount =
                                              (controller.isTravelPackage &&
                                                      controller
                                                          .isTravelPackageOk)
                                                  ? (subTotal *
                                                      (ValueStatic
                                                              .travelPackageDis /
                                                          100))
                                                  : ((!ValueStatic
                                                              .seatPriceGoDiscount
                                                          ? (ValueStatic
                                                                  .totalPriceGo *
                                                              0.05)
                                                          : 0) +
                                                      (!ValueStatic
                                                              .seatPriceBackDiscount
                                                          ? (ValueStatic
                                                                  .totalPriceBack *
                                                              0.05)
                                                          : 0));
                                          final total =
                                              subTotal -
                                              discount +
                                              (controller.luckyDraw
                                                  ? ValueStatic.luckyDrawValue
                                                  : 0);

                                          return Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'sub_total'.tr,
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.textColor,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    '\$${subTotal.toStringAsFixed(2)}',
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Text(
                                                    (controller.isTravelPackage &&
                                                            controller
                                                                .isTravelPackageOk)
                                                        ? 'discount_travel'.tr
                                                        : 'discount'.tr,
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.textColor,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    '\$${discount.toStringAsFixed(2)}',
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Text(
                                                    'total_price'.tr,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    '\$${total.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      ),

                                    // * value of one way with coupon code
                                    if (ValueStatic.journeyType == 1 &&
                                        controller.status == 1)
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'sub_total'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                ValueStatic.seatPriceGoDiscount
                                                    ? '\$${(double.parse(ValueStatic.totalPrice)).toStringAsFixed(2)}'
                                                    : '\$${(double.parse(ValueStatic.totalPrice) * 0.95).toStringAsFixed(2)}',
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Text(
                                                'dis_coupon'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                ValueStatic.seatPriceGoDiscount
                                                    ? '\$${(double.parse(ValueStatic.totalPrice)).toStringAsFixed(2)}'
                                                    : '\$${(double.parse(ValueStatic.totalPrice) * 0.95).toStringAsFixed(2)}',
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Text(
                                                'total_price'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '\$${(double.parse(ValueStatic.totalPrice) - double.parse(ValueStatic.totalPrice)).toStringAsFixed(2)}',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                    // * value of one way with travel package same phone number
                                    if (ValueStatic.journeyType == 1 &&
                                        controller.isPhone == false &&
                                        controller.status == 0)
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'sub_total'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '\$${ValueStatic.totalPrice}',
                                              ),
                                            ],
                                          ),
                                          if (controller.isTravelPackage ==
                                                  true &&
                                              controller.isTravelPackageOk ==
                                                  true)
                                            Column(
                                              children: [
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Text('discount_travel'.tr),
                                                    const Spacer(),
                                                    Text(
                                                      "\$${((double.parse(ValueStatic.totalPrice) * (ValueStatic.travelPackageDis / 100))).toStringAsFixed(2)}",
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          if (controller.isTravelPackage ==
                                              false)
                                            if (ValueStatic
                                                    .seatPriceGoDiscount ==
                                                false)
                                              Column(
                                                children: [
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'discount'.tr,
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors
                                                                  .textColor,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        ValueStatic.seatPriceGoDiscount ==
                                                                true
                                                            ? "\$${double.parse(ValueStatic.totalPrice).toStringAsFixed(2)}"
                                                            : "\$${(double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)}",
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                          if (controller.isTravelPackage ==
                                              true)
                                            if (controller.isNoPackage == true)
                                              if (ValueStatic
                                                      .seatPriceGoDiscount ==
                                                  false)
                                                Column(
                                                  children: [
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'discount'.tr,
                                                          style: const TextStyle(
                                                            color:
                                                                AppColors
                                                                    .textColor,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Text(
                                                          "\$${(double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)}",
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                          controller.luckyDraw
                                              ? const SizedBox(height: 10)
                                              : const SizedBox(),
                                          controller.luckyDraw
                                              ? Row(
                                                children: [
                                                  Text('lucky_draw'.tr),
                                                  const Spacer(),
                                                  Text(
                                                    ValueStatic.journeyType == 2
                                                        ? '\$${0.25 * (ValueStatic.oneWaySelectedSeat.length + ValueStatic.twoWaySelectedSeat.length)}'
                                                        : '\$${0.25 * ValueStatic.oneWaySelectedSeat.length}',
                                                  ),
                                                ],
                                              )
                                              : const SizedBox(),
                                          const SizedBox(height: 8),
                                          if (controller.isTravelPackage ==
                                              false)
                                            Row(
                                              children: [
                                                Text(
                                                  'total_price'.tr,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Spacer(),
                                                if (ValueStatic
                                                    .totalPrice
                                                    .isNotEmpty)
                                                  Text(
                                                    ValueStatic.seatPriceGoDiscount ==
                                                            true
                                                        ? "\$${double.parse(((double.parse(ValueStatic.totalPrice) + ValueStatic.luckyDrawValue).toStringAsFixed(2))).toStringAsFixed(2)}"
                                                        : "\$${double.parse(((double.parse(ValueStatic.totalPrice) - (double.parse((double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)))) + ValueStatic.luckyDrawValue).toStringAsFixed(2))}",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          if (controller.isTravelPackage ==
                                                  true &&
                                              controller.isTravelPackageOk ==
                                                  true)
                                            Row(
                                              children: [
                                                Text(
                                                  'total_price'.tr,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  "\$${(double.parse(ValueStatic.totalPrice) - (double.parse(ValueStatic.totalPrice) * (ValueStatic.travelPackageDis / 100))).toStringAsFixed(2)}",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (controller.isTravelPackage ==
                                                  true &&
                                              controller.isNoPackage == true &&
                                              controller.isTravelPackageOk ==
                                                  false)
                                            Row(
                                              children: [
                                                Text(
                                                  'total_price'.tr,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Spacer(),
                                                if (ValueStatic
                                                    .totalPrice
                                                    .isNotEmpty)
                                                  Text(
                                                    ValueStatic.seatPriceGoDiscount ==
                                                            true
                                                        ? "\$${double.parse(((double.parse(ValueStatic.totalPrice) + ValueStatic.luckyDrawValue).toStringAsFixed(2)))}"
                                                        : "\$${double.parse(((double.parse(ValueStatic.totalPrice) - (double.parse((double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)))) + ValueStatic.luckyDrawValue).toStringAsFixed(2))}",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          if (controller.isTravelPackage ==
                                                  true &&
                                              controller.isTravelPackageOk ==
                                                  false &&
                                              controller.isNoPackage == false)
                                            Row(
                                              children: [
                                                Text(
                                                  'total_price'.tr,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Spacer(),
                                                if (ValueStatic
                                                    .totalPrice
                                                    .isNotEmpty)
                                                  Text(
                                                    ValueStatic.seatPriceGoDiscount ==
                                                            true
                                                        ? "\$${double.parse(((double.parse(ValueStatic.totalPrice) + ValueStatic.luckyDrawValue).toStringAsFixed(2)))}"
                                                        : "\$${double.parse(((double.parse(ValueStatic.totalPrice) - (double.parse((double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)))) + ValueStatic.luckyDrawValue).toStringAsFixed(2))}",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                        ],
                                      ),

                                    // * value of one way with travel package different phone number
                                    if (ValueStatic.journeyType == 1 &&
                                        controller.isPhone == true &&
                                        controller.status == 0)
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'sub_total'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '\$${ValueStatic.totalPrice}',
                                              ),
                                            ],
                                          ),
                                          if (controller.isTravelPackage ==
                                                  true &&
                                              controller.isPhone &&
                                              controller.isTravelPackageOk ==
                                                  false)
                                            Column(
                                              children: [
                                                if (ValueStatic
                                                            .seatPriceGoDiscount ==
                                                        true &&
                                                    ValueStatic
                                                            .seatPriceGoDiscount ==
                                                        true)
                                                  const SizedBox(height: 10),

                                                // * when go don't have dis and back have dis
                                                if (ValueStatic
                                                            .seatPriceGoDiscount ==
                                                        true &&
                                                    ValueStatic
                                                            .seatPriceBackDiscount ==
                                                        false)
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'discount'.tr,
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors
                                                                  .textColor,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "\$${((ValueStatic.totalPriceBack) * 0.05).toStringAsFixed(2)}",
                                                      ),
                                                    ],
                                                  ),

                                                // * when go have dis and back have dis
                                                if (ValueStatic
                                                            .seatPriceGoDiscount ==
                                                        false &&
                                                    ValueStatic
                                                            .seatPriceBackDiscount ==
                                                        false)
                                                  const SizedBox(height: 10),

                                                if (ValueStatic
                                                            .seatPriceGoDiscount ==
                                                        false &&
                                                    ValueStatic
                                                            .seatPriceBackDiscount ==
                                                        false)
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'discount'.tr,
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors
                                                                  .textColor,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "\$${(double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)}",
                                                      ),
                                                    ],
                                                  ),

                                                // * when go have dis and back don't have dis
                                                if (ValueStatic
                                                            .seatPriceGoDiscount ==
                                                        false &&
                                                    ValueStatic
                                                            .seatPriceBackDiscount ==
                                                        true)
                                                  const SizedBox(height: 10),
                                                if (ValueStatic
                                                            .seatPriceGoDiscount ==
                                                        false &&
                                                    ValueStatic
                                                            .seatPriceBackDiscount ==
                                                        true)
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'discount'.tr,
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors
                                                                  .textColor,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "\$${((ValueStatic.totalPriceGo) * 0.05).toStringAsFixed(2)}",
                                                      ),
                                                    ],
                                                  ),

                                                controller.luckyDraw
                                                    ? const SizedBox(height: 10)
                                                    : const SizedBox(),

                                                controller.luckyDraw
                                                    ? Row(
                                                      children: [
                                                        Text('lucky_draw'.tr),
                                                        const Spacer(),
                                                        Text(
                                                          ValueStatic.journeyType ==
                                                                  2
                                                              ? '\$${0.25 * (ValueStatic.oneWaySelectedSeat.length + ValueStatic.twoWaySelectedSeat.length)}'
                                                              : '\$${0.25 * ValueStatic.oneWaySelectedSeat.length}',
                                                        ),
                                                      ],
                                                    )
                                                    : const SizedBox(),

                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'total_price'.tr,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const Spacer(),

                                                    // * when go don't have dis and back have dis
                                                    if (ValueStatic
                                                                .seatPriceGoDiscount ==
                                                            true &&
                                                        ValueStatic
                                                                .seatPriceBackDiscount ==
                                                            false)
                                                      Text(
                                                        "\$${double.parse(((double.parse(ValueStatic.totalPrice) - (double.parse(((ValueStatic.totalPriceBack) * 0.05).toStringAsFixed(2)))) + ValueStatic.luckyDrawValue).toStringAsFixed(2))}",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),

                                                    // * when go have dis and back have dis
                                                    if (ValueStatic
                                                                .seatPriceGoDiscount ==
                                                            false &&
                                                        ValueStatic
                                                                .seatPriceBackDiscount ==
                                                            false)
                                                      Text(
                                                        "\$${double.parse(((double.parse(ValueStatic.totalPrice) - (double.parse((double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)))) + ValueStatic.luckyDrawValue).toStringAsFixed(2))}",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),

                                                    // * when go have dis and back don't have dis
                                                    if (ValueStatic
                                                                .seatPriceGoDiscount ==
                                                            false &&
                                                        ValueStatic
                                                                .seatPriceBackDiscount ==
                                                            true)
                                                      Text(
                                                        "\$${double.parse(((double.parse(ValueStatic.totalPrice) - (double.parse(((ValueStatic.totalPriceGo) * 0.05).toStringAsFixed(2)))) + ValueStatic.luckyDrawValue).toStringAsFixed(2))}",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          if (controller.isTravelPackage ==
                                                  true &&
                                              controller.isTravelPackageOk ==
                                                  true)
                                            Column(
                                              children: [
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Text('discount_travel'.tr),
                                                    const Spacer(),
                                                    Text(
                                                      "\$${((double.parse(ValueStatic.totalPrice) * (ValueStatic.travelPackageDis / 100))).toStringAsFixed(2)}",
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          if (controller.isTravelPackage ==
                                                  true &&
                                              controller.isTravelPackageOk ==
                                                  false)
                                            if (ValueStatic
                                                        .seatPriceGoDiscount ==
                                                    true &&
                                                ValueStatic
                                                        .seatPriceBackDiscount ==
                                                    true)
                                              Column(
                                                children: [
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'discount'.tr,
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors
                                                                  .textColor,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        ValueStatic.seatPriceGoDiscount ==
                                                                true
                                                            ? "\$${double.parse(ValueStatic.totalPrice).toStringAsFixed(2)}"
                                                            : "\$${(double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)}",
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                          if (controller.isTravelPackage ==
                                                  false &&
                                              controller.isTravelPackageOk ==
                                                  true)
                                            if (ValueStatic
                                                        .seatPriceGoDiscount ==
                                                    false &&
                                                ValueStatic
                                                        .seatPriceBackDiscount ==
                                                    false)
                                              Column(
                                                children: [
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'discount'.tr,
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors
                                                                  .textColor,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        ValueStatic.seatPriceGoDiscount ==
                                                                true
                                                            ? "\$${double.parse(ValueStatic.totalPrice).toStringAsFixed(2)}"
                                                            : "\$${(double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)}",
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                          if (controller.isPhone &&
                                              controller.isTravelPackage ==
                                                  false)
                                            Column(
                                              children: [
                                                if (ValueStatic
                                                            .seatPriceGoDiscount ==
                                                        true &&
                                                    ValueStatic
                                                            .seatPriceGoDiscount ==
                                                        true)
                                                  const SizedBox(height: 10),

                                                // * when go don't have dis and back have dis
                                                if (ValueStatic
                                                            .seatPriceGoDiscount ==
                                                        true &&
                                                    ValueStatic
                                                            .seatPriceBackDiscount ==
                                                        false)
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'discount'.tr,
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors
                                                                  .textColor,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "\$${((ValueStatic.totalPriceBack) * 0.05).toStringAsFixed(2)}",
                                                      ),
                                                    ],
                                                  ),

                                                // * when go have dis and back have dis
                                                if (ValueStatic
                                                            .seatPriceGoDiscount ==
                                                        false &&
                                                    ValueStatic
                                                            .seatPriceBackDiscount ==
                                                        false)
                                                  const SizedBox(height: 10),

                                                if (ValueStatic
                                                            .seatPriceGoDiscount ==
                                                        false &&
                                                    ValueStatic
                                                            .seatPriceBackDiscount ==
                                                        false)
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'discount'.tr,
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors
                                                                  .textColor,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "\$${(double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)}",
                                                      ),
                                                    ],
                                                  ),

                                                // * when go have dis and back don't have dis
                                                if (ValueStatic
                                                            .seatPriceGoDiscount ==
                                                        false &&
                                                    ValueStatic
                                                            .seatPriceBackDiscount ==
                                                        true)
                                                  const SizedBox(height: 10),
                                                if (ValueStatic
                                                            .seatPriceGoDiscount ==
                                                        false &&
                                                    ValueStatic
                                                            .seatPriceBackDiscount ==
                                                        true)
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'discount'.tr,
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors
                                                                  .textColor,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "\$${((ValueStatic.totalPriceGo) * 0.05).toStringAsFixed(2)}",
                                                      ),
                                                    ],
                                                  ),

                                                controller.luckyDraw
                                                    ? const SizedBox(height: 10)
                                                    : const SizedBox(),

                                                controller.luckyDraw
                                                    ? Row(
                                                      children: [
                                                        Text('lucky_draw'.tr),
                                                        const Spacer(),
                                                        Text(
                                                          ValueStatic.journeyType ==
                                                                  2
                                                              ? '\$${0.25 * (ValueStatic.oneWaySelectedSeat.length + ValueStatic.twoWaySelectedSeat.length)}'
                                                              : '\$${0.25 * ValueStatic.oneWaySelectedSeat.length}',
                                                        ),
                                                      ],
                                                    )
                                                    : const SizedBox(),

                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'total_price'.tr,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const Spacer(),

                                                    // * when go don't have dis and back have dis
                                                    if (ValueStatic
                                                                .seatPriceGoDiscount ==
                                                            true &&
                                                        ValueStatic
                                                                .seatPriceBackDiscount ==
                                                            false)
                                                      Text(
                                                        "\$${double.parse(((double.parse(ValueStatic.totalPrice) - (double.parse(((ValueStatic.totalPriceBack) * 0.05).toStringAsFixed(2)))) + ValueStatic.luckyDrawValue).toStringAsFixed(2))}",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),

                                                    // * when go have dis and back have dis
                                                    if (ValueStatic
                                                                .seatPriceGoDiscount ==
                                                            false &&
                                                        ValueStatic
                                                                .seatPriceBackDiscount ==
                                                            false)
                                                      Text(
                                                        "\$${double.parse(((double.parse(ValueStatic.totalPrice) - (double.parse((double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)))) + ValueStatic.luckyDrawValue).toStringAsFixed(2))}",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),

                                                    // * when go have dis and back don't have dis
                                                    if (ValueStatic
                                                                .seatPriceGoDiscount ==
                                                            false &&
                                                        ValueStatic
                                                                .seatPriceBackDiscount ==
                                                            true)
                                                      Text(
                                                        "\$${double.parse(((double.parse(ValueStatic.totalPrice) - (double.parse(((ValueStatic.totalPriceGo) * 0.05).toStringAsFixed(2)))) + ValueStatic.luckyDrawValue).toStringAsFixed(2))}",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            //* Terms and Conditions
                            SliverToBoxAdapter(
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => const WebViewScreen(
                                      type: 1,
                                      ticketId: '',
                                    ),
                                    duration: const Duration(
                                      milliseconds: Constrains.duration,
                                    ),
                                    transition: Transition.rightToLeft,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 20,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'click'.tr,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: 'term and policy'.tr,
                                            style: const TextStyle(
                                              color: AppColors.secondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: AppColors.whiteColor,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          child: globalButton(
                            context: context,
                            buttonText: 'process_to_payment'.tr,
                            buttonColor:
                                ValueStatic.ticketType == '3'
                                    ? AppColors.airBusColor
                                    : AppColors.primaryColor,
                            onPressed: () {
                              ///onClick for one way
                              if (ValueStatic.journeyType == 1) {
                                ///check condition for only Kampot to Koh Tral
                                if (ValueStatic.companyTypeOneWay == 4) {
                                  if (controller.checkData(
                                        controller.genderOneWay,
                                      ) ||
                                      ValueStatic.boardingPointOneWayId == '' ||
                                      ValueStatic.dropOffPointOneWayId == '' ||
                                      controller.checkDataNation(
                                        controller.nationalOneWay,
                                      ) ||
                                      controller.check(
                                        controller.getDobOneWay(
                                          controller.dobOneWay,
                                        ),
                                      ) ||
                                      controller.check(
                                        controller.getPassportOneWay(
                                          controller.passportOneWay,
                                        ),
                                      ) ||
                                      controller.check(
                                        controller.getNameOneWay(
                                          controller.nameOneWay,
                                        ),
                                      )) {
                                    alertDialogOneButton(
                                      title: 'information'.tr,
                                      description:
                                          "please_input_require_data".tr,
                                      buttonText: 'yes'.tr,
                                    );
                                  } else {
                                    _callGetData(context, isConfirm: true);
                                  }
                                }
                                ///normal route
                                else {
                                  if (controller.checkData(
                                        controller.genderOneWay,
                                      ) ||
                                      ValueStatic.boardingPointOneWayId == '' ||
                                      ValueStatic.dropOffPointOneWayId == '' ||
                                      controller.checkDataNation(
                                        controller.nationalOneWay,
                                      )) {
                                    alertDialogOneButton(
                                      title: 'information'.tr,
                                      description:
                                          "please_input_require_data".tr,
                                      buttonText: 'yes'.tr,
                                    );
                                  } else {
                                    _callGetData(context, isConfirm: true);
                                  }
                                }
                              }
                              ///onClick for round trip
                              else {
                                ///check condition for only Kampot to Koh Tral
                                if (ValueStatic.companyTypeTwoWay == 4 &&
                                    ValueStatic.companyTypeOneWay == 4) {
                                  final hasError =
                                      controller.checkData(
                                        controller.genderOneWay,
                                      ) ||
                                      controller.checkData(
                                        controller.genderTwoWay,
                                      ) ||
                                      ValueStatic.boardingPointOneWayId == '' ||
                                      ValueStatic.dropOffPointOneWayId == '' ||
                                      ValueStatic.dropOffPointTwoWayId == '' ||
                                      controller.checkDataNation(
                                        controller.nationalOneWay,
                                      ) ||
                                      controller.checkDataNation(
                                        controller.nationalTwoWay,
                                      ) ||
                                      controller.check(
                                        controller.getDobOneWay(
                                          controller.dobOneWay,
                                        ),
                                      ) ||
                                      controller.check(
                                        controller.getDobTwoWay(
                                          controller.dobTwoWay,
                                        ),
                                      ) ||
                                      controller.check(
                                        controller.getPassportOneWay(
                                          controller.passportOneWay,
                                        ),
                                      ) ||
                                      controller.check(
                                        controller.getPassportTwoWay(
                                          controller.passportTwoWay,
                                        ),
                                      ) ||
                                      controller.check(
                                        controller.getNameOneWay(
                                          controller.nameOneWay,
                                        ),
                                      ) ||
                                      controller.check(
                                        controller.getNameTwoWay(
                                          controller.nameTwoWay,
                                        ),
                                      );

                                  if (hasError) {
                                    alertDialogOneButton(
                                      title: 'information'.tr,
                                      description:
                                          "please_input_require_data".tr,
                                      buttonText: 'yes'.tr,
                                    );
                                  } else {
                                    _callGetData(context, isConfirm: true);
                                  }
                                }
                                ///normal route
                                else {
                                  if (controller.checkData(
                                        controller.genderOneWay,
                                      ) ||
                                      controller.checkDataNation(
                                        controller.nationalOneWay,
                                      ) ||
                                      controller.checkData(
                                        controller.genderTwoWay,
                                      ) ||
                                      controller.checkDataNation(
                                        controller.nationalTwoWay,
                                      ) ||
                                      ValueStatic.boardingPointTwoWayId == '' ||
                                      ValueStatic.boardingPointOneWayId == '' ||
                                      ValueStatic.dropOffPointOneWayId == '' ||
                                      ValueStatic.dropOffPointTwoWayId == '') {
                                    alertDialogOneButton(
                                      title: 'information'.tr,
                                      description:
                                          "please_input_require_data".tr,
                                      buttonText: 'yes'.tr,
                                    );
                                  } else {
                                    _callGetData(context, isConfirm: true);
                                  }
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
