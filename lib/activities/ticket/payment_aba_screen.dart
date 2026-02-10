import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart'; // Import the main package
import 'package:webview_flutter_android/webview_flutter_android.dart'; // For Android-specific features
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart'; // For iOS-specific features
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:express_vet/models/payment/aba_payment_response.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/loading.dart';

import '../../base/base_url.dart';
import '../../utils/app_pref.dart';

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
  static bool loop = true;
  late WebViewController _controller;

  // For ACLEDA
  bool checkChangeURL = false;

  @override
  void initState() {
    super.initState();
    loop = true;

    // Initialize WebViewController
    _controller = WebViewController();

    // Platform-specific initialization
    if (Platform.isAndroid) {
      final androidController =
          _controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    } else if (Platform.isIOS) {
      final iosController = _controller.platform as WebKitWebViewController;
      iosController.setAllowsBackForwardNavigationGestures(true);
    }

    // Load the initial URL (check url to reload ui)
    _controller.loadRequest(
      Uri.parse(returnUrl(widget.type, widget.transactionId, widget.token)),
    );

    // Set JavaScript mode
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);

    /// User pay with ABA Mobile (just open deep link)
    if (widget.type == 1) {
      payWithABAMobile(widget.transactionId, widget.token);
    }

    ///check payment complete or not
    if (widget.type == 4) {
      /// User pay with XPay
      checkPaymentACLEDAComplete(widget.transactionId, widget.token);
    } else {
      /// User pay with KHQR, Credit Card, Alipay
      checkPaymentABAComplete(widget.transactionId, widget.token);
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: popScreen,
    child: Scaffold(
      appBar: AppBarVET().appBar(context, widget.title),
      body: WebViewWidget(controller: _controller),
    ),
  );

  Future<bool> popScreen() async {
    Navigator.pop(context);
    return false;
  }

  String returnUrl(int type, String transactionId, String token) {
    if (type == 1) {
      return widget.url;
    } else if (type == 2) {
      return "${BaseUrl.PAYMENT_URL}payments/abaVisalPayment/$transactionId/$token/2";
    } else if (type == 3) {
      return "${BaseUrl.PAYMENT_URL}payments/abaAlipay/$transactionId/$token";
    } else if (type == 4) {
      return "${BaseUrl.PAYMENT_URL}payments/acledaXpay/$transactionId/$token";
    }
    return '';
  }

  /// Payment with ABA
  Future<void> payWithABAMobile(transactionId, token) async {
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
        if ((data.qrCode)!.isNotEmpty) {
          // open deep link
          openDeepLinkABA(data.abapayDeeplink);
        } else {
          // has something went wrong
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('something_wrong'.tr)));
        }
      } else {
        // payment session expire
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('payment_time_out'.tr)));
      }
    } else {
      throw Exception('Failed to load to server!');
    }
  }

  Future<void> openDeepLinkABA(deepLink) async {
    try {
      await launchUrl(
        Uri.parse(deepLink),
        mode: LaunchMode.externalApplication,
      );
      log("launching... deep link");
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> checkPaymentABAComplete(transactionId, token) async {
    final response = await http.post(
      Uri.parse(
        '${BaseUrl.PAYMENT_URL}payments/checkAbaTransaction/$transactionId',
      ),
      headers: <String, String>{'Authorization': AppPref.getToken() ?? ''},
    );

    if (response.statusCode == 200) {
      log(
        'This is response check payment ${widget.title} ==>>${response.body}',
      );
      Map<dynamic, dynamic> result = jsonDecode(response.body);
      if (result['status'] == 1) {
        log('Check status transaction == 1');
        checkTransactionABAComplete(transactionId, token);
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (loop) {
            checkPaymentABAComplete(transactionId, token);
          }
        });
      }
    } else {
      checkPaymentABAComplete(transactionId, token);
      throw Exception('Failed to load to server!');
    }
  }

  Future<void> checkTransactionABAComplete(transactionId, token) async {
    loop = false;

    Loading().loadingShow(context);

    final response = await http.post(
      Uri.parse(
        '${BaseUrl.PAYMENT_URL}payments/checkTerminalPaymentComplete/$transactionId/$token',
      ),
      headers: <String, String>{'Authorization': AppPref.getToken() ?? ''},
    );

    if (response.statusCode == 200) {
      log(
        'This is response check transaction ${widget.title} ==>>${response.body}',
      );
      Map<dynamic, dynamic> result = jsonDecode(response.body);
      log(result['status']);
      Loading().loadingClose(context);
      if (result['status'] == "1") {
        log('Check status transaction ${widget.title} == 1');
        Navigator.pop(context, '1');
      }
    } else {
      checkTransactionABAComplete(transactionId, token);
      throw Exception('Failed to load to server!');
    }
  }

  /// For ACLEDA BANK
  Future<void> checkPaymentACLEDAComplete(transactionId, token) async {
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
          checkTransactionACLEDAComplete(transactionId, token);
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (loop) {
            checkPaymentACLEDAComplete(transactionId, token);
          }
        });
      }
    } else {
      checkPaymentACLEDAComplete(transactionId, token);
      throw Exception('Failed to load to server!');
    }
  }

  Future<void> checkTransactionACLEDAComplete(transactionId, token) async {
    loop = false;

    Loading().loadingShow(context);

    final response = await http.post(
      Uri.parse(
        '${BaseUrl.PAYMENT_URL}payments/acledaComplete/$transactionId/$token',
      ),
      headers: <String, String>{'Authorization': AppPref.getToken() ?? ''},
    );

    if (response.statusCode == 200) {
      log('This is response check transaction ACLEDA ==>>${response.body}');
      Map<dynamic, dynamic> result = jsonDecode(response.body);
      log(result['status'].toString());
      Loading().loadingClose(context);
      if (result['status'] == 1) {
        log('Check status transaction ACLEDA == 1');
        Navigator.pop(context, '1');
      }
    } else {
      checkTransactionACLEDAComplete(transactionId, token);
      throw Exception('Failed to load to server!');
    }
  }
}
