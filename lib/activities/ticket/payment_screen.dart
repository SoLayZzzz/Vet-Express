import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:express_vet/activities/ticket/payment_aba_screen.dart';
import 'package:express_vet/activities/ticket/payment_wing_screen.dart';
import 'package:express_vet/activities/ticket/value_statics.dart';
import 'package:express_vet/models/booking/confirm_booking_response.dart';
import 'package:express_vet/models/payment/aba_payment_response.dart';
import 'package:express_vet/utils/button.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../base/base_url.dart';
import '../../api/booking.dart';
import '../../models/booking/process_payment_response.dart';
import '../../utils/alert_dialog.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_pref.dart';
import '../../utils/contains.dart';
import '../../utils/loading.dart';
import '../home_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String id;
  final ConfirmBookingResponse datas;

  const PaymentScreen({super.key, required this.id, required this.datas});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with WidgetsBindingObserver {
  int paymentMethodID =
      0; // 2 cash, 6 credit, 5 ABA, 4 wing, 7 Ali pay //dom rov tam api type
  int paymentMethodSelected =
      0; // 1 ABA and KHQR, 2 Credit Card, 3 Wing, 4 Acleda //ah nis kran tah type del select
  bool loop = true;
  late String newToken;
  bool show = false;

  late WebViewController
  _controller; // WebViewController for webview_flutter 4.x

  @override
  void initState() {
    super.initState();

    // Initialize WebViewController
    _controller = WebViewController();

    // Platform-specific initialization
    if (Platform.isAndroid) {
      final androidController =
          _controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    } else if (Platform.isIOS) {
      final iosController = _controller.platform as WebKitWebViewController;
      iosController.setAllowsBackForwardNavigationGestures(true);
    }

    // Load the initial URL
    _controller.loadRequest(
      Uri.parse('https://example.com'), // Replace with your URL
    );

    // Set JavaScript mode
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      log('On Resume');
      if (paymentMethodSelected == 5) {
        checkPaymentACLEDAComplete(widget.id, newToken);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: popScreen,
      child: Container(
        color: AppColors.whiteColor,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: AppColors.whiteColor,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.blueAccent, size: 34),
              onPressed: () {
                if (popScreen() == true) {
                  Navigator.pop(context);
                }
              },
            ),
            title: Text(
              'cancel'.tr,
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                //* display value
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //* choose payment
                          Text(
                            'choose_payment'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.titleColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          //* bank
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  paymentMethodID = 5;
                                  paymentMethodSelected = 1;
                                  setState(() {});
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color:
                                          paymentMethodSelected == 1
                                              ? ValueStatic.ticketType == '3'
                                                  ? AppColors.airBusColor
                                                  : AppColors.primaryColor
                                              : Colors.grey,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/ic_khqr.png',
                                          height: 44,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 15,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'ABA KHQR',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 5,
                                                      ),
                                                  child: Text(
                                                    'tap_to_pay_with_KHQR'.tr,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Radio(
                                          value: 1,
                                          groupValue: paymentMethodSelected,
                                          fillColor:
                                              WidgetStateColor.resolveWith(
                                                (states) =>
                                                    ValueStatic.ticketType ==
                                                            '3'
                                                        ? AppColors.airBusColor
                                                        : AppColors
                                                            .primaryColor,
                                              ),
                                          onChanged: (value) {
                                            paymentMethodSelected = 1;
                                            paymentMethodID = 5;
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  paymentMethodID = 6;
                                  paymentMethodSelected = 2;
                                  setState(() {});
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color:
                                          paymentMethodSelected == 2
                                              ? ValueStatic.ticketType == '3'
                                                  ? AppColors.airBusColor
                                                  : AppColors.primaryColor
                                              : Colors.grey,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/ic_big_visa.png',
                                          height: 44,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 15,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Credit/Debit Card',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 5,
                                                      ),
                                                  child: Image.asset(
                                                    'assets/images/ic_visa_small.png',
                                                    height: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Radio(
                                          value: 2,
                                          groupValue: paymentMethodSelected,
                                          fillColor:
                                              WidgetStateColor.resolveWith(
                                                (states) =>
                                                    ValueStatic.ticketType ==
                                                            '3'
                                                        ? AppColors.airBusColor
                                                        : AppColors
                                                            .primaryColor,
                                              ),
                                          onChanged: (value) {
                                            paymentMethodSelected = 2;
                                            paymentMethodID = 6;
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  paymentMethodID = 7;
                                  paymentMethodSelected = 3;
                                  setState(() {});
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color:
                                          paymentMethodSelected == 3
                                              ? ValueStatic.ticketType == '3'
                                                  ? AppColors.airBusColor
                                                  : AppColors.primaryColor
                                              : Colors.grey,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/ic_alipay.png',
                                          height: 44,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 15,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'AliPay',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 5,
                                                      ),
                                                  child: Text(
                                                    'tap_to_pay_with_ALIPAY'.tr,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Radio(
                                          value: 3,
                                          groupValue: paymentMethodSelected,
                                          fillColor:
                                              WidgetStateColor.resolveWith(
                                                (states) =>
                                                    ValueStatic.ticketType ==
                                                            '3'
                                                        ? AppColors.airBusColor
                                                        : AppColors
                                                            .primaryColor,
                                              ),
                                          onChanged: (value) {
                                            paymentMethodSelected = 3;
                                            paymentMethodID = 7;
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  paymentMethodID = 4;
                                  paymentMethodSelected = 4;
                                  setState(() {});
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color:
                                          paymentMethodSelected == 4
                                              ? ValueStatic.ticketType == '3'
                                                  ? AppColors.airBusColor
                                                  : AppColors.primaryColor
                                              : Colors.grey,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/ic_wing.jpg',
                                          height: 44,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 15,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Wing Bank',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 5,
                                                      ),
                                                  child: Text(
                                                    'tap_to_pay_wing'.tr,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Radio(
                                          value: 4,
                                          groupValue: paymentMethodSelected,
                                          fillColor:
                                              WidgetStateColor.resolveWith(
                                                (states) =>
                                                    ValueStatic.ticketType ==
                                                            '3'
                                                        ? AppColors.airBusColor
                                                        : AppColors
                                                            .primaryColor,
                                              ),
                                          onChanged: (value) {
                                            paymentMethodSelected = 4;
                                            paymentMethodID = 4;
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  paymentMethodID = 8;
                                  paymentMethodSelected = 5;
                                  setState(() {});
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color:
                                          paymentMethodSelected == 5
                                              ? ValueStatic.ticketType == '3'
                                                  ? AppColors.airBusColor
                                                  : AppColors.primaryColor
                                              : Colors.grey,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/ic_acleda.png',
                                          height: 44,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 15,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'ACLEDA',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 5,
                                                      ),
                                                  child: Text(
                                                    'tap_to_pay_acleda'.tr,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Radio(
                                          value: 5,
                                          groupValue: paymentMethodSelected,
                                          fillColor:
                                              WidgetStateColor.resolveWith(
                                                (states) =>
                                                    ValueStatic.ticketType ==
                                                            '3'
                                                        ? AppColors.airBusColor
                                                        : AppColors
                                                            .primaryColor,
                                              ),
                                          onChanged: (value) {
                                            paymentMethodSelected = 5;
                                            paymentMethodID = 8;
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          //* payment type
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                "payment_method".tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                paymentMethodSelected == 1
                                    ? "ABA KHQR"
                                    : paymentMethodSelected == 2
                                    ? "Credit/Debit Card"
                                    : paymentMethodSelected == 3
                                    ? "AliPay"
                                    : paymentMethodSelected == 4
                                    ? "Wing Bank"
                                    : paymentMethodSelected == 5
                                    ? "ACLEDA"
                                    : "",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),

                          ListView.separated(
                            scrollDirection: Axis.vertical,
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                widget
                                    .datas
                                    .body!
                                    .confirmBookingInformation!
                                    .length,
                            itemBuilder: (context, index) {
                              final data =
                                  widget
                                      .datas
                                      .body!
                                      .confirmBookingInformation![index];
                              final isRoundTrip =
                                  widget
                                      .datas
                                      .body!
                                      .confirmBookingInformation!
                                      .length ==
                                  2;

                              return isRoundTrip
                                  ///round trip
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Display trip destination
                                      show
                                          ? const SizedBox(height: 12)
                                          : const SizedBox.shrink(),

                                      //show see more
                                      if (isRoundTrip == true && index == 1)
                                        !show
                                            ? Row(
                                              children: [
                                                Text(
                                                  "total_amount".tr,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.textColor,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  "\$${(double.parse(widget.datas.body!.orderPaymentLists![0].total ?? '0') + double.parse(widget.datas.body!.orderPaymentLists![1].total ?? '0')).toStringAsFixed(2)}",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                TextButton(
                                                  child: Text(
                                                    "fare_summary".tr,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors
                                                              .secondaryColor,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      show = !show;
                                                    });
                                                  },
                                                ),
                                              ],
                                            )
                                            : const SizedBox.shrink(),

                                      show
                                          ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${data.destinationFrom}${'to'.tr}${data.destinationTo}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),

                                              ListView.separated(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    data
                                                        .bookingSeatDetailList!
                                                        .length,
                                                itemBuilder: (context, i) {
                                                  final seatDetail =
                                                      data.bookingSeatDetailList![i];
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      view(
                                                        'name_pro'.tr,
                                                        seatDetail.name,
                                                      ),
                                                      view(
                                                        'seat_number'.tr,
                                                        seatDetail.seatNumber,
                                                      ),
                                                      view(
                                                        'gender'.tr,
                                                        seatDetail.gender,
                                                      ),
                                                      view(
                                                        'nationality'.tr,
                                                        seatDetail
                                                            .nationalityName,
                                                      ),
                                                      if (seatDetail
                                                          .dob!
                                                          .isNotEmpty)
                                                        view(
                                                          'dob'.tr,
                                                          seatDetail.dob!,
                                                        ),
                                                      if (seatDetail
                                                          .passport!
                                                          .isNotEmpty)
                                                        view(
                                                          'passport'.tr,
                                                          seatDetail.passport!,
                                                        ),
                                                    ],
                                                  );
                                                },
                                                separatorBuilder:
                                                    (_, __) => Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 8.0,
                                                          ),
                                                      child: Image.asset(
                                                        "assets/images/img_line.png",
                                                      ),
                                                    ),
                                              ),

                                              // Display order payment details
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 10.0,
                                                  bottom: 10.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    view(
                                                      "sub_total".tr,
                                                      "${widget.datas.body!.orderPaymentLists![index].grandTotal} \$",
                                                    ),
                                                    view(
                                                      "discount".tr,
                                                      "${widget.datas.body!.orderPaymentLists![index].discount} \$",
                                                    ),
                                                    view(
                                                      index == 0
                                                          ? "total_going".tr
                                                          : "total_return".tr,
                                                      "${widget.datas.body!.orderPaymentLists![index].total} \$",
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              if (isRoundTrip && index == 1)
                                                Column(
                                                  children: [
                                                    const Divider(thickness: 1),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 6.0,
                                                          ),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "total_amount".tr,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500, // Semi-bold for label
                                                              color:
                                                                  AppColors
                                                                      .textColor,
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          Text(
                                                            "\$${(double.parse(widget.datas.body!.orderPaymentLists![0].total ?? '0') + double.parse(widget.datas.body!.orderPaymentLists![1].total ?? '0')).toStringAsFixed(2)}",
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  Colors
                                                                      .black54, // Slightly lighter text for value
                                                            ),
                                                          ),
                                                          TextButton(
                                                            child: Text(
                                                              "show_less".tr,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    AppColors
                                                                        .secondaryColor,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              setState(() {
                                                                show = !show;
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          )
                                          : const SizedBox.shrink(),
                                    ],
                                  )
                                  ///one way
                                  : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Display trip destination
                                      show
                                          ? const SizedBox(height: 12)
                                          : const SizedBox.shrink(),

                                      //show see more
                                      !show
                                          ? Row(
                                            children: [
                                              Text(
                                                "total_amount".tr,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight
                                                          .w500, // Semi-bold for label
                                                  color: AppColors.titleColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "\$${(double.parse(widget.datas.body!.orderPaymentLists![index].total ?? '0')).toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.titleColor,
                                                ),
                                              ),
                                              TextButton(
                                                child: Text(
                                                  "fare_summary".tr,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        AppColors
                                                            .secondaryColor,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    show = !show;
                                                  });
                                                },
                                              ),
                                            ],
                                          )
                                          : const SizedBox.shrink(),

                                      show
                                          ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${data.destinationFrom}${'to'.tr}${data.destinationTo}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),

                                              ListView.separated(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    data
                                                        .bookingSeatDetailList!
                                                        .length,
                                                itemBuilder: (context, i) {
                                                  final seatDetail =
                                                      data.bookingSeatDetailList![i];
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      view(
                                                        'name_pro'.tr,
                                                        seatDetail.name,
                                                      ),
                                                      view(
                                                        'seat_number'.tr,
                                                        seatDetail.seatNumber,
                                                      ),
                                                      view(
                                                        'gender'.tr,
                                                        seatDetail.gender,
                                                      ),
                                                      view(
                                                        'nationality'.tr,
                                                        seatDetail
                                                            .nationalityName,
                                                      ),
                                                      if (seatDetail
                                                          .dob!
                                                          .isNotEmpty)
                                                        view(
                                                          'dob'.tr,
                                                          seatDetail.dob!,
                                                        ),
                                                      if (seatDetail
                                                          .passport!
                                                          .isNotEmpty)
                                                        view(
                                                          'passport'.tr,
                                                          seatDetail.passport!,
                                                        ),
                                                    ],
                                                  );
                                                },
                                                separatorBuilder:
                                                    (_, __) => Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 8.0,
                                                          ),
                                                      child: Image.asset(
                                                        "assets/images/img_line.png",
                                                      ),
                                                    ),
                                              ),

                                              // Display order payment details
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 10.0,
                                                  bottom: 10.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    view(
                                                      "sub_total".tr,
                                                      "${widget.datas.body!.orderPaymentLists![index].grandTotal} \$",
                                                    ),
                                                    view(
                                                      "discount".tr,
                                                      "${widget.datas.body!.orderPaymentLists![index].discount} \$",
                                                    ),
                                                    view(
                                                      "total_ticket_price".tr,
                                                      "${widget.datas.body!.orderPaymentLists![index].total} \$",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                          : const SizedBox.shrink(),

                                      // show see less
                                      show
                                          ? Column(
                                            children: [
                                              const Divider(thickness: 1),
                                              Row(
                                                children: [
                                                  Text(
                                                    "total_amount".tr,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight
                                                              .w500, // Semi-bold for label
                                                      color:
                                                          AppColors.titleColor,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    "\$${(double.parse(widget.datas.body!.orderPaymentLists![index].total ?? '0')).toStringAsFixed(2)}",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          AppColors.titleColor,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    child: Text(
                                                      "show_less".tr,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            AppColors
                                                                .secondaryColor,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        show = !show;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                          : const SizedBox.shrink(),
                                    ],
                                  );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                //* button pay now
                Container(
                  color: AppColors.whiteColor,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: globalButton(
                      context: context,
                      buttonText: 'pay_now'.tr,
                      buttonColor:
                          ValueStatic.ticketType == '3'
                              ? AppColors.airBusColor
                              : AppColors.primaryColor,
                      onPressed: () {
                        if (paymentMethodSelected == 0) {
                          alertDialogOneButton(
                            title: 'information'.tr,
                            description: 'choose_payment_method'.tr,
                            buttonText: 'yes'.tr,
                          );
                        } else {
                          processBooking(widget.id);
                        }
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
  }

  view(title, value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500, // Semi-bold for label
              color: AppColors.titleColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.titleColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> popScreen() async {
    alertDialogTwoButton(
      title: "information".tr,
      description: "do_you_want_to_cancel_booking".tr,
      buttonText1: 'no'.tr,
      buttonText2: 'yes'.tr,
      onButtonPressed1: () {
        Get.back();
      },
      onButtonPressed2: () {
        Booking().cancelBooking(context, widget.id);
      },
    );
    return false;
  }

  Future<void> processBooking(transactionId) async {
    Loading().loadingShow(context);

    var map = <String, dynamic>{};
    map['code'] = transactionId.toString();
    map['paymentMethodId'] = paymentMethodID.toString();
    map['totalAmount'] = ValueStatic.totalPrice.toString();

    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}booking/processPayment'),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
            body: map,
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response booking process ==>>${response.body}');
        var data = PaymentResponse.fromJson(jsonDecode(response.body));
        Loading().loadingClose(context);
        if (data.header?.statusCode == 200 && data.header?.result == true) {
          if (paymentMethodSelected == 1) {
            /// do payment with ABA mobile
            log('Pay by ABA Mobile');
            var token = data.body?.token;
            payWithABAMobile(transactionId, token);
          } else if (paymentMethodSelected == 2) {
            /// open web view for credit payment
            log('===> Pay Credit card');
            var token = data.body?.token;
            var result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PaymentABAScreen(
                      transactionId: transactionId,
                      token: token.toString(),
                      title: 'Credit/Debit Card',
                      type: 2,
                      url: '',
                    ),
              ),
            );

            log('Result $result');

            if (result == "1") {
              /// Payment Credit card success
              showDialogPaymentComplete();
            } else {
              showDialogPaymentFail();
            }
          } else if (paymentMethodSelected == 3) {
            /// open web view for ali pay
            log('===> Pay Ali Pay');
            var token = data.body?.token;
            var result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PaymentABAScreen(
                      transactionId: transactionId,
                      token: token.toString(),
                      title: 'Alipay',
                      type: 3,
                      url: '',
                    ),
              ),
            );
            if (result == "1") {
              /// Payment Alipay success
              showDialogPaymentComplete();
            } else {
              showDialogPaymentFail();
            }
          } else if (paymentMethodSelected == 4) {
            /// open web view for Wing
            log('===> Pay by Wing');
            var token = data.body?.token;
            var result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PaymentWingScreen(
                      transactionId: transactionId,
                      token: token.toString(),
                    ),
              ),
            );
            if (result == "1") {
              /// Payment Wing success
              showDialogPaymentComplete();
            }
          } else if (paymentMethodSelected == 5) {
            /// Do payment with Acleda Mobile
            log('===> Pay by ACLEDA');
            var token = data.body?.token;
            newToken = token!;

            showDialog(
              barrierColor: Colors.black26,
              context: context,
              builder: (context) {
                return dialogOptionACLEDA(transactionId, token.toString());
              },
            );
          }
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

  void showDialogPaymentComplete() {
    alertDialogTwoButton(
      title: 'your_ticket_has_been_reserved'.tr,
      description: 'ticket_info1'.tr,
      buttonText1: 'home'.tr,
      buttonText2: 'show_ticket'.tr,
      onButtonPressed1: () {
        ValueStatic().clearDataTicket();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen(from: 0)),
          (Route<dynamic> route) => false,
        );
      },
      onButtonPressed2: () {
        ValueStatic().clearDataTicket();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen(from: 2)),
          (Route<dynamic> route) => false,
        );
      },
    );
  }

  void showDialogPaymentFail() {
    PaymentABAScreenState.loop = false;
    alertDialogOneButton(
      title: 'information'.tr,
      description: 'payment_not_success'.tr,
      buttonText: 'ok'.tr,
    );
  }

  Future<void> payWithABAMobile(transactionId, token) async {
    log('ff ${BaseUrl.PAYMENT_URL}payments/abaMobilePay/$transactionId/$token');
    log('transactionId $transactionId');
    log('token $token');

    final response = await http.post(
      Uri.parse(
        '${BaseUrl.PAYMENT_URL}payments/abaMobilePay/$transactionId/$token',
      ),
      headers: <String, String>{'Authorization': AppPref.getToken() ?? ''},
    );

    if (response.statusCode == 200) {
      log('This is response ABA Payment 1 ==>>${response.body}');
      var data = ABAPayResponse.fromJson(jsonDecode(response.body));

      log('QR Link ${data.checkout_qr_url}');
      var result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PaymentABAScreen(
                transactionId: transactionId,
                token: token.toString(),
                title: 'ABA KHQR',
                type: 1,
                url: data.checkout_qr_url ?? '',
              ),
        ),
      );

      log("result $result");
      if (result == "1") {
        /// Payment ABA KHQR success
        showDialogPaymentComplete();
      } else {
        showDialogPaymentFail();
      }
    } else {
      throw Exception('Failed to load to server!');
    }
  }

  /// Payment with Acleda
  Future<void> payWithACLEDAMobile(transactionId, token) async {
    String type = '1';

    // * For check Deep Link in API
    if (Platform.isAndroid) {
      type = '1';
    } else if (Platform.isIOS) {
      type = '2';
    }

    log(
      '${BaseUrl.PAYMENT_URL}payments/acledaMobilePay/$transactionId/$token/$type',
    );

    final response = await http.post(
      Uri.parse(
        '${BaseUrl.PAYMENT_URL}payments/acledaMobilePay/$transactionId/$token/$type',
      ),
      headers: <String, String>{'Authorization': AppPref.getToken() ?? ''},
    );

    if (response.statusCode == 200) {
      log('This is response ACLEDA Payment ==>>${response.body}');
      var data = ABAPayResponse.fromJson(jsonDecode(response.body));

      log('Status meee ${data.status}');

      if (data.status == 1) {
        if ((data.abapayDeeplink)!.isNotEmpty) {
          // open deep link
          openDeepLinkACLEDA(data.abapayDeeplink, transactionId, token);
        } else {
          // has something went wrong
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('something_wrong'.tr)));
        }
      } else {
        // payment session expire
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('payment_time_out'.tr)));
      }
    } else {
      throw Exception('Failed to load to server!');
    }
  }

  Future<void> openDeepLinkACLEDA(deepLink, transactionId, token) async {
    try {
      bool launched = await launchUrl(
        Uri.parse(deepLink),
        mode: LaunchMode.externalApplication, // Open in an external application
      );
      log("launching... deep link");
      if (!launched) {
        if (Platform.isAndroid) {
          log('Open Play store');
          await launchUrl(
            Uri.parse(
              'https://play.google.com/store/search?q=acleda%20bank&c=apps',
            ), // Parse the deep link into a Uri object
            mode:
                LaunchMode
                    .externalApplication, // Open in an external application
          );
        } else if (Platform.isIOS) {
          log('Open App store');
          await launchUrl(
            Uri.parse(
              'https://apps.apple.com/al/app/acleda-mobile/id1196285236',
            ), // Parse the deep link into a Uri object
            mode:
                LaunchMode
                    .externalApplication, // Open in an external application
          );
        }
      }
    } catch (e) {
      if (Platform.isAndroid) {
        log('Open Play store');
        await launchUrl(
          Uri.parse(
            'https://play.google.com/store/search?q=acleda%20bank&c=apps',
          ), // Parse the deep link into a Uri object
          mode:
              LaunchMode.externalApplication, // Open in an external application
        );
      } else if (Platform.isIOS) {
        log('Open App store');
        await launchUrl(
          Uri.parse(
            'https://apps.apple.com/al/app/acleda-mobile/id1196285236',
          ), // Parse the deep link into a Uri object
          mode:
              LaunchMode.externalApplication, // Open in an external application
        );
      }
    }
  }

  Future<void> checkPaymentACLEDAComplete(transactionId, token) async {
    final response = await http.post(
      Uri.parse(
        '${BaseUrl.PAYMENT_URL}payments/acledaCheckStatus/$transactionId',
      ),
      headers: <String, String>{'Authorization': AppPref.getToken() ?? ''},
    );

    if (response.statusCode == 200) {
      log('This is response check payment ACLEDA ==>>${response.body}');
      Map<dynamic, dynamic> result = jsonDecode(response.body);
      if (result['status'] == 1) {
        log('Check status transaction == 1');
        checkTransactionACLEDAComplete(transactionId, token);
      } else {
        showDialogPaymentFail();
        /*       Future.delayed(const Duration(milliseconds: 1000), () {
          if(loop){
            checkPaymentACLEDAComplete(transactionId, token);
          }
        });*/
      }
    } else {
      checkPaymentACLEDAComplete(transactionId, token);
      throw Exception('Failed to load to server!');
    }
  }

  Future<void> checkTransactionACLEDAComplete(transactionId, token) async {
    loop = false;

    Loading().loadingShow(context);

    final response = await http.post(
      Uri.parse(
        '${BaseUrl.PAYMENT_URL}payments/acledaComplete/$transactionId/$token',
      ),
      headers: <String, String>{'Authorization': AppPref.getToken() ?? ''},
    );

    if (response.statusCode == 200) {
      log('This is response check transaction ACLEDA ==>>${response.body}');
      Map<dynamic, dynamic> result = jsonDecode(response.body);
      log(result['status'].toString());
      Loading().loadingClose(context);
      if (result['status'] == 1) {
        log('Check status transaction ACLEDA == 1');
        showDialogPaymentComplete();
      }
    } else {
      checkTransactionACLEDAComplete(transactionId, token);
      throw Exception('Failed to load to server!');
    }
  }

  Dialog dialogOptionACLEDA(transactionId, token) {
    return Dialog(
      elevation: 0,
      backgroundColor: const Color(0xffffffff),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                payWithACLEDAMobile(transactionId, token);
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/acleda_app.png',
                        width: 54,
                        height: 54,
                      ),
                      const SizedBox(width: 5),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACLEDA Mobile App',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Required ACLEDA App Installed and Registered',
                              style: TextStyle(fontSize: 12),
                              maxLines: 3,
                              overflow: TextOverflow.clip,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                Navigator.pop(context);
                var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PaymentABAScreen(
                          transactionId: transactionId,
                          token: token,
                          title: 'ACLEDA XPay',
                          type: 4,
                          url: '',
                        ),
                  ),
                );
                if (result == "1") {
                  showDialogPaymentComplete();
                } else {
                  showDialogPaymentFail();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/acleda_xpay.png',
                        width: 54,
                        height: 54,
                      ),
                      const SizedBox(width: 5),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACLEDA Card or Account number',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'OTP will send to phone which register account or card',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
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
    );
  }
}
