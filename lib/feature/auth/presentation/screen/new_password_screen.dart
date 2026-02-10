import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/utils/button.dart';
import 'package:express_vet/utils/check_input.dart';
import 'package:express_vet/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';

class CreateNewPasswordScreen extends GetView<AuthController> {
  final String token;

  const CreateNewPasswordScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'new_pass'.tr),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: controller.createNewPasswordFormKey,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Image(
                      image: AssetImage('assets/images/ic_forgot_password.png'),
                      color: AppColors.primaryColor,
                      height: 200,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 12),
                    child: Text(
                      'new_password'.tr,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  Obx(() {
                    final ui = controller.uiState.value;
                    return TextFormField(
                      controller: controller.createNewPasswordController,
                      autofocus: false,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: const TextStyle(fontSize: 14),
                      validator: (String? value) {
                        return CheckInput().checkLength(
                          value!,
                          4,
                          'pass_req'.tr,
                          'pass_inco'.tr,
                        );
                      },
                      decoration: Style.inputText(
                        'pass'.tr,
                        iconLeft: Ionicons.lock_closed_outline,
                        iconRight:
                            ui.newPasswordVisible
                                ? Ionicons.eye
                                : Ionicons.eye_off_outline,
                        onPressed: controller.toggleCreateNewPasswordVisibility,
                      ),
                      obscureText: !ui.newPasswordVisible,
                    );
                  }),
                  const SizedBox(height: 12),
                  Obx(() {
                    final ui = controller.uiState.value;
                    return TextFormField(
                      controller: controller.createNewRePasswordController,
                      autofocus: false,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: const TextStyle(fontSize: 14),
                      validator: (String? value) {
                        return CheckInput().checkMatch(
                          value!,
                          controller.createNewPasswordController.text,
                          'pass_not_match'.tr,
                        );
                      },
                      decoration: Style.inputText(
                        'confirm_pass'.tr,
                        iconLeft: Ionicons.lock_closed_outline,
                        iconRight:
                            ui.newRePasswordVisible
                                ? Ionicons.eye
                                : Ionicons.eye_off_outline,
                        onPressed:
                            controller.toggleCreateNewRePasswordVisibility,
                      ),
                      obscureText: !ui.newRePasswordVisible,
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: globalButton(
                        context: context,
                        buttonText: 'continue'.tr,
                        onPressed: () {
                          controller.submitCreateNewPassword(
                            context,
                            token: token,
                          );
                        },
                      ),
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
}
