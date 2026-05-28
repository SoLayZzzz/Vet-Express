import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:express_vet/asset_image.dart';
import 'package:express_vet/base/base_url.dart';
import 'package:express_vet/feature/home-dashboard/payment/presentaion/state/payment_uistate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/value_statics.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/response/confirm_booking_response.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'component/payment_option_card.dart';
import '../binding/payment_binding.dart';
import '../controller/payment_controller.dart';
import '../../../passenger/presentation/controller/booking.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/app_colors.dart';

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

  String _formatDobForDisplay(String rawDob) {
    final raw = rawDob.trim();
    if (raw.isEmpty) return '';

    DateTime? parsed = DateTime.tryParse(raw);
    parsed ??= DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    if (parsed == null) {
      try {
        parsed = DateFormat('yyyy-MM-dd').parseStrict(raw);
      } catch (_) {
        parsed = null;
      }
    }
    if (parsed == null) return raw;
    return DateFormat('dd-MM-yyyy').format(parsed);
  }

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
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      controller.setLoop(false);
      return;
    }

    if (state == AppLifecycleState.resumed) {
      log('On Resume');

      if (controller.state.paymentMethodSelected == 5 &&
          controller.state.newToken.isNotEmpty &&
          controller.state.acledaPaymentInitiated) {
        controller.setLoop(true);
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
      final orderPayments =
          widget.datas.body?.orderPaymentLists ?? <OrderPaymentList>[];
      final paymentMethods =
          widget.datas.body?.paymentMethods ?? <PaymentMethod>[];
      final grandTotalAll = orderPayments.fold<double>(
        0.0,
        (sum, item) => sum + _parseAmount(item.grandTotal),
      );
      // final apiSubTotalAll = _parseAmount(widget.datas.body?.orderPaymentLists?.first.grandTotal);
      final apiSubTotalAll = _parseAmount(widget.datas.body?.subTotal);
       final apiPlatformDiscountAll = _parseAmount(widget.datas.body?.totalDiscount);
      // final apiTotalAll = _parseAmount(widget.datas.body?.orderPaymentLists?.first.total);
      final apiTotalAll = _parseAmount(widget.datas.body?.totalAmount);

      final baseSubTotalAll =
          apiSubTotalAll > 0 ? apiSubTotalAll : grandTotalAll;
      final selectedDiscountAmount = _getSelectedPaymentDiscountAmount(
        paymentMethods: paymentMethods,
        paymentMethodId: uiState.paymentMethodId,
      );
      final selectedPaymentMethodName = _getSelectedPaymentMethodName(
        paymentMethods: paymentMethods,
        paymentMethodId: uiState.paymentMethodId,
      );
      final selectedServiceFeeAmount = _getSelectedPaymentServiceFeeAmount(
        paymentMethods: paymentMethods,
        paymentMethodId: uiState.paymentMethodId,
      );
      final travelPackageDiscountAll = _getTravelPackageDiscountAll(
        orderPayments: orderPayments,
        grandTotalAll: grandTotalAll,
      );

      final baseTotalAll = apiTotalAll > 0
          ? apiTotalAll
          : _nonNegative(
              grandTotalAll - travelPackageDiscountAll - apiPlatformDiscountAll,
            );
      final totalPayableAll = _nonNegative(
        baseTotalAll - selectedDiscountAmount + selectedServiceFeeAmount,
      );

      final totalAmountForApi = totalPayableAll > 0
          ? totalPayableAll.toStringAsFixed(2)
          : ((widget.datas.body?.orderPaymentLists?.first.total ?? '').toString().trim().isNotEmpty
              ? widget.datas.body!.orderPaymentLists!.first.total!.toString().trim()
              : baseTotalAll.toStringAsFixed(2));
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
              backgroundColor: AppColors.primaryColor,
              leading: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  popScreen();
                },
              ),
              title: Text(
                'payment'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            bottomNavigationBar: _buildButtonPay(
              context,
              uiState,
              totalPayableAll: totalPayableAll,
              totalAmountForApi: totalAmountForApi,
            ),
            body: SafeArea(
              child: Column(
                children: [
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
                              style:  TextStyle(
                                fontSize: 16,
                                color: AppColors.titleColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            //* bank
                            _buildSelectBankOption(uiState),

                            //* payment type
                            
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: _buildPaymentMethodStatus(uiState),
                            ),
                            

                          _buildPaymentDetail(
                            uiState,
                            totalPayableAll,
                            travelPackageDiscountAll,
                            selectedDiscountAmount,
                            selectedPaymentMethodName,
                            selectedServiceFeeAmount,
                            baseSubTotalAll,
                            apiPlatformDiscountAll,
                            baseTotalAll,
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

  Widget _buildPaymentMethodStatus(PaymentUistate uiState) {
    return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "payment_method".tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
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
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          );
  }

  Widget _buildPaymentDetail(
    PaymentUistate uiState,
    double totalPayableAll,
    double travelPackageDiscountAll,
    double selectedDiscountAmount,
    String selectedPaymentMethodName,
    double selectedServiceFeeAmount,
    double baseSubTotalAll,
    double apiPlatformDiscountAll,
    double baseTotalAll,
  ) {
    final normalizedPaymentMethodName =
        selectedPaymentMethodName.trim().toLowerCase();
    final discountTitle = normalizedPaymentMethodName.contains('wing')
        ? 'discount_wing'.tr
        : "${"discount".tr} $selectedPaymentMethodName";
    final grandTotalAll = (widget.datas.body?.orderPaymentLists ?? []).fold(
      0.0,
      (sum, item) => sum + _parseAmount(item.grandTotal),
    );

    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final interTheme = theme.copyWith(
          textTheme: GoogleFonts.interTextTheme(theme.textTheme),
          primaryTextTheme: GoogleFonts.interTextTheme(theme.primaryTextTheme),
        );

        return Theme(
          data: interTheme,
          child: ListView.separated(
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            primary: false,
            itemCount:
                widget.datas.body!.confirmBookingInformation!.length,
            itemBuilder: (context, index) {
              final data =
                  widget.datas.body!.confirmBookingInformation![index];
              final isRoundTrip =
                  widget.datas.body!.confirmBookingInformation!.length == 2;
              final companyTypeForSegment =
                  index == 0
                      ? ValueStatic.companyTypeOneWay
                      : ValueStatic.companyTypeTwoWay;
              final isBuvaSea = companyTypeForSegment == 4;

              return isRoundTrip
                  ///round trip
                  ? _buildPaymentRooundtrip(
                      index,
                      data,
                      isBuvaSea,
                      isRoundTrip,
                      grandTotalAll,
                      travelPackageDiscountAll,
                      selectedDiscountAmount,
                      discountTitle,
                      selectedServiceFeeAmount,
                      totalPayableAll,
                      baseSubTotalAll,
                      apiPlatformDiscountAll,
                      baseTotalAll,
                    )
                  ///one way
                  : _buildPaymentOneway(
                      data,
                      isBuvaSea,
                      index,
                      selectedDiscountAmount,
                      discountTitle,
                      selectedServiceFeeAmount,
                      baseSubTotalAll,
                      apiPlatformDiscountAll,
                      baseTotalAll,
                      totalPayableAll,
                    );
            },
            separatorBuilder: (context, index) {
              return SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildPaymentRooundtrip(
    int index,
    ConfirmBookingInformation data,
    bool isBuvaSea,
    bool isRoundTrip,
    double grandTotalAll,
    double travelPackageDiscountAll,
    double selectedDiscountAmount,
    String discountTitle,
    double selectedServiceFeeAmount,
    double totalPayableAll,
    double baseSubTotalAll,
    double apiPlatformDiscountAll,
    double baseTotalAll,
  ) {
    return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Display trip destination
                                    if (index == 1)
                                      Padding(
                                        padding:  EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: Divider(thickness: 1),
                                      ),

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                            Text(
                                              '${data.destinationFrom}${' - '.tr}${data.destinationTo}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
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
                                                    if (isBuvaSea)
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
                                                        _formatDobForDisplay(
                                                          seatDetail.dob!,
                                                        ),
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

                                            if (isRoundTrip && index == 1)
                                              Column(
                                                children: [
                                                  view(
                                                    'sub_total'.tr,
                                                    "\$${baseSubTotalAll.toStringAsFixed(2)}",
                                                  ),
                                                  // if (_hasVisibleAmount(
                                                  //   apiPlatformDiscountAll,
                                                  // ))
                                                  //   Padding(
                                                  //     padding:
                                                  //         const EdgeInsets.symmetric(
                                                  //           vertical: 6.0,
                                                  //         ),
                                                  //     child: view(
                                                  //       'discount_platform'.tr,
                                                  //       "\$${apiPlatformDiscountAll.toStringAsFixed(2)}",
                                                  //       textColor:
                                                  //           AppColors.greyColor,
                                                  //     ),
                                                  //   ),
                                                  const Divider(
                                                    thickness: 1,
                                                  ),
                                                  
                                                  if (_hasVisibleAmount(
                                                    travelPackageDiscountAll,
                                                  ))
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 6.0,
                                                          ),
                                                      child: view(
                                                        'discount_travel'.tr,
                                                        "\$${travelPackageDiscountAll.toStringAsFixed(2)}",
                                                        textColor:
                                                            AppColors.greyColor,
                                                      ),
                                                    ),
                                                  if (_hasVisibleAmount(
                                                    selectedDiscountAmount,
                                                  ))
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 6.0,
                                                          ),
                                                      child: view(
                                                        discountTitle,
                                                        "\$${selectedDiscountAmount.toStringAsFixed(2)}",
                                                        textColor:
                                                            AppColors.greyColor,
                                                      ),
                                                    ),
                                                  if (_hasVisibleAmount(
                                                    selectedServiceFeeAmount,
                                                  ))
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 6.0,
                                                          ),
                                                      child: view(
                                                        _getSelectedPaymentServiceFeePercent(
                                                                  paymentMethods: widget.datas.body?.paymentMethods ?? <PaymentMethod>[],
                                                                  paymentMethodId: controller.state.paymentMethodId,
                                                                ) > 0
                                                            ? "${"service_fee".tr} (${_getSelectedPaymentServiceFeePercent(paymentMethods: widget.datas.body?.paymentMethods ?? <PaymentMethod>[], paymentMethodId: controller.state.paymentMethodId)}%)"
                                                            : "service_fee".tr,
                                                        "\$${selectedServiceFeeAmount.toStringAsFixed(2)}",
                                                      ),
                                                    ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 6.0,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "total_mn".tr,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400,
                                                            color:
                                                                AppColors
                                                                    .textColor,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Text(
                                                          "\$${totalPayableAll.toStringAsFixed(2)}",
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,

                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                  ],
                                );
  }

  Widget _buildPaymentOneway(
    ConfirmBookingInformation data,
    bool isBuvaSea,
    int index,
    double selectedDiscountAmount,
    String discountTitle,
    double selectedServiceFeeAmount,
    double baseSubTotalAll,
    double apiPlatformDiscountAll,
    double baseTotalAll,
    double totalPayableAll,
  ) {
    return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [

                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                            Text(
                                              '${data.destinationFrom}${' - '.tr}${data.destinationTo}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
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
                                                    if (isBuvaSea)
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
                                                        _formatDobForDisplay(
                                                          seatDetail.dob!,
                                                        ),
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
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  view(
                                                    "sub_total".tr,
                                                    "\$${baseSubTotalAll.toStringAsFixed(2)}",
                                                  ),
                                                  
                                                  // if (_hasVisibleAmount(
                                                  //   apiPlatformDiscountAll,
                                                  // ))
                                                  //   view(
                                                  //     'discount_platform'.tr,
                                                  //     "\$${apiPlatformDiscountAll.toStringAsFixed(2)}",
                                                  //     textColor: AppColors.greyColor,
                                                  //   ),
                                                  if (_hasVisibleAmount(
                                                    _getTravelPackageDiscountItem(
                                                      widget
                                                          .datas
                                                          .body!
                                                          .orderPaymentLists![index],
                                                    ),
                                                  ))
                                                    view(
                                                      'discount_travel'.tr,
                                                      "\$${_getTravelPackageDiscountItem(widget.datas.body!.orderPaymentLists![index]).toStringAsFixed(2)}",
                                                       textColor: AppColors.greyColor
                                                    ),
                                                  if (_hasVisibleAmount(
                                                    selectedDiscountAmount,
                                                  ))
                                                    view(
                                                      discountTitle,
                                                      "\$${selectedDiscountAmount.toStringAsFixed(2)}",
                                                      textColor: AppColors.greyColor
                                                    ),
                                                  // Line
                                                  // Padding(
                                                  //   padding:  EdgeInsets.symmetric(vertical: 10),
                                                  //   child: Container(
                                                  //     height: 2,
                                                  //     width: double.infinity,
                                                  //     color: AppColors.lineGray,
                                                  //   ),
                                                  // ),
                                                   const Divider(height: 10,thickness: 1,),
                                                   
                                                  if (_hasVisibleAmount(
                                                    selectedServiceFeeAmount,
                                                  ))
                                                    view(
                                                      _getSelectedPaymentServiceFeePercent(
                                                                paymentMethods: widget.datas.body?.paymentMethods ?? <PaymentMethod>[],
                                                                paymentMethodId: controller.state.paymentMethodId,
                                                              ) > 0
                                                          ? "${"service_fee".tr} (${_getSelectedPaymentServiceFeePercent(paymentMethods: widget.datas.body?.paymentMethods ?? <PaymentMethod>[], paymentMethodId: controller.state.paymentMethodId)}%)"
                                                          : "service_fee".tr,
                                                      "\$${selectedServiceFeeAmount.toStringAsFixed(2)}",
                                                    ),
                                                  view(
                                                    "total_ticket_price".tr,
                                                    "\$${totalPayableAll.toStringAsFixed(2)}",
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ],
                                                ),
                                              ),
                                          ],
                                        ),
                                  ],
                                );
  }

  Widget _buildSelectBankOption(PaymentUistate uiState) {
    return RadioGroup<int>(
                            groupValue: uiState.paymentMethodSelected,
                            onChanged: (value) {
                              _onPaymentGroupChanged(value);
                            },
                            child: Column(
                              children: [

                                // ================
                                // ABA KHQR
                                // ================
                                PaymentOptionCard(
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
                               
                                // ================
                                // Wing Bank
                                // ================
                                PaymentOptionCard(
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

                                // ================
                                // ACLEDA
                                // ================
                                PaymentOptionCard(
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

                                // ================
                                // Credid Card
                                // ================
                                 PaymentOptionCard(
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

                                // ================
                                // AliPay
                                // ================
                                PaymentOptionCard(
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
                              ],
                            ),
                          );
  }

  Widget _buildButtonPay(
    BuildContext context,
    PaymentUistate uiState, {
    required double totalPayableAll,
    required String totalAmountForApi,
  }) {
    final isPaymentSelected = uiState.paymentMethodSelected != 0;
    return SafeArea(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
    color: AppColors.whiteColor,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1), 
        offset: const Offset(0, -1), 
        blurRadius: 1,
        spreadRadius: 0,
      ),
    ],
  ),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Total amount
                   Expanded(
                    flex: 2,
                     child: Row(
                       children: [
                         Text(
                          'total_price'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                          color: Colors.black, 
                          // fontWeight: FontWeight.w500,
                          ),
                         ),
                         Text(
                           "\$${totalPayableAll.toStringAsFixed(2)}",
                           style: const TextStyle(
                     fontSize: 16,
                          color: Colors.black, 
                          fontWeight: FontWeight.w600,
                           ),
                                         ),
                       ],
                     ),
                   ),
                  //
                  // Button pay 
                   Expanded(
                    flex: 2,
                     child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isPaymentSelected
                              ? () async {
                                  if (uiState.paymentMethodSelected == 5) {
                                    await controller.processBooking(
                                      context: context,
                                      transactionId: widget.id,
                                      totalAmount: totalAmountForApi,
                                    );
                                    final token = controller.state.newToken;
                                    if (token.isNotEmpty && context.mounted) {
                                      showDialog(
                                        barrierColor: Colors.black26,
                                        context: context,
                                        builder: (dialogContext) {
                                          return dialogOptionACLEDA(
                                            widget.id,
                                            token,
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    controller.processBooking(
                                      context: context,
                                      transactionId: widget.id,
                                      totalAmount: totalAmountForApi,
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            disabledBackgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            disabledForegroundColor: AppColors.titleColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: AppColors.primaryColor,
                                width: 1
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'pay_now'.tr,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        ),
                       ),
                   )
                 
                ],
              ),
            ),
          );
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

  Widget view(
    title,
    value, {
    Color? textColor = AppColors.titleColor,
    FontWeight? fontWeight = FontWeight.w400,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: fontWeight,
              color: textColor,
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

  double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  double _nonNegative(double value) {
    if (value < 0) return 0.0;
    return value;
  }

  double _getTravelPackageDiscountAll({
    required List<OrderPaymentList> orderPayments,
    required double grandTotalAll,
  }) {
    final explicit = orderPayments.fold<double>(
      0.0,
      (sum, item) => sum + _parseAmount(item.disTravel),
    );
    if (explicit > 0) return explicit;

    final percent = ValueStatic.travelPackageDis.toDouble();
    if (percent > 0 && grandTotalAll > 0) {
      final rawDiscount = grandTotalAll * (percent / 100.0);
      final appliedDiscount =
          rawDiscount > grandTotalAll ? grandTotalAll : rawDiscount;
      return double.parse(appliedDiscount.toStringAsFixed(2));
    }

    final computedFromTotals = orderPayments.fold<double>(0.0, (sum, item) {
      final grandTotal = _parseAmount(item.grandTotal);
      final totalAfterDiscount = _parseAmount(item.total);
      final diff = grandTotal - totalAfterDiscount;
      return sum + (diff > 0 ? diff : 0.0);
    });
    if (computedFromTotals > 0) {
      return double.parse(computedFromTotals.toStringAsFixed(2));
    }
    return 0.0;
  }

  double _getTravelPackageDiscountItem(OrderPaymentList item) {
    final explicit = _parseAmount(item.disTravel);
    if (explicit > 0) return explicit;

    final percent = ValueStatic.travelPackageDis.toDouble();
    final grandTotal = _parseAmount(item.grandTotal);
    if (percent > 0 && grandTotal > 0) {
      final rawDiscount = grandTotal * (percent / 100.0);
      final appliedDiscount =
          rawDiscount > grandTotal ? grandTotal : rawDiscount;
      return double.parse(appliedDiscount.toStringAsFixed(2));
    }

    // Fallback for some flows (e.g. Buvasea) where travel discount isn't
    // provided in disTravel and percent isn't set, but totals reflect it.
    final totalAfterDiscount = _parseAmount(item.total);
    final diff = grandTotal - totalAfterDiscount;
    if (diff > 0) {
      return double.parse(diff.toStringAsFixed(2));
    }
    return 0.0;
  }

  double _getSelectedPaymentDiscountAmount({
    required List<PaymentMethod> paymentMethods,
    required int paymentMethodId,
  }) {
    for (final method in paymentMethods) {
      if (method.id == paymentMethodId) {
        return _parseAmount(method.discountAmount);
      }
    }
    return 0.0;
  }

  String _getSelectedPaymentMethodName({
    required List<PaymentMethod> paymentMethods,
    required int paymentMethodId,
  }) {
    for (final method in paymentMethods) {
      if (method.id == paymentMethodId) {
        final name = method.name?.trim() ?? '';
        return name.isEmpty ? '-' : name;
      }
    }
    return '-';
  }

  double _getSelectedPaymentServiceFeeAmount({
    required List<PaymentMethod> paymentMethods,
    required int paymentMethodId,
  }) {
    for (final method in paymentMethods) {
      if (method.id == paymentMethodId) {
        return _parseAmount(method.serviceFeeAmount);
      }
    }
    return 0.0;
  }

  int _getSelectedPaymentServiceFeePercent({
    required List<PaymentMethod> paymentMethods,
    required int paymentMethodId,
  }) {
    for (final method in paymentMethods) {
      if (method.id == paymentMethodId) {
        return method.serviceFeePercent ?? 0;
      }
    }
    return 0;
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


  Widget dialogOptionACLEDA(transactionId, token) {
    return Dialog(
      elevation: 0,
      backgroundColor: const Color(0xffffffff),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOpenAcledaApp(transactionId, token),
            const SizedBox(height: 10),
            _buildOpenCartOfAceleda(transactionId, token),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenCartOfAceleda(transactionId, token) {
    return InkWell(
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
          );
  }

  Widget _buildOpenAcledaApp(transactionId, token) {
    return InkWell(
            onTap: () {
              final type = Platform.isAndroid ? '1' : '2';
              final requestUrl =
                  '${BaseUrl.PAYMENT_URL}payments/acledaMobilePay/$transactionId/$token/$type';
              debugPrint(
                'Ac App url = $requestUrl',
              );
              controller.onAcledaOptionTapOpenApp(
                context: context,
                transactionId: transactionId,
                token: token,
                type: type,
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
          );
  }
}
