import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import '../../data/model/response/nationality_response.dart';
import '../../../../utils/app_bar.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/button.dart';
import '../../../../utils/check_input.dart';
import '../../../../utils/style.dart';
import '../../../../value_statics.dart';
import '../../../../base/web_view_screen.dart';
import '../controller/auth_controller.dart';

class SignUpScreen extends GetView<AuthController> {
  const SignUpScreen({super.key});

  static const genderItems = ['male', 'female'];

  @override
  Widget build(BuildContext context) {
    controller.ensureNationalityLoaded(context);
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
                        controller:
                            controller.uiState.value.signUpUsernameController,
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
                          'name-signup'.tr,
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
                        controller:
                            controller.uiState.value.signUpPhoneController,
                        autofocus: false,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 14),
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
                        controller:
                            controller.uiState.value.signUpEmailController,
                        autofocus: false,
                        keyboardType: TextInputType.emailAddress,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: const TextStyle(fontSize: 14),
                        validator: (String? value) {
                          final baseError =
                              CheckInput().validateEmailAddress(value);
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
                          controller:
                              controller
                                  .uiState
                                  .value
                                  .signUpPasswordController,
                          autofocus: false,
                          autovalidateMode:
                              AutovalidateMode.onUserInteraction,
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
                            onPressed:
                                controller.toggleSignUpPasswordVisibility,
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
                          controller:
                              controller
                                  .uiState
                                  .value
                                  .signUpRePasswordController,
                          autofocus: false,
                          autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                          style: const TextStyle(fontSize: 14),
                          validator: (String? value) {
                            return CheckInput().checkMatch(
                              value!,
                              controller
                                  .uiState
                                  .value
                                  .signUpPasswordController
                                  .text,
                              'pass_not_match'.tr,
                            );
                          },
                          decoration: Style.inputText(
                            'confirm_pass'.tr,
                            iconRight:
                                ui.signUpRePasswordVisible.value
                                    ? Ionicons.eye
                                    : Ionicons.eye_off_outline,
                            onPressed:
                                controller.toggleSignUpRePasswordVisibility,
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
                          contentPadding: const EdgeInsets.fromLTRB(
                            0,
                            1,
                            10,
                            1,
                          ),
                          enabledBorder: Style.outlineInputBorder(),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
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
                                  genderItems
                                      .map(
                                        (String item) =>
                                            DropdownMenuItem<String>(
                                              value: item,
                                              child: SizedBox(
                                                width:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width /
                                                    1.5,
                                                child: Text(
                                                  item.tr,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                      )
                                      .toList(),
                              value:
                                  genderItems.contains(normalizedGender)
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
                      FutureBuilder<NationalityResponse>(
                        future: controller.uiState.value.nationalityFuture,
                        builder: (context, data) {
                          if (data.hasData) {
                            if ((data.data?.header?.result) == true &&
                                (data.data?.header?.statusCode) == 200) {
                              if ((data.data?.body)!.status == true &&
                                  (data.data?.body)!.data!.isNotEmpty) {
                                final nationalityData =
                                    data.data?.body?.data ?? [];
                                final uniqueNationalityByName = <String, dynamic>{};
                                for (final item in nationalityData) {
                                  final name = (item.name ?? '').trim();
                                  if (name.isEmpty) continue;
                                  uniqueNationalityByName.putIfAbsent(
                                    name,
                                    () => item,
                                  );
                                }
                                return InputDecorator(
                                  decoration: InputDecoration(
                                    isDense: true,
                                    prefixIcon: const Icon(
                                      Ionicons.flag_outline,
                                    ),
                                    contentPadding: const EdgeInsets.fromLTRB(
                                      0,
                                      1,
                                      10,
                                      1,
                                    ),
                                    enabledBorder: Style.outlineInputBorder(),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.primaryColor,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: Obx(() {
                                      final ui = controller.uiState.value;
                                      final selectedNationality =
                                          uniqueNationalityByName
                                                  .containsKey(
                                                    ui.signUpNationalityValue.value,
                                                  )
                                              ? ui.signUpNationalityValue.value
                                              : null;
                                      return DropdownButton2<String>(
                                        isExpanded: true,
                                        hint: Text(
                                          'nationality'.tr,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                Theme.of(context).hintColor,
                                          ),
                                        ),
                                        items:
                                            uniqueNationalityByName
                                                .values
                                                .map(
                                                  (item) => DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: item.name,
                                                    child: Text(
                                                      "${item.name}",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        value:
                                            selectedNationality,
                                        onChanged: (value) {
                                          if (value == null) {
                                            controller.setSignUpNationality(
                                              value: null,
                                              id: null,
                                            );
                                            return;
                                          }
                                          final nationalityId =
                                              uniqueNationalityByName[value]
                                                  ?.id;
                                          controller.setSignUpNationality(
                                            value: value,
                                            id: nationalityId,
                                          );
                                        },
                                        iconStyleData: const IconStyleData(
                                          iconEnabledColor:
                                              AppColors.borderColor,
                                        ),
                                        dropdownStyleData:
                                            const DropdownStyleData(
                                              width: double.infinity,
                                            ),
                                        menuItemStyleData:
                                            const MenuItemStyleData(
                                              height: 40,
                                            ),
                                        dropdownSearchData: DropdownSearchData(
                                          searchController:
                                              controller
                                                  .uiState
                                                  .value
                                                  .signUpNationalitySearchController,
                                          searchInnerWidgetHeight: 50,
                                          searchInnerWidget: Container(
                                            height: 60,
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                              bottom: 4,
                                              right: 8,
                                              left: 8,
                                            ),
                                            child: TextFormField(
                                              expands: true,
                                              maxLines: null,
                                              controller:
                                                  controller
                                                      .uiState
                                                      .value
                                                      .signUpNationalitySearchController,
                                              decoration: Style.inputText(
                                                'search_nation'.tr,
                                              ),
                                            ),
                                          ),
                                          searchMatchFn: (item, searchValue) {
                                            return item.value
                                                .toString()
                                                .toLowerCase()
                                                .contains(
                                                  searchValue.toLowerCase(),
                                                );
                                          },
                                        ),
                                        //* This to clear the search value when you close the menu
                                        onMenuStateChange: (isOpen) {
                                          if (!isOpen) {
                                            controller
                                                .uiState
                                                .value
                                                .signUpNationalitySearchController
                                                .clear();
                                          }
                                        },
                                      );
                                    }),
                                  ),
                                );
                              }
                            }
                          } else if (data.hasError) {
                            return const Text('');
                          }
                          return const Center(
                            child: SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child: CircularProgressIndicator(
                                value: null,
                                color: AppColors.primaryColor,
                                strokeWidth: 3.0,
                              ),
                            ),
                          );
                        },
                      ),
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
                      if (
                          controller.uiState.value.signUpFormKey.currentState
                              ?.validate() ==
                          true) {
                        final ui = controller.uiState.value;
                        final g = ui.signUpGender.value;
                        controller.register(
                          context,
                          name:
                              controller
                                  .uiState
                                  .value
                                  .signUpUsernameController
                                  .text,
                          telephone:
                              controller
                                  .uiState
                                  .value
                                  .signUpPhoneController
                                  .text,
                          password:
                              controller
                                  .uiState
                                  .value
                                  .signUpPasswordController
                                  .text,
                          email:
                              controller
                                  .uiState
                                  .value
                                  .signUpEmailController
                                  .text,
                          dob:
                              controller
                                  .uiState
                                  .value
                                  .signUpDateOfBirthController
                                  .text,
                          filename: ui.signUpImagePath.value,
                          gender:
                              g == 'male' || g == 'male'.tr
                                  ? 1
                                  : g == 'female' || g == 'female'.tr
                                  ? 2
                                  : 0, // male = 1, female = 2
                          nationalityId: ValueStatic.nationalityId,
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
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'agree'.tr,
                            style: const TextStyle(
                              color: AppColors.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
  }
}
