import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import '../../../../api/user.dart';
import '../../data/model/response/nationality_response.dart';
import '../../../../utils/app_bar.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/button.dart';
import '../../../../utils/check_input.dart';
import '../../../../utils/style.dart';
import '../../../../activities/ticket/value_statics.dart';
import '../../../../activities/screen/web_view_screen.dart';
import '../controller/auth_controller.dart';

class SignUpScreen extends GetView<AuthController> {
  const SignUpScreen({super.key});

  static final genderItems = ['male'.tr, 'female'.tr];

  @override
  Widget build(BuildContext context) {
    controller.ensureNationalityLoaded(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarVET().appBar(context, 'create_account'.tr),
      body: SafeArea(
        child: Form(
          key: controller.signUpFormKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  //* username
                  Padding(
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
                          controller: controller.signUpUsernameController,
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
                  ),

                  //* phone number
                  Padding(
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
                          controller: controller.signUpPhoneController,
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
                  ),

                  //* email
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("email".tr),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: controller.signUpEmailController,
                          autofocus: false,
                          keyboardType: TextInputType.emailAddress,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: const TextStyle(fontSize: 14),
                          validator: (String? value) {
                            return CheckInput().validateEmailAddress(value);
                          },
                          decoration: Style.inputText(
                            'email'.tr,
                            iconLeft: Ionicons.mail_unread_outline,
                          ),
                        ),
                      ],
                    ),
                  ),

                  //* password
                  Padding(
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
                            controller: controller.signUpPasswordController,
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
                                  ui.signUpPasswordVisible
                                      ? Ionicons.eye
                                      : Ionicons.eye_off_outline,
                              onPressed:
                                  controller.toggleSignUpPasswordVisibility,
                            ),
                            obscureText: !ui.signUpPasswordVisible,
                          );
                        }),
                      ],
                    ),
                  ),

                  //* confirm password
                  Padding(
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
                            controller: controller.signUpRePasswordController,
                            autofocus: false,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: const TextStyle(fontSize: 14),
                            validator: (String? value) {
                              return CheckInput().checkMatch(
                                value!,
                                controller.signUpPasswordController.text,
                                'pass_not_match'.tr,
                              );
                            },
                            decoration: Style.inputText(
                              'confirm_pass'.tr,
                              iconRight:
                                  ui.signUpRePasswordVisible
                                      ? Ionicons.eye
                                      : Ionicons.eye_off_outline,
                              onPressed:
                                  controller.toggleSignUpRePasswordVisibility,
                              iconLeft: Ionicons.lock_closed_outline,
                            ),
                            obscureText: !ui.signUpRePasswordVisible,
                          );
                        }),
                      ],
                    ),
                  ),

                  //* gender
                  Padding(
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
                                                    item,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                        )
                                        .toList(),
                                value: ui.signUpGender,
                                onChanged: (String? value) {
                                  controller.setSignUpGender(value);
                                },
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //* nationality
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('nationality'.tr),
                        const SizedBox(height: 5),
                        FutureBuilder<NationalityResponse>(
                          future: controller.nationalityFuture,
                          builder: (context, data) {
                            if (data.hasData) {
                              if ((data.data?.header?.result) == true &&
                                  (data.data?.header?.statusCode) == 200) {
                                if ((data.data?.body)!.status == true &&
                                    (data.data?.body)!.data!.isNotEmpty) {
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
                                              data.data?.body!.data
                                                  ?.map(
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
                                          value: ui.signUpNationalityValue,
                                          onChanged: (value) {
                                            final nationalityId =
                                                data.data?.body?.data
                                                    ?.firstWhere(
                                                      (item) =>
                                                          item.name == value,
                                                    )
                                                    .id;
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
                  ),

                  //* button register
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 20),
                    child: globalButton(
                      context: context,
                      buttonText: 'register'.tr,
                      onPressed: () {
                        if (controller.signUpFormKey.currentState!.validate()) {
                          final ui = controller.uiState.value;
                          User().register(
                            context,
                            controller.signUpUsernameController.text,
                            controller.signUpPasswordController.text.trim(),
                            controller.signUpPhoneController.text.trim(),
                            email: controller.signUpEmailController.text,
                            dob: controller.signUpDateOfBirthController.text,
                            filename: ui.signUpImagePath ?? '',
                            gender:
                                ui.signUpGender == null
                                    ? 0
                                    : ui.signUpGender == 'male'.tr
                                    ? 1
                                    : 2, // male = 1, female = 2
                            nationalityId: ValueStatic.nationalityId,
                          );
                        }
                      },
                    ),
                  ),

                  //* conditional
                  Padding(
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
