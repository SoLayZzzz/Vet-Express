import 'dart:async';

import 'package:express_vet/asset_image.dart';
import 'package:express_vet/utils/alert_dialog_twine.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/auth_controller.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String token;
  final String phone;
  final int identify;
  static String newToken = '';

  const VerifyCodeScreen({
    super.key,
    required this.identify,
    required this.token,
    required this.phone,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  late final AuthController controller;

  Timer? _timer;
  DateTime? _expireAt;
  final ValueNotifier<int> _remainingSeconds = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    controller = Get.find<AuthController>();

    if (controller.uiState.value.verifyIdentify.value != widget.identify) {
      controller.setVerifyIdentify(widget.identify);
    }

    if (widget.identify >= 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openTelegram(context);
      });
    }

    _restartCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _remainingSeconds.dispose();
    super.dispose();
  }

  Future<void> _openTelegram(BuildContext context) async {
    final uri = Uri.parse('https://telegram.me/teleLogisticBot');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('can_not_open_telegram'.tr)));
      Get.back();
    }
  }

  void _restartCountdown() {
    _timer?.cancel();

    _expireAt = DateTime.now().add(const Duration(seconds: 120));
    _tickCountdown();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickCountdown();
    });
  }

  void _tickCountdown() {
    final expireAt = _expireAt;
    if (expireAt == null) return;

    final next = expireAt.difference(DateTime.now()).inSeconds;
    final nextClamped = next < 0 ? 0 : next;

    if (_remainingSeconds.value != nextClamped) {
      _remainingSeconds.value = nextClamped;
    }

    if (nextClamped <= 0) {
      _timer?.cancel();
      controller.setVerifyTimeExpired(true);
    }
  }

  String _formatRemaining(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'verify_code'.tr),
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Form(
            key: GlobalKey<FormState>(),
            child: SafeArea(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (widget.identify >= 3) {
                        _openTelegram(context);
                      }
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child:
                              widget.identify >= 3
                                  ? const Image(
                                    image: AssetImage(
                                      // 'assets/icons/icon_telegram.png',
                                      AssetImages.ic_telegram,
                                    ),
                                    height: 150,
                                  )
                                  : const Image(
                                    image: AssetImage(
                                      // 'assets/images/ic_forgot_password.png',
                                      AssetImages.ic_forgot_password,
                                    ),
                                    color: AppColors.primaryColor,
                                    height: 150,
                                  ),
                        ),
                        if (widget.identify >= 3)
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Text(
                              'click_open_telegram'.tr,
                              style: const TextStyle(
                                color: AppColors.secondaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 30,
                      bottom: 10,
                      left: 25,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'enter_code_sms'.tr,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30.0),
                          PinCodeTextField(
                            appContext: context,
                            length: 4,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            cursorColor: AppColors.primaryColor,
                            autoFocus: true,
                            onChanged: (value) {},
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(5),
                              fieldHeight: 80,
                              fieldWidth: 80,
                              inactiveColor: Colors.grey,
                              activeColor: AppColors.primaryColor,
                              selectedColor: AppColors.primaryColor,
                            ),
                            onCompleted: (value) {
                              controller.verifyCodeCompleted(
                                context,
                                code: value,
                                identify: widget.identify,
                                token: widget.token,
                                phone: widget.phone,
                                resend:
                                    controller.uiState.value.verifyResend.value,
                                newToken: VerifyCodeScreen.newToken,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Obx(() {
                    final ui = controller.uiState.value;
                    if (ui.verifyTimeExpired.value) return const SizedBox();

                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('code_expire'.tr),
                          const SizedBox(width: 5),
                          ValueListenableBuilder<int>(
                            valueListenable: _remainingSeconds,
                            builder: (context, seconds, _) {
                              return Text(
                                _formatRemaining(seconds),
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  Obx(() {
                    final ui = controller.uiState.value;
                    if (!ui.verifyTimeExpired.value) return const SizedBox();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('code_expired'.tr),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.all(16.0),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            final parentContext = context;

                            await controller.onVerifyResendPressed(
                              parentContext,
                              identify: widget.identify,
                              token: widget.token,
                              phone: widget.phone,
                            );

                            if (!parentContext.mounted) return;

                            if (controller
                                    .uiState
                                    .value
                                    .verifyCountResend
                                    .value ==
                                0) {
                              showDialog(
                                barrierColor: Colors.black26,
                                context: parentContext,
                                builder: (context) {
                                  return AlertDialogTwine(
                                    title: 'information'.tr,
                                    description: 'opt_not_working'.tr,
                                    confirmClick: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              );
                              return;
                            }

                            _restartCountdown();
                            FocusScope.of(parentContext).unfocus();
                          },
                          child: Text('resend'.tr),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
