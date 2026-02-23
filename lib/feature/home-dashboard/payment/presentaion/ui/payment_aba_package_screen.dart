import 'package:express_vet/feature/home-dashboard/payment/presentaion/controller/payment_aba_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../value_statics.dart';

class PaymentABAPackageScreen extends StatefulWidget {
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
  State<PaymentABAPackageScreen> createState() =>
      _PaymentABAPackageScreenState();
}

class _PaymentABAPackageScreenState extends State<PaymentABAPackageScreen> {
  late final PaymentAbaController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<PaymentAbaController>()) {
      try {
        Get.find<PaymentAbaController>().stop();
      } catch (_) {}
      Get.delete<PaymentAbaController>();
    }
    controller = Get.put(
      PaymentAbaController(
        transactionId: widget.transactionId,
        token: widget.token,
        title: widget.title,
        url: widget.url,
        type: widget.type,
      ),
    );
    controller.init(context: context);
  }

  @override
  void dispose() {
    try {
      controller.stop();
    } catch (_) {}
    if (Get.isRegistered<PaymentAbaController>()) {
      Get.delete<PaymentAbaController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          controller.stop();
        } catch (_) {}
        if (Get.isRegistered<PaymentAbaController>()) {
          Get.delete<PaymentAbaController>(force: true);
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
                Get.delete<PaymentAbaController>(force: true);
              }
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: Text(
            widget.title,
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
