import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
  int _pollCount = 0;
  static const int _maxPollCount = 240;

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

  /// Called by the screen's WidgetsBindingObserver when the app resumes
  /// from the Wing Bank app, ensuring the loading overlay is dismissed.
  void hideLoadingOnResume() {
    debugPrint('PaymentWingController.hideLoadingOnResume called');
    _hideLoadingIfShown();
  }

  void init({required BuildContext context}) {
    webViewController = WebViewController();
    final encodedTransactionId = Uri.encodeComponent(transactionId);
    final encodedToken = Uri.encodeComponent(token);
    final wingPaymentUrl =
        "${BaseUrl.PAYMENT_URL}payments/wingNewApiPaymentPro/$encodedTransactionId/$encodedToken";
    debugPrint(
      'PaymentWingController.loadWingPayment.request '
      'flavor=${BaseUrl.flavor} '
      'transactionId=$transactionId '
      'url=${kDebugMode ? wingPaymentUrl : "${BaseUrl.PAYMENT_URL}payments/wingNewApiPaymentPro/$encodedTransactionId/<redacted>"}',
    );

    _showLoadingIfNeeded();

    if (Platform.isAndroid) {
      final androidController =
          webViewController.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
      androidController.setMixedContentMode(MixedContentMode.alwaysAllow);
    } else if (Platform.isIOS) {
      final iosController =
          webViewController.platform as WebKitWebViewController;
      iosController.setAllowsBackForwardNavigationGestures(true);
    }

    webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    webViewController.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {
          debugPrint('PaymentWingController.onPageStarted url=$url');
          _showLoadingIfNeeded();
        },
        onPageFinished: (String url) {
          debugPrint('PaymentWingController.onPageFinished url=$url');
          _hideLoadingIfShown();
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint(
            'PaymentWingController.onWebResourceError '
            'code=${error.errorCode} desc=${error.description}',
          );
          _hideLoadingIfShown();
        },
        onHttpError: (HttpResponseError error) {
          debugPrint(
            'PaymentWingController.onHttpError '
            'statusCode=${error.response?.statusCode} request=$error',
          );
        },
        onNavigationRequest: (NavigationRequest request) {
          debugPrint(
            'PaymentWingController.onNavigationRequest url=${request.url}',
          );
          if (request.url.startsWith('https://closewingpayment/')) {
            _hideLoadingIfShown();
            return NavigationDecision.prevent;
          }
          final uri = Uri.tryParse(request.url);
          if (uri != null && _isWingPaymentDeepLink(uri)) {
            openDeepLinkWingBank(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );

    webViewController.loadRequest(Uri.parse(wingPaymentUrl));

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
    _hideLoadingIfShown();
    super.onClose();
  }

  bool _isWingPaymentDeepLink(Uri uri) {
    final scheme = (uri.scheme).toLowerCase();
    if (scheme != 'wingbankuat' && scheme != 'wingbankapp' && scheme != 'wingbank') {
      return false;
    }
    return uri.host.toLowerCase() == 'payment';
  }

  Future<void> openDeepLinkWingBank(String deepLink) async {
    final Uri url = Uri.parse(deepLink);
    debugPrint(
      'PaymentWingController.openDeepLinkWingBank.request deepLink=$deepLink',
    );

    try {
      _showLoadingIfNeeded();
      var launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Some environments return a different Wing scheme than the installed app supports.
        // Try swapping between known schemes before falling back to the store.
        final alternativeUrl = switch (url.scheme.toLowerCase()) {
          'wingbankuat' => url.replace(scheme: 'wingbankapp'),
          'wingbankapp' => url.replace(scheme: 'wingbankuat'),
          _ => null,
        };
        if (alternativeUrl != null) {
          debugPrint(
            'PaymentWingController.openDeepLinkWingBank.retryAlternative '
            'fromScheme=${url.scheme} toScheme=${alternativeUrl.scheme}',
          );
          launched = await launchUrl(
            alternativeUrl,
            mode: LaunchMode.externalApplication,
          );
        }
      }
      debugPrint(
        'PaymentWingController.openDeepLinkWingBank.launchResult launched=$launched uri=$url',
      );
      // Hide loading after deep link was handled – the user has left (or
      // will leave) the app, so the spinner should not be visible when they
      // come back.  The lifecycle observer will also call hideLoadingOnResume
      // as a safety net.
      _hideLoadingIfShown();
      if (!launched) {
        if (Platform.isIOS) {
          debugPrint(
            'PaymentWingController.openDeepLinkWingBank.fallback open AppStore',
          );
          await launchUrl(
            Uri.parse('https://apps.apple.com/cd/app/wing-bank/id1113286385'),
            mode: LaunchMode.externalApplication,
          );
        } else if (Platform.isAndroid) {
          debugPrint(
            'PaymentWingController.openDeepLinkWingBank.fallback open PlayStore',
          );
          await launchUrl(
            Uri.parse(
              'https://play.google.com/store/apps/details?id=com.wingmoney.wingpay&hl=en_US',
            ),
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (error, st) {
      debugPrint(
        'PaymentWingController.openDeepLinkWingBank.error error=$error\n$st',
      );
      if (Platform.isAndroid) {
        debugPrint(
          'PaymentWingController.openDeepLinkWingBank.fallback open PlayStore',
        );
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
    _pollCount++;
    debugPrint(
      'PaymentWingController.checkTicketStatus.poll '
      'pollCount=$_pollCount/$_maxPollCount transactionId=$transactionId',
    );
    if (_pollCount > _maxPollCount) {
      debugPrint(

        'PaymentWingController.checkTicketStatus.stop polling (max reached) '
        'transactionId=$transactionId',
      );
      _hideLoadingIfShown();
      if (_active) {
        Get.back(result: '0');
      }
      return;
    }
    try {
      debugPrint(
        'PaymentWingController.checkTicketStatus.request transactionId=$transactionId',
      );
      final wingResponse = await _ensureNetworkRequest().checkTicketStatus(
        context: context,
        transactionId: transactionId.toString(),
      );

      final prettyWingResponse = const JsonEncoder.withIndent('  ').convert(
        wingResponse.toJson(),
      );
      debugPrint(
        'PaymentWingController.checkTicketStatus.responseJson\n$prettyWingResponse',
      );

      if (wingResponse.header?.statusCode == 200) {
        final status = '${wingResponse.body?.data?[0].status ?? ''}';
        debugPrint(
          'PaymentWingController.checkTicketStatus.response '
          'statusCode=${wingResponse.header?.statusCode}, '
          'result=${wingResponse.header?.result}, status=$status',
        );

        if (status == '1') {
          _hideLoadingIfShown();
          if (_active) {
            Get.back(result: '1');
          }
          return;
        }

        // Wing commonly returns status=0 while payment is still pending/awaiting user action.
        // Only treat explicit non-success states as failure.
        if (status == '2' || status == '-1') {
          _hideLoadingIfShown();
          if (_active) {
            Get.back(result: '0');
          }
          return;
        }

        debugPrint(
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
      } else {
        debugPrint(
          'PaymentWingController.checkTicketStatus.non200 '
          'statusCode=${wingResponse.header?.statusCode}, '
          'result=${wingResponse.header?.result}, '
          'message=${wingResponse.body?.message}',
        );
      }
    } catch (e, st) {
      debugPrint(
        'PaymentWingController.checkTicketStatus.error '
        'transactionId=$transactionId error=$e\n$st',
      );
      _hideLoadingIfShown();
      if (_active) {
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
  }
}
