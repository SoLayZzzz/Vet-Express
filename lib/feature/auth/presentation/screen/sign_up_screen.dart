import 'package:express_vet/components/input_text_field.dart';
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
                TextSpan(text: 'name-signup'.tr, style: TextStyle(color: AppColors.mainTitle)),
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.redColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          InputTextField(
            hint: 'full_name'.tr,
            controller: controller.uiState.value.signUpUsernameController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            iconLeft: Ionicons.person_outline,
            validator: (String? value) {
              return CheckInput().checkLength(
                value ?? '',
                4,
                'username_req'.tr,
                'username_inco'.tr,
              );
            },
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
                TextSpan(text: 'phone_number'.tr, style: TextStyle(color: AppColors.mainTitle)),
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
          InputTextField(
            hint: 'telephone_num'.tr,
            controller: controller.uiState.value.signUpPhoneController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.phone,
            inputFormatters: [PhoneNumberFormatter()],
            iconLeft: Ionicons.call_outline,
            validator: (String? value) {
              return CheckInput().validatePhoneRe(value);
            },
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
          Text("email".tr,style: TextStyle(color: AppColors.mainTitle)),
          const SizedBox(height: 5),
          InputTextField(
            hint: 'email'.tr,
            controller: controller.uiState.value.signUpEmailController,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            iconLeft: Ionicons.mail_unread_outline,
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
                TextSpan(text: 'pass'.tr,style: TextStyle(color: AppColors.mainTitle)),
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
            return InputTextField(
              hint: 'pass'.tr,
              controller: controller.uiState.value.signUpPasswordController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: !ui.signUpPasswordVisible.value,
              iconLeft: Ionicons.lock_closed_outline,
              iconRight:
                  ui.signUpPasswordVisible.value
                      ? Ionicons.eye
                      : Ionicons.eye_off_outline,
              iconRightColor: AppColors.suffixIconColor,
              onIconRightPressed: controller.toggleSignUpPasswordVisibility,
              validator: (String? value) {
                return CheckInput().checkLength(
                  value ?? '',
                  4,
                  'pass_req'.tr,
                  'pass_inco'.tr,
                );
              },
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
                TextSpan(text: 'confirm_pass'.tr,style: TextStyle(color: AppColors.mainTitle)),
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
            return InputTextField(
              hint: 'confirm_pass'.tr,
              controller: controller.uiState.value.signUpRePasswordController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: !ui.signUpRePasswordVisible.value,
              iconLeft: Ionicons.lock_closed_outline,
              iconRight:
                  ui.signUpRePasswordVisible.value
                      ? Ionicons.eye
                      : Ionicons.eye_off_outline,
              iconRightColor: AppColors.suffixIconColor,
              onIconRightPressed: controller.toggleSignUpRePasswordVisibility,
              validator: (String? value) {
                return CheckInput().checkMatch(
                  value ?? '',
                  controller.uiState.value.signUpPasswordController.text,
                  'pass_not_match'.tr,
                );
              },
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
          Text('gender'.tr,style: TextStyle(color: AppColors.mainTitle)),
          const SizedBox(height: 5),
          InputDecorator(
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(
                Ionicons.male_female_outline,
                color: AppColors.mainTitle,
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
                        style: const TextStyle(fontSize: 14, color: AppColors.placeholderColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  iconEnabledColor: AppColors.suffixIconColor,
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
          Text('nationality'.tr,style: TextStyle(color: AppColors.mainTitle)),
          const SizedBox(height: 5),
          Obx(() {
            final ui = controller.uiState.value;
            final selectedName = ui.signUpNationalityValue.value;
            return InputTextField(
              key: ValueKey(selectedName),
              hint: 'select_nation'.tr,
              initialValue: selectedName,
              readOnly: true,
              showCursor: false,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              iconLeft: Ionicons.flag_outline,
              iconRight: Ionicons.chevron_forward_outline,
              iconRightColor: AppColors.suffixIconColor,
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
            style: const TextStyle(color: AppColors.placeholderColor, fontSize: 12),
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
