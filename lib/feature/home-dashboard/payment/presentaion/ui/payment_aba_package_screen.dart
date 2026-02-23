import 'package:express_vet/feature/home-dashboard/payment/presentaion/controller/payment_aba_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../value_statics.dart';

class PaymentABAPackageScreen extends GetView<PaymentAbaController> {
  final String transactionId;
  final String token;
  final String title;
  final String url;
  final int type;

  const PaymentABAPackageScreen({
    super.key,
    required this.transactionId,
    required this.token,
    required this.type,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<PaymentAbaController>()) {
      // Ensure no lingering polling from previous session
      try {
        Get.find<PaymentAbaController>().stop();
      } catch (_) {}
      Get.delete<PaymentAbaController>();
    }
    Get.put(
      PaymentAbaController(
        transactionId: transactionId,
        token: token,
        title: title,
        url: url,
        type: type,
      ),
    );

    // Initialize controller synchronously; guarded internally to avoid re-init
    controller.init(context: context);

    return WillPopScope(
      onWillPop: () async {
        // Stop polling and dispose controller when user leaves
        try {
          controller.stop();
        } catch (_) {}
        if (Get.isRegistered<PaymentAbaController>()) {
          Get.delete<PaymentAbaController>();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.2,
          backgroundColor:
              ValueStatic.ticketType == '3'
                  ? AppColors.airBusColor
                  : AppColors.primaryColor,
          leading: IconButton(
            icon: const Icon(
              Ionicons.chevron_back_outline,
              color: AppColors.whiteColor,
            ),
            onPressed: () {
              try {
                controller.stop();
              } catch (_) {}
              if (Get.isRegistered<PaymentAbaController>()) {
                Get.delete<PaymentAbaController>();
              }
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: WebViewWidget(controller: controller.webViewController),
      ),
    );
  }
}
