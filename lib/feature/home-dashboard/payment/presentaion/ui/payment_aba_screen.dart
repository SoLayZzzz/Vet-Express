import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/utils/app_bar.dart';
import '../controller/payment_aba_controller.dart';

class PaymentABAScreen extends StatefulWidget {
  final String transactionId;
  final String token;
  final String title;
  final String url;
  final int type;

  /// 1 is KHQR 2 is Credit card 3 Alipay 4 ACLEDA XPay

  const PaymentABAScreen({
    super.key,
    required this.transactionId,
    required this.token,
    required this.type,
    required this.title,
    required this.url,
  });

  @override
  State<PaymentABAScreen> createState() => PaymentABAScreenState();
}

class PaymentABAScreenState extends State<PaymentABAScreen>
    with WidgetsBindingObserver {
  late final PaymentAbaController controller;

  @override
  void initState() {
    super.initState();
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
    if (Get.isRegistered<PaymentAbaController>()) {
      Get.delete<PaymentAbaController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: popScreen,
    child: Scaffold(
      appBar: AppBarVET().appBar(context, widget.title),
      body: WebViewWidget(controller: controller.webViewController),
    ),
  );

  Future<bool> popScreen() async {
    Get.back();
    return false;
  }
}
