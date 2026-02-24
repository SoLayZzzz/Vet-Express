import 'package:express_vet/utils/alert_dialog_twine.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/auth_controller.dart';

class VerifyCodeScreen extends GetView<AuthController> {
  final String token;
  final String phone;
  final int
  identify; // identify using for noted that data is from Ex: identify = 1 is from sign Up or identify = 2 is for forgot password. identify = 3 is for forgot password by telegram

  static String newToken =
      ''; // new Token is for resend code and get new token for request login

  const VerifyCodeScreen({
    super.key,
    required this.identify,
    required this.token,
    required this.phone,
  });

  Future<void> _openTelegram(BuildContext context) async {
    final uri = Uri.parse('https://telegram.me/teleLogisticBot');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(SnackBar(content: Text('can_not_open_telegram'.tr)));
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.uiState.value.verifyIdentify.value != identify) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.setVerifyIdentify(identify);
      });
    }

    if (identify >= 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openTelegram(context);
      });
    }
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
                    if (identify >= 3) {
                      _openTelegram(context);
                    }
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child:
                            identify >= 3
                                ? const Image(
                                  image: AssetImage(
                                    'assets/icons/icon_telegram.png',
                                  ),
                                  height: 150,
                                )
                                : const Image(
                                  image: AssetImage(
                                    'assets/images/ic_forgot_password.png',
                                  ),
                                  color: AppColors.primaryColor,
                                  height: 150,
                                ),
                      ),
                      if (identify >= 3)
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
                  padding: const EdgeInsets.only(top: 30, bottom: 10, left: 25),
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
                              identify: identify,
                              token: token,
                              phone: phone,
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
                        Countdown(
                          seconds: 120,
                          build: (BuildContext context, double time) {
                            int minutes = (time ~/ 60);
                            int seconds = (time % 60).toInt();

                            String formattedTime;

                            if (minutes > 0) {
                              formattedTime = '${minutes}m ${seconds}s';
                            } else {
                              formattedTime = '${seconds}s';
                            }

                            return Text(
                              formattedTime,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            );
                          },
                          interval: const Duration(seconds: 1),
                          onFinished: () {
                            controller.setVerifyTimeExpired(true);
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
                          await controller.onVerifyResendPressed(
                            context,
                            identify: identify,
                            token: token,
                            phone: phone,
                          );

                          if (controller
                                  .uiState
                                  .value
                                  .verifyCountResend
                                  .value ==
                              0) {
                            showDialog(
                              barrierColor: Colors.black26,
                              context: Get.context!,
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
                          }
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
