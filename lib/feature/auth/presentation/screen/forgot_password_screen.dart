import 'package:express_vet/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';

import '../../../../utils/app_bar.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/button.dart';
import '../../../../utils/check_input.dart';
import '../../../../utils/style.dart';
import '../controller/auth_controller.dart';

class ForgotPasswordScreen extends GetView<AuthController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'forgot_pass'.tr),
      bottomNavigationBar: _buttonContinue(context),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: controller.uiState.value.forgotPasswordFormKey,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Image(
                      image: AssetImage(AssetImages.ic_forgot_password),
                      color: AppColors.primaryColor,
                      height: 200,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 12),
                    child: Text(
                      'enter_phone_num'.tr,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  TextFormField(
                    controller:
                        controller.uiState.value.forgotPasswordPhoneController,
                    autofocus: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [PhoneNumberFormatter()],
                    style: const TextStyle(fontSize: 14),
                    validator: (String? value) {
                      return CheckInput().checkLength(
                        (value ?? '').replaceAll(' ', ''),
                        9,
                        'phone_r'.tr,
                        'phone_in'.tr,
                      );
                    },
                    decoration: Style.inputText(
                      'telephone_num'.tr,
                      iconLeft: Ionicons.call_outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonContinue(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.whiteColor,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: globalButton(
            context: context,
            buttonText: 'continue'.tr,
            onPressed: () {
              controller.submitForgotPassword(context);
            },
          ),
        ),
      ),
    );
  }
}
