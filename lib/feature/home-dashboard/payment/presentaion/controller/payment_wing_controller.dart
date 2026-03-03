import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../../../../base/base_url.dart';
import '../../../passenger/data/network/passenger_network_request.dart';
import '../../../passenger/presentation/binding/passenger_binding.dart';
import '../../../../../utils/loading.dart';

class PaymentWingController extends GetxController {
  final String transactionId;
  final String token;

  PaymentWingController({required this.transactionId, required this.token});

  late final WebViewController webViewController;
  bool _active = true;
  bool _isLoadingShown = false;

  PassengerNetworkRequest _ensureNetworkRequest() {
    if (!Get.isRegistered<PassengerNetworkRequest>()) {
      PassengerBinding().dependencies();
    }
    return Get.find<PassengerNetworkRequest>();
  }

  void _showLoadingIfNeeded() {
    if (!_isLoadingShown) {
      _isLoadingShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only show if still intended to be visible
        if (_isLoadingShown) {
          Loading().loadingShow();
        }
      });
    }
  }

  void _hideLoadingIfShown() {
    if (_isLoadingShown) {
      _isLoadingShown = false;
      Loading().loadingClose();
    }
  }

  void init({required BuildContext context}) {
    webViewController = WebViewController();

    if (Platform.isAndroid) {
      final androidController =
          webViewController.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    } else if (Platform.isIOS) {
      final iosController =
          webViewController.platform as WebKitWebViewController;
      iosController.setAllowsBackForwardNavigationGestures(true);
    }

    webViewController.loadRequest(
      Uri.parse(
        "${BaseUrl.PAYMENT_URL}payments/wingNewApiPaymentPro/$transactionId/$token",
      ),
    );

    webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);

    webViewController.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://closewingpayment/')) {
            return NavigationDecision.prevent;
          }
          if (request.url.startsWith('wingbankapp://payment?')) {
            openDeepLinkWingBank(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_active) {
        checkPaymentWingComplete(
          context: context,
          transactionId: transactionId,
        );
      }
    });
  }

  @override
  void onClose() {
    _active = false;
    super.onClose();
  }

  Future<void> openDeepLinkWingBank(String deepLink) async {
    final Uri url = Uri.parse(deepLink);

    try {
      _showLoadingIfNeeded();
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (Platform.isIOS) {
          await launchUrl(
            Uri.parse('https://apps.apple.com/cd/app/wing-bank/id1113286385'),
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (error) {
      if (Platform.isAndroid) {
        await launchUrl(
          Uri.parse(
            'https://play.google.com/store/apps/details?id=com.wingmoney.wingpay&hl=en_US',
          ),
          mode: LaunchMode.externalApplication,
        );
      }
    }
  }

  Future<void> checkPaymentWingComplete({
    required BuildContext context,
    required String transactionId,
  }) async {
    if (!_active) return;
    _showLoadingIfNeeded();
    try {
      log(
        'PaymentWingController.checkTicketStatus.request transactionId=$transactionId',
      );
      final wingResponse = await _ensureNetworkRequest().checkTicketStatus(
        context: context,
        transactionId: transactionId.toString(),
      );

      if (wingResponse.header?.statusCode == 200 &&
          wingResponse.header?.result == true) {
        final status = '${wingResponse.body?.data?[0].status ?? ''}';
        log(
          'PaymentWingController.checkTicketStatus.response '
          'statusCode=${wingResponse.header?.statusCode}, '
          'result=${wingResponse.header?.result}, status=$status',
        );
        if (status == '1') {
          _hideLoadingIfShown();
          Get.back(result: '1');
        } else {
          log(
            'PaymentWingController.checkTicketStatus.pending -> poll again in 2s',
          );
          Future.delayed(const Duration(seconds: 2), () {
            if (_active) {
              checkPaymentWingComplete(
                context: context,
                transactionId: transactionId,
              );
            }
          });
        }
      }
    } catch (_) {
      log(
        'PaymentWingController.checkTicketStatus.error for transactionId=$transactionId',
      );
      if (_active) {
        checkPaymentWingComplete(
          context: context,
          transactionId: transactionId,
        );
      }
    }
  }
}
