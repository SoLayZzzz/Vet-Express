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

class PaymentAbaPackageController extends GetxController {
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

  PaymentAbaPackageController({
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

  void resumePolling({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) {
    if (_loop) return;
    _loop = true;
    checkPaymentABAComplete(
      context: context,
      transactionId: transactionId,
      token: token,
    );
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
      if (deeplink.isNotEmpty) {
        Future.microtask(() async {
          await openDeepLinkABA(deeplink);
        });
      }
      if ((url).isEmpty) {
        payWithABAMobile(
          context: context,
          transactionId: transactionId,
          token: token,
        );
      }
      checkPaymentABAComplete(
        context: context,
        transactionId: transactionId,
        token: token,
      );
    } else {
      checkPaymentABAComplete(
        context: context,
        transactionId: transactionId,
        token: token,
      );
    }

    _initialized = true;
  }

  String _returnUrl(int type, String transactionId, String token) {
    if (type == 1) {
      return url;
    } else if (type == 2) {
      return "${BaseUrl.PAYMENT_URL}payments/abaVisalPaymentPackage/$transactionId/$token/2";
    }
    return '';
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

  Future<void> payWithABAMobile({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    log(
      '${BaseUrl.PAYMENT_URL}payments/abaMobilePayPackage/$transactionId/$token',
    );

    final response = await http.post(
      Uri.parse(
        '${BaseUrl.PAYMENT_URL}payments/abaMobilePayPackage/$transactionId/$token',
      ),
      headers: <String, String>{'Authorization': AppPref.getToken() ?? ''},
    );

    if (response.statusCode == 200) {
      log('This is response ABA Payment ==>>${response.body}');
      var data = ABAPayResponse.fromJson(jsonDecode(response.body));

      if (data.status == 1) {
        if ((data.qrCode)!.isNotEmpty) {
          final deepLink = data.abapayDeeplink ?? '';
          if (deepLink.isNotEmpty) {
            openDeepLinkABA(deepLink);
          }
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('something_wrong'.tr)));
        }
      } else {
        if (!context.mounted) return;
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
    try {
      log(
        '${BaseUrl.PAYMENT_URL}payments/checkTravelPackageStatus/$transactionId',
      );

      final response = await http
          .post(
            Uri.parse(
              '${BaseUrl.PAYMENT_URL}payments/checkTravelPackageStatus/$transactionId',
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
          log('Check status transaction $title == 1');
          _loop = false;
          Get.back(result: '1');
        } else {
          log('Check status transaction $title == $status (payment pending)');
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
          'Check travel package payment request failed (${response.statusCode}). Retrying...',
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
      log('Network error while checking travel package payment status: $e');
      _scheduleRetry(() {
        checkPaymentABAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    } on http.ClientException catch (e) {
      log('HTTP client error while checking travel package payment status: $e');
      _scheduleRetry(() {
        checkPaymentABAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    } on TimeoutException catch (e) {
      log('Timeout while checking travel package payment status: $e');
      _scheduleRetry(() {
        checkPaymentABAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    } catch (e) {
      log('Unexpected error while checking travel package payment status: $e');
      _scheduleRetry(() {
        checkPaymentABAComplete(
          context: Get.context ?? context,
          transactionId: transactionId,
          token: token,
        );
      }, delay: const Duration(seconds: 2));
    }
  }
}
