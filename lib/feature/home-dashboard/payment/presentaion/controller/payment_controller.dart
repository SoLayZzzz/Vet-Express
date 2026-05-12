import 'dart:async';
import 'dart:convert';

import 'package:express_vet/base/state_controller.dart';
import 'package:express_vet/base/base_url.dart';
import 'package:express_vet/feature/home-dashboard/payment/data/model/response/aba_payment_response.dart';
import 'package:express_vet/feature/home-dashboard/payment/domain/uscase/payment_uscase.dart';
import 'package:express_vet/feature/home-dashboard/payment/presentaion/state/payment_uistate.dart';
import 'package:express_vet/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../value_statics.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/loading.dart';
import '../ui/payment_aba_screen.dart';
import '../ui/payment_wing_screen.dart';
import '../../../passenger/data/network/passenger_network_request.dart';
import '../../../passenger/presentation/binding/passenger_binding.dart';

class PaymentController extends StateController<PaymentUistate> {
  final PaymentUscase uscase;

  PaymentController(this.uscase);

  @override
  PaymentUistate onInitUiState() => const PaymentUistate();

  @override
  void onClose() {
    setLoop(false);
    setNewToken('');
    setAcledaPaymentInitiated(false);
    super.onClose();
  }

  void selectPaymentMethod({
    required int paymentMethodId,
    required int paymentMethodSelected,
  }) {
    uiState.value = PaymentUistate(
      paymentMethodId: paymentMethodId,
      paymentMethodSelected: paymentMethodSelected,
      showFareSummary: state.showFareSummary,
      loop: state.loop,
      newToken: state.newToken,
      acledaPaymentInitiated: state.acledaPaymentInitiated,
    );
  }

  void toggleFareSummary() {
    uiState.value = PaymentUistate(
      paymentMethodId: state.paymentMethodId,
      paymentMethodSelected: state.paymentMethodSelected,
      showFareSummary: !state.showFareSummary,
      loop: state.loop,
      newToken: state.newToken,
      acledaPaymentInitiated: state.acledaPaymentInitiated,
    );
  }

  void setNewToken(String token) {
    uiState.value = PaymentUistate(
      paymentMethodId: state.paymentMethodId,
      paymentMethodSelected: state.paymentMethodSelected,
      showFareSummary: state.showFareSummary,
      loop: state.loop,
      newToken: token,
      acledaPaymentInitiated: state.acledaPaymentInitiated,
    );
  }

  void setLoop(bool loop) {
    uiState.value = PaymentUistate(
      paymentMethodId: state.paymentMethodId,
      paymentMethodSelected: state.paymentMethodSelected,
      showFareSummary: state.showFareSummary,
      loop: loop,
      newToken: state.newToken,
      acledaPaymentInitiated: state.acledaPaymentInitiated,
    );
  }

  void setAcledaPaymentInitiated(bool initiated) {
    uiState.value = PaymentUistate(
      paymentMethodId: state.paymentMethodId,
      paymentMethodSelected: state.paymentMethodSelected,
      showFareSummary: state.showFareSummary,
      loop: state.loop,
      newToken: state.newToken,
      acledaPaymentInitiated: initiated,
    );
  }

  PassengerNetworkRequest _ensurePassengerNetworkRequest() {
    if (!Get.isRegistered<PassengerNetworkRequest>()) {
      PassengerBinding().dependencies();
    }
    return Get.find<PassengerNetworkRequest>();
  }

  Future<void> _cancelBookingSilently(
    BuildContext context,
    String transactionId,
  ) async {
    try {
      final response = await _ensurePassengerNetworkRequest().cancelBooking(
        context: context,
        transactionId: transactionId,
      );
      if (response.header?.statusCode == 200 &&
          response.header?.result == true) {
        if (response.body?.status == 1) {
          ValueStatic().clearDataTicket();
        }
      }
    } catch (_) {}
  }

  Future<void> processBooking({
    required BuildContext context,
    required String transactionId,
    String? totalAmount,
  }) async {
    final resolvedTotalAmount = (totalAmount ?? '').trim().isNotEmpty
        ? totalAmount!.trim()
        : ValueStatic.totalPrice.toString();
    debugPrint('================= [Payment] processBooking (tap) =================');
    debugPrint(
      '[Payment] processBooking.request '
      'code=$transactionId, '
      'paymentMethodId=${state.paymentMethodId}, '
      'paymentMethodSelected=${state.paymentMethodSelected}, '
      'totalAmount=$resolvedTotalAmount',
    );
    try {
      final requestMap = <String, dynamic>{
        'code': transactionId.toString(),
        'paymentMethodId': state.paymentMethodId.toString(),
        'paymentMethodSelected': state.paymentMethodSelected,
        'totalAmount': resolvedTotalAmount,
      };
      debugPrint(
        '[Payment] processBooking.requestJson ->\n'
        '${const JsonEncoder.withIndent('  ').convert(requestMap)}',
      );
    } catch (_) {}
    Loading().loadingShow();

    try {
      final data = await uscase.processPayment(
        code: transactionId.toString(),
        paymentMethodId: state.paymentMethodId.toString(),
        totalAmount: resolvedTotalAmount,
      );
      Loading().loadingClose();

      try {
        debugPrint(
          '[Payment] processBooking.responseJson ->\n'
          '${const JsonEncoder.withIndent('  ').convert(data.toJson())}',
        );
      } catch (_) {}

      final rawToken = data.body?.token;
      final token = (rawToken ?? '').trim();
      final hasUsableToken = token.isNotEmpty && token.toLowerCase() != 'null';

      debugPrint(
        'PaymentController.processBooking.response '
        'statusCode=${data.header?.statusCode}, '
        'result=${data.header?.result}, '
        'bodyStatus=${data.body?.status}, '
        'hasToken=$hasUsableToken, '
        'msg=${data.body?.msg}',
      );

      final isSuccessHeader =
          data.header?.statusCode == 200 && data.header?.result == true;

      // Wing sometimes returns result=false but still includes a token that must be used
      // to continue in the Wing web payment flow.
      final shouldProceedWing =
          state.paymentMethodSelected == 4 &&
          data.header?.statusCode == 200 &&
          hasUsableToken;

      if (isSuccessHeader || shouldProceedWing) {
        if (state.paymentMethodSelected == 1) {
          final token = data.body?.token;
          debugPrint(
            'PaymentController.ABA_KHQR.start '
            'transactionId=$transactionId, token=${token ?? ''}',
          );
          await payWithABAMobile(
            context: Get.context!,
            transactionId: transactionId,
            token: token ?? '',
          );
        } else if (state.paymentMethodSelected == 2) {
          final token = data.body?.token;
          final result = await Get.to(
            () => PaymentABAScreen(
              transactionId: transactionId,
              token: token.toString(),
              title: 'Credit/Debit Card',
              type: 2,
              url: '',
            ),
          );
          debugPrint('PaymentController.ABA_Card.result=$result');
          if (result == '1') {
            // showDialogPaymentComplete(context);
            Get.toNamed(AppRoutes.ticketpaymentSuccessScreen);
          } else {
            showDialogPaymentFail(context, transactionId);
          }
        } else if (state.paymentMethodSelected == 3) {
          final token = data.body?.token;
          final result = await Get.to(
            () => PaymentABAScreen(
              transactionId: transactionId,
              token: token.toString(),
              title: 'Alipay',
              type: 3,
              url: '',
            ),
          );
          debugPrint('PaymentController.Alipay.result=$result');
          if (result == '1') {
            // showDialogPaymentComplete(context);
            Get.toNamed(AppRoutes.ticketpaymentSuccessScreen);
          } else {
            showDialogPaymentFail(context, transactionId);
          }
        } else if (state.paymentMethodSelected == 4) {
          final token = (data.body?.token ?? '').trim();
          final result = await Get.to(
            () => PaymentWingScreen(
              transactionId: transactionId,
              token: token.toString(),
            ),
          );
          debugPrint('PaymentController.Wing.result=$result');
          if (result == '1') {
            // showDialogPaymentComplete(context);
            Get.toNamed(AppRoutes.ticketpaymentSuccessScreen);
          } else {
            showDialogPaymentFail(context, transactionId);
          }
        } else if (state.paymentMethodSelected == 5) {
          final token = data.body?.token ?? '';
          debugPrint(
            'PaymentController.ACLEDA_App.start transactionId=$transactionId, token=$token',
          );
          setNewToken(token);
        }
      } else {
        alertDialogOneButton(
          title: 'information'.tr,
          description: data.body?.msg ?? 'Failed to load to server!',
          buttonText: 'ok'.tr,
        );
      }
    } catch (e) {
      try {
        Loading().loadingClose();
      } catch (_) {}
      debugPrint('[Payment] processBooking.error $e');
      debugPrint('[Payment] processBooking.stackTrace\n${StackTrace.current}');
      alertDialogOneButton(
        title: 'information'.tr,
        description: 'Failed to load to server!',
        buttonText: 'ok'.tr,
      );
    }
  }

  Future<void> payWithABAMobile({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    debugPrint(
      'PaymentController.abaMobilePay.request transactionId=$transactionId, token=$token',
    );
    final data = await uscase.abaMobilePay(
      transactionId: transactionId,
      token: token,
    );
    debugPrint(
      'PaymentController.abaMobilePay.response status=${data.status}, '
      'hasDeeplink=${(data.abapayDeeplink ?? '').isNotEmpty}, '
      'hasCheckoutQr=${(data.checkout_qr_url ?? '').isNotEmpty}',
    );
    final result = await Get.to(
      () => PaymentABAScreen(
        transactionId: transactionId,
        token: token.toString(),
        title: 'ABA KHQR',
        type: 1,
        url: data.checkout_qr_url ?? '',
        deeplink: data.abapayDeeplink ?? '',
      ),
    );
    debugPrint('PaymentController.ABA_KHQR.result=$result');
    if (result == '1') {
      // showDialogPaymentComplete(context);
      Get.toNamed(AppRoutes.ticketpaymentSuccessScreen);
    } else {
      showDialogPaymentFail(context, transactionId);
    }
  }

  Future<void> openDeepLinkACLEDA(
    String deepLink, {
    String? appStoreUrl,
    String? playStoreUrl,
  }) async {
    try {
      final uri = Uri.tryParse(deepLink);
      if (uri == null || !uri.hasScheme) {
        // Fallback to store links if deep link is invalid or empty
        if (GetPlatform.isAndroid) {
          await launchUrl(
            Uri.parse(
              (playStoreUrl ?? '').isNotEmpty
                  ? playStoreUrl!
                  : 'https://play.google.com/store/search?q=acleda%20bank&c=apps',
            ),
            mode: LaunchMode.externalApplication,
          );
        } else if (GetPlatform.isIOS) {
          await launchUrl(
            Uri.parse(
              (appStoreUrl ?? '').isNotEmpty
                  ? appStoreUrl!
                  : 'https://apps.apple.com/al/app/acleda-mobile/id1196285236',
            ),
            mode: LaunchMode.externalApplication,
          );
        }
        return;
      }

      final launched = await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      final launchedFallback = launched
          ? true
          : await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
      if (!launchedFallback) {
        if (GetPlatform.isAndroid) {
          await launchUrl(
            Uri.parse(
              (playStoreUrl ?? '').isNotEmpty
                  ? playStoreUrl!
                  : 'https://play.google.com/store/search?q=acleda%20bank&c=apps',
            ),
            mode: LaunchMode.externalApplication,
          );
        } else if (GetPlatform.isIOS) {
          await launchUrl(
            Uri.parse(
              (appStoreUrl ?? '').isNotEmpty
                  ? appStoreUrl!
                  : 'https://apps.apple.com/al/app/acleda-mobile/id1196285236',
            ),
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (_) {
      if (GetPlatform.isAndroid) {
        await launchUrl(
          Uri.parse(
            (playStoreUrl ?? '').isNotEmpty
                ? playStoreUrl!
                : 'https://play.google.com/store/search?q=acleda%20bank&c=apps',
          ),
          mode: LaunchMode.externalApplication,
        );
      } else if (GetPlatform.isIOS) {
        await launchUrl(
          Uri.parse(
            (appStoreUrl ?? '').isNotEmpty
                ? appStoreUrl!
                : 'https://apps.apple.com/al/app/acleda-mobile/id1196285236',
          ),
          mode: LaunchMode.externalApplication,
        );
      }
    }
  }

  Future<void> checkPaymentACLEDAComplete({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    if (!state.loop) return;
    Map<String, dynamic> result;
    try {
      result = await uscase.acledaCheckStatus(transactionId: transactionId);
    } on TimeoutException catch (e) {
      debugPrint(
        'PaymentController.acledaCheckStatus.timeout transactionId=$transactionId error=$e',
      );
      Future.delayed(const Duration(seconds: 1), () async {
        if (state.loop) {
          await checkPaymentACLEDAComplete(
            context: context,
            transactionId: transactionId,
            token: token,
          );
        }
      });
      return;
    } catch (e) {
      debugPrint(
        'PaymentController.acledaCheckStatus.error transactionId=$transactionId error=$e',
      );
      Future.delayed(const Duration(seconds: 1), () async {
        if (state.loop) {
          await checkPaymentACLEDAComplete(
            context: context,
            transactionId: transactionId,
            token: token,
          );
        }
      });
      return;
    }
    final status = '${result['status']}';
    debugPrint(
      'PaymentController.acledaCheckStatus.response status=$status for transactionId=$transactionId',
    );
    if (status == '1') {
      debugPrint(
        'PaymentController.acledaCheckStatus.next checkTransactionACLEDAComplete in 3s',
      );
      Future.delayed(const Duration(seconds: 3), () async {
        await checkTransactionACLEDAComplete(
          context: context,
          transactionId: transactionId,
          token: token,
        );
      });
    } else if (status == '0') {
      // Payment failed -> stop loop and cancel booking so seats are released
      setLoop(false);
      debugPrint(
        'PaymentController.acledaCheckStatus.failed -> cancel booking for transactionId=$transactionId',
      );
      showDialogPaymentFail(context, transactionId);
    } else {
      debugPrint('PaymentController.acledaCheckStatus.pending -> poll again');
      Future.delayed(const Duration(milliseconds: 1000), () async {
        if (state.loop) {
          await checkPaymentACLEDAComplete(
            context: context,
            transactionId: transactionId,
            token: token,
          );
        }
      });
    }
  }

  Future<void> checkTransactionACLEDAComplete({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    setLoop(false);
    Loading().loadingShow();
    Map<String, dynamic> result;
    try {
      result = await uscase.acledaComplete(
        transactionId: transactionId,
        token: token,
      );
    } on TimeoutException catch (e) {
      Loading().loadingClose();
      debugPrint(
        'PaymentController.acledaComplete.timeout transactionId=$transactionId error=$e',
      );
      return;
    } catch (e) {
      Loading().loadingClose();
      debugPrint(
        'PaymentController.acledaComplete.error transactionId=$transactionId error=$e',
      );
      return;
    }
    Loading().loadingClose();
    debugPrint(
      'PaymentController.acledaComplete.response status=${result['status']} for transactionId=$transactionId',
    );
    if (result['status'] == 1) {
      // showDialogPaymentComplete(Get.context!);
      Get.toNamed(AppRoutes.ticketpaymentSuccessScreen);
    }
  }

  Future<void> onAcledaOptionTapOpenApp({
    required BuildContext context,
    required String transactionId,
    required String token,
    required String type,
  }) async {
    final requestUrl =
        '${BaseUrl.PAYMENT_URL}payments/acledaMobilePay/$transactionId/$token/$type';
    debugPrint(
      'Ac App url = $requestUrl',
    );
    await payWithACLEDAMobile(
      context: context,
      transactionId: transactionId,
      token: token,
      type: type,
    );
  }

  Future<void> onAcledaOptionTapXPay({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    final requestUrl =
        '${BaseUrl.PAYMENT_URL}payments/acledaXpay/$transactionId/$token';
    debugPrint('Ac Card url = $requestUrl');
    debugPrint(
      'Ac Card url =$requestUrl $transactionId, token=$token',
    );
    final result = await Get.to(
      () => PaymentABAScreen(
        transactionId: transactionId,
        token: token,
        title: 'ACLEDA XPay',
        type: 4,
        url: '',
      ),
    );
    debugPrint('PaymentController.ACLEDA_XPay.result=$result');
    if (result == '1') {
      // showDialogPaymentComplete(context);
      Get.toNamed(AppRoutes.ticketpaymentSuccessScreen);

    } else {
      showDialogPaymentFail(context, transactionId);
    }
  }

  Future<void> payWithACLEDAMobile({
    required BuildContext context,
    required String transactionId,
    required String token,
    required String type,
  }) async {
   
    late ABAPayResponse data;
    try {
      data = await uscase.acledaMobilePay(
        transactionId: transactionId,
        token: token,
        type: type,
      );
      if (data.status != 1 || (data.abapayDeeplink ?? '').toString().isEmpty) {
        data = await uscase.acledaMobilePay(
          transactionId: transactionId,
          token: token,
          type: type,
        );
      }

    } on TimeoutException catch (e) {
      debugPrint(
        'PaymentController.acledaMobilePay.timeout transactionId=$transactionId error=$e',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('request_timed_out'.tr)));
      }
      return;
    } catch (e) {
      debugPrint(
        'PaymentController.acledaMobilePay.error transactionId=$transactionId error=$e',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('something_wrong'.tr)));
      }
      return;
    }
    debugPrint(
      'PaymentController.acledaMobilePay.response status=${data.status}, '
      'hasDeeplink=${(data.abapayDeeplink ?? '').isNotEmpty}',
    );
    if (data.status == 1) {
      final deep = data.abapayDeeplink ?? '';
      if (deep.isNotEmpty) {
        setAcledaPaymentInitiated(true);
        setLoop(true);
        await openDeepLinkACLEDA(
          deep,
          appStoreUrl: data.appStore,
          playStoreUrl: data.playStore,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('something_wrong'.tr)));
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('payment_time_out'.tr)));
      }
    }
  }

  // void showDialogPaymentComplete(BuildContext context) {
  //   alertDialogTwoButton(
  //     title: 'your_ticket_has_been_reserved'.tr,
  //     description: 'ticket_info1'.tr,
  //     buttonText1: 'home'.tr,
  //     buttonText2: 'show_ticket'.tr,
  //     onButtonPressed1: () {
  //       ValueStatic().clearDataTicket();
  //       Get.offAll(() => const DashboardScreen(from: 0));
  //     },
  //     onButtonPressed2: () {
  //       ValueStatic().clearDataTicket();
  //       Get.offAll(() => const DashboardScreen(from: 2));
  //     },
  //   );
  // }

  void showDialogPaymentFail(BuildContext context, String transactionId) {
    alertDialogOneButton(
      title: 'information'.tr,
      description: 'payment_not_success'.tr,
      buttonText: 'ok'.tr,
    );

    _cancelBookingSilently(context, transactionId);
  }
}

// https://qacl.udaya-tech.com/0430_CamTicket/payments/wingNewApiPaymentPro/VTCK-iCeZgcqETUvwmw9/UxIVUCILfrEVEYnxUGJOEVQnUXDEX1VDqLQ
