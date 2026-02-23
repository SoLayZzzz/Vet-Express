import 'dart:async';
import 'package:express_vet/value_statics.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/network/passenger_network_request.dart';
import 'package:express_vet/feature/home-dashboard/passenger/presentation/binding/passenger_binding.dart';
import 'package:express_vet/utils/alert_dialog.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/utils/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectCouponScreen extends StatefulWidget {
  final String amount;
  final String travelDate;

  const SelectCouponScreen({
    super.key,
    required this.amount,
    required this.travelDate,
  });

  @override
  State<SelectCouponScreen> createState() => _SelectCouponScreenState();
}

class _SelectCouponScreenState extends State<SelectCouponScreen> {
  final couponCodeController = TextEditingController();
  final FocusNode inputFocusNode = FocusNode();
  bool _isApplyButtonActive = false;
  String price = '';

  PassengerNetworkRequest _ensureNetworkRequest() {
    if (!Get.isRegistered<PassengerNetworkRequest>()) {
      PassengerBinding().dependencies();
    }
    return Get.find<PassengerNetworkRequest>();
  }

  @override
  void initState() {
    super.initState();

    /// Listen to text changes to enable/disable apply button
    couponCodeController.addListener(_onTextChanged);
  }

  /// Listen to text changes to enable/disable apply button
  void _onTextChanged() {
    setState(() {
      _isApplyButtonActive = couponCodeController.text.length >= 8;
    });
  }

  /// Clear input and focus when button is pressed
  void _clearInputAndFocus() {
    setState(() {
      couponCodeController.clear();
      _isApplyButtonActive = false;
    });
    // Focus back on the input field
    inputFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'my_offer'.tr),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Coupon Code Input Section
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            /// Text Input Field
                            Expanded(
                              child: TextField(
                                controller: couponCodeController,
                                focusNode: inputFocusNode,
                                autofocus: true,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: "enter_pro".tr,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),

                            /// Clear button (X) - only visible when there's text
                            if (couponCodeController.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: GestureDetector(
                                  onTap: _clearInputAndFocus,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),

                            /// Apply Button
                            GestureDetector(
                              onTap:
                                  _isApplyButtonActive
                                      ? () async {
                                        inputFocusNode.unfocus();

                                        /// Call your API here
                                        if (ValueStatic.seatPriceGoDiscount) {
                                          price = widget.amount;
                                        } else {
                                          price =
                                              double.parse(
                                                (double.parse(widget.amount) *
                                                        0.95)
                                                    .toStringAsFixed(2),
                                              ).toString();
                                        }

                                        await checkApplyCoupon(
                                          context,
                                          price,
                                          couponCodeController.text,
                                          widget.travelDate,
                                        );
                                      }
                                      : null, // Disable onTap when button is inactive
                              child: Container(
                                height: 55,
                                width: 110,
                                decoration: BoxDecoration(
                                  color:
                                      _isApplyButtonActive
                                          ? ValueStatic.ticketType == '3'
                                              ? AppColors.airBusColor
                                              : AppColors.primaryColor
                                          : Colors
                                              .grey[400]!, // Grey when inactive
                                  borderRadius: BorderRadius.circular(
                                    25,
                                  ), // Rounded corners like Figma
                                ),
                                child: Center(
                                  child: Text(
                                    "apply".tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          _isApplyButtonActive
                                              ? Colors.white
                                              : Colors.grey[200]!,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                /// Info Message
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 24, color: Colors.grey[500]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "pro_message".tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //* check coupon apply
  checkApplyCoupon(
    context,
    String amount,
    String code,
    String travelDate,
  ) async {
    Loading().loadingShow(context);

    try {
      final data = await _ensureNetworkRequest().checkCoupon(
        context: context,
        amount: amount,
        code: code,
        travelDate: travelDate,
      );
      Loading().loadingClose(context);

      if (data.header!.statusCode == 200 && data.header?.result == true) {
        ///Coupon applied successfully
        final status = data.body?.status;
        final balance = data.body?.balance;

        Navigator.pop(context, {
          'status': status,
          'balance': balance,
          'code': code,
        });
        return;
      } else if (data.header!.statusCode == 200 &&
          data.header?.result == false) {
        if (data.body?.errorStatus == 1) {
          alertDialogCoupon(
            title: "information".tr,
            descriptionSpans: [
              TextSpan(text: "your_pro".tr),
              TextSpan(
                text: couponCodeController.text,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryColor,
                ),
              ),
              TextSpan(text: "is_invalid".tr),
            ],
            buttonText: 'return'.tr,
            onButtonPressed: () {
              Navigator.pop(context);
              _clearInputAndFocus();
            },
          );
        } else if (data.body?.errorStatus == 2) {
          alertDialogCoupon(
            title: "information".tr,
            descriptionSpans: [
              TextSpan(text: "your_pro".tr),
              TextSpan(
                text: couponCodeController.text,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryColor,
                ),
              ),
              TextSpan(text: "is_expired".tr),
            ],
            buttonText: 'return'.tr,
            onButtonPressed: () {
              Navigator.pop(context);
              _clearInputAndFocus();
            },
          );
        } else {
          alertDialogCoupon(
            title: "information".tr,
            descriptionSpans: [
              TextSpan(text: "your_pro".tr),
              TextSpan(
                text: couponCodeController.text,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryColor,
                ),
              ),
              TextSpan(text: "is_not_apply".tr),
            ],
            buttonText: 'return'.tr,
            onButtonPressed: () {
              Navigator.pop(context);
              _clearInputAndFocus();
            },
          );
        }
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
      Loading().loadingClose(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('error_occurred'.tr),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    }
  }

  @override
  void dispose() {
    couponCodeController.removeListener(_onTextChanged);
    couponCodeController.dispose();
    inputFocusNode.dispose();
    super.dispose();
  }

  alertDialogCoupon({
    required String title,
    required List<TextSpan> descriptionSpans,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 300, // Set minimum dialog width
              maxWidth: 400, // Set maximum dialog width
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.titleColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textColor,
                            ),
                            children: descriptionSpans,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: onButtonPressed,
                          child: Container(
                            width: 200, // Fixed button width
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color:
                                    ValueStatic.ticketType == '3'
                                        ? AppColors.airBusColor
                                        : AppColors.primaryColor,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                buttonText,
                                style: TextStyle(
                                  color:
                                      ValueStatic.ticketType == '3'
                                          ? AppColors.airBusColor
                                          : AppColors.primaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
