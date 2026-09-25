import 'package:express_vet/asset_image.dart';
import 'package:express_vet/components/input_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';

import '../../../../utils/app_bar.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/button.dart';
import '../../../../utils/check_input.dart';
import '../controller/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final AuthController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AuthController>();
    controller.clearForgotPasswordInputs();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'forgot_pass'.tr),
      // bottomNavigationBar: _buttonContinue(context),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: controller.uiState.value.forgotPasswordFormKey,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                    InputTextField(
                      hint: 'telephone_num'.tr,
                      controller:
                          controller.uiState.value.forgotPasswordPhoneController,
                      autofocus: false,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [PhoneNumberFormatter()],
                      iconLeft: Ionicons.call_outline,
                      onSubmitted: (_) {
                        FocusScope.of(context).unfocus();
                      },
                      validator: (String? value) {
                        return CheckInput().checkLength(
                          (value ?? '').replaceAll(' ', ''),
                          9,
                          'phone_r'.tr,
                          'phone_in'.tr,
                        );
                      },
                    ),

                    SizedBox(height: 20),
                    //
                    _buttonContinue(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonContinue(BuildContext context) {

    return Container(
      color: AppColors.whiteColor,
      width: double.infinity,
      child: globalButton(
        context: context,
        buttonText: 'continue'.tr,
        onPressed: () {
          controller.submitForgotPassword(context);
        },
      ),
    );
  }
}
