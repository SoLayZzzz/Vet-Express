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
  DateTime? _acledaPollStartAt;
  final Duration _acledaMaxWait = const Duration(minutes: 3);

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

  void _logNetwork({
    required String url,
    required String method,
    required Map<String, String>? headers,
    required dynamic requestBody,
    required int statusCode,
    required String responseBody,
  }) {
    dynamic prettyResponse = responseBody;
    try {
      final decoded = jsonDecode(responseBody);
      prettyResponse = const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {}

    String endpoint = '';
    try {
      endpoint = Uri.parse(url).path;
    } catch (_) {}

    debugPrint(
      '--------------------------------------------------\n'
      '🚀 REQUEST: $method\n'
      '🛣️ Endpoint: $endpoint\n'
      '🔗 URL: $url\n'
      '🔑 Headers: $headers\n'
      '📦 Body: $requestBody\n'
      '--------------------------------------------------\n'
      '📥 RESPONSE ($statusCode):\n$prettyResponse\n'
      '--------------------------------------------------',
    );
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
      _acledaPollStartAt = DateTime.now();
      _scheduleRetry(() {
        checkPaymentACLEDAComplete(
          context: context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    }

    _initialized = true;
  }

  Future<void> openDeepLinkABA(String deepLink) async {
    try {
      final uri = Uri.tryParse(deepLink);
      if (uri == null || !uri.hasScheme) {
        debugPrint('Invalid or empty ABA deep link: $deepLink');
        return;
      }
      final canOpen = await canLaunchUrl(uri);
      if (!canOpen) {
        debugPrint('ABA app is not available for deep link: $deepLink');
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      debugPrint("launching... deep link");
    } catch (e) {
      debugPrint(e.toString());
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
    final url =
        '${BaseUrl.PAYMENT_URL}payments/abaMobilePay/$transactionId/$token';
    final headers = <String, String>{'Authorization': AppPref.getToken() ?? ''};

    final response = await http.post(Uri.parse(url), headers: headers);

    _logNetwork(
      url: url,
      method: 'POST',
      headers: headers,
      requestBody: null,
      statusCode: response.statusCode,
      responseBody: response.body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseMap = jsonDecode(response.body);
      var data = ABAPayResponse.fromJson(responseMap);
      debugPrint('This is response ABA Payment 2 ==>>${response.body}');
      final checkoutUrl =
          (responseMap['checkout_qr_url'] ?? data.checkout_qr_url ?? '')
              .toString();
      debugPrint("======>> Check out url: === $checkoutUrl");
      if (data.status == 1) {
        if (checkoutUrl.isNotEmpty) {
          final uri = Uri.tryParse(checkoutUrl);

          if (uri != null && uri.hasScheme) {
            debugPrint("======----->> Check out url - uri: === $uri");
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
      final url =
          '${BaseUrl.PAYMENT_URL}payments/checkAbaTransaction/$transactionId';
      final headers = <String, String>{
        'Authorization': AppPref.getToken() ?? '',
      };
      final response = await http
          .post(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 20));

      if (!_loop) return;

      _logNetwork(
        url: url,
        method: 'POST',
        headers: headers,
        requestBody: null,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200) {
        debugPrint(
          'This is response check payment $title ==>>${response.body}',
        );
        Map<dynamic, dynamic> result = jsonDecode(response.body);
        final status = '${result['status']}';
        if (status == '1') {
          debugPrint(
            'Check status transaction == 1. Checking terminal payment completion.',
          );
          _loop = false;
          checkTransactionABAComplete(
            context: Get.context ?? context,
            transactionId: transactionId,
            token: token,
          );
        } else {
          debugPrint('Check status transaction == $status (payment pending)');
          _scheduleRetry(() {
            checkPaymentABAComplete(
              context: Get.context ?? context,
              transactionId: transactionId,
              token: token,
            );
          });
        }
      } else {
        debugPrint(
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
      debugPrint('Network error while checking payment status: $e');
      _scheduleRetry(() {
        checkPaymentABAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    } on http.ClientException catch (e) {
      debugPrint('HTTP client error while checking payment status: $e');
      _scheduleRetry(() {
        checkPaymentABAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    } on TimeoutException catch (e) {
      debugPrint('Timeout while checking payment status: $e');
      _scheduleRetry(() {
        checkPaymentABAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Unexpected error while checking payment status: $e');
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
    debugPrint(
      'PaymentAbaController.checkTransactionABAComplete.request '
      'transactionId=$transactionId, token=$token, url=$requestUrl',
    );
    Loading().loadingShow();

    try {
      final headers = <String, String>{
        'Authorization': AppPref.getToken() ?? '',
      };
      final response = await http
          .post(Uri.parse(requestUrl), headers: headers)
          .timeout(const Duration(seconds: 20));

      _logNetwork(
        url: requestUrl,
        method: 'POST',
        headers: headers,
        requestBody: null,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200) {
        Map<dynamic, dynamic> result = jsonDecode(response.body);
        final normalizedResponse = jsonEncode(<String, dynamic>{
          'transactionCode': result['transactionCode'] ?? transactionId,
          'status': '${result['status']}',
        });
        debugPrint(
          'PaymentAbaController.checkTransactionABAComplete.response '
          'statusCode=${response.statusCode}, status=${result['status']}',
        );
        debugPrint(
          'This is response check transaction $title ==>>\n      $normalizedResponse',
        );
        debugPrint(
          'PaymentAbaController.checkTransactionABAComplete.status=${result['status']}',
        );
        Loading().loadingClose();
        if (result['status'] == "1") {
          debugPrint('Check status transaction $title == 1');
          Get.back(result: '1');
        }
      } else {
        Loading().loadingClose();
        debugPrint(
          'PaymentAbaController.checkTransactionABAComplete.failed '
          'statusCode=${response.statusCode}, body=${response.body}',
        );
      }
    } on SocketException catch (e) {
      Loading().loadingClose();
      debugPrint(
        'PaymentAbaController.checkTransactionABAComplete.networkError '
        'transactionId=$transactionId, error=$e',
      );
    } on http.ClientException catch (e) {
      Loading().loadingClose();
      debugPrint(
        'PaymentAbaController.checkTransactionABAComplete.httpClientError '
        'transactionId=$transactionId, error=$e',
      );
    } on TimeoutException catch (e) {
      Loading().loadingClose();
      debugPrint(
        'PaymentAbaController.checkTransactionABAComplete.timeout '
        'transactionId=$transactionId, error=$e',
      );
    } catch (e) {
      Loading().loadingClose();
      debugPrint(
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
    final startedAt = _acledaPollStartAt;
    if (startedAt != null &&
        DateTime.now().difference(startedAt) > _acledaMaxWait) {
      debugPrint(
        'Check status transaction timeout (ACLEDA) -> transactionId=$transactionId',
      );
      _loop = false;
      Get.back(result: '0');
      return;
    }
    try {
      final url =
          '${BaseUrl.PAYMENT_URL}payments/acledaCheckStatus/$transactionId';
      final headers = <String, String>{
        'Authorization': AppPref.getToken() ?? '',
      };
      final response = await http
          .post(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 20));

      if (!_loop) return;

      _logNetwork(
        url: url,
        method: 'POST',
        headers: headers,
        requestBody: null,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200) {
        debugPrint(
          'This is response check payment ACLEDA ==>>${response.body}',
        );
        Map<dynamic, dynamic> result = jsonDecode(response.body);
        final status = '${result['status']}';
        if (status == '1') {
          debugPrint('Check status transaction == 1');
          _loop = false;
          Get.back(result: '1');
        } else {
          debugPrint('Check status transaction == $status (payment pending)');
          _scheduleRetry(() {
            checkPaymentACLEDAComplete(
              context: Get.context ?? context,
              transactionId: transactionId,
              token: token,
            );
          });
        }
      } else {
        debugPrint(
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
      debugPrint('Network error while checking ACLEDA payment status: $e');
      _scheduleRetry(() {
        checkPaymentACLEDAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    } on http.ClientException catch (e) {
      debugPrint('HTTP client error while checking ACLEDA payment status: $e');
      _scheduleRetry(() {
        checkPaymentACLEDAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    } on TimeoutException catch (e) {
      debugPrint('Timeout while checking ACLEDA payment status: $e');
      _scheduleRetry(() {
        checkPaymentACLEDAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Unexpected error while checking ACLEDA payment status: $e');
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
      final url =
          '${BaseUrl.PAYMENT_URL}payments/acledaComplete/$transactionId/$token';
      final headers = <String, String>{
        'Authorization': AppPref.getToken() ?? '',
      };
      final response = await http
          .post(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 20));

      _logNetwork(
        url: url,
        method: 'POST',
        headers: headers,
        requestBody: null,
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200) {
        debugPrint(
          'This is response check transaction ACLEDA ==>>${response.body}',
        );
        Map<dynamic, dynamic> result = jsonDecode(response.body);
        debugPrint(result['status'].toString());
        Loading().loadingClose();
        if (result['status'] == 1) {
          debugPrint('Check status transaction ACLEDA == 1');
          Get.back(result: '1');
        }
      } else {
        Loading().loadingClose();
        debugPrint(
          'Check ACLEDA transaction request failed (${response.statusCode}).',
        );
      }
    } on SocketException catch (e) {
      Loading().loadingClose();
      debugPrint('Network error while checking ACLEDA transaction status: $e');
    } on http.ClientException catch (e) {
      Loading().loadingClose();
      debugPrint(
        'HTTP client error while checking ACLEDA transaction status: $e',
      );
    } on TimeoutException catch (e) {
      Loading().loadingClose();
      debugPrint('Timeout while checking ACLEDA transaction status: $e');
    } catch (e) {
      Loading().loadingClose();
      debugPrint(
        'Unexpected error while checking ACLEDA transaction status: $e',
      );
    }
  }
}
