import 'dart:developer';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:express_vet/utils/app_bar.dart';
import '../controller/payment_aba_controller.dart';

class PaymentABAScreen extends StatefulWidget {
  final String transactionId;
  final String token;
  final String title;
  final String url;
  final String deeplink;
  final int type;

  /// 1 is KHQR 2 is Credit card 3 Alipay 4 ACLEDA XPay

  const PaymentABAScreen({
    super.key,
    required this.transactionId,
    required this.token,
    required this.type,
    required this.title,
    required this.url,
    this.deeplink = '',
  });

  @override
  State<PaymentABAScreen> createState() => PaymentABAScreenState();
}

class PaymentABAScreenState extends State<PaymentABAScreen>
    with WidgetsBindingObserver {
  late final PaymentAbaController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Get.isRegistered<PaymentAbaController>()) {
      try {
        Get.find<PaymentAbaController>().stop();
      } catch (_) {}
      try {
        Get.delete<PaymentAbaController>(force: true);
      } catch (_) {}
    }
    controller = Get.put(
      PaymentAbaController(
        transactionId: widget.transactionId,
        token: widget.token,
        title: widget.title,
        url: widget.url,
        deeplink: widget.deeplink,
        type: widget.type,
      ),
    );
    controller.init(context: context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    log(
      'PaymentABAScreen.lifecycle state=$state, type=${widget.type}, transactionId=${widget.transactionId}',
    );
    if (widget.type != 1) return;
    if (state == AppLifecycleState.resumed) {
      log(
        'PaymentABAScreen.resume trigger checkTransactionABAComplete transactionId=${widget.transactionId}',
      );
      controller.checkTransactionABAComplete(
        context: context,
        transactionId: widget.transactionId,
        token: widget.token,
      );
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      controller.stop();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (didPop) return;
      popScreen();
    },
    child: Scaffold(
      appBar: AppBarVET().appBar(context, widget.title),
      body:
          widget.type == 1 && widget.url.isNotEmpty
              ? Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                    initialSettings: InAppWebViewSettings(
                      transparentBackground: true,
                      javaScriptEnabled: true,
                      useShouldOverrideUrlLoading: true,
                    ),
                    onProgressChanged: (_, progress) {
                      if (!mounted) return;
                      setState(() {
                        isLoading = progress < 100;
                      });
                    },
                    onLoadStop: (_, __) {
                      if (!mounted) return;
                      setState(() {
                        isLoading = false;
                      });
                    },
                    shouldOverrideUrlLoading: (_, navigationAction) async {
                      final requestUrl =
                          navigationAction.request.url?.toString() ?? '';
                      if (requestUrl.startsWith('abapay://') ||
                          requestUrl.startsWith('aba://') ||
                          requestUrl.startsWith('abamobilebank://') ||
                          requestUrl.contains('abapay')) {
                        await controller.openDeepLinkABA(requestUrl);
                        return NavigationActionPolicy.CANCEL;
                      }
                      return NavigationActionPolicy.ALLOW;
                    },
                    onReceivedServerTrustAuthRequest:
                        (_, __) async => ServerTrustAuthResponse(
                          action: ServerTrustAuthResponseAction.PROCEED,
                        ),
                  ),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              )
              : WebViewWidget(controller: controller.webViewController),
    ),
  );

  void popScreen() {
    Get.back();
  }
}
