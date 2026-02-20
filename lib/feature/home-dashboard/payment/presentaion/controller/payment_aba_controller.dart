import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../../../base/base_url.dart';
import '../../data/model/response/aba_payment_response.dart';
import '../../../../../utils/app_pref.dart';
import '../../../../../utils/loading.dart';

class PaymentAbaController extends GetxController {
  bool _loop = true;

  final String transactionId;
  final String token;
  final String title;
  final String url;
  final int type;

  PaymentAbaController({
    required this.transactionId,
    required this.token,
    required this.title,
    required this.url,
    required this.type,
  });

  late final WebViewController webViewController;

  @override
  void onClose() {
    _loop = false;
    super.onClose();
  }

  void init({required BuildContext context}) {
    _loop = true;

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

    final initialUrl = _returnUrl(type, transactionId, token);
    if (initialUrl.isNotEmpty) {
      final uri = Uri.tryParse(initialUrl);
      if (uri != null && uri.hasScheme) {
        webViewController.loadRequest(uri);
      }
    }

    webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);

    if (type == 1) {
      // ABA KHQR
      if ((url).isEmpty) {
        // Only call backend to get deeplink/qr when URL not provided by caller
        payWithABAMobile(
          context: context,
          transactionId: transactionId,
          token: token,
        );
      }
      // Start ABA transaction status polling
      checkPaymentABAComplete(
        context: context,
        transactionId: transactionId,
        token: token,
      );
    } else if (type == 2 || type == 3) {
      // Credit/Debit Card or Alipay
      checkPaymentABAComplete(
        context: context,
        transactionId: transactionId,
        token: token,
      );
    } else if (type == 4) {
      // ACLEDA XPay
      checkPaymentACLEDAComplete(
        context: context,
        transactionId: transactionId,
        token: token,
      );
    }
  }

  Future<void> openDeepLinkABA(String deepLink) async {
    try {
      final uri = Uri.tryParse(deepLink);
      if (uri == null || !uri.hasScheme) {
        log('Invalid or empty ABA deep link: $deepLink');
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      log("launching... deep link");
    } catch (e) {
      log(e.toString());
    }
  }

  String _returnUrl(int type, String transactionId, String token) {
    if (type == 1) {
      return url;
    } else if (type == 2) {
      return "${BaseUrl.PAYMENT_URL}payments/abaVisalPayment/$transactionId/$token/2";
    } else if (type == 3) {
      return "${BaseUrl.PAYMENT_URL}payments/abaAlipay/$transactionId/$token";
    } else if (type == 4) {
      return "${BaseUrl.PAYMENT_URL}payments/acledaXpay/$transactionId/$token";
    }
    return '';
  }

  Future<void> payWithABAMobile({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    log('${BaseUrl.PAYMENT_URL}payments/abaMobilePay/$transactionId/$token');

    final response = await http.post(
      Uri.parse(
        '${BaseUrl.PAYMENT_URL}payments/abaMobilePay/$transactionId/$token',
      ),
      headers: <String, String>{'Authorization': AppPref.getToken() ?? ''},
    );

    if (response.statusCode == 200) {
      log('This is response ABA Payment 2 ==>>${response.body}');
      var data = ABAPayResponse.fromJson(jsonDecode(response.body));

      if (data.status == 1) {
        final deepLink = data.abapayDeeplink ?? '';
        if (deepLink.isNotEmpty) {
          openDeepLinkABA(deepLink);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('something_wrong'.tr)));
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('payment_time_out'.tr)));
      }
    } else {
      throw Exception('Failed to load to server!');
    }
  }

  Future<void> checkPaymentABAComplete({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    if (!_loop) return;
    final response = await http.post(
      Uri.parse(
        '${BaseUrl.PAYMENT_URL}payments/checkAbaTransaction/$transactionId',
      ),
      headers: <String, String>{'Authorization': AppPref.getToken() ?? ''},
    );

    if (response.statusCode == 200) {
      log('This is response check payment $title ==>>${response.body}');
      Map<dynamic, dynamic> result = jsonDecode(response.body);
      if (result['status'] == 1) {
        log('Check status transaction == 1');
        checkTransactionABAComplete(
          context: context,
          transactionId: transactionId,
          token: token,
        );
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (_loop) {
            checkPaymentABAComplete(
              context: context,
              transactionId: transactionId,
              token: token,
            );
          }
        });
      }
    } else {
      if (_loop) {
        checkPaymentABAComplete(
          context: context,
          transactionId: transactionId,
          token: token,
        );
      }
      throw Exception('Failed to load to server!');
    }
  }

  Future<void> checkTransactionABAComplete({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    _loop = false;

    Loading().loadingShow(context);

    final response = await http.post(
      Uri.parse(
        '${BaseUrl.PAYMENT_URL}payments/checkTerminalPaymentComplete/$transactionId/$token',
      ),
      headers: <String, String>{'Authorization': AppPref.getToken() ?? ''},
    );

    if (!_loop) {
      Loading().loadingClose(context);
      return;
    }

    if (response.statusCode == 200) {
      log('This is response check transaction $title ==>>${response.body}');
      Map<dynamic, dynamic> result = jsonDecode(response.body);
      log(result['status']);
      Loading().loadingClose(context);
      if (result['status'] == "1") {
        log('Check status transaction $title == 1');
        Get.back(result: '1');
      }
    } else {
      if (_loop) {
        checkTransactionABAComplete(
          context: context,
          transactionId: transactionId,
          token: token,
        );
      }
      throw Exception('Failed to load to server!');
    }
  }

  Future<void> checkPaymentACLEDAComplete({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    if (!_loop) return;
    final response = await http.post(
      Uri.parse(
        '${BaseUrl.PAYMENT_URL}payments/acledaCheckStatus/$transactionId',
      ),
      headers: <String, String>{'Authorization': AppPref.getToken() ?? ''},
    );

    if (response.statusCode == 200) {
      log('This is response check payment ACLEDA ==>>${response.body}');
      Map<dynamic, dynamic> result = jsonDecode(response.body);
      if (result['status'] == 1) {
        log('Check status transaction == 1');

        Future.delayed(const Duration(seconds: 3), () {
          checkTransactionACLEDAComplete(
            context: context,
            transactionId: transactionId,
            token: token,
          );
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (_loop) {
            checkPaymentACLEDAComplete(
              context: context,
              transactionId: transactionId,
              token: token,
            );
          }
        });
      }
    } else {
      if (_loop) {
        checkPaymentACLEDAComplete(
          context: context,
          transactionId: transactionId,
          token: token,
        );
      }
      throw Exception('Failed to load to server!');
    }
  }

  Future<void> checkTransactionACLEDAComplete({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    _loop = false;

    Loading().loadingShow(context);

    final response = await http.post(
      Uri.parse(
        '${BaseUrl.PAYMENT_URL}payments/acledaComplete/$transactionId/$token',
      ),
      headers: <String, String>{'Authorization': AppPref.getToken() ?? ''},
    );

    if (!_loop) {
      Loading().loadingClose(context);
      return;
    }

    if (response.statusCode == 200) {
      log('This is response check transaction ACLEDA ==>>${response.body}');
      Map<dynamic, dynamic> result = jsonDecode(response.body);
      log(result['status'].toString());
      Loading().loadingClose(context);
      if (result['status'] == 1) {
        log('Check status transaction ACLEDA == 1');
        Get.back(result: '1');
      }
    } else {
      if (_loop) {
        checkTransactionACLEDAComplete(
          context: context,
          transactionId: transactionId,
          token: token,
        );
      }
      throw Exception('Failed to load to server!');
    }
  }
}
