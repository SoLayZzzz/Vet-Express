import 'dart:async';
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
  bool _initialized = false;

  void _scheduleRetry(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 1000),
  }) {
    Future.delayed(delay, () {
      if (_loop) {
        callback();
      }
    });
  }

  final String transactionId;
  final String token;
  final String title;
  final String url;
  final String deeplink;
  final int type;

  PaymentAbaController({
    required this.transactionId,
    required this.token,
    required this.title,
    required this.url,
    required this.deeplink,
    required this.type,
  });

  late final WebViewController webViewController;

  @override
  void onClose() {
    _loop = false;
    super.onClose();
  }

  void stop() {
    _loop = false;
  }

  void init({required BuildContext context}) {
    if (_initialized) return;
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
      if (deeplink.isNotEmpty) {
        Future.microtask(() async {
          await openDeepLinkABA(deeplink);
        });
      }
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

    _initialized = true;
  }

  Future<void> openDeepLinkABA(String deepLink) async {
    try {
      final uri = Uri.tryParse(deepLink);
      if (uri == null || !uri.hasScheme) {
        log('Invalid or empty ABA deep link: $deepLink');
        return;
      }
      final canOpen = await canLaunchUrl(uri);
      if (!canOpen) {
        log('ABA app is not available for deep link: $deepLink');
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
      final Map<String, dynamic> responseMap = jsonDecode(response.body);
      var data = ABAPayResponse.fromJson(responseMap);
      log('This is response ABA Payment 2 ==>>${response.body}');
      final checkoutUrl =
          (responseMap['checkout_qr_url'] ?? data.checkout_qr_url ?? '')
              .toString();
      log("======>> Check out url: === $checkoutUrl");
      if (data.status == 1) {
        if (checkoutUrl.isNotEmpty) {
          final uri = Uri.tryParse(checkoutUrl);

          if (uri != null && uri.hasScheme) {
            log("======----->> Check out url - uri: === $uri");
            webViewController.loadRequest(uri);
          }
        }

        final deepLink = data.abapayDeeplink ?? '';
        if (deepLink.isNotEmpty) {
          openDeepLinkABA(deepLink);
        } else if (checkoutUrl.isEmpty) {
          ScaffoldMessenger.of(
            Get.context!,
          ).showSnackBar(SnackBar(content: Text('something_wrong'.tr)));
        }
      } else {
        ScaffoldMessenger.of(
          Get.context!,
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
    try {
      final response = await http
          .post(
            Uri.parse(
              '${BaseUrl.PAYMENT_URL}payments/checkAbaTransaction/$transactionId',
            ),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (!_loop) return;

      if (response.statusCode == 200) {
        log('This is response check payment $title ==>>${response.body}');
        Map<dynamic, dynamic> result = jsonDecode(response.body);
        final status = '${result['status']}';
        if (status == '1') {
          log('Check status transaction == 1');
          _loop = false;
          Get.back(result: '1');
        } else {
          log('Check status transaction == $status (payment pending)');
          _scheduleRetry(() {
            checkPaymentABAComplete(
              context: Get.context ?? context,
              transactionId: transactionId,
              token: token,
            );
          });
        }
      } else {
        log(
          'Check payment request failed (${response.statusCode}). Retrying...',
        );
        _scheduleRetry(() {
          checkPaymentABAComplete(
            context: Get.context ?? context,
            transactionId: transactionId,
            token: token,
          );
        });
      }
    } on SocketException catch (e) {
      log('Network error while checking payment status: $e');
      _scheduleRetry(() {
        checkPaymentABAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    } on http.ClientException catch (e) {
      log('HTTP client error while checking payment status: $e');
      _scheduleRetry(() {
        checkPaymentABAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    } on TimeoutException catch (e) {
      log('Timeout while checking payment status: $e');
      _scheduleRetry(() {
        checkPaymentABAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    } catch (e) {
      log('Unexpected error while checking payment status: $e');
      _scheduleRetry(() {
        checkPaymentABAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    }
  }

  Future<void> checkTransactionABAComplete({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    final requestUrl =
        '${BaseUrl.PAYMENT_URL}payments/checkTerminalPaymentComplete/$transactionId/$token';
    log(
      'PaymentAbaController.checkTransactionABAComplete.request '
      'transactionId=$transactionId, tokenLen=${token.length}, url=$requestUrl',
    );
    Loading().loadingShow();

    try {
      final response = await http
          .post(
            Uri.parse(requestUrl),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        Map<dynamic, dynamic> result = jsonDecode(response.body);
        final normalizedResponse = jsonEncode(<String, dynamic>{
          'transactionCode': result['transactionCode'] ?? transactionId,
          'status': '${result['status']}',
        });
        log(
          'PaymentAbaController.checkTransactionABAComplete.response '
          'statusCode=${response.statusCode}, status=${result['status']}',
        );
        log(
          'This is response check transaction $title ==>>\n      $normalizedResponse',
        );
        log(
          'PaymentAbaController.checkTransactionABAComplete.status=${result['status']}',
        );
        Loading().loadingClose();
        if (result['status'] == "1") {
          log('Check status transaction $title == 1');
          Get.back(result: '1');
        }
      } else {
        Loading().loadingClose();
        log(
          'PaymentAbaController.checkTransactionABAComplete.failed '
          'statusCode=${response.statusCode}, body=${response.body}',
        );
      }
    } on SocketException catch (e) {
      Loading().loadingClose();
      log(
        'PaymentAbaController.checkTransactionABAComplete.networkError '
        'transactionId=$transactionId, error=$e',
      );
    } on http.ClientException catch (e) {
      Loading().loadingClose();
      log(
        'PaymentAbaController.checkTransactionABAComplete.httpClientError '
        'transactionId=$transactionId, error=$e',
      );
    } on TimeoutException catch (e) {
      Loading().loadingClose();
      log(
        'PaymentAbaController.checkTransactionABAComplete.timeout '
        'transactionId=$transactionId, error=$e',
      );
    } catch (e) {
      Loading().loadingClose();
      log(
        'PaymentAbaController.checkTransactionABAComplete.unexpectedError '
        'transactionId=$transactionId, error=$e',
      );
    }
  }

  Future<void> checkPaymentACLEDAComplete({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    if (!_loop) return;
    try {
      final response = await http
          .post(
            Uri.parse(
              '${BaseUrl.PAYMENT_URL}payments/acledaCheckStatus/$transactionId',
            ),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (!_loop) return;

      if (response.statusCode == 200) {
        log('This is response check payment ACLEDA ==>>${response.body}');
        Map<dynamic, dynamic> result = jsonDecode(response.body);
        final status = '${result['status']}';
        if (status == '1') {
          log('Check status transaction == 1');
          _loop = false;
          Get.back(result: '1');
        } else if (status == '0') {
          log('Check status transaction == 0 (payment failed)');
          _loop = false;
          Get.back(result: '0');
        } else {
          _scheduleRetry(() {
            checkPaymentACLEDAComplete(
              context: Get.context ?? context,
              transactionId: transactionId,
              token: token,
            );
          });
        }
      } else {
        log(
          'Check ACLEDA payment request failed (${response.statusCode}). Retrying...',
        );
        _scheduleRetry(() {
          checkPaymentACLEDAComplete(
            context: Get.context ?? context,
            transactionId: transactionId,
            token: token,
          );
        });
      }
    } on SocketException catch (e) {
      log('Network error while checking ACLEDA payment status: $e');
      _scheduleRetry(() {
        checkPaymentACLEDAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    } on http.ClientException catch (e) {
      log('HTTP client error while checking ACLEDA payment status: $e');
      _scheduleRetry(() {
        checkPaymentACLEDAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    } on TimeoutException catch (e) {
      log('Timeout while checking ACLEDA payment status: $e');
      _scheduleRetry(() {
        checkPaymentACLEDAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    } catch (e) {
      log('Unexpected error while checking ACLEDA payment status: $e');
      _scheduleRetry(() {
        checkPaymentACLEDAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    }
  }

  Future<void> checkTransactionACLEDAComplete({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    Loading().loadingShow();

    try {
      final response = await http
          .post(
            Uri.parse(
              '${BaseUrl.PAYMENT_URL}payments/acledaComplete/$transactionId/$token',
            ),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        log('This is response check transaction ACLEDA ==>>${response.body}');
        Map<dynamic, dynamic> result = jsonDecode(response.body);
        log(result['status'].toString());
        Loading().loadingClose();
        if (result['status'] == 1) {
          log('Check status transaction ACLEDA == 1');
          Get.back(result: '1');
        }
      } else {
        Loading().loadingClose();
        log(
          'Check ACLEDA transaction request failed (${response.statusCode}).',
        );
      }
    } on SocketException catch (e) {
      Loading().loadingClose();
      log('Network error while checking ACLEDA transaction status: $e');
    } on http.ClientException catch (e) {
      Loading().loadingClose();
      log('HTTP client error while checking ACLEDA transaction status: $e');
    } on TimeoutException catch (e) {
      Loading().loadingClose();
      log('Timeout while checking ACLEDA transaction status: $e');
    } catch (e) {
      Loading().loadingClose();
      log('Unexpected error while checking ACLEDA transaction status: $e');
    }
  }
}
