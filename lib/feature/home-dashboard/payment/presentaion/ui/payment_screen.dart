import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:express_vet/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/value_statics.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/response/confirm_booking_response.dart';
import 'package:express_vet/utils/button.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../binding/payment_binding.dart';
import '../controller/payment_controller.dart';
import '../../../passenger/presentation/controller/booking.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../dash_board/presentation/screen/dashboard_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String id;
  final ConfirmBookingResponse datas;

  const PaymentScreen({super.key, required this.id, required this.datas});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with WidgetsBindingObserver {
  late final PaymentController controller;

  late WebViewController _controller;
  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<PaymentController>()) {
      PaymentBinding().dependencies();
    }
    controller = Get.find<PaymentController>();

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
    // _controller.loadRequest(
    //   Uri.parse('https://example.com'), // Replace with your URL
    // );

    // Set JavaScript mode
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Get.isRegistered<PaymentController>()) {
      Get.delete<PaymentController>(force: true);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      log('On Resume');
      if (controller.state.paymentMethodSelected == 5 &&
          controller.state.newToken.isNotEmpty) {
        controller.checkPaymentACLEDAComplete(
          context: context,
          transactionId: widget.id,
          token: controller.state.newToken,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uiState = controller.state;
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          popScreen();
        },
        child: Container(
          color: AppColors.whiteColor,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: AppColors.whiteColor,
              leading: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.blueAccent,
                  size: 34,
                ),
                onPressed: () {
                  popScreen();
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
            bottomNavigationBar: SafeArea(
              child: Container(
                color: AppColors.whiteColor,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: globalButton(
                  context: context,
                  buttonText: 'pay_now'.tr,
                  buttonColor:
                      ValueStatic.ticketType == '3'
                          ? AppColors.airBusColor
                          : AppColors.primaryColor,
                  onPressed: () async {
                    if (uiState.paymentMethodSelected == 0) {
                      alertDialogOneButton(
                        title: 'information'.tr,
                        description: 'choose_payment_method'.tr,
                        buttonText: 'yes'.tr,
                      );
                    } else if (uiState.paymentMethodSelected == 5) {
                      await controller.processBooking(
                        context: context,
                        transactionId: widget.id,
                      );
                      final token = controller.state.newToken;
                      if (token.isNotEmpty && context.mounted) {
                        showDialog(
                          barrierColor: Colors.black26,
                          context: context,
                          builder: (dialogContext) {
                            return dialogOptionACLEDA(widget.id, token);
                          },
                        );
                      }
                    } else {
                      controller.processBooking(
                        context: context,
                        transactionId: widget.id,
                      );
                    }
                  },
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
                            RadioGroup<int>(
                              groupValue: uiState.paymentMethodSelected,
                              onChanged: (value) {
                                _onPaymentGroupChanged(value);
                              },
                              child: Column(
                                children: [
                                  _buildPaymentOption(
                                    asset: AssetImages.ic_khqr,
                                    title: const Text(
                                      'ABA KHQR',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitleWidget: Text(
                                      'tap_to_pay_with_KHQR'.tr,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    value: 1,
                                    isSelected:
                                        uiState.paymentMethodSelected == 1,
                                    onTap: () {
                                      controller.selectPaymentMethod(
                                        paymentMethodId: 5,
                                        paymentMethodSelected: 1,
                                      );
                                    },
                                  ),
                                  _buildPaymentOption(
                                    asset: AssetImages.ic_big_visa,
                                    title: const Text(
                                      'Credit/Debit Card',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitleWidget: Image.asset(
                                      AssetImages.ic_small_visa,
                                      height: 14,
                                    ),
                                    value: 2,
                                    isSelected:
                                        uiState.paymentMethodSelected == 2,
                                    onTap: () {
                                      controller.selectPaymentMethod(
                                        paymentMethodId: 6,
                                        paymentMethodSelected: 2,
                                      );
                                    },
                                  ),
                                  _buildPaymentOption(
                                    asset: AssetImages.ic_alipay,
                                    title: const Text(
                                      'AliPay',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitleWidget: Text(
                                      'tap_to_pay_with_ALIPAY'.tr,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    value: 3,
                                    isSelected:
                                        uiState.paymentMethodSelected == 3,
                                    onTap: () {
                                      controller.selectPaymentMethod(
                                        paymentMethodId: 7,
                                        paymentMethodSelected: 3,
                                      );
                                    },
                                  ),
                                  _buildPaymentOption(
                                    asset: AssetImages.ic_wing,
                                    title: const Text(
                                      'Wing Bank',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitleWidget: Text(
                                      'tap_to_pay_wing'.tr,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    value: 4,
                                    isSelected:
                                        uiState.paymentMethodSelected == 4,
                                    onTap: () {
                                      controller.selectPaymentMethod(
                                        paymentMethodId: 4,
                                        paymentMethodSelected: 4,
                                      );
                                    },
                                  ),
                                  _buildPaymentOption(
                                    asset: AssetImages.ic_acleda,
                                    title: const Text(
                                      'ACLEDA',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitleWidget: Text(
                                      'tap_to_pay_acleda'.tr,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    value: 5,
                                    isSelected:
                                        uiState.paymentMethodSelected == 5,
                                    onTap: () {
                                      controller.selectPaymentMethod(
                                        paymentMethodId: 8,
                                        paymentMethodSelected: 5,
                                      );
                                    },
                                  ),
                                ],
                              ),
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
                                  uiState.paymentMethodSelected == 1
                                      ? "ABA KHQR"
                                      : uiState.paymentMethodSelected == 2
                                      ? "Credit/Debit Card"
                                      : uiState.paymentMethodSelected == 3
                                      ? "AliPay"
                                      : uiState.paymentMethodSelected == 4
                                      ? "Wing Bank"
                                      : uiState.paymentMethodSelected == 5
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
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              primary: false,
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
                                        uiState.showFareSummary
                                            ? const SizedBox(height: 12)
                                            : const SizedBox.shrink(),

                                        //show see more
                                        if (isRoundTrip == true && index == 1)
                                          !uiState.showFareSummary
                                              ? Row(
                                                children: [
                                                  Text(
                                                    "total_amount".tr,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors.textColor,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    "\$${(double.parse(widget.datas.body!.orderPaymentLists![0].total ?? '0') + double.parse(widget.datas.body!.orderPaymentLists![1].total ?? '0')).toStringAsFixed(2)}",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400,
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
                                                      controller
                                                          .toggleFareSummary();
                                                    },
                                                  ),
                                                ],
                                              )
                                              : const SizedBox.shrink(),

                                        uiState.showFareSummary
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
                                                            seatDetail
                                                                .passport!,
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
                                                          AssetImages.line,
                                                        ),
                                                      ),
                                                ),

                                                // Display order payment details
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 10.0,
                                                        bottom: 10.0,
                                                      ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      view(
                                                        "sub_total".tr,
                                                        "${widget.datas.body!.orderPaymentLists![index].grandTotal} \$",
                                                      ),
                                                      if (_hasVisibleAmount(
                                                        widget
                                                            .datas
                                                            .body!
                                                            .orderPaymentLists![index]
                                                            .discount,
                                                      ))
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
                                                      const Divider(
                                                        thickness: 1,
                                                      ),
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
                                                                controller
                                                                    .toggleFareSummary();
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
                                        uiState.showFareSummary
                                            ? const SizedBox(height: 12)
                                            : const SizedBox.shrink(),

                                        //show see more
                                        !uiState.showFareSummary
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
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors
                                                              .secondaryColor,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    controller
                                                        .toggleFareSummary();
                                                  },
                                                ),
                                              ],
                                            )
                                            : const SizedBox.shrink(),

                                        uiState.showFareSummary
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
                                                            seatDetail
                                                                .passport!,
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
                                                          AssetImages.line,
                                                        ),
                                                      ),
                                                ),

                                                // Display order payment details
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 10.0,
                                                        bottom: 10.0,
                                                      ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      view(
                                                        "sub_total".tr,
                                                        "${widget.datas.body!.orderPaymentLists![index].grandTotal} \$",
                                                      ),
                                                      if (_hasVisibleAmount(
                                                        widget
                                                            .datas
                                                            .body!
                                                            .orderPaymentLists![index]
                                                            .discount,
                                                      ))
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
                                        uiState.showFareSummary
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
                                                            AppColors
                                                                .titleColor,
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
                                                            AppColors
                                                                .titleColor,
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
                                                        controller
                                                            .toggleFareSummary();
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
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _onPaymentGroupChanged(int? value) {
    if (value == null) return;
    switch (value) {
      case 1:
        controller.selectPaymentMethod(
          paymentMethodId: 5,
          paymentMethodSelected: 1,
        );
        break;
      case 2:
        controller.selectPaymentMethod(
          paymentMethodId: 6,
          paymentMethodSelected: 2,
        );
        break;
      case 3:
        controller.selectPaymentMethod(
          paymentMethodId: 7,
          paymentMethodSelected: 3,
        );
        break;
      case 4:
        controller.selectPaymentMethod(
          paymentMethodId: 4,
          paymentMethodSelected: 4,
        );
        break;
      case 5:
        controller.selectPaymentMethod(
          paymentMethodId: 8,
          paymentMethodSelected: 5,
        );
        break;
      default:
        break;
    }
  }

  Widget _buildPaymentOption({
    required String asset,
    required Widget title,
    required Widget subtitleWidget,
    required int value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color:
                isSelected
                    ? (ValueStatic.ticketType == '3'
                        ? AppColors.airBusColor
                        : AppColors.primaryColor)
                    : Colors.grey,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Image.asset(asset, height: 44),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: subtitleWidget,
                      ),
                    ],
                  ),
                ),
              ),
              Radio<int>(
                value: value,
                fillColor: WidgetStateColor.resolveWith(
                  (states) =>
                      ValueStatic.ticketType == '3'
                          ? AppColors.airBusColor
                          : AppColors.primaryColor,
                ),
              ),
            ],
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
              fontWeight: FontWeight.w500,
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

  bool _hasVisibleAmount(dynamic value) {
    if (value == null) return false;
    final amount = double.tryParse(value.toString()) ?? 0;
    return amount > 0;
  }

  Future<void> popScreen() async {
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
  }

  Future<void> processBooking(transactionId) async {
    await controller.processBooking(
      context: context,
      transactionId: transactionId.toString(),
    );
  }

  void showDialogPaymentComplete() {
    alertDialogTwoButton(
      title: 'your_ticket_has_been_reserved'.tr,
      description: 'ticket_info1'.tr,
      buttonText1: 'home'.tr,
      buttonText2: 'show_ticket'.tr,
      onButtonPressed1: () {
        ValueStatic().clearDataTicket();
        Get.offAll(() => const DashboardScreen(from: 0));
      },
      onButtonPressed2: () {
        ValueStatic().clearDataTicket();
        Get.offAll(() => const DashboardScreen(from: 2));
      },
    );
  }

  void showDialogPaymentFail() {
    alertDialogOneButton(
      title: 'information'.tr,
      description: 'payment_not_success'.tr,
      buttonText: 'ok'.tr,
    );
  }

  Future<void> payWithABAMobile(transactionId, token) async {
    await controller.payWithABAMobile(
      context: context,
      transactionId: transactionId,
      token: token,
    );
  }

  /// Payment with Acleda
  Future<void> payWithACLEDAMobile(transactionId, token) async {
    await controller.payWithACLEDAMobile(
      context: context,
      transactionId: transactionId,
      token: token,
    );
  }

  Future<void> openDeepLinkACLEDA(deepLink, transactionId, token) async {
    await controller.openDeepLinkACLEDA(deepLink);
  }

  Future<void> checkPaymentACLEDAComplete(transactionId, token) async {
    await controller.checkPaymentACLEDAComplete(
      context: context,
      transactionId: transactionId,
      token: token,
    );
  }

  Future<void> checkTransactionACLEDAComplete(transactionId, token) async {
    await controller.checkTransactionACLEDAComplete(
      context: context,
      transactionId: transactionId,
      token: token,
    );
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
                controller.onAcledaOptionTapOpenApp(
                  context: context,
                  transactionId: transactionId,
                  token: token,
                );
                Get.back();
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
                        AssetImages.acleda_app,
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
                Get.back();
                await controller.onAcledaOptionTapXPay(
                  context: context,
                  transactionId: transactionId,
                  token: token,
                );
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
                        AssetImages.acleda_xpay,
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
