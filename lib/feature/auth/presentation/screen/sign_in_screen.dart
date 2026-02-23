import 'dart:io';
import 'package:express_vet/asset_image.dart';
import 'package:express_vet/base/base_url.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/utils/button.dart';
import 'package:express_vet/utils/check_input.dart';
import 'package:express_vet/utils/contains.dart';
import 'package:express_vet/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';

import 'forgot_password_screen.dart';
import 'search_goods_transfer.dart';
import 'sign_up_screen.dart';

class SignInScreen extends GetView<AuthController> {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: const BoxDecoration(color: AppColors.primaryColor),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AssetImages.vet_logo, width: 200, height: 140),
                    const SizedBox(height: 4),
                    const Text(
                      "VET Express",
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Form(
                key: controller.signInFormKey,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: controller.signInPhoneController,
                        autofocus: false,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textColor,
                        ),
                        validator: (String? value) {
                          return CheckInput().checkLength(
                            value!,
                            9,
                            'phone_req'.tr,
                            'phone_inco'.tr,
                          );
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          hintText: 'phone_num'.tr,
                          enabledBorder: Style.outlineInputBorder(),
                          focusedBorder: Style.outlineInputBorder(),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.redColor,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.redColor,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(() {
                        final ui = controller.uiState.value;
                        return TextFormField(
                          controller: controller.signInPasswordController,
                          autofocus: false,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textColor,
                          ),
                          validator: (String? value) {
                            return CheckInput().checkLength(
                              value!,
                              0,
                              'pass_req'.tr,
                              'pass_inco'.tr,
                            );
                          },
                          decoration: Style.inputText(
                            'pass'.tr,
                            iconRight:
                                ui.signInPasswordVisible
                                    ? Ionicons.eye
                                    : Ionicons.eye_off_outline,
                            onPressed:
                                controller.toggleSignInPasswordVisibility,
                          ),
                          obscureText: !ui.signInPasswordVisible,
                        );
                      }),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'new_here'.tr,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              Get.to(
                                () => const SignUpScreen(),
                                transition: Transition.rightToLeft,
                                duration: const Duration(
                                  milliseconds: Constrains.duration,
                                ),
                              );
                            },
                            child: Text(
                              'register'.tr,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              Get.to(
                                () => const ForgotPasswordScreen(),
                                transition: Transition.rightToLeft,
                                duration: const Duration(
                                  milliseconds: Constrains.duration,
                                ),
                              );
                            },
                            child: Text(
                              'forget_pass'.tr,
                              style: const TextStyle(
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      globalButton(
                        context: context,
                        buttonText: 'login'.tr,
                        onPressed: () {
                          controller.submitLogin(context);
                        },
                      ),
                      const SizedBox(height: 20),
                      buttonNoBackground(
                        context: context,
                        buttonText: 'scan_parcel'.tr,
                        onPressed: () {
                          Get.to(
                            () => const SearchGoodsTransferScreen(),
                            transition: Transition.rightToLeft,
                            duration: const Duration(
                              milliseconds: Constrains.duration,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() {
                            final ui = controller.uiState.value;
                            return InkWell(
                              onTap: () {
                                controller.setLanguage('km');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'ភាសាខ្មែរ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        ui.activeLanguage == 'km'
                                            ? AppColors.primaryColor
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 30),
                          Obx(() {
                            final ui = controller.uiState.value;
                            return InkWell(
                              onTap: () {
                                controller.setLanguage('en');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'English',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        ui.activeLanguage == 'en'
                                            ? AppColors.primaryColor
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 30),
                          Obx(() {
                            final ui = controller.uiState.value;
                            return InkWell(
                              onTap: () {
                                controller.setLanguage('zh');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '中文',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        ui.activeLanguage == 'zh'
                                            ? AppColors.primaryColor
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'version'.tr +
                              (Platform.isAndroid
                                  ? BaseUrl.APP_VERSION_ANDROID
                                  : BaseUrl.APP_VERSION_IOS),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
