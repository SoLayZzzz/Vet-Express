import 'package:express_vet/base/state_controller.dart';
import 'package:express_vet/feature/home-dashboard/payment/domain/uscase/payment_uscase.dart';
import 'package:express_vet/feature/home-dashboard/payment/presentaion/state/payment_uistate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../activities/ticket/value_statics.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/loading.dart';
import '../../../../dash_board/presentation/screen/dashboard_screen.dart';
import '../ui/payment_aba_screen.dart';
import '../ui/payment_wing_screen.dart';

class PaymentController extends StateController<PaymentUistate> {
  final PaymentUscase uscase;

  PaymentController(this.uscase);

  @override
  PaymentUistate onInitUiState() => const PaymentUistate();

  @override
  void onClose() {
    // stop any ongoing polling loops when the screen/controller is disposed
    setLoop(false);
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
    );
  }

  void toggleFareSummary() {
    uiState.value = PaymentUistate(
      paymentMethodId: state.paymentMethodId,
      paymentMethodSelected: state.paymentMethodSelected,
      showFareSummary: !state.showFareSummary,
      loop: state.loop,
      newToken: state.newToken,
    );
  }

  void setNewToken(String token) {
    uiState.value = PaymentUistate(
      paymentMethodId: state.paymentMethodId,
      paymentMethodSelected: state.paymentMethodSelected,
      showFareSummary: state.showFareSummary,
      loop: state.loop,
      newToken: token,
    );
  }

  void setLoop(bool loop) {
    uiState.value = PaymentUistate(
      paymentMethodId: state.paymentMethodId,
      paymentMethodSelected: state.paymentMethodSelected,
      showFareSummary: state.showFareSummary,
      loop: loop,
      newToken: state.newToken,
    );
  }

  Future<void> processBooking({
    required BuildContext context,
    required String transactionId,
  }) async {
    Loading().loadingShow(context);

    try {
      final data = await uscase.processPayment(
        code: transactionId.toString(),
        paymentMethodId: state.paymentMethodId.toString(),
        totalAmount: ValueStatic.totalPrice.toString(),
      );
      Loading().loadingClose(context);

      if (data.header?.statusCode == 200 && data.header?.result == true) {
        if (state.paymentMethodSelected == 1) {
          final token = data.body?.token;
          await payWithABAMobile(
            context: context,
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
          if (result == '1') {
            showDialogPaymentComplete(context);
          } else {
            showDialogPaymentFail(context);
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
          if (result == '1') {
            showDialogPaymentComplete(context);
          } else {
            showDialogPaymentFail(context);
          }
        } else if (state.paymentMethodSelected == 4) {
          final token = data.body?.token;
          final result = await Get.to(
            () => PaymentWingScreen(
              transactionId: transactionId,
              token: token.toString(),
            ),
          );
          if (result == '1') {
            showDialogPaymentComplete(context);
          }
        } else if (state.paymentMethodSelected == 5) {
          final token = data.body?.token ?? '';
          setNewToken(token);
          // Let the screen show the ACLEDA option dialog (UI). Controller exposes methods for actions.
        }
      } else {
        throw Exception('Failed to load to server!');
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<void> payWithABAMobile({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    final data = await uscase.abaMobilePay(
      transactionId: transactionId,
      token: token,
    );
    final result = await Get.to(
      () => PaymentABAScreen(
        transactionId: transactionId,
        token: token.toString(),
        title: 'ABA KHQR',
        type: 1,
        url: data.checkout_qr_url ?? '',
      ),
    );
    if (result == '1') {
      showDialogPaymentComplete(context);
    } else {
      showDialogPaymentFail(context);
    }
  }

  Future<void> openDeepLinkACLEDA(String deepLink) async {
    try {
      final uri = Uri.tryParse(deepLink);
      if (uri == null || !uri.hasScheme) {
        // Fallback to store links if deep link is invalid or empty
        if (GetPlatform.isAndroid) {
          await launchUrl(
            Uri.parse(
              'https://play.google.com/store/search?q=acleda%20bank&c=apps',
            ),
            mode: LaunchMode.externalApplication,
          );
        } else if (GetPlatform.isIOS) {
          await launchUrl(
            Uri.parse(
              'https://apps.apple.com/al/app/acleda-mobile/id1196285236',
            ),
            mode: LaunchMode.externalApplication,
          );
        }
        return;
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        if (GetPlatform.isAndroid) {
          await launchUrl(
            Uri.parse(
              'https://play.google.com/store/search?q=acleda%20bank&c=apps',
            ),
            mode: LaunchMode.externalApplication,
          );
        } else if (GetPlatform.isIOS) {
          await launchUrl(
            Uri.parse(
              'https://apps.apple.com/al/app/acleda-mobile/id1196285236',
            ),
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (_) {
      if (GetPlatform.isAndroid) {
        await launchUrl(
          Uri.parse(
            'https://play.google.com/store/search?q=acleda%20bank&c=apps',
          ),
          mode: LaunchMode.externalApplication,
        );
      } else if (GetPlatform.isIOS) {
        await launchUrl(
          Uri.parse('https://apps.apple.com/al/app/acleda-mobile/id1196285236'),
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
    final result = await uscase.acledaCheckStatus(transactionId: transactionId);
    if (result['status'] == 1) {
      Future.delayed(const Duration(seconds: 3), () async {
        await checkTransactionACLEDAComplete(
          context: context,
          transactionId: transactionId,
          token: token,
        );
      });
    } else {
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
    Loading().loadingShow(context);
    final result = await uscase.acledaComplete(
      transactionId: transactionId,
      token: token,
    );
    Loading().loadingClose(context);
    if (result['status'] == 1) {
      showDialogPaymentComplete(context);
    }
  }

  Future<void> onAcledaOptionTapOpenApp({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    await payWithACLEDAMobile(
      context: context,
      transactionId: transactionId,
      token: token,
    );
  }

  Future<void> onAcledaOptionTapXPay({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    final result = await Get.to(
      () => PaymentABAScreen(
        transactionId: transactionId,
        token: token,
        title: 'ACLEDA XPay',
        type: 4,
        url: '',
      ),
    );
    if (result == '1') {
      showDialogPaymentComplete(context);
    } else {
      showDialogPaymentFail(context);
    }
  }

  Future<void> payWithACLEDAMobile({
    required BuildContext context,
    required String transactionId,
    required String token,
  }) async {
    String type = GetPlatform.isIOS ? '2' : '1';
    final data = await uscase.acledaMobilePay(
      transactionId: transactionId,
      token: token,
      type: type,
    );
    if (data.status == 1) {
      final deep = data.abapayDeeplink ?? '';
      if (deep.isNotEmpty) {
        await openDeepLinkACLEDA(deep);
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

  void showDialogPaymentComplete(BuildContext context) {
    alertDialogTwoButton(
      title: 'your_ticket_has_been_reserved'.tr,
      description: 'ticket_info1'.tr,
      buttonText1: 'home'.tr,
      buttonText2: 'show_ticket'.tr,
      onButtonPressed1: () {
        ValueStatic().clearDataTicket();
        Get.offAll(() => const DashboardScreen(from: 0));
      },
      onButtonPressed2: () {
        ValueStatic().clearDataTicket();
        Get.offAll(() => const DashboardScreen(from: 2));
      },
    );
  }

  void showDialogPaymentFail(BuildContext context) {
    alertDialogOneButton(
      title: 'information'.tr,
      description: 'payment_not_success'.tr,
      buttonText: 'ok'.tr,
    );
  }
}
