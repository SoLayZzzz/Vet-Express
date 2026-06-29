import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import '../../../../utils/app_bar.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/button.dart';
import '../../../../utils/check_input.dart';
import '../../../../utils/style.dart';
import '../../../../base/web_view_screen.dart';
import '../controller/auth_controller.dart';
import 'select_nationality_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const genderItems = ['male', 'female'];

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final AuthController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AuthController>();
    controller.clearRegisterInputs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarVET().appBar(context, 'create_account'.tr),
      body: SafeArea(
        child: Form(
          key: controller.uiState.value.signUpFormKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildInputUserName(),
                  _buildInputPhNumber(),
                  _buildInputEmail(),
                  _buildPassword(),
                  _buildConfirmPassword(),
                  _buildSelectGender(context),
                  _buildSelectNationality(),
                  _buildButtonRegister(context),
                  _builConditional(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputUserName() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'name-signup'.tr),
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.redColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller.uiState.value.signUpUsernameController,
            autofocus: false,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(fontSize: 14),
            validator: (String? value) {
              return CheckInput().checkLength(
                value!,
                4,
                'username_req'.tr,
                'username_inco'.tr,
              );
            },
            decoration: Style.inputText(
              'full_name'.tr,
              iconLeft: Ionicons.person_outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputPhNumber() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'phone_number'.tr),
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.redColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "user_can".tr,
            style: const TextStyle(color: AppColors.textColor),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller.uiState.value.signUpPhoneController,
            autofocus: false,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 14),
            inputFormatters: [PhoneNumberFormatter()],
            validator: (String? value) {
              return CheckInput().validatePhoneRe(value);
            },
            decoration: Style.inputText(
              'telephone_num'.tr,
              iconLeft: Ionicons.call_outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputEmail() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("email".tr),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller.uiState.value.signUpEmailController,
            autofocus: false,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(fontSize: 14),
            validator: (String? value) {
              final baseError = CheckInput().validateEmailAddress(value);
              if (baseError != null) return baseError;

              final email = (value ?? '').trim();
              if (email.isEmpty) return null;
              if (!email.toLowerCase().endsWith('@gmail.com')) {
                return 'email_must_be_gmail'.tr;
              }
              return null;
            },
            decoration: Style.inputText(
              'email'.tr,
              iconLeft: Ionicons.mail_unread_outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassword() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'pass'.tr),
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.redColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Obx(() {
            final ui = controller.uiState.value;
            return TextFormField(
              controller: controller.uiState.value.signUpPasswordController,
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
                    ui.signUpPasswordVisible.value
                        ? Ionicons.eye
                        : Ionicons.eye_off_outline,
                onPressed: controller.toggleSignUpPasswordVisibility,
              ),
              obscureText: !ui.signUpPasswordVisible.value,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildConfirmPassword() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'confirm_pass'.tr),
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.redColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Obx(() {
            final ui = controller.uiState.value;
            return TextFormField(
              controller: controller.uiState.value.signUpRePasswordController,
              autofocus: false,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: const TextStyle(fontSize: 14),
              validator: (String? value) {
                return CheckInput().checkMatch(
                  value!,
                  controller.uiState.value.signUpPasswordController.text,
                  'pass_not_match'.tr,
                );
              },
              decoration: Style.inputText(
                'confirm_pass'.tr,
                iconRight:
                    ui.signUpRePasswordVisible.value
                        ? Ionicons.eye
                        : Ionicons.eye_off_outline,
                onPressed: controller.toggleSignUpRePasswordVisibility,
                iconLeft: Ionicons.lock_closed_outline,
              ),
              obscureText: !ui.signUpRePasswordVisible.value,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSelectGender(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('gender'.tr),
          const SizedBox(height: 5),
          InputDecorator(
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(
                Ionicons.male_female_outline,
                color: AppColors.borderColor,
              ),
              contentPadding: const EdgeInsets.fromLTRB(0, 1, 10, 1),
              enabledBorder: Style.outlineInputBorder(),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryColor),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: Obx(() {
                final ui = controller.uiState.value;
                final rawGender = ui.signUpGender.value;
                final normalizedGender =
                    rawGender == 'male'.tr
                        ? 'male'
                        : rawGender == 'female'.tr
                        ? 'female'
                        : rawGender;
                return DropdownButton<String>(
                  isExpanded: true,
                  hint: Row(
                    children: [
                      Text(
                        'gender'.tr,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  iconEnabledColor: AppColors.borderColor,
                  items:
                      SignUpScreen.genderItems
                          .map(
                            (String item) => DropdownMenuItem<String>(
                              value: item,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: Text(
                                  item.tr,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  value:
                      SignUpScreen.genderItems.contains(normalizedGender)
                          ? normalizedGender
                          : null,
                  onChanged: (String? value) {
                    controller.setSignUpGender(value);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectNationality() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('nationality'.tr),
          const SizedBox(height: 5),
          Obx(() {
            final ui = controller.uiState.value;
            final selectedName = ui.signUpNationalityValue.value;
            return TextFormField(
              key: ValueKey(selectedName),
              initialValue: selectedName,
              readOnly: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onTap: () async {
                final result = await Get.to<Map<String, dynamic>>(
                  () => const SelectNationalityScreen(),
                  duration: const Duration(milliseconds: 350),
                  transition: Transition.rightToLeft,
                );
                if (result != null) {
                  controller.setSignUpNationality(
                    value: result['name'],
                    id: result['id'],
                  );
                }
              },
              style: const TextStyle(fontSize: 14),
              decoration: Style.inputText(
                'select_nation'.tr,
                iconLeft: Ionicons.flag_outline,
                iconRight: Ionicons.chevron_forward_outline,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildButtonRegister(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 20),
      child: globalButton(
        context: context,
        buttonText: 'register'.tr,
        onPressed: () {
          if (controller.uiState.value.signUpFormKey.currentState?.validate() ==
              true) {
            final ui = controller.uiState.value;
            final g = ui.signUpGender.value;
            controller.register(
              context,
              name: controller.uiState.value.signUpUsernameController.text,
              telephone: controller.uiState.value.signUpPhoneController.text
                  .replaceAll(' ', ''),
              password: controller.uiState.value.signUpPasswordController.text,
              email: controller.uiState.value.signUpEmailController.text,
              dob: controller.uiState.value.signUpDateOfBirthController.text,
              filename: ui.signUpImagePath.value,
              gender:
                  g == 'male' || g == 'male'.tr
                      ? 1
                      : g == 'female' || g == 'female'.tr
                      ? 2
                      : 0, // male = 1, female = 2
              nationalityId:
                  ui.signUpNationalityId.value == 0
                      ? null
                      : ui.signUpNationalityId.value,
            );
          }
        },
      ),
    );
  }

  Widget _builConditional() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
        onTap: () {
          Get.to(
            () => const WebViewScreen(type: 1, ticketId: ''),
            duration: const Duration(milliseconds: 350),
            transition: Transition.rightToLeft,
          );
        },
        child: Text.rich(
          TextSpan(
            text: 'agree_info'.tr,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            children: <TextSpan>[
              TextSpan(
                text: 'agree'.tr,
                style: const TextStyle(color: AppColors.secondaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
