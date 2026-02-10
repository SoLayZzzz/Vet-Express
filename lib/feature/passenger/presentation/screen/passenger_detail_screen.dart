import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:date_format_field/date_format_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:express_vet/activities/ticket/value_statics.dart';
import 'package:express_vet/api/user.dart';
import 'package:express_vet/utils/alert_dialog.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/button.dart';

import '../../../../base/base_url.dart';
import '../../../../api/boarding_point.dart';
import '../../../../api/booking.dart';
import '../../../../api/travel_package.dart';
import '../../../auth/data/model/response/nationality_response.dart';
import '../../../../models/boarding_point.dart';
import '../../../../models/booking/check_booking_package_apply_response.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_pref.dart';
import '../../../../utils/contains.dart';
import '../../../../utils/loading.dart';
import '../../../../utils/style.dart';
import '../../../../activities/screen/coupon_screen.dart';
import '../../../../activities/screen/web_view_screen.dart';

class PassengerDetailScreen extends StatefulWidget {
  const PassengerDetailScreen({super.key});

  @override
  State<PassengerDetailScreen> createState() => _PassengerDetailScreenState();
}

class _PassengerDetailScreenState extends State<PassengerDetailScreen> {
  final FocusNode inputFocusNode = FocusNode();

  late Future<CarPointResponse> futureBoardingPointOneWay;
  late Future<CarPointResponse> futureDropOffPointOneWay;
  late Future<CarPointResponse> futureBoardingPointTwoWay;
  late Future<CarPointResponse> futureDropOffPointTwoWay;

  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final codeController = TextEditingController();
  final couponController = TextEditingController();

  //one way
  List<String> genderOneWay = [];
  List<int> nationalOneWay = [];
  List<TextEditingController> dobOneWay = [];
  List<TextEditingController> dobOneWayList = [];
  List<TextEditingController> passportOneWay = [];
  List<TextEditingController> nameOneWay = [];
  //round trip
  List<String> genderTwoWay = [];
  List<int> nationalTwoWay = [];
  List<TextEditingController> dobTwoWay = [];
  List<TextEditingController> dobTwoWayList = [];
  List<TextEditingController> passportTwoWay = [];
  List<TextEditingController> nameTwoWay = [];

  //destination
  List<String> boardingPointOneway = [];
  List<String> dropOffPointOneway = [];
  List<String> boardingPointTwoWay = [];
  List<String> dropOffPointTwoWay = [];

  //*lucky draw tick or un_tick
  bool luckyDraw = false;

  //*tick or un_tick apply package
  bool isTravelPackage = false;

  bool isLoaded = false;
  bool isTravelPackageOk = false;

  //*check phone number change or not change
  bool isPhone = false;
  //*check this acc has package or not
  bool isNoPackage = false;

  Color getColor(Set<WidgetState> states) {
    const Set<WidgetState> interactiveStates = <WidgetState>{
      WidgetState.pressed,
      WidgetState.hovered,
      WidgetState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.grey[300]!;
    }
    return Colors.grey[300]!;
  }

  // * nationality
  List<int?> nationalityIds = List.filled(
    ValueStatic.oneWaySelectedSeat.length,
    null,
  );
  List<int?> nationalityIdsTwoWay = List.filled(
    ValueStatic.twoWaySelectedSeat.length,
    null,
  );
  late final Future<NationalityResponse> futureNationality;
  final nationalityController = TextEditingController();

  // * boarding and drop off point
  String selectedBoardingPointOneWay =
      "select_boarding".tr; // Define a variable to hold the selected value
  String selectedBoardingPointAddressOneWay = "";
  int isSelectedIndexBoardingOneWay = -1;
  int isSelectedIndexDropOffOneWay = -1;
  String selectBoardingPointTwoWay =
      "select_boarding".tr; // Define a variable to hold the selected value
  String selectBoardingPointAddressTwoWay =
      ""; // Define a variable to hold the selected value
  int isSelectIndexBoardingTwoWay = -1;
  int isSelectIndexDropOffTwoWay = -1;
  String selectedDropPointOneWay =
      "select_drop".tr; // Define a variable to hold the selected value
  String selectedDropPointAddressOneWay =
      ""; // Define a variable to hold the selected value
  String selectDropPointTwoWay =
      "select_drop".tr; // Define a variable to hold the selected value
  String selectDropPointAddressTwoWay =
      ""; // Define a variable to hold the selected value

  String msgPackage = ''; //get message when check travel package
  int packageTypeOneWay =
      0; //check travel package type (normal and student's A)
  int packageTypeTwoWay =
      0; //check travel package type (normal and student's A)

  ///coupon code
  int status = 0;
  String balance = '';

  @override
  void initState() {
    super.initState();

    futureBoardingPointOneWay = CarPoint().getBoardingPoint(
      context,
      ValueStatic.goDate,
      ValueStatic.journeyIdGo.toString(),
    );
    futureDropOffPointOneWay = CarPoint().getDropOffPoint(
      context,
      ValueStatic.journeyIdGo.toString(),
    );

    if (ValueStatic.journeyType == 2) {
      futureBoardingPointTwoWay = CarPoint().getBoardingPoint(
        context,
        ValueStatic.backDate,
        ValueStatic.journeyIdBack.toString(),
      );
      futureDropOffPointTwoWay = CarPoint().getDropOffPoint(
        context,
        ValueStatic.journeyIdBack.toString(),
      );
    }

    if (ValueStatic.journeyType == 1) {
      ValueStatic.totalPrice = getTotalAmount(seatPriceGo()).toStringAsFixed(2);
    } else {
      ValueStatic.totalPrice = (getTotalAmount(seatPriceGo()) +
              getTotalAmount(seatPriceBack()))
          .toStringAsFixed(2);
    }

    ValueStatic.totalPriceBack = getTotalAmount(seatPriceBack());
    ValueStatic.totalPriceGo = getTotalAmount(seatPriceGo());

    // *  set text to edit text
    phoneNumberController.text = ValueStatic.phone;
    usernameController.text = ValueStatic.username;
    emailController.text = ValueStatic.email;

    // * create list for gender, national, dob and passport
    createGenderListOneWay();
    createNationalListOneWay();
    createGenderListTwoWay();
    createNationalListTwoWay();
    createDobOneWay();
    createDobOneWayList();
    createPassportOneWay();
    createNameOneWay();
    createDobTwoWay();
    createDobTwoWayList();
    createPassportTwoWay();
    createNameTwoWay();

    //* create list for drop box when API return null body
    boardingListOneway();
    dropOffListOneway();
    boardingListTwoWay();
    dropOffListTwoWay();

    futureNationality = User().getNationalityTicket(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBarVET().appBar(context, 'passenger'.tr),
        body: SafeArea(
          child: Column(
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
                                controller: usernameController,
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
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: TextField(
                                controller: phoneNumberController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                                onChanged: (value) {
                                  if (value != ValueStatic.phone) {
                                    setState(() {
                                      isPhone = true;
                                      isTravelPackageOk = false;
                                      isTravelPackage = false;

                                      codeController.text.isEmpty;
                                    });
                                  } else {
                                    setState(() {
                                      isPhone = false;
                                    });
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                'departure_date:'.tr + ValueStatic.goDate,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),

                              //* boarding point
                              FutureBuilder<CarPointResponse>(
                                future: futureBoardingPointOneWay,
                                builder: (context, data) {
                                  if (data.hasData) {
                                    if ((data.data?.header?.result) == true &&
                                        (data.data?.header?.statusCode) ==
                                            200) {
                                      if ((data.data?.body)!.isNotEmpty) {
                                        if (data.data?.body?.length == 1) {
                                          ValueStatic.boardingPointOneWayId =
                                              (data.data?.body?[0].id)
                                                  .toString();
                                          ValueStatic.boardingPointOneWay =
                                              (data.data?.body?[0].name)
                                                  .toString();
                                        }

                                        if (ValueStatic
                                            .dropOffPointOneWayId
                                            .isNotEmpty) {
                                          getData(isConfirm: false);
                                        }

                                        return Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
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
                                                          AppColors.titleColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  (data.data?.body?.length != 1)
                                                      ? const Text(
                                                        "*",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      )
                                                      : const SizedBox(),
                                                ],
                                              ),
                                            ),
                                            InputDecorator(
                                              decoration: Style.inputText(''),
                                              child:
                                                  (data.data?.body?.length != 1)
                                                      ? InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (
                                                              BuildContext
                                                              context,
                                                            ) {
                                                              return Dialog(
                                                                insetPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                child: SingleChildScrollView(
                                                                  child: SizedBox(
                                                                    width:
                                                                        MediaQuery.of(
                                                                          context,
                                                                        ).size.width,
                                                                    child: Material(
                                                                      child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Padding(
                                                                            padding: const EdgeInsets.symmetric(
                                                                              vertical:
                                                                                  15,
                                                                              horizontal:
                                                                                  20,
                                                                            ),
                                                                            child: Text(
                                                                              'boarding_point'.tr,
                                                                              style: const TextStyle(
                                                                                fontSize:
                                                                                    14,
                                                                                fontWeight:
                                                                                    FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                double.infinity,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.only(
                                                                                bottom:
                                                                                    15.0,
                                                                              ),
                                                                              child: ListView.builder(
                                                                                shrinkWrap:
                                                                                    true,
                                                                                itemCount:
                                                                                    data.data?.body?.length,
                                                                                itemBuilder: (
                                                                                  BuildContext context,
                                                                                  int index,
                                                                                ) {
                                                                                  return CheckboxListTile(
                                                                                    controlAffinity:
                                                                                        ListTileControlAffinity.leading,
                                                                                    value:
                                                                                        isSelectedIndexBoardingOneWay ==
                                                                                        index,
                                                                                    activeColor:
                                                                                        Colors.transparent,
                                                                                    checkColor:
                                                                                        Colors.green,
                                                                                    title: Container(
                                                                                      padding: const EdgeInsets.symmetric(
                                                                                        vertical:
                                                                                            10,
                                                                                        horizontal:
                                                                                            10,
                                                                                      ),
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(
                                                                                          10,
                                                                                        ),
                                                                                        border: Border.all(
                                                                                          color: const Color(
                                                                                            0xffC6C6C6,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      child: Column(
                                                                                        crossAxisAlignment:
                                                                                            CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            "${data.data?.body?[index].name}",
                                                                                            style: const TextStyle(
                                                                                              color:
                                                                                                  AppColors.primaryColor,
                                                                                            ),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            height:
                                                                                                10,
                                                                                          ),
                                                                                          Text(
                                                                                            "${data.data?.body?[index].address}",
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    onChanged:
                                                                                        (data.data?.body?[index].isAllow ==
                                                                                                0)
                                                                                            ? null // Disable onChanged for items with isAllow == 0
                                                                                            : (
                                                                                              bool? value,
                                                                                            ) {
                                                                                              setState(
                                                                                                () {
                                                                                                  if (value ??
                                                                                                      false) {
                                                                                                    isSelectedIndexBoardingOneWay =
                                                                                                        index; // Update the selected index
                                                                                                    selectedBoardingPointOneWay =
                                                                                                        data.data?.body?[index].name ??
                                                                                                        "select_boarding".tr;
                                                                                                    selectedBoardingPointAddressOneWay =
                                                                                                        data.data?.body?[index].address ??
                                                                                                        "";
                                                                                                    ValueStatic.boardingPointOneWayId = (data.data?.body?[index].id).toString();

                                                                                                    ValueStatic.boardingPointOneWay = (data.data?.body?[index].name).toString();
                                                                                                  } else {
                                                                                                    isSelectedIndexBoardingOneWay =
                                                                                                        -1; // Deselect if unchecked
                                                                                                    selectedBoardingPointOneWay =
                                                                                                        'select_boarding'.tr;
                                                                                                    selectedBoardingPointAddressOneWay =
                                                                                                        '';
                                                                                                    ValueStatic.boardingPointOneWayId = '';
                                                                                                  }
                                                                                                },
                                                                                              );
                                                                                              Navigator.pop(
                                                                                                context,
                                                                                              );
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
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    selectedBoardingPointOneWay, // Show the selected value here
                                                                    style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          14,
                                                                      color:
                                                                          AppColors
                                                                              .textColor,
                                                                    ),
                                                                  ),
                                                                  if (selectedBoardingPointOneWay !=
                                                                      "select_boarding"
                                                                          .tr)
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                  if (selectedBoardingPointOneWay !=
                                                                      "select_boarding"
                                                                          .tr)
                                                                    Text(
                                                                      selectedBoardingPointAddressOneWay, // Show the selected value here
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
                                                            const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              color:
                                                                  AppColors
                                                                      .borderColor,
                                                            ),
                                                          ],
                                                        ),
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
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                              color:
                                                                  AppColors
                                                                      .textColor,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Text(
                                                            "${data.data?.body?[0].address}",
                                                            style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14,
                                                              color:
                                                                  AppColors
                                                                      .textColor,
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
                                            ValueStatic.ticketType == '3'
                                                ? AppColors.airBusColor
                                                : AppColors.primaryColor,
                                        strokeWidth: 3.0,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              //* drop off point
                              FutureBuilder<CarPointResponse>(
                                future: futureDropOffPointOneWay,
                                builder: (context, data) {
                                  if (data.hasData) {
                                    if ((data.data?.header?.result) == true &&
                                        (data.data?.header?.statusCode) ==
                                            200) {
                                      if ((data.data?.body)!.isNotEmpty) {
                                        if (data.data?.body?.length == 1) {
                                          ValueStatic.dropOffPointOneWayId =
                                              (data.data?.body?[0].id)
                                                  .toString();
                                          ValueStatic.dropOffPointOneWay =
                                              (data.data?.body?[0].name)
                                                  .toString();
                                        }
                                        if (ValueStatic
                                            .boardingPointOneWayId
                                            .isNotEmpty) {
                                          getData(isConfirm: false);
                                        }

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
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
                                                          AppColors.titleColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  (data.data?.body?.length != 1)
                                                      ? const Text(
                                                        "*",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      )
                                                      : const SizedBox(),
                                                ],
                                              ),
                                            ),
                                            InputDecorator(
                                              decoration: Style.inputText(''),
                                              child:
                                                  (data.data?.body?.length != 1)
                                                      ? InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (
                                                              BuildContext
                                                              context,
                                                            ) {
                                                              return Dialog(
                                                                insetPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                child: SingleChildScrollView(
                                                                  child: SizedBox(
                                                                    width:
                                                                        MediaQuery.of(
                                                                          context,
                                                                        ).size.width,
                                                                    child: Material(
                                                                      child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Padding(
                                                                            padding: const EdgeInsets.symmetric(
                                                                              vertical:
                                                                                  15,
                                                                              horizontal:
                                                                                  20,
                                                                            ),
                                                                            child: Text(
                                                                              'drop_off_point'.tr,
                                                                              style: const TextStyle(
                                                                                fontSize:
                                                                                    14,
                                                                                fontWeight:
                                                                                    FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                double.infinity,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.only(
                                                                                bottom:
                                                                                    15.0,
                                                                              ),
                                                                              child: ListView.builder(
                                                                                shrinkWrap:
                                                                                    true,
                                                                                itemCount:
                                                                                    data.data?.body?.length,
                                                                                itemBuilder: (
                                                                                  BuildContext context,
                                                                                  int index,
                                                                                ) {
                                                                                  return CheckboxListTile(
                                                                                    controlAffinity:
                                                                                        ListTileControlAffinity.leading,
                                                                                    value:
                                                                                        isSelectedIndexDropOffOneWay ==
                                                                                        index,
                                                                                    activeColor:
                                                                                        Colors.transparent,
                                                                                    checkColor:
                                                                                        Colors.green,
                                                                                    title: Container(
                                                                                      padding: const EdgeInsets.symmetric(
                                                                                        vertical:
                                                                                            10,
                                                                                        horizontal:
                                                                                            10,
                                                                                      ),
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(
                                                                                          10,
                                                                                        ),
                                                                                        border: Border.all(
                                                                                          color: const Color(
                                                                                            0xffC6C6C6,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      child: Column(
                                                                                        crossAxisAlignment:
                                                                                            CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            "${data.data?.body?[index].name}",
                                                                                            style: const TextStyle(
                                                                                              color:
                                                                                                  AppColors.primaryColor,
                                                                                            ),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            height:
                                                                                                10,
                                                                                          ),
                                                                                          Text(
                                                                                            "${data.data?.body?[index].address}",
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    onChanged: (
                                                                                      bool? value,
                                                                                    ) {
                                                                                      setState(
                                                                                        () {
                                                                                          if (value ??
                                                                                              false) {
                                                                                            isSelectedIndexDropOffOneWay =
                                                                                                index; // Update the selected index
                                                                                            selectedDropPointOneWay =
                                                                                                data.data?.body?[index].name ??
                                                                                                "select_drop".tr;
                                                                                            selectedDropPointAddressOneWay =
                                                                                                data.data?.body?[index].address ??
                                                                                                "";
                                                                                            ValueStatic.dropOffPointOneWayId = (data.data?.body?[index].id).toString();

                                                                                            ValueStatic.dropOffPointOneWay = (data.data?.body?[index].name).toString();
                                                                                          } else {
                                                                                            isSelectedIndexDropOffOneWay =
                                                                                                -1; // Deselect if unchecked
                                                                                            selectedDropPointOneWay =
                                                                                                'select_drop'.tr;
                                                                                            selectedDropPointAddressOneWay =
                                                                                                '';
                                                                                            ValueStatic.dropOffPointOneWayId = '';
                                                                                          }
                                                                                        },
                                                                                      );
                                                                                      Navigator.pop(
                                                                                        context,
                                                                                      );
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
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    selectedDropPointOneWay, // Show the selected value here
                                                                    style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          14,
                                                                      color:
                                                                          AppColors
                                                                              .textColor,
                                                                    ),
                                                                  ),
                                                                  if (selectedDropPointOneWay !=
                                                                      'select_drop'
                                                                          .tr)
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                  if (selectedDropPointOneWay !=
                                                                      'select_drop'
                                                                          .tr)
                                                                    Text(
                                                                      selectedDropPointAddressOneWay, // Show the selected value here
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
                                                            const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              color:
                                                                  AppColors
                                                                      .borderColor,
                                                            ),
                                                          ],
                                                        ),
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
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                              color:
                                                                  AppColors
                                                                      .textColor,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Text(
                                                            "${data.data?.body?[0].address}",
                                                            style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14,
                                                              color:
                                                                  AppColors
                                                                      .textColor,
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
                                            ValueStatic.ticketType == '3'
                                                ? AppColors.airBusColor
                                                : AppColors.primaryColor,
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
                        Container(
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
                                itemCount:
                                    ValueStatic.oneWaySelectedSeat.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //* Seat Number
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 20,
                                          bottom: 10,
                                        ),
                                        child: Text(
                                          '${'seat_number'.tr} ${(ValueStatic.oneWaySelectedSeat[index]).toString()}',
                                          style: const TextStyle(
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),

                                      //* Name Selection
                                      if (ValueStatic.companyTypeOneWay == 4)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Text.rich(
                                                TextSpan(
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: 'name_pro'.tr,
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.textColor,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: ' *',
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.redColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: TextField(
                                                controller: nameOneWay[index],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 15,
                                                      ),
                                                  hintText: 'name_pro'.tr,
                                                  enabledBorder:
                                                      Style.outlineInputBorder(),
                                                  focusedBorder:
                                                      Style.outlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (ValueStatic.companyTypeOneWay == 4)
                                        const SizedBox(height: 15),

                                      //* Gender Selection
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'gender'.tr,
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.textColor,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text: ' *',
                                                    style: TextStyle(
                                                      color: AppColors.redColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                //* Male Button
                                                InkWell(
                                                  onTap: () {
                                                    genderOneWay.removeAt(
                                                      index,
                                                    );
                                                    genderOneWay.insert(
                                                      index,
                                                      '1',
                                                    );
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    height: 45,
                                                    width:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width /
                                                        3.5,
                                                    decoration:
                                                        genderOneWay[index] ==
                                                                "1"
                                                            ? BoxDecoration(
                                                              color:
                                                                  ValueStatic.ticketType ==
                                                                          '3'
                                                                      ? AppColors
                                                                          .airBusColor
                                                                      : AppColors
                                                                          .primaryColor,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    5,
                                                                  ),
                                                            )
                                                            : BoxDecoration(
                                                              color:
                                                                  AppColors
                                                                      .whiteColor,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    5,
                                                                  ),
                                                              border: Border.all(
                                                                color:
                                                                    AppColors
                                                                        .borderColor,
                                                              ),
                                                            ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            10.0,
                                                          ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Ionicons
                                                                .male_outline,
                                                            color:
                                                                genderOneWay[index] ==
                                                                        "1"
                                                                    ? AppColors
                                                                        .whiteColor
                                                                    : AppColors
                                                                        .textColor,
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            'male'.tr,
                                                            style: TextStyle(
                                                              color:
                                                                  genderOneWay[index] ==
                                                                          "1"
                                                                      ? AppColors
                                                                          .whiteColor
                                                                      : AppColors
                                                                          .textColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                //* Female Button
                                                InkWell(
                                                  onTap: () {
                                                    genderOneWay.removeAt(
                                                      index,
                                                    );
                                                    genderOneWay.insert(
                                                      index,
                                                      '2',
                                                    );
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    height: 45,
                                                    width:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width /
                                                        3.5,
                                                    decoration:
                                                        genderOneWay[index] ==
                                                                "2"
                                                            ? BoxDecoration(
                                                              color:
                                                                  ValueStatic.ticketType ==
                                                                          '3'
                                                                      ? AppColors
                                                                          .airBusColor
                                                                      : AppColors
                                                                          .primaryColor,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    5,
                                                                  ),
                                                            )
                                                            : BoxDecoration(
                                                              color:
                                                                  AppColors
                                                                      .whiteColor,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    5,
                                                                  ),
                                                              border: Border.all(
                                                                color:
                                                                    AppColors
                                                                        .borderColor,
                                                              ),
                                                            ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            10.0,
                                                          ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Ionicons
                                                                .female_outline,
                                                            color:
                                                                genderOneWay[index] ==
                                                                        "2"
                                                                    ? AppColors
                                                                        .whiteColor
                                                                    : AppColors
                                                                        .textColor,
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            'female'.tr,
                                                            style: TextStyle(
                                                              color:
                                                                  genderOneWay[index] ==
                                                                          "2"
                                                                      ? AppColors
                                                                          .whiteColor
                                                                      : AppColors
                                                                          .textColor,
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

                                      //* Nationality Selection
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: 'nationality'.tr,
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.textColor,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text: ' *',
                                                    style: TextStyle(
                                                      color: AppColors.redColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: FutureBuilder<
                                              NationalityResponse
                                            >(
                                              future: futureNationality,
                                              builder: (context, data) {
                                                if (data.hasData) {
                                                  if ((data
                                                              .data
                                                              ?.header
                                                              ?.result) ==
                                                          true &&
                                                      (data
                                                              .data
                                                              ?.header
                                                              ?.statusCode) ==
                                                          200) {
                                                    if ((data.data?.body)!
                                                                .status ==
                                                            true &&
                                                        (data.data?.body)!
                                                            .data!
                                                            .isNotEmpty) {
                                                      return Column(
                                                        children: [
                                                          InputDecorator(
                                                            decoration: InputDecoration(
                                                              isDense: true,
                                                              contentPadding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical: 4,
                                                                  ),
                                                              border:
                                                                  Style.outlineInputBorder(),
                                                              enabledBorder:
                                                                  Style.outlineInputBorder(),
                                                              focusedBorder:
                                                                  Style.outlineInputBorder(),
                                                            ),
                                                            child: DropdownButtonHideUnderline(
                                                              child: DropdownButton2<
                                                                String
                                                              >(
                                                                iconStyleData: const IconStyleData(
                                                                  iconEnabledColor:
                                                                      AppColors
                                                                          .borderColor,
                                                                ),
                                                                isExpanded:
                                                                    true,
                                                                hint: Text(
                                                                  'select_nation'
                                                                      .tr,
                                                                  style:
                                                                      const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                      ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                items:
                                                                    data
                                                                        .data
                                                                        ?.body!
                                                                        .data
                                                                        ?.map(
                                                                          (
                                                                            item,
                                                                          ) => DropdownMenuItem<
                                                                            String
                                                                          >(
                                                                            value:
                                                                                item.name,
                                                                            child: Text(
                                                                              "${item.name}",
                                                                              style: const TextStyle(
                                                                                fontSize:
                                                                                    14,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        )
                                                                        .toList(),
                                                                value:
                                                                    nationalityIds[index] !=
                                                                            null
                                                                        ? data
                                                                            .data
                                                                            ?.body!
                                                                            .data
                                                                            ?.firstWhere(
                                                                              (
                                                                                item,
                                                                              ) =>
                                                                                  item.id ==
                                                                                  nationalityIds[index],
                                                                            )
                                                                            .name
                                                                        : null,
                                                                onChanged: (
                                                                  value,
                                                                ) {
                                                                  setState(() {
                                                                    // Get the selected nationality ID
                                                                    nationalityIds[index] =
                                                                        data
                                                                            .data
                                                                            ?.body!
                                                                            .data
                                                                            ?.firstWhere(
                                                                              (
                                                                                item,
                                                                              ) =>
                                                                                  item.name ==
                                                                                  value,
                                                                            )
                                                                            .id;

                                                                    // Update the nationalOneWay list directly at the index
                                                                    nationalOneWay[index] =
                                                                        nationalityIds[index]!;
                                                                  });
                                                                },
                                                                dropdownStyleData:
                                                                    const DropdownStyleData(
                                                                      width:
                                                                          double
                                                                              .infinity,
                                                                    ),
                                                                menuItemStyleData:
                                                                    const MenuItemStyleData(
                                                                      height:
                                                                          40,
                                                                    ),
                                                                dropdownSearchData: DropdownSearchData(
                                                                  searchController:
                                                                      nationalityController,
                                                                  searchInnerWidgetHeight:
                                                                      50,
                                                                  searchInnerWidget: Container(
                                                                    height: 60,
                                                                    padding:
                                                                        const EdgeInsets.only(
                                                                          top:
                                                                              8,
                                                                          bottom:
                                                                              4,
                                                                          right:
                                                                              8,
                                                                          left:
                                                                              8,
                                                                        ),
                                                                    child: TextFormField(
                                                                      expands:
                                                                          true,
                                                                      maxLines:
                                                                          null,
                                                                      controller:
                                                                          nationalityController,
                                                                      decoration: InputDecoration(
                                                                        isDense:
                                                                            true,
                                                                        contentPadding: const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              8,
                                                                        ),
                                                                        hintText:
                                                                            'search_nation'.tr,
                                                                        hintStyle: const TextStyle(
                                                                          fontSize:
                                                                              12,
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
                                                                    return item
                                                                        .value
                                                                        .toString()
                                                                        .toLowerCase()
                                                                        .contains(
                                                                          searchValue
                                                                              .toLowerCase(),
                                                                        );
                                                                  },
                                                                ),
                                                                //This to clear the search value when you close the menu
                                                                onMenuStateChange: (
                                                                  isOpen,
                                                                ) {
                                                                  if (!isOpen) {
                                                                    nationalityController
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
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),

                                      //* DOB Selection
                                      if (ValueStatic.companyTypeOneWay == 4)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Text.rich(
                                                TextSpan(
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: 'dob'.tr,
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.textColor,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: ' *',
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.redColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Expanded(
                                            //     flex: 2,
                                            //     child: TextField(
                                            //       readOnly: true,
                                            //       controller: dobOneWay[index],
                                            //       style: const TextStyle(fontSize: 14),
                                            //       decoration: InputDecoration(
                                            //         isDense: true,
                                            //         contentPadding: const EdgeInsets.symmetric(
                                            //             horizontal: 10, vertical: 15),
                                            //         hintText: 'yyyy-mm-dd',
                                            //         enabledBorder: Style.outlineInputBorder(),
                                            //         focusedBorder: Style.outlineInputBorder(),
                                            //       ),
                                            //       onTap: () async {
                                            //         DateTime? pickedDate = await showDatePicker(
                                            //           context: context,
                                            //           locale: Get.locale.toString() == "km_KH"
                                            //               ? const Locale("km", "KH")
                                            //               : Get.locale.toString() == "en_US"
                                            //                   ? const Locale("en", "US")
                                            //                   : const Locale("zh", "CN"),
                                            //           initialDate: DateFormat('yyyy-MM-dd')
                                            //               .parse(DateTime.now().toString()),
                                            //           firstDate: DateTime.now()
                                            //               .subtract(const Duration(days: 50000)),
                                            //           lastDate: DateTime.now(),
                                            //           builder: (context, child) {
                                            //             return Theme(
                                            //               data: Theme.of(context).copyWith(
                                            //                 colorScheme: const ColorScheme.light(
                                            //                   primary: AppColors.primaryColor,
                                            //                   onSurface: AppColors.textColor,
                                            //                 ),
                                            //                 textButtonTheme: TextButtonThemeData(
                                            //                   style: TextButton.styleFrom(
                                            //                     foregroundColor:
                                            //                         AppColors.primaryColor,
                                            //                   ),
                                            //                 ),
                                            //               ),
                                            //               child: child!,
                                            //             );
                                            //           },
                                            //         );
                                            //
                                            //         if (pickedDate != null) {
                                            //           final DateFormat formatter =
                                            //               DateFormat('yyyy-MM-dd');
                                            //           dobOneWay[index].text =
                                            //               formatter.format(pickedDate);
                                            //
                                            //           setState(() {});
                                            //         }
                                            //       },
                                            //     )),
                                            Expanded(
                                              flex: 2,
                                              child: DateFormatField(
                                                controller:
                                                    dobOneWayList[index],
                                                addCalendar: false,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 15,
                                                      ),
                                                  hintText: 'dd-MM-yyyy',
                                                  enabledBorder:
                                                      Style.outlineInputBorder(),
                                                  focusedBorder:
                                                      Style.outlineInputBorder(),
                                                ),
                                                initialDate: DateFormat(
                                                  'yyyy-MM-dd',
                                                ).parse(
                                                  DateTime.now().toString(),
                                                ),
                                                firstDate: DateTime.now()
                                                    .subtract(
                                                      const Duration(
                                                        days: 50000,
                                                      ),
                                                    ),
                                                lastDate: DateTime.now(),
                                                type: DateFormatType.type4,
                                                onComplete: (date) {
                                                  if (date != null) {
                                                    if (date.isAfter(
                                                      DateTime.now(),
                                                    )) {
                                                      dobOneWayList[index]
                                                          .text = '';
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Please input a date not greater than today.',
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      dobOneWayList[index]
                                                          .text = DateFormat(
                                                        'dd-MM-yyyy',
                                                      ).format(date);
                                                      dobOneWay[index]
                                                          .text = DateFormat(
                                                        'yyyy-MM-dd',
                                                      ).format(date);

                                                      setState(() {});
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (ValueStatic.companyTypeOneWay == 4)
                                        const SizedBox(height: 15),

                                      //* Passport Number Selection
                                      if (ValueStatic.companyTypeOneWay == 4)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Text.rich(
                                                TextSpan(
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: 'passport'.tr,
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.textColor,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: ' *',
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.redColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: TextField(
                                                controller:
                                                    passportOneWay[index],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 15,
                                                      ),
                                                  hintText: 'Passport number',
                                                  enabledBorder:
                                                      Style.outlineInputBorder(),
                                                  focusedBorder:
                                                      Style.outlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (ValueStatic.companyTypeOneWay == 4)
                                        const SizedBox(height: 20),
                                    ],
                                  );
                                },
                                separatorBuilder: (
                                  BuildContext context,
                                  int index,
                                ) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Image.asset(
                                      "assets/images/img_line.png",
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  'departure_date:'.tr + ValueStatic.backDate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: AppColors.titleColor,
                                  ),
                                ),

                                //* boarding point two way
                                FutureBuilder<CarPointResponse>(
                                  future: futureBoardingPointTwoWay,
                                  builder: (context, data) {
                                    if (data.hasData) {
                                      if ((data.data?.header?.result) == true &&
                                          (data.data?.header?.statusCode) ==
                                              200) {
                                        if ((data.data?.body)!.isNotEmpty) {
                                          if (data.data?.body?.length == 1) {
                                            ValueStatic.boardingPointTwoWayId =
                                                (data.data?.body?[0].id)
                                                    .toString();
                                            ValueStatic.boardingPointTwoWay =
                                                (data.data?.body?[0].name)
                                                    .toString();
                                          }

                                          if (ValueStatic
                                              .dropOffPointOneWayId
                                              .isNotEmpty) {
                                            getData(isConfirm: false);
                                          }

                                          return Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 10,
                                                  bottom: 5,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'boarding_point'.tr,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14,
                                                        color:
                                                            AppColors
                                                                .titleColor,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    (data.data?.body?.length !=
                                                            1)
                                                        ? const Text(
                                                          "*",
                                                          style: TextStyle(
                                                            color: Colors.red,
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
                                                          Radius.circular(5),
                                                        ),
                                                  ),
                                                ),
                                                child:
                                                    (data.data?.body?.length !=
                                                            1)
                                                        ? InkWell(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (
                                                                BuildContext
                                                                context,
                                                              ) {
                                                                return Dialog(
                                                                  insetPadding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  child: SingleChildScrollView(
                                                                    child: SizedBox(
                                                                      width:
                                                                          MediaQuery.of(
                                                                            context,
                                                                          ).size.width,
                                                                      child: Material(
                                                                        child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(
                                                                                vertical:
                                                                                    15,
                                                                                horizontal:
                                                                                    20,
                                                                              ),
                                                                              child: Text(
                                                                                'boarding_point'.tr,
                                                                                style: const TextStyle(
                                                                                  fontSize:
                                                                                      14,
                                                                                  fontWeight:
                                                                                      FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width:
                                                                                  double.infinity,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(
                                                                                  bottom:
                                                                                      15.0,
                                                                                ),
                                                                                child: ListView.builder(
                                                                                  shrinkWrap:
                                                                                      true,
                                                                                  itemCount:
                                                                                      data.data?.body?.length,
                                                                                  itemBuilder: (
                                                                                    BuildContext context,
                                                                                    int index,
                                                                                  ) {
                                                                                    return CheckboxListTile(
                                                                                      controlAffinity:
                                                                                          ListTileControlAffinity.leading,
                                                                                      value:
                                                                                          isSelectIndexBoardingTwoWay ==
                                                                                          index,
                                                                                      activeColor:
                                                                                          Colors.transparent,
                                                                                      checkColor:
                                                                                          Colors.green,
                                                                                      title: Container(
                                                                                        padding: const EdgeInsets.symmetric(
                                                                                          vertical:
                                                                                              10,
                                                                                          horizontal:
                                                                                              10,
                                                                                        ),
                                                                                        decoration: BoxDecoration(
                                                                                          borderRadius: BorderRadius.circular(
                                                                                            10,
                                                                                          ),
                                                                                          border: Border.all(
                                                                                            color: const Color(
                                                                                              0xffC6C6C6,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        child: Column(
                                                                                          crossAxisAlignment:
                                                                                              CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Text(
                                                                                              "${data.data?.body?[index].name}",
                                                                                              style: const TextStyle(
                                                                                                color:
                                                                                                    AppColors.primaryColor,
                                                                                              ),
                                                                                            ),
                                                                                            const SizedBox(
                                                                                              height:
                                                                                                  10,
                                                                                            ),
                                                                                            Text(
                                                                                              "${data.data?.body?[index].address}",
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      onChanged:
                                                                                          (data.data?.body?[index].isAllow ==
                                                                                                  0)
                                                                                              ? null // Disable onChanged for items with isAllow == 0
                                                                                              : (
                                                                                                bool? value,
                                                                                              ) {
                                                                                                setState(
                                                                                                  () {
                                                                                                    if (value ??
                                                                                                        false) {
                                                                                                      isSelectIndexBoardingTwoWay =
                                                                                                          index; // Update the selected index
                                                                                                      selectBoardingPointTwoWay =
                                                                                                          data.data?.body?[index].name ??
                                                                                                          "select_boarding".tr;
                                                                                                      selectBoardingPointAddressTwoWay =
                                                                                                          data.data?.body?[index].address ??
                                                                                                          "";
                                                                                                      ValueStatic.boardingPointTwoWayId = (data.data?.body?[index].id).toString();
                                                                                                      ValueStatic.boardingPointTwoWay = (data.data?.body?[index].name).toString();
                                                                                                    } else {
                                                                                                      isSelectIndexBoardingTwoWay =
                                                                                                          -1; // Deselect if unchecked
                                                                                                      selectBoardingPointTwoWay =
                                                                                                          'select_boarding'.tr;
                                                                                                      selectBoardingPointAddressTwoWay =
                                                                                                          '';
                                                                                                      ValueStatic.boardingPointTwoWayId = '';
                                                                                                    }
                                                                                                  },
                                                                                                );
                                                                                                Navigator.pop(
                                                                                                  context,
                                                                                                );
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
                                                          },
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      selectBoardingPointTwoWay, // Show the selected value here
                                                                      style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontSize:
                                                                            14,
                                                                        color:
                                                                            AppColors.textColor,
                                                                      ),
                                                                    ),
                                                                    if (selectBoardingPointTwoWay !=
                                                                        "select_boarding"
                                                                            .tr)
                                                                      const SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                    if (selectBoardingPointTwoWay !=
                                                                        "select_boarding"
                                                                            .tr)
                                                                      Text(
                                                                        selectBoardingPointAddressTwoWay,
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
                                                              const Icon(
                                                                Icons
                                                                    .arrow_drop_down,
                                                                color:
                                                                    AppColors
                                                                        .borderColor,
                                                              ),
                                                            ],
                                                          ),
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
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 14,
                                                                color:
                                                                    AppColors
                                                                        .textColor,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                            Text(
                                                              "${data.data?.body?[0].address}",
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 14,
                                                                color:
                                                                    AppColors
                                                                        .textColor,
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
                                              ValueStatic.ticketType == '3'
                                                  ? AppColors.airBusColor
                                                  : AppColors.primaryColor,
                                          strokeWidth: 3.0,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                //* drop off two way
                                FutureBuilder<CarPointResponse>(
                                  future: futureDropOffPointTwoWay,
                                  builder: (context, data) {
                                    if (data.hasData) {
                                      if ((data.data?.header?.result) == true &&
                                          (data.data?.header?.statusCode) ==
                                              200) {
                                        if ((data.data?.body)!.isNotEmpty) {
                                          if (data.data?.body?.length == 1) {
                                            ValueStatic.dropOffPointTwoWayId =
                                                (data.data?.body?[0].id)
                                                    .toString();
                                            ValueStatic.dropOffPointTwoWay =
                                                (data.data?.body?[0].name)
                                                    .toString();
                                          }

                                          if (ValueStatic
                                              .boardingPointOneWayId
                                              .isNotEmpty) {
                                            getData(isConfirm: false);
                                          }

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 10,
                                                  bottom: 5,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'drop_off_point'.tr,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14,
                                                        color:
                                                            AppColors
                                                                .titleColor,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    (data.data?.body?.length !=
                                                            1)
                                                        ? const Text(
                                                          "*",
                                                          style: TextStyle(
                                                            color: Colors.red,
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
                                                          Radius.circular(5),
                                                        ),
                                                  ),
                                                ),
                                                child:
                                                    (data.data?.body?.length !=
                                                            1)
                                                        ? InkWell(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (
                                                                BuildContext
                                                                context,
                                                              ) {
                                                                return Dialog(
                                                                  insetPadding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  child: SingleChildScrollView(
                                                                    child: SizedBox(
                                                                      width:
                                                                          MediaQuery.of(
                                                                            context,
                                                                          ).size.width,
                                                                      child: Material(
                                                                        child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(
                                                                                vertical:
                                                                                    15,
                                                                                horizontal:
                                                                                    20,
                                                                              ),
                                                                              child: Text(
                                                                                'drop_off_point'.tr,
                                                                                style: const TextStyle(
                                                                                  fontSize:
                                                                                      14,
                                                                                  fontWeight:
                                                                                      FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width:
                                                                                  double.infinity,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(
                                                                                  bottom:
                                                                                      15.0,
                                                                                ),
                                                                                child: ListView.builder(
                                                                                  shrinkWrap:
                                                                                      true,
                                                                                  itemCount:
                                                                                      data.data?.body?.length,
                                                                                  itemBuilder: (
                                                                                    BuildContext context,
                                                                                    int index,
                                                                                  ) {
                                                                                    return CheckboxListTile(
                                                                                      controlAffinity:
                                                                                          ListTileControlAffinity.leading,
                                                                                      value:
                                                                                          isSelectIndexDropOffTwoWay ==
                                                                                          index,
                                                                                      activeColor:
                                                                                          Colors.transparent,
                                                                                      checkColor:
                                                                                          Colors.green,
                                                                                      title: Container(
                                                                                        padding: const EdgeInsets.symmetric(
                                                                                          vertical:
                                                                                              10,
                                                                                          horizontal:
                                                                                              10,
                                                                                        ),
                                                                                        decoration: BoxDecoration(
                                                                                          borderRadius: BorderRadius.circular(
                                                                                            10,
                                                                                          ),
                                                                                          border: Border.all(
                                                                                            color: const Color(
                                                                                              0xffC6C6C6,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        child: Column(
                                                                                          crossAxisAlignment:
                                                                                              CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Text(
                                                                                              "${data.data?.body?[index].name}",
                                                                                              style: const TextStyle(
                                                                                                color:
                                                                                                    AppColors.primaryColor,
                                                                                              ),
                                                                                            ),
                                                                                            const SizedBox(
                                                                                              height:
                                                                                                  10,
                                                                                            ),
                                                                                            Text(
                                                                                              "${data.data?.body?[index].address}",
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      onChanged: (
                                                                                        bool? value,
                                                                                      ) {
                                                                                        setState(
                                                                                          () {
                                                                                            if (value ??
                                                                                                false) {
                                                                                              isSelectIndexDropOffTwoWay =
                                                                                                  index; // Update the selected index
                                                                                              selectDropPointTwoWay =
                                                                                                  data.data?.body?[index].name ??
                                                                                                  "select_drop".tr;
                                                                                              selectDropPointAddressTwoWay =
                                                                                                  data.data?.body?[index].address ??
                                                                                                  "";
                                                                                              ValueStatic.dropOffPointTwoWayId = (data.data?.body?[index].id).toString();
                                                                                              ValueStatic.dropOffPointTwoWay = (data.data?.body?[index].name).toString();
                                                                                            } else {
                                                                                              isSelectIndexDropOffTwoWay =
                                                                                                  -1; // Deselect if unchecked
                                                                                              selectDropPointTwoWay =
                                                                                                  'select_drop'.tr;
                                                                                              selectDropPointAddressTwoWay =
                                                                                                  '';
                                                                                              ValueStatic.dropOffPointTwoWayId = '';
                                                                                            }
                                                                                          },
                                                                                        );
                                                                                        Navigator.pop(
                                                                                          context,
                                                                                        );
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
                                                          },
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      selectDropPointTwoWay, // Show the selected value here
                                                                      style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontSize:
                                                                            14,
                                                                        color:
                                                                            AppColors.textColor,
                                                                      ),
                                                                    ),
                                                                    if (selectDropPointTwoWay !=
                                                                        "select_drop"
                                                                            .tr)
                                                                      const SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                    if (selectDropPointTwoWay !=
                                                                        "select_drop"
                                                                            .tr)
                                                                      Text(
                                                                        selectDropPointAddressTwoWay,
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
                                                              const Icon(
                                                                Icons
                                                                    .arrow_drop_down,
                                                                color:
                                                                    AppColors
                                                                        .borderColor,
                                                              ),
                                                            ],
                                                          ),
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
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 14,
                                                                color:
                                                                    AppColors
                                                                        .textColor,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                            Text(
                                                              "${data.data?.body?[0].address}",
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 14,
                                                                color:
                                                                    AppColors
                                                                        .textColor,
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
                                              ValueStatic.ticketType == '3'
                                                  ? AppColors.airBusColor
                                                  : AppColors.primaryColor,
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
                          Container(
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
                                  itemCount:
                                      ValueStatic.twoWaySelectedSeat.length,
                                  itemBuilder: (
                                    BuildContext context,
                                    int index,
                                  ) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //* Seat Number
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 20,
                                            bottom: 10,
                                          ),
                                          child: Text(
                                            '${'seat_number'.tr} ${(ValueStatic.twoWaySelectedSeat[index]).toString()}',
                                          ),
                                        ),
                                        const SizedBox(height: 5),

                                        //* Name Selection
                                        if (ValueStatic.companyTypeTwoWay == 4)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text.rich(
                                                  TextSpan(
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                        text: 'name_pro'.tr,
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors
                                                                  .textColor,
                                                        ),
                                                      ),
                                                      const TextSpan(
                                                        text: ' *',
                                                        style: TextStyle(
                                                          color:
                                                              AppColors
                                                                  .redColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: TextField(
                                                  controller: nameTwoWay[index],
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 15,
                                                        ),
                                                    hintText: 'name_pro'.tr,
                                                    enabledBorder:
                                                        Style.outlineInputBorder(),
                                                    focusedBorder:
                                                        Style.outlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (ValueStatic.companyTypeTwoWay == 4)
                                          const SizedBox(height: 15),

                                        //* Gender Selection
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(text: 'gender'.tr),
                                                    const TextSpan(
                                                      text: '*',
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.redColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      genderTwoWay.removeAt(
                                                        index,
                                                      );
                                                      genderTwoWay.insert(
                                                        index,
                                                        '1',
                                                      );
                                                      //print(genderTwoWay);
                                                      setState(() {});
                                                    },
                                                    child: Container(
                                                      height: 45,
                                                      width:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width /
                                                          3.5,
                                                      decoration:
                                                          genderTwoWay[index] ==
                                                                  "1"
                                                              ? BoxDecoration(
                                                                color:
                                                                    ValueStatic.ticketType ==
                                                                            '3'
                                                                        ? AppColors
                                                                            .airBusColor
                                                                        : AppColors
                                                                            .primaryColor,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      5,
                                                                    ),
                                                              )
                                                              : BoxDecoration(
                                                                color:
                                                                    AppColors
                                                                        .whiteColor,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      5,
                                                                    ),
                                                                border: Border.all(
                                                                  color:
                                                                      AppColors
                                                                          .borderColor,
                                                                ),
                                                              ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              10.0,
                                                            ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .person_outline_outlined,
                                                              color:
                                                                  genderTwoWay[index] ==
                                                                          "1"
                                                                      ? AppColors
                                                                          .whiteColor
                                                                      : AppColors
                                                                          .textColor,
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              'male'.tr,
                                                              style: TextStyle(
                                                                color:
                                                                    genderTwoWay[index] ==
                                                                            "1"
                                                                        ? AppColors
                                                                            .whiteColor
                                                                        : AppColors
                                                                            .textColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      genderTwoWay.removeAt(
                                                        index,
                                                      );
                                                      genderTwoWay.insert(
                                                        index,
                                                        '2',
                                                      );
                                                      //print(genderTwoWay);
                                                      setState(() {});
                                                    },
                                                    child: Container(
                                                      height: 45,
                                                      width:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width /
                                                          3.5,
                                                      decoration:
                                                          genderTwoWay[index] ==
                                                                  "2"
                                                              ? BoxDecoration(
                                                                color:
                                                                    ValueStatic.ticketType ==
                                                                            '3'
                                                                        ? AppColors
                                                                            .airBusColor
                                                                        : AppColors
                                                                            .primaryColor,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      5,
                                                                    ),
                                                              )
                                                              : BoxDecoration(
                                                                color:
                                                                    AppColors
                                                                        .whiteColor,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      5,
                                                                    ),
                                                                border: Border.all(
                                                                  color:
                                                                      AppColors
                                                                          .borderColor,
                                                                ),
                                                              ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              10.0,
                                                            ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .person_outline_outlined,
                                                              color:
                                                                  genderTwoWay[index] ==
                                                                          "2"
                                                                      ? AppColors
                                                                          .whiteColor
                                                                      : AppColors
                                                                          .textColor,
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              'female'.tr,
                                                              style: TextStyle(
                                                                color:
                                                                    genderTwoWay[index] ==
                                                                            "2"
                                                                        ? AppColors
                                                                            .whiteColor
                                                                        : AppColors
                                                                            .textColor,
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

                                        //* Nationality Selection
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Text.rich(
                                                TextSpan(
                                                  text: 'nationality'.tr,
                                                  children: const <TextSpan>[
                                                    TextSpan(
                                                      text: ' *',
                                                      style: TextStyle(
                                                        color:
                                                            AppColors
                                                                .primaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: FutureBuilder<
                                                NationalityResponse
                                              >(
                                                future: futureNationality,
                                                builder: (context, data) {
                                                  if (data.hasData) {
                                                    if ((data
                                                                .data
                                                                ?.header
                                                                ?.result) ==
                                                            true &&
                                                        (data
                                                                .data
                                                                ?.header
                                                                ?.statusCode) ==
                                                            200) {
                                                      if ((data.data?.body)!
                                                                  .status ==
                                                              true &&
                                                          (data.data?.body)!
                                                              .data!
                                                              .isNotEmpty) {
                                                        return Column(
                                                          children: [
                                                            InputDecorator(
                                                              decoration: InputDecoration(
                                                                isDense: true,
                                                                contentPadding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          4,
                                                                    ),
                                                                border:
                                                                    Style.outlineInputBorder(),
                                                                enabledBorder:
                                                                    Style.outlineInputBorder(),
                                                                focusedBorder:
                                                                    Style.outlineInputBorder(),
                                                              ),
                                                              child: DropdownButtonHideUnderline(
                                                                child: DropdownButton2<
                                                                  String
                                                                >(
                                                                  isExpanded:
                                                                      true,
                                                                  iconStyleData: const IconStyleData(
                                                                    iconEnabledColor:
                                                                        AppColors
                                                                            .borderColor,
                                                                  ),
                                                                  hint: Text(
                                                                    'select_nation'
                                                                        .tr,
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  items:
                                                                      data
                                                                          .data
                                                                          ?.body!
                                                                          .data
                                                                          ?.map(
                                                                            (
                                                                              item,
                                                                            ) => DropdownMenuItem<
                                                                              String
                                                                            >(
                                                                              value:
                                                                                  item.name,
                                                                              child: Text(
                                                                                "${item.name}",
                                                                                style: const TextStyle(
                                                                                  fontSize:
                                                                                      14,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                          .toList(),
                                                                  value:
                                                                      nationalityIdsTwoWay[index] !=
                                                                              null
                                                                          ? data
                                                                              .data
                                                                              ?.body!
                                                                              .data
                                                                              ?.firstWhere(
                                                                                (
                                                                                  item,
                                                                                ) =>
                                                                                    item.id ==
                                                                                    nationalityIdsTwoWay[index],
                                                                              )
                                                                              .name
                                                                          : null,
                                                                  onChanged: (
                                                                    value,
                                                                  ) {
                                                                    setState(() {
                                                                      // Get the selected nationality ID
                                                                      nationalityIdsTwoWay[index] =
                                                                          data
                                                                              .data
                                                                              ?.body!
                                                                              .data
                                                                              ?.firstWhere(
                                                                                (
                                                                                  item,
                                                                                ) =>
                                                                                    item.name ==
                                                                                    value,
                                                                              )
                                                                              .id;

                                                                      // Update the nationalTwoWay list directly at the index
                                                                      nationalTwoWay[index] =
                                                                          nationalityIdsTwoWay[index]!;
                                                                    });
                                                                  },
                                                                  dropdownStyleData:
                                                                      const DropdownStyleData(
                                                                        /*maxHeight: 400,*/
                                                                        width:
                                                                            double.infinity,
                                                                      ),
                                                                  menuItemStyleData:
                                                                      const MenuItemStyleData(
                                                                        height:
                                                                            40,
                                                                      ),
                                                                  dropdownSearchData: DropdownSearchData(
                                                                    searchController:
                                                                        nationalityController,
                                                                    searchInnerWidgetHeight:
                                                                        50,
                                                                    searchInnerWidget: Container(
                                                                      height:
                                                                          60,
                                                                      padding: const EdgeInsets.only(
                                                                        top: 8,
                                                                        bottom:
                                                                            4,
                                                                        right:
                                                                            8,
                                                                        left: 8,
                                                                      ),
                                                                      child: TextFormField(
                                                                        expands:
                                                                            true,
                                                                        maxLines:
                                                                            null,
                                                                        controller:
                                                                            nationalityController,
                                                                        decoration: InputDecoration(
                                                                          isDense:
                                                                              true,
                                                                          contentPadding: const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10,
                                                                            vertical:
                                                                                8,
                                                                          ),
                                                                          hintText:
                                                                              'search_nation'.tr,
                                                                          hintStyle: const TextStyle(
                                                                            fontSize:
                                                                                12,
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
                                                                      return item
                                                                          .value
                                                                          .toString()
                                                                          .toLowerCase()
                                                                          .contains(
                                                                            searchValue.toLowerCase(),
                                                                          );
                                                                    },
                                                                  ),
                                                                  //This to clear the search value when you close the menu
                                                                  onMenuStateChange: (
                                                                    isOpen,
                                                                  ) {
                                                                    if (!isOpen) {
                                                                      nationalityController
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
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 15),

                                        //* DOB Selection
                                        if (ValueStatic.companyTypeTwoWay == 4)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text.rich(
                                                  TextSpan(
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                        text: 'dob'.tr,
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors
                                                                  .textColor,
                                                        ),
                                                      ),
                                                      const TextSpan(
                                                        text: ' *',
                                                        style: TextStyle(
                                                          color:
                                                              AppColors
                                                                  .redColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: DateFormatField(
                                                  controller:
                                                      dobTwoWayList[index],
                                                  addCalendar: false,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 15,
                                                        ),
                                                    hintText: 'dd-MM-yyyy',
                                                    enabledBorder:
                                                        Style.outlineInputBorder(),
                                                    focusedBorder:
                                                        Style.outlineInputBorder(),
                                                  ),
                                                  initialDate: DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).parse(
                                                    DateTime.now().toString(),
                                                  ),
                                                  firstDate: DateTime.now()
                                                      .subtract(
                                                        const Duration(
                                                          days: 50000,
                                                        ),
                                                      ),
                                                  lastDate: DateTime.now(),
                                                  type: DateFormatType.type4,
                                                  onComplete: (date) {
                                                    if (date != null) {
                                                      if (date.isAfter(
                                                        DateTime.now(),
                                                      )) {
                                                        dobTwoWayList[index]
                                                            .text = '';
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              'Please input a date not greater than today.',
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        dobTwoWayList[index]
                                                            .text = DateFormat(
                                                          'dd-MM-yyyy',
                                                        ).format(date);
                                                        dobTwoWay[index]
                                                            .text = DateFormat(
                                                          'yyyy-MM-dd',
                                                        ).format(date);

                                                        setState(() {});
                                                      }
                                                    }
                                                  },
                                                ),
                                              ),
                                              // Expanded(
                                              //     flex: 2,
                                              //     child: TextField(
                                              //       readOnly: true,
                                              //       controller: dobTwoWay[index],
                                              //       style: const TextStyle(fontSize: 14),
                                              //       decoration: InputDecoration(
                                              //         isDense: true,
                                              //         contentPadding: const EdgeInsets.symmetric(
                                              //             horizontal: 10, vertical: 15),
                                              //         hintText: 'yyyy-mm-dd',
                                              //         enabledBorder: Style.outlineInputBorder(),
                                              //         focusedBorder: Style.outlineInputBorder(),
                                              //       ),
                                              //       onTap: () async {
                                              //         DateTime? pickedDate = await showDatePicker(
                                              //           context: context,
                                              //           locale: Get.locale.toString() == "km_KH"
                                              //               ? const Locale("km", "KH")
                                              //               : Get.locale.toString() == "en_US"
                                              //                   ? const Locale("en", "US")
                                              //                   : const Locale("zh", "CN"),
                                              //           initialDate: DateFormat('yyyy-MM-dd')
                                              //               .parse(DateTime.now().toString()),
                                              //           firstDate: DateTime.now()
                                              //               .subtract(const Duration(days: 50000)),
                                              //           lastDate: DateTime.now(),
                                              //           builder: (context, child) {
                                              //             return Theme(
                                              //               data: Theme.of(context).copyWith(
                                              //                 colorScheme: const ColorScheme.light(
                                              //                   primary: AppColors.primaryColor,
                                              //                   onSurface: AppColors.textColor,
                                              //                 ),
                                              //                 textButtonTheme: TextButtonThemeData(
                                              //                   style: TextButton.styleFrom(
                                              //                     foregroundColor:
                                              //                         AppColors.primaryColor,
                                              //                   ),
                                              //                 ),
                                              //               ),
                                              //               child: child!,
                                              //             );
                                              //           },
                                              //         );
                                              //
                                              //         if (pickedDate != null) {
                                              //           final DateFormat formatter =
                                              //               DateFormat('yyyy-MM-dd');
                                              //           dobTwoWay[index].text =
                                              //               formatter.format(pickedDate);
                                              //           setState(() {});
                                              //         }
                                              //       },
                                              //     ))
                                            ],
                                          ),
                                        if (ValueStatic.companyTypeTwoWay == 4)
                                          const SizedBox(height: 15),

                                        //* Passport Number Selection
                                        if (ValueStatic.companyTypeTwoWay == 4)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text.rich(
                                                  TextSpan(
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                        text: 'passport'.tr,
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors
                                                                  .textColor,
                                                        ),
                                                      ),
                                                      const TextSpan(
                                                        text: ' *',
                                                        style: TextStyle(
                                                          color:
                                                              AppColors
                                                                  .redColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: TextField(
                                                  controller:
                                                      passportTwoWay[index],
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 15,
                                                        ),
                                                    hintText: 'Passport number',
                                                    enabledBorder:
                                                        Style.outlineInputBorder(),
                                                    focusedBorder:
                                                        Style.outlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (ValueStatic.companyTypeTwoWay == 4)
                                          const SizedBox(height: 20),
                                      ],
                                    );
                                  },
                                  separatorBuilder: (
                                    BuildContext context,
                                    int index,
                                  ) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Image.asset(
                                        "assets/images/img_line.png",
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            if (ValueStatic.phone == phoneNumberController.text)
                              ///one way
                              if (ValueStatic.journeyType == 1)
                                ///check the number of seat one way(can apply only when user book one seat)
                                ValueStatic.oneWaySelectedSeat.length == 1
                                    ? Column(
                                      children: [
                                        //* checkbox apply package
                                        Row(
                                          children: [
                                            //* checkbox
                                            Container(
                                              width: 25,
                                              height: 25,
                                              margin: const EdgeInsets.only(
                                                top: 5,
                                              ),
                                              child: Transform.scale(
                                                scale: 1.5,
                                                child: Checkbox(
                                                  tristate: false,
                                                  activeColor: Colors.grey[300],
                                                  fillColor:
                                                      WidgetStateColor.resolveWith(
                                                        (states) =>
                                                            getColor(states),
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
                                                  value: isTravelPackage,
                                                  onChanged:
                                                      (status == 1)
                                                          ? null // disable checkbox when promo code applied
                                                          : (value) async {
                                                            ///user click apply and set isTravelPackage==true
                                                            if (value != null) {
                                                              setState(() {
                                                                isTravelPackage =
                                                                    value;
                                                              });
                                                            }

                                                            ///user not click or un_click apply
                                                            if (value ==
                                                                false) {
                                                              setState(() {
                                                                codeController
                                                                    .text = '';
                                                              });
                                                            }

                                                            ///user apply with the same phone number
                                                            if (value! &&
                                                                !isPhone) {
                                                              ///check user have travel package or not
                                                              final travelPackage =
                                                                  await TravelPackage()
                                                                      .getBuyList(
                                                                        context,
                                                                      );

                                                              /// when user don't have travel package, it will alert dialog
                                                              if (travelPackage
                                                                  .body!
                                                                  .isEmpty) {
                                                                ///when user don't have travel package, set isNoPackage = true;
                                                                setState(() {
                                                                  isNoPackage =
                                                                      true;
                                                                });

                                                                ///alert dialog no package
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

                                                                    ///when user don't have travel package, set isTravelPackage = false; then un_tick the checkbox
                                                                    setState(() {
                                                                      isTravelPackage =
                                                                          false;
                                                                    });
                                                                  },
                                                                );
                                                              }
                                                              ///when user have travel package
                                                              else {
                                                                ///when user have travel package, set isNoPackage = false;
                                                                setState(() {
                                                                  isNoPackage =
                                                                      false;
                                                                });

                                                                ///get the first index package code
                                                                String?
                                                                packageCoded =
                                                                    travelPackage
                                                                        .body?[0]
                                                                        .packageCode;
                                                                codeController
                                                                        .text =
                                                                    packageCoded!;

                                                                ///set the first index package code to inputCodeController
                                                                setState(() {
                                                                  codeController
                                                                          .text =
                                                                      packageCoded;
                                                                  packageTypeOneWay =
                                                                      travelPackage
                                                                          .body![0]
                                                                          .type!
                                                                          .toInt();
                                                                });

                                                                ///check is travel package is normal or A
                                                                if (packageTypeOneWay ==
                                                                        2 &&
                                                                    ValueStatic
                                                                            .vehicleTypeOneWay ==
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
                                                                      setState(() {
                                                                        codeController.text =
                                                                            '';
                                                                        isTravelPackage =
                                                                            false;
                                                                      });
                                                                    },
                                                                  );
                                                                } else {
                                                                  ///check travel package apply available or unavailable
                                                                  final data = await checkPackageApply(
                                                                    context,
                                                                    codeController
                                                                        .text,
                                                                    ValueStatic
                                                                        .journeyIdGo,
                                                                    ValueStatic
                                                                        .goDate,
                                                                  );

                                                                  ///travel package code is ok
                                                                  if (data ==
                                                                      1) {
                                                                    ///save that this travel package code that apply is OK, set isTravelPackageOk = true;
                                                                    setState(() {
                                                                      isTravelPackageOk =
                                                                          true;

                                                                      // disable promo code
                                                                      status =
                                                                          0;
                                                                      couponController
                                                                          .text = '';
                                                                    });
                                                                  }
                                                                  ///travel package code is unavailable
                                                                  else {
                                                                    ///save when this travel package code that apply is unavailable, set isTravelPackageOk = false;
                                                                    ///(sometime package code is expired, invalid, or already apply in this date)
                                                                    setState(() {
                                                                      isTravelPackageOk =
                                                                          false;
                                                                    });

                                                                    ///alert dialog travel package code is unavailable
                                                                    alertDialogTravelPackage(
                                                                      title:
                                                                          'information'
                                                                              .tr,
                                                                      description:
                                                                          msgPackage,
                                                                      buttonText:
                                                                          'yes'
                                                                              .tr,
                                                                      onButtonPressed: () {
                                                                        Navigator.pop(
                                                                          context,
                                                                        );

                                                                        ///when user apply code and the code is unavailable, set isTravelPackage = false; then un_tick the checkbox
                                                                        setState(() {
                                                                          isTravelPackage =
                                                                              false;
                                                                        });
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
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),

                                        ///apply package code with same phone number
                                        if (isTravelPackage && !isPhone)
                                          ///user have package and show the package code in the text_field(view only)
                                          if (!isNoPackage)
                                            Column(
                                              children: [
                                                TextFormField(
                                                  controller: codeController,
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
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                color:
                                                                    Colors.grey,
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
                                                ),
                                                const SizedBox(height: 20),
                                              ],
                                            ),
                                      ],
                                    )
                                    : const SizedBox.shrink(),

                            //* coupon code
                            if (ValueStatic.journeyType == 1)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      (status == 0 && !isTravelPackage)
                                          ? TextButton(
                                            onPressed: () async {
                                              final result = await Get.to(
                                                () => SelectCouponScreen(
                                                  amount:
                                                      ValueStatic.totalPrice,
                                                  travelDate:
                                                      ValueStatic.goDate,
                                                ),
                                                transition:
                                                    Transition.rightToLeft,
                                                duration: const Duration(
                                                  milliseconds:
                                                      Constrains.duration,
                                                ),
                                              );

                                              if (result != null) {
                                                setState(() {
                                                  couponController.text =
                                                      result['code']; // show the applied code
                                                  status =
                                                      result['status']; // save status
                                                  balance =
                                                      result['balance']; // save balance

                                                  // ✅ force disable travel package
                                                  isTravelPackage = false;
                                                  isTravelPackageOk = false;
                                                  codeController.text = '';
                                                });
                                              }
                                            },
                                            child: Text(
                                              'enter_pro'.tr,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppColors.greyColor,
                                              ),
                                            ),
                                          )
                                          : SizedBox.shrink(),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  status == 1
                                      ? TextFormField(
                                        controller: couponController,
                                        autofocus: false,
                                        enabled: false,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        keyboardType: TextInputType.text,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.secondaryColor,
                                        ),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.fromLTRB(
                                            10,
                                            15,
                                            10,
                                            15,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                          ),
                                        ),
                                      )
                                      : SizedBox.shrink(),
                                  status == 1
                                      ? SizedBox(height: 12)
                                      : SizedBox.shrink(),
                                  status == 1
                                      ? RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.textColor,
                                          ),
                                          children: [
                                            TextSpan(text: "pro_available".tr),
                                            TextSpan(text: " \$$balance "),
                                            TextSpan(text: "more".tr),
                                          ],
                                        ),
                                      )
                                      : SizedBox.shrink(),

                                  status == 1
                                      ? SizedBox(height: 6)
                                      : SizedBox.shrink(),

                                  const Divider(),
                                ],
                              ),

                            // * travel package
                            // * check the phone number
                            if (ValueStatic.phone == phoneNumberController.text)
                              ///round trip
                              if (ValueStatic.journeyType == 2)
                                ///check the number of seat round trip(can apply only when user book one seat for one way and one seat for two way)
                                ValueStatic.oneWaySelectedSeat.length == 1 &&
                                        ValueStatic.twoWaySelectedSeat.length ==
                                            1
                                    ? Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 25,
                                              height: 25,
                                              margin: const EdgeInsets.only(
                                                top: 5,
                                              ),
                                              child: Transform.scale(
                                                scale: 1.5,
                                                child: Checkbox(
                                                  tristate: false,
                                                  activeColor: Colors.grey[300],
                                                  fillColor:
                                                      WidgetStateColor.resolveWith(
                                                        (states) =>
                                                            getColor(states),
                                                      ),
                                                  checkColor:
                                                      ValueStatic.ticketType ==
                                                              '3'
                                                          ? AppColors
                                                              .airBusColor
                                                          : AppColors
                                                              .primaryColor,
                                                  side: const BorderSide(
                                                    color: Colors.transparent,
                                                  ),
                                                  value: isTravelPackage,
                                                  onChanged: (value) async {
                                                    if (value != null) {
                                                      setState(() {
                                                        isTravelPackage = value;
                                                      });
                                                    }
                                                    if (value == false) {
                                                      setState(() {
                                                        codeController.text =
                                                            '';
                                                      });
                                                    }

                                                    if (value! && !isPhone) {
                                                      final travelPackage =
                                                          await TravelPackage()
                                                              .getBuyList(
                                                                context,
                                                              );

                                                      if (travelPackage
                                                          .body!
                                                          .isEmpty) {
                                                        setState(() {
                                                          isNoPackage = true;
                                                        });
                                                        alertDialogTravelPackage(
                                                          title:
                                                              "information".tr,
                                                          description:
                                                              "no_package".tr,
                                                          buttonText: 'yes'.tr,
                                                          onButtonPressed: () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            setState(() {
                                                              isTravelPackage =
                                                                  false;
                                                            });
                                                          },
                                                        );
                                                      } else {
                                                        ///when user have travel package, set isNoPackage = false;
                                                        setState(() {
                                                          isNoPackage = false;
                                                        });

                                                        ///get the first index package code
                                                        String? packageCoded =
                                                            travelPackage
                                                                .body?[0]
                                                                .packageCode;
                                                        codeController.text =
                                                            packageCoded!;

                                                        ///set the first index package code to inputCodeController
                                                        setState(() {
                                                          codeController.text =
                                                              packageCoded;
                                                          packageTypeTwoWay =
                                                              travelPackage
                                                                  .body![0]
                                                                  .type!
                                                                  .toInt();
                                                        });

                                                        ///check package code student A
                                                        if (ValueStatic
                                                                    .vehicleTypeOneWay ==
                                                                2 &&
                                                            packageTypeTwoWay ==
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
                                                                'yes'.tr,
                                                            onButtonPressed: () {
                                                              Navigator.pop(
                                                                context,
                                                              );

                                                              ///when user don't have travel package, set isTravelPackage = false; then un_tick the checkbox
                                                              setState(() {
                                                                codeController
                                                                    .text = '';
                                                                isTravelPackage =
                                                                    false;
                                                              });
                                                            },
                                                          );
                                                        } else {
                                                          final data =
                                                              await checkPackageApply(
                                                                context,
                                                                codeController
                                                                    .text,
                                                                ValueStatic
                                                                    .journeyIdGo,
                                                                ValueStatic
                                                                    .goDate,
                                                              );

                                                          if (data == 1) {
                                                            setState(() {
                                                              isTravelPackageOk =
                                                                  true;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              isTravelPackageOk =
                                                                  false;
                                                            });

                                                            alertDialogTravelPackage(
                                                              title:
                                                                  'information'
                                                                      .tr,
                                                              description:
                                                                  msgPackage,
                                                              buttonText:
                                                                  'yes'.tr,
                                                              onButtonPressed: () {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                                setState(() {
                                                                  isTravelPackage =
                                                                      false;
                                                                });
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
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),

                                        ///user apply package code with same phone number
                                        if (isTravelPackage && !isPhone)
                                          ///user have package and show the package code in the text_field(view only)
                                          if (!isNoPackage)
                                            Column(
                                              children: [
                                                TextFormField(
                                                  controller: codeController,
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
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                color:
                                                                    Colors.grey,
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
                                                ),
                                                const SizedBox(height: 10),
                                                const Divider(),
                                                const SizedBox(height: 10),
                                              ],
                                            ),
                                      ],
                                    )
                                    : const SizedBox.shrink(),

                            // * value of one way with coupon code
                            if (ValueStatic.journeyType == 1 && status == 1)
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
                                isPhone == false &&
                                status == 0)
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
                                      Text('\$${ValueStatic.totalPrice}'),
                                    ],
                                  ),
                                  if (isTravelPackage == true &&
                                      isTravelPackageOk == true)
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
                                  if (isTravelPackage == false)
                                    if (ValueStatic.seatPriceGoDiscount ==
                                        false)
                                      Column(
                                        children: [
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Text(
                                                'discount'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
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
                                  if (isTravelPackage == true)
                                    if (isNoPackage == true)
                                      if (ValueStatic.seatPriceGoDiscount ==
                                          false)
                                        Column(
                                          children: [
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Text(
                                                  'discount'.tr,
                                                  style: const TextStyle(
                                                    color: AppColors.textColor,
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
                                  luckyDraw
                                      ? const SizedBox(height: 10)
                                      : const SizedBox(),
                                  luckyDraw
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
                                  if (isTravelPackage == false)
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
                                        if (ValueStatic.totalPrice.isNotEmpty)
                                          Text(
                                            ValueStatic.seatPriceGoDiscount ==
                                                    true
                                                ? "\$${double.parse(((double.parse(ValueStatic.totalPrice) + ValueStatic.luckyDrawValue).toStringAsFixed(2))).toStringAsFixed(2)}"
                                                : "\$${double.parse(((double.parse(ValueStatic.totalPrice) - (double.parse((double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)))) + ValueStatic.luckyDrawValue).toStringAsFixed(2)).toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                  if (isTravelPackage == true &&
                                      isTravelPackageOk == true)
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
                                  if (isTravelPackage == true &&
                                      isNoPackage == true &&
                                      isTravelPackageOk == false)
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
                                        if (ValueStatic.totalPrice.isNotEmpty)
                                          Text(
                                            ValueStatic.seatPriceGoDiscount ==
                                                    true
                                                ? "\$${double.parse(((double.parse(ValueStatic.totalPrice) + ValueStatic.luckyDrawValue).toStringAsFixed(2)))}"
                                                : "\$${double.parse(((double.parse(ValueStatic.totalPrice) - (double.parse((double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)))) + ValueStatic.luckyDrawValue).toStringAsFixed(2)).toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                  if (isTravelPackage == true &&
                                      isTravelPackageOk == false &&
                                      isNoPackage == false)
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
                                        if (ValueStatic.totalPrice.isNotEmpty)
                                          Text(
                                            ValueStatic.seatPriceGoDiscount ==
                                                    true
                                                ? "\$${double.parse(((double.parse(ValueStatic.totalPrice) + ValueStatic.luckyDrawValue).toStringAsFixed(2)))}"
                                                : "\$${double.parse(((double.parse(ValueStatic.totalPrice) - (double.parse((double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)))) + ValueStatic.luckyDrawValue).toStringAsFixed(2))}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),

                            // * value of one way with travel package different phone number
                            if (ValueStatic.journeyType == 1 &&
                                isPhone == true &&
                                status == 0)
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
                                      Text('\$${ValueStatic.totalPrice}'),
                                    ],
                                  ),
                                  if (isTravelPackage == true &&
                                      isTravelPackageOk == true)
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
                                  const SizedBox(height: 10),
                                  if (ValueStatic.seatPriceGoDiscount == false)
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'discount'.tr,
                                              style: const TextStyle(
                                                color: AppColors.textColor,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              "\$${(double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)}",
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  if (isTravelPackage == true)
                                    !isTravelPackageOk
                                        ? Row(
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
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                          ],
                                        )
                                        : Row(
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
                                  if (isTravelPackage == false)
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
                                        if (ValueStatic.totalPrice.isNotEmpty)
                                          Text(
                                            ValueStatic.seatPriceGoDiscount ==
                                                    true
                                                ? "\$${double.parse(((double.parse(ValueStatic.totalPrice) + ValueStatic.luckyDrawValue).toStringAsFixed(2)))}"
                                                : "\$${double.parse(((double.parse(ValueStatic.totalPrice) - (double.parse((double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)))) + ValueStatic.luckyDrawValue).toStringAsFixed(2))}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),

                            // * value of round trip
                            if (ValueStatic.journeyType == 2 &&
                                isPhone == false)
                              if (isTravelPackage == false)
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
                                        Text('\$${ValueStatic.totalPrice}'),
                                      ],
                                    ),
                                    if (ValueStatic.seatPriceGoDiscount ==
                                            true &&
                                        ValueStatic.seatPriceGoDiscount == true)
                                      const SizedBox(height: 10),

                                    // * when go don't have dis and back have dis
                                    if (ValueStatic.seatPriceGoDiscount ==
                                            true &&
                                        ValueStatic.seatPriceBackDiscount ==
                                            false)
                                      Row(
                                        children: [
                                          Text(
                                            'discount'.tr,
                                            style: const TextStyle(
                                              color: AppColors.textColor,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "\$${((ValueStatic.totalPriceBack) * 0.05).toStringAsFixed(2)}",
                                          ),
                                        ],
                                      ),

                                    // * when go have dis and back have dis
                                    if (ValueStatic.seatPriceGoDiscount ==
                                            false &&
                                        ValueStatic.seatPriceBackDiscount ==
                                            false)
                                      const SizedBox(height: 10),

                                    if (ValueStatic.seatPriceGoDiscount ==
                                            false &&
                                        ValueStatic.seatPriceBackDiscount ==
                                            false)
                                      Row(
                                        children: [
                                          Text(
                                            'discount'.tr,
                                            style: const TextStyle(
                                              color: AppColors.textColor,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "\$${(double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)}",
                                          ),
                                        ],
                                      ),

                                    // * when go have dis and back don't have dis
                                    if (ValueStatic.seatPriceGoDiscount ==
                                            false &&
                                        ValueStatic.seatPriceBackDiscount ==
                                            true)
                                      const SizedBox(height: 10),
                                    if (ValueStatic.seatPriceGoDiscount ==
                                            false &&
                                        ValueStatic.seatPriceBackDiscount ==
                                            true)
                                      Row(
                                        children: [
                                          Text(
                                            'discount'.tr,
                                            style: const TextStyle(
                                              color: AppColors.textColor,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "\$${((ValueStatic.totalPriceGo) * 0.05).toStringAsFixed(2)}",
                                          ),
                                        ],
                                      ),

                                    luckyDraw
                                        ? const SizedBox(height: 10)
                                        : const SizedBox(),

                                    luckyDraw
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

                                        // * when go don't have dis and back have dis
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                true &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                false)
                                          Text(
                                            "\$${double.parse(((double.parse(ValueStatic.totalPrice) - (double.parse(((ValueStatic.totalPriceBack) * 0.05).toStringAsFixed(2)))) + ValueStatic.luckyDrawValue).toStringAsFixed(2))}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                        // * when go have dis and back have dis
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                false &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                false)
                                          Text(
                                            "\$${double.parse(((double.parse(ValueStatic.totalPrice) - (double.parse((double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)))) + ValueStatic.luckyDrawValue).toStringAsFixed(2))}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                        // * when go don have dis and back don have dis
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                true &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                true)
                                          Text(
                                            "\$${double.parse(((double.parse(ValueStatic.totalPrice)) + ValueStatic.luckyDrawValue).toStringAsFixed(2))}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                        // * when go have dis and back don't have dis
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                false &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                true)
                                          Text(
                                            "\$${double.parse(((double.parse(ValueStatic.totalPrice) - (double.parse(((ValueStatic.totalPriceGo) * 0.05).toStringAsFixed(2)))) + ValueStatic.luckyDrawValue).toStringAsFixed(2))}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),

                            // * value of round trip and user apply travel package
                            if (ValueStatic.journeyType == 2 &&
                                isPhone == false)
                              if (isTravelPackage)
                                isNoPackage == false
                                    ? Column(
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
                                            Text('\$${ValueStatic.totalPrice}'),
                                          ],
                                        ),
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
                                        luckyDraw
                                            ? const SizedBox(height: 10)
                                            : const SizedBox(),
                                        luckyDraw
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
                                      ],
                                    )
                                    : Column(
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
                                            Text('\$${ValueStatic.totalPrice}'),
                                          ],
                                        ),
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                true &&
                                            ValueStatic.seatPriceGoDiscount ==
                                                true)
                                          const SizedBox(height: 10),

                                        // * when go don't have dis and back have dis
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                true &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                false)
                                          Row(
                                            children: [
                                              Text(
                                                'discount'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "\$${((ValueStatic.totalPriceBack) * 0.05).toStringAsFixed(2)}",
                                              ),
                                            ],
                                          ),

                                        // * when go have dis and back have dis
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                false &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                false)
                                          const SizedBox(height: 10),

                                        if (ValueStatic.seatPriceGoDiscount ==
                                                false &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                false)
                                          Row(
                                            children: [
                                              Text(
                                                'discount'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "\$${(double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)}",
                                              ),
                                            ],
                                          ),

                                        // * when go have dis and back don't have dis
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                false &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                true)
                                          const SizedBox(height: 10),
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                false &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                true)
                                          Row(
                                            children: [
                                              Text(
                                                'discount'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "\$${((ValueStatic.totalPriceGo) * 0.05).toStringAsFixed(2)}",
                                              ),
                                            ],
                                          ),

                                        luckyDraw
                                            ? const SizedBox(height: 10)
                                            : const SizedBox(),

                                        luckyDraw
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
                                                  fontWeight: FontWeight.bold,
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
                                                  fontWeight: FontWeight.bold,
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
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),

                            // * value of two way with travel package different phone number
                            if (ValueStatic.journeyType == 2 && isPhone == true)
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
                                      Text('\$${ValueStatic.totalPrice}'),
                                    ],
                                  ),
                                  if (isTravelPackage &&
                                      isPhone &&
                                      isTravelPackageOk == false)
                                    Column(
                                      children: [
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                true &&
                                            ValueStatic.seatPriceGoDiscount ==
                                                true)
                                          const SizedBox(height: 10),

                                        // * when go don't have dis and back have dis
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                true &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                false)
                                          Row(
                                            children: [
                                              Text(
                                                'discount'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "\$${((ValueStatic.totalPriceBack) * 0.05).toStringAsFixed(2)}",
                                              ),
                                            ],
                                          ),

                                        // * when go have dis and back have dis
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                false &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                false)
                                          const SizedBox(height: 10),

                                        if (ValueStatic.seatPriceGoDiscount ==
                                                false &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                false)
                                          Row(
                                            children: [
                                              Text(
                                                'discount'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "\$${(double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)}",
                                              ),
                                            ],
                                          ),

                                        // * when go have dis and back don't have dis
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                false &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                true)
                                          const SizedBox(height: 10),
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                false &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                true)
                                          Row(
                                            children: [
                                              Text(
                                                'discount'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "\$${((ValueStatic.totalPriceGo) * 0.05).toStringAsFixed(2)}",
                                              ),
                                            ],
                                          ),

                                        luckyDraw
                                            ? const SizedBox(height: 10)
                                            : const SizedBox(),

                                        luckyDraw
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
                                                  fontWeight: FontWeight.bold,
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
                                                  fontWeight: FontWeight.bold,
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
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  if (isTravelPackage == true &&
                                      isTravelPackageOk == true)
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
                                  if (isTravelPackage == true &&
                                      isTravelPackageOk == false)
                                    if (ValueStatic.seatPriceGoDiscount ==
                                            true &&
                                        ValueStatic.seatPriceBackDiscount ==
                                            true)
                                      Column(
                                        children: [
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Text(
                                                'discount'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
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
                                  if (isTravelPackage == false &&
                                      isTravelPackageOk == true)
                                    if (ValueStatic.seatPriceGoDiscount ==
                                            false &&
                                        ValueStatic.seatPriceBackDiscount ==
                                            false)
                                      Column(
                                        children: [
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Text(
                                                'discount'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
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
                                  if (isPhone && isTravelPackage == false)
                                    Column(
                                      children: [
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                true &&
                                            ValueStatic.seatPriceGoDiscount ==
                                                true)
                                          const SizedBox(height: 10),

                                        // * when go don't have dis and back have dis
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                true &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                false)
                                          Row(
                                            children: [
                                              Text(
                                                'discount'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "\$${((ValueStatic.totalPriceBack) * 0.05).toStringAsFixed(2)}",
                                              ),
                                            ],
                                          ),

                                        // * when go have dis and back have dis
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                false &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                false)
                                          const SizedBox(height: 10),

                                        if (ValueStatic.seatPriceGoDiscount ==
                                                false &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                false)
                                          Row(
                                            children: [
                                              Text(
                                                'discount'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "\$${(double.parse(ValueStatic.totalPrice) * 0.05).toStringAsFixed(2)}",
                                              ),
                                            ],
                                          ),

                                        // * when go have dis and back don't have dis
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                false &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                true)
                                          const SizedBox(height: 10),
                                        if (ValueStatic.seatPriceGoDiscount ==
                                                false &&
                                            ValueStatic.seatPriceBackDiscount ==
                                                true)
                                          Row(
                                            children: [
                                              Text(
                                                'discount'.tr,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "\$${((ValueStatic.totalPriceGo) * 0.05).toStringAsFixed(2)}",
                                              ),
                                            ],
                                          ),

                                        luckyDraw
                                            ? const SizedBox(height: 10)
                                            : const SizedBox(),

                                        luckyDraw
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
                                                  fontWeight: FontWeight.bold,
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
                                                  fontWeight: FontWeight.bold,
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
                                                  fontWeight: FontWeight.bold,
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
                            () => const WebViewScreen(type: 1, ticketId: ''),
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
                          if (checkData(genderOneWay) ||
                              ValueStatic.boardingPointOneWayId == '' ||
                              ValueStatic.dropOffPointOneWayId == '' ||
                              checkDataNation(nationalOneWay) ||
                              check(getDobOneWay()) ||
                              check(getPassportOneWay()) ||
                              check(getNameOneWay())) {
                            alertDialogOneButton(
                              title: 'information'.tr,
                              description: "please_input_require_data".tr,
                              buttonText: 'yes'.tr,
                            );
                          } else {
                            getData();
                          }
                        }
                        ///normal route
                        else {
                          if (checkData(genderOneWay) ||
                              ValueStatic.boardingPointOneWayId == '' ||
                              ValueStatic.dropOffPointOneWayId == '' ||
                              checkDataNation(nationalOneWay)) {
                            alertDialogOneButton(
                              title: 'information'.tr,
                              description: "please_input_require_data".tr,
                              buttonText: 'yes'.tr,
                            );
                          } else {
                            getData();
                          }
                        }
                      }
                      ///onClick for round trip
                      else {
                        ///check condition for only Kampot to Koh Tral
                        if (ValueStatic.companyTypeTwoWay == 4 &&
                            ValueStatic.companyTypeOneWay == 4) {
                          if (checkData(genderOneWay) ||
                              checkDataNation(nationalOneWay) ||
                              checkData(genderTwoWay) ||
                              checkDataNation(nationalTwoWay) ||
                              ValueStatic.boardingPointTwoWayId == '' ||
                              ValueStatic.boardingPointOneWayId == '' ||
                              ValueStatic.dropOffPointOneWayId == '' ||
                              ValueStatic.dropOffPointTwoWayId == '' ||
                              check(getDobOneWay()) ||
                              check(getDobTwoWay()) ||
                              check(getPassportOneWay()) ||
                              check(getPassportTwoWay()) ||
                              check(getNameOneWay()) ||
                              check(getNameTwoWay())) {
                            alertDialogOneButton(
                              title: 'information'.tr,
                              description: "please_input_require_data".tr,
                              buttonText: 'yes'.tr,
                            );
                          } else {
                            getData();
                          }
                        }
                        ///normal route
                        else {
                          if (checkData(genderOneWay) ||
                              checkDataNation(nationalOneWay) ||
                              checkData(genderTwoWay) ||
                              checkDataNation(nationalTwoWay) ||
                              ValueStatic.boardingPointTwoWayId == '' ||
                              ValueStatic.boardingPointOneWayId == '' ||
                              ValueStatic.dropOffPointOneWayId == '' ||
                              ValueStatic.dropOffPointTwoWayId == '') {
                            alertDialogOneButton(
                              title: 'information'.tr,
                              description: "please_input_require_data".tr,
                              buttonText: 'yes'.tr,
                            );
                          } else {
                            getData();
                          }
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

  bool checkData(List<String> data) {
    bool check = false;
    for (int i = 0; i < data.length; i++) {
      if (data[i] == '0') {
        check = true;
        break;
      }
    }
    return check;
  }

  bool check(List<String> data) {
    return data.any((item) => item.isEmpty);
  }

  bool checkDataNation(List<int> data) {
    return data.contains(0); // Simplified check
  }

  void getData({bool isConfirm = true}) {
    ValueStatic.luckyDrawValue =
        luckyDraw
            ? ValueStatic.journeyType == 2
                ? 0.25 *
                    (ValueStatic.oneWaySelectedSeat.length +
                        ValueStatic.twoWaySelectedSeat.length)
                : 0.25 * ValueStatic.oneWaySelectedSeat.length
            : 0;

    if (ValueStatic.journeyType == 1) {
      // one way
      if (isConfirm) {
        List<int> boardingPointId = [
          int.parse(ValueStatic.boardingPointOneWayId),
        ];
        List<int> dropOffPointId = [
          int.parse(ValueStatic.dropOffPointOneWayId),
        ];
        String email =
            ValueStatic.email.isEmpty ? 'user@gmail.com' : ValueStatic.email;
        List<String> journeyDate = [ValueStatic.goDate];
        List<String> journeyId = [ValueStatic.journeyIdGo];
        int journeyType = 1;
        String name = ValueStatic.username;
        List<String> seatGender = genderOneWay;
        List<int> seatNationallyId = nationalOneWay;
        List<String> seatJourney = seatJourneyGo();
        List<String> seatName =
            ValueStatic.companyTypeOneWay == 4 ? getNameOneWay() : seatNameGo();
        List<String> seatNum = ValueStatic.oneWaySelectedSeatValue;
        List<double> seatPrice = seatPriceGo();
        String telephone = ValueStatic.phone;

        double totalAmount = getTotalAmount(seatPrice);
        double totalDiscount = 0;
        if (ValueStatic.seatPriceGoDiscount) {
          totalDiscount = 0;
        } else {
          totalDiscount = double.parse(
            (getTotalAmount(seatPrice) * 0.05).toStringAsFixed(2),
          );
        }
        String totalSeat = ValueStatic.oneWaySelectedSeat.length.toString();

        ValueStatic.totalPrice = totalAmount.toString();

        String packageCode =
            codeController.text.isNotEmpty ? codeController.text : '';
        String couponCode =
            couponController.text.isNotEmpty ? couponController.text : '';

        List<String>? seatDob = getDobOneWay();
        List<String>? seatPassport = getPassportOneWay();

        Booking().confirmBooking(
          context,
          boardingPointId,
          dropOffPointId,
          email,
          journeyDate,
          journeyId,
          journeyType,
          name,
          seatGender,
          seatJourney,
          seatName,
          seatNum,
          seatPrice,
          telephone,
          totalAmount,
          totalDiscount,
          totalSeat,
          '2',
          seatNationallyId,
          ValueStatic.national,
          luckyDraw,
          packageCode,
          couponCode,
          seatDob: seatDob,
          seatPassport: seatPassport,
        );
      }
    } else {
      // Two way
      if (isConfirm) {
        List<int> boardingPointId = [
          int.parse(ValueStatic.boardingPointOneWayId),
          int.parse(ValueStatic.boardingPointTwoWayId),
        ];
        List<int> dropOffPointId = [
          int.parse(ValueStatic.dropOffPointOneWayId),
          int.parse(ValueStatic.dropOffPointTwoWayId),
        ];
        String email =
            ValueStatic.email.isEmpty ? 'user@gmail.com' : ValueStatic.email;
        List<String> journeyDate = [ValueStatic.goDate, ValueStatic.backDate];
        List<String> journeyId = [
          ValueStatic.journeyIdGo,
          ValueStatic.journeyIdBack,
        ];
        int journeyType = 2;
        String name = ValueStatic.username;
        // add gender
        List<String> seatGender = [];
        seatGender.addAll(genderOneWay);
        seatGender.addAll(genderTwoWay);

        //add nationality
        List<int> seatNationality = [];
        seatNationality.addAll(nationalOneWay);
        seatNationality.addAll(nationalTwoWay);

        List<String> seatJourney = seatJourneyGo();

        /// check for Kam pot to Koh Tral need to input name
        List<String> seatName = [];
        seatName.addAll(
          ValueStatic.companyTypeOneWay == 4 ? getNameOneWay() : seatNameGo(),
        );
        seatName.addAll(
          ValueStatic.companyTypeTwoWay == 4 ? getNameTwoWay() : seatNameBack(),
        );

        // add seat num
        List<String> seatNum = [];
        seatNum.addAll(ValueStatic.oneWaySelectedSeatValue);
        seatNum.addAll(ValueStatic.twoWaySelectedSeatValue);

        /// Add seat price go and back
        List<double> seatPrice = seatPriceGo();
        List<double> seatPriceRound = seatPriceBack();

        /// Add price to list for send to API
        List<double> totalSeatPrice = [];
        totalSeatPrice.addAll(seatPrice);
        totalSeatPrice.addAll(seatPriceRound);

        String telephone = ValueStatic.phone;

        /// Set Total price go and back
        double totalAmount = getTotalAmount(seatPrice);
        double totalAmountBack = getTotalAmount(seatPriceRound);

        /// Set value to constrain
        ValueStatic.totalPriceGo = totalAmount;
        ValueStatic.totalPriceBack = totalAmountBack;

        /// Calculate discount price
        double totalDiscount = setDiscountTwoWay(seatPrice, seatPriceBack());
        ValueStatic.totalPriceDiscount = totalDiscount;

        String totalSeat =
            (ValueStatic.oneWaySelectedSeat.length +
                    ValueStatic.twoWaySelectedSeat.length)
                .toString();
        ValueStatic.totalPrice = (totalAmount + totalAmountBack).toString();

        String packageCode =
            codeController.text.isNotEmpty ? codeController.text : '';
        String couponCode =
            couponController.text.isNotEmpty ? couponController.text : '';

        // add seat dob
        List<String>? seatDob = [];
        seatDob.addAll(getDobOneWay());
        seatDob.addAll(getDobTwoWay());

        // add seat seatPassport
        List<String>? seatPassport = [];
        seatPassport.addAll(getPassportOneWay());
        seatPassport.addAll(getPassportTwoWay());

        Booking().confirmBooking(
          context,
          boardingPointId,
          dropOffPointId,
          email,
          journeyDate,
          journeyId,
          journeyType,
          name,
          seatGender,
          seatJourney,
          seatName,
          seatNum,
          totalSeatPrice,
          telephone,
          (totalAmount + totalAmountBack),
          // total amount
          totalDiscount,
          totalSeat,
          '2',
          seatNationality,
          ValueStatic.national,
          luckyDraw,
          packageCode,
          couponCode,
          seatDob: seatDob,
          seatPassport: seatPassport,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isLoaded && ValueStatic.totalPrice.isNotEmpty)
        setState(() => isLoaded = true);
    });
  }

  List<String> getDobOneWay() {
    List<String> seatDob = [];

    for (var controller in dobOneWay) {
      seatDob.add(controller.text);
    }
    return seatDob;
  }

  List<String> getDobTwoWay() {
    List<String> seatDob = [];

    for (var controller in dobTwoWay) {
      seatDob.add(controller.text);
    }
    return seatDob;
  }

  List<String> getPassportOneWay() {
    List<String> seatPassport = [];
    for (var controller in passportOneWay) {
      seatPassport.add(controller.text);
    }
    return seatPassport;
  }

  List<String> getNameOneWay() {
    List<String> seatName = [];
    for (var controller in nameOneWay) {
      seatName.add(controller.text);
    }
    return seatName;
  }

  List<String> getNameTwoWay() {
    List<String> seatName = [];
    for (var controller in nameTwoWay) {
      seatName.add(controller.text);
    }
    return seatName;
  }

  List<String> getPassportTwoWay() {
    List<String> seatPassport = [];
    for (var controller in passportTwoWay) {
      seatPassport.add(controller.text);
    }
    return seatPassport;
  }

  double setDiscountTwoWay(List<double> seatPrice, List<double> seatPriceBack) {
    double disCountGo, disCountBack;

    if (ValueStatic.seatPriceGoDiscount) {
      disCountGo = 0;
    } else {
      disCountGo = double.parse(
        (getTotalAmount(seatPrice) * 0.05).toStringAsFixed(2),
      );
    }

    if (ValueStatic.seatPriceBackDiscount) {
      disCountBack = 0;
    } else {
      disCountBack = double.parse(
        (getTotalAmount(seatPriceBack) * 0.05).toStringAsFixed(2),
      );
    }

    return (disCountGo + disCountBack);
  }

  double getTotalAmount(List<double> seatPrice) {
    double totalPrice = 0;
    for (int i = 0; i < seatPrice.length; i++) {
      totalPrice = totalPrice + seatPrice[i];
    }
    return totalPrice;
  }

  List<double> seatPriceGo() {
    List<double> seatPrice = [];
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      seatPrice.add(double.parse(ValueStatic.seatPriceGo));
    }
    return seatPrice;
  }

  List<double> seatPriceBack() {
    List<double> seatPrice = [];
    if (ValueStatic.journeyType == 2) {
      for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
        seatPrice.add(double.parse(ValueStatic.seatPriceBack));
      }
    }
    //print("seatBack$seatPrice");
    return seatPrice;
  }

  List<String> seatNameGo() {
    List<String> seatName = [];
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      seatName.add((ValueStatic.username).toString());
    }
    return seatName;
  }

  List<String> seatNameBack() {
    List<String> seatName = [];
    if (ValueStatic.journeyType == 2) {
      for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
        seatName.add((ValueStatic.username).toString());
      }
    }
    return seatName;
  }

  List<String> seatJourneyGo() {
    List<String> seatJourney = [];
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      seatJourney.add(ValueStatic.journeyIdGo.toString());
    }
    if (ValueStatic.journeyType == 2) {
      for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
        seatJourney.add(ValueStatic.journeyIdBack.toString());
      }
    }
    return seatJourney;
  }

  void createGenderListOneWay() {
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      genderOneWay.add('0');
    }
  }

  void createNationalListOneWay() {
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      nationalOneWay.add(0);
    }
  }

  void createDobOneWay() {
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      dobOneWay.add(TextEditingController());
    }
  }

  void createDobOneWayList() {
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      dobOneWayList.add(TextEditingController());
    }
  }

  void createPassportOneWay() {
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      passportOneWay.add(TextEditingController());
    }
  }

  void createNameOneWay() {
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      nameOneWay.add(TextEditingController());
    }
  }

  void createGenderListTwoWay() {
    for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
      genderTwoWay.add('0');
    }
  }

  void createNationalListTwoWay() {
    for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
      nationalTwoWay.add(0);
    }
  }

  void createDobTwoWay() {
    for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
      dobTwoWay.add(TextEditingController());
    }
  }

  void createDobTwoWayList() {
    for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
      dobTwoWayList.add(TextEditingController());
    }
  }

  void createPassportTwoWay() {
    for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
      passportTwoWay.add(TextEditingController());
    }
  }

  void createNameTwoWay() {
    for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
      nameTwoWay.add(TextEditingController());
    }
  }

  void boardingListOneway() {
    boardingPointOneway.add(ValueStatic.boardingPointOneWay);
    setState(() {});
  }

  void dropOffListOneway() {
    dropOffPointOneway.add(ValueStatic.dropOffPointOneWay);
    setState(() {});
  }

  void boardingListTwoWay() {
    boardingPointTwoWay.add(ValueStatic.boardingPointTwoWay);
    setState(() {});
  }

  void dropOffListTwoWay() {
    dropOffPointTwoWay.add(ValueStatic.dropOffPointTwoWay);
    setState(() {});
  }

  //* check package apply
  checkPackageApply(
    context,
    String code,
    String journeyId,
    String travelDate,
  ) async {
    Loading().loadingShow(context);

    var map = <String, dynamic>{};
    map['code'] = code;
    map['journeyId'] = journeyId;
    map['travelDate'] = travelDate;

    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}booking/checkPackageApply'),
            headers: <String, String>{
              "Content-type": "application/x-www-form-urlencoded",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: map,
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        Loading().loadingClose(context);
        log('This is response check Package Apply ==>> ${response.body}');
        var data = CheckPackageApplyResponse.fromJson(
          jsonDecode(response.body),
        );

        if (data.header!.statusCode == 200 && data.header?.result == true) {
          if (data.body?.status == 1) {
            setState(() {
              ValueStatic.travelPackageDis = data.body!.discount!;
            });
            return 1;
          } else {
            return 0;
          }
        } else if (data.header!.statusCode == 200 &&
            data.header?.result == false) {
          setState(() {
            msgPackage = data.body!.msg!;
          });
          return 0;
        }
      } else {
        throw Exception('Failed to load to server!');
      }
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  ///dispose value
  @override
  void dispose() {
    //inputCodeController.dispose();
    inputFocusNode.dispose();

    // Dispose of the controllers
    for (var controller in dobOneWay) {
      controller.dispose();
    }
    for (var controller in dobOneWayList) {
      controller.dispose();
    }
    for (var controller in passportOneWay) {
      controller.dispose();
    }
    for (var controller in nameOneWay) {
      controller.dispose();
    }
    for (var controller in dobTwoWay) {
      controller.dispose();
    }
    for (var controller in dobTwoWayList) {
      controller.dispose();
    }
    for (var controller in passportTwoWay) {
      controller.dispose();
    }
    for (var controller in nameTwoWay) {
      controller.dispose();
    }

    super.dispose();
  }
}
