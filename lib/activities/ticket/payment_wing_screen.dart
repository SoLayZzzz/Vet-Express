import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:express_vet/models/wing/wing_response.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart'; // Import the main package
import 'package:webview_flutter_android/webview_flutter_android.dart'; // For Android-specific features
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart'; // For iOS-specific features

import '../../base/base_url.dart';
import '../../utils/app_pref.dart';

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
  bool loop = true;
  late WebViewController _controller;

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

    // Load the initial URL
    _controller.loadRequest(
      Uri.parse(
        "${BaseUrl.PAYMENT_URL}payments/wingNewApiPaymentPro/${widget.transactionId}/${widget.token}",
      ),
    );

    // Set JavaScript mode
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);

    // Set navigation delegate
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {
          // Handle page started loading
        },
        onPageFinished: (String url) {
          // Handle page finished loading
        },
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://closewingpayment/')) {
            // Block navigation
            return NavigationDecision.prevent;
          }
          if (request.url.startsWith('wingbankapp://payment?')) {
            // Open deep link
            openDeepLinkWingBank(request.url);
            return NavigationDecision.prevent;
          }
          // Allow navigation
          return NavigationDecision.navigate;
        },
      ),
    );

    // Loop check status
    checkPaymentWingComplete(widget.transactionId);
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
              children: [Center(child: WebViewWidget(controller: _controller))],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openDeepLinkWingBank(deepLink) async {
    final Uri url = Uri.parse(deepLink);

    try {
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

  Future<void> checkPaymentWingComplete(transactionId) async {
    Map<String, String> headers = {"Authorization": AppPref.getToken() ?? ''};

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL_TICKET}booking/checkTicketStatus'),
    );
    request.headers.addAll(headers);
    request.fields['transactionId'] = transactionId;

    request.send().then((result) async {
      http.Response.fromStream(result).then((response) {
        if (response.statusCode == 200) {
          log('This is response check wing==>>${response.body}');
          final wingResponse = WingResponse.fromJson(jsonDecode(response.body));

          if (wingResponse.header?.statusCode == 200 &&
              wingResponse.header?.result == true) {
            if (wingResponse.body?.data?[0].status == "1" ||
                wingResponse.body?.data?[0].status == 1) {
              Navigator.pop(context, "1");
            } else {
              Future.delayed(
                const Duration(seconds: 2),
                () => checkPaymentWingComplete(transactionId),
              );
            }
          }
        } else {
          checkPaymentWingComplete(widget.transactionId);
        }
      });
    });
  }

  Future<bool> popScreen() async {
    checkPaymentWingComplete(widget.transactionId);
    return false;
  }
}
