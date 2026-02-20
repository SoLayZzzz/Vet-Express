import 'package:express_vet/feature/home-dashboard/payment/presentaion/controller/payment_aba_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../../utils/app_bar.dart';

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
    if (!Get.isRegistered<PaymentAbaController>()) {
      Get.put(
        PaymentAbaController(
          transactionId: transactionId,
          token: token,
          title: title,
          url: url,
          type: type,
        ),
      );
    }

    // Ensure controller initialized once after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.init(context: context);
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBarVET().appBar(context, title),
        body: WebViewWidget(controller: controller.webViewController),
      ),
    );
  }
}
