import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controller/payment_wing_controller.dart';

class PaymentWingScreen extends StatefulWidget {
  final String transactionId;
  final String token;

  const PaymentWingScreen({
    super.key,
    required this.transactionId,
    required this.token,
  });

  @override
  State<PaymentWingScreen> createState() => _PaymentWingScreenState();
}

class _PaymentWingScreenState extends State<PaymentWingScreen>
    with WidgetsBindingObserver {
  late final PaymentWingController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.put(
      PaymentWingController(
        transactionId: widget.transactionId,
        token: widget.token,
      ),
    );
    controller.init(context: context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When the user returns from the Wing Bank app, dismiss any loading overlay
    if (state == AppLifecycleState.resumed) {
      debugPrint('PaymentWingScreen.didChangeAppLifecycleState -> resumed, hiding loading');
      controller.hideLoadingOnResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: popScreen,
      child: Scaffold(
        appBar: AppBarVET().appBar(context, 'Wing Bank'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Stack(
              children: [
                Center(
                  child: WebViewWidget(
                    controller: controller.webViewController,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Get.isRegistered<PaymentWingController>()) {
      Get.delete<PaymentWingController>(force: true);
    }
    super.dispose();
  }

  Future<bool> popScreen() async {
    Get.back();
    return false;
  }
}
