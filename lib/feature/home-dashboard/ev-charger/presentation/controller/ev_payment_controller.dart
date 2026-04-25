import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'ev_top_up_controller.dart';

class EvPaymentController extends GetxController {
  late final String deepLink;
  late final String checkoutQrUrl;

  final RxBool isLoading = true.obs;
  final RxBool paymentCompleted = false.obs;
  final RxBool showWebView = false.obs;
  final RxBool deepLinkAttempted = false.obs;

  final Rxn<WebViewController> webViewController = Rxn<WebViewController>();

  late final EvTopUpController topUpController;

  @override
  void onInit() {
    super.onInit();

    topUpController = Get.find<EvTopUpController>();

    final args = Get.arguments;
    if (args is Map) {
      deepLink = (args['deepLink'] as String?) ?? '';
      checkoutQrUrl = (args['checkoutQrUrl'] as String?) ?? '';
    } else {
      deepLink = '';
      checkoutQrUrl = '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startPaymentProcess();
    });
  }

  @override
  void onClose() {
    if (!paymentCompleted.value) {
      debugPrint('Payment screen closed, checking status');
      topUpController.checkPaymentStatusManually();
    }

    final wv = webViewController.value;
    if (showWebView.value && wv != null) {
      wv.clearCache();
      wv.clearLocalStorage();
    }

    super.onClose();
  }

  Future<void> startPaymentProcess() async {
    await tryOpenDeepLink();
  }

  Future<void> tryOpenDeepLink() async {
    deepLinkAttempted.value = true;
    isLoading.value = true;

    try {
      final uri = Uri.parse(deepLink);
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        debugPrint('Attempting to launch deeplink: $deepLink');
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          debugPrint('Banking app launched successfully');
          Get.snackbar(
            'Payment App Opened',
            'Please complete the payment in your banking app',
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            duration: const Duration(milliseconds: 3000),
          );

          Future.delayed(const Duration(milliseconds: 3000), () {
            topUpController.checkPaymentStatusManually();
          });

          Future.delayed(const Duration(milliseconds: 10000), () {
            if (!paymentCompleted.value && !showWebView.value) {
              fallbackToWebView();
            }
          });

          return;
        }
      }

      debugPrint('Cannot launch deeplink or launch failed');
      fallbackToWebView();
    } catch (e) {
      debugPrint('Error launching deeplink: $e');
      fallbackToWebView();
    }
  }

  void fallbackToWebView() {
    debugPrint('Falling back to webview with URL: $checkoutQrUrl');
    showWebView.value = true;
    isLoading.value = false;
    initializeWebView();
  }

  void initializeWebView() {
    if (checkoutQrUrl.isEmpty) {
      Get.snackbar(
        'Error',
        'Payment URL is not available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.back();
      });
      return;
    }

    final controller = WebViewController();

    controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {},
        onPageStarted: (String url) {
          isLoading.value = true;
          if (checkForPaymentCompletion(url)) {
            isLoading.value = false;
          }
        },
        onPageFinished: (String url) {
          isLoading.value = false;
          checkForPaymentCompletion(url);
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('WebView error: ${error.description}');
          isLoading.value = false;
        },
        onNavigationRequest: (NavigationRequest request) {
          debugPrint('WebView navigation to: ${request.url}');

          if (paymentCompleted.value) {
            return NavigationDecision.prevent;
          }

          if (checkForPaymentCompletion(request.url)) {
            return NavigationDecision.prevent;
          }

          if (request.url.startsWith('abapay://') ||
              request.url.startsWith('aba://') ||
              request.url.startsWith('abamobilebank://') ||
              request.url.contains('abapay')) {
            launchDeepLinkFromWebView(request.url);
            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
      ),
    );

    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.loadRequest(Uri.parse(checkoutQrUrl));

    webViewController.value = controller;
  }

  Future<void> launchDeepLinkFromWebView(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching deeplink from WebView: $e');
    }
  }

  bool checkForPaymentCompletion(String url) {
    if (paymentCompleted.value) return false;

    final successPatterns = [
      'success',
      'payment-success',
      'completed',
      'thank-you',
      'successful',
      'approved',
      'transaction-complete',
      'payment-done',
      'order-success',
      'paymentsuccess',
      'payment/success',
      'status=success',
      'result=success',
    ];

    final lowerUrl = url.toLowerCase();
    for (final pattern in successPatterns) {
      if (lowerUrl.contains(pattern)) {
        handleSuccessfulPayment();
        return true;
      }
    }

    if (lowerUrl.contains('aba') &&
        (lowerUrl.contains('complete') ||
            lowerUrl.contains('success') ||
            lowerUrl.contains('done'))) {
      handleSuccessfulPayment();
      return true;
    }

    return false;
  }

  void handleSuccessfulPayment() {
    if (paymentCompleted.value) return;

    paymentCompleted.value = true;
    debugPrint('Payment success detected in WebView');

    final wv = webViewController.value;
    if (showWebView.value && wv != null) {
      wv.clearCache();
      wv.clearLocalStorage();
    }

    Get.snackbar(
      'Payment Successful',
      'Your payment was completed successfully!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 2000),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      Get.back();

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      topUpController.checkPaymentStatusManually();
    });
  }

  void handlePaymentFailure() {
    if (paymentCompleted.value) return;

    paymentCompleted.value = true;
    debugPrint('Payment failure detected in WebView');

    final wv = webViewController.value;
    if (showWebView.value && wv != null) {
      wv.clearCache();
      wv.clearLocalStorage();
    }

    Get.snackbar(
      'Payment Failed',
      'Payment was not completed. Please try again.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 3000),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      Get.back();
    });
  }

  Future<bool> onWillPop() async {
    if (paymentCompleted.value) {
      return true;
    }

    final shouldClose = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel Payment'),
        content: const Text('Are you sure you want to cancel this payment?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldClose == true) {
      topUpController.checkPaymentStatusManually();

      final wv = webViewController.value;
      if (showWebView.value && wv != null) {
        wv.clearCache();
        wv.clearLocalStorage();
      }
    }

    return shouldClose ?? false;
  }
}
