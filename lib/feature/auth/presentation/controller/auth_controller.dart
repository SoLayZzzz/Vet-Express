import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../api/user.dart';
import '../../../../activities/ticket/value_statics.dart';
import '../../../../base/state_controller.dart';
import '../../../../controller/user_controller.dart';
import '../../../../utils/alert_dialog.dart';
import '../../../../utils/app_pref.dart';
import '../../../../utils/contains.dart';
import '../../../../utils/loading.dart';
import '../../data/model/response/nationality_response.dart';
import '../../data/model/request/login_request.dart';
import '../../domain/uscase/auth_usecase.dart';
import '../uiState/auth_ui_state.dart';
import '../../../../routes/app_routes.dart';

class AuthController extends StateController<AuthUiState> {
  final AuthUseCase authUseCase;

  AuthController(this.authUseCase);

  final signInFormKey = GlobalKey<FormState>();
  final signUpFormKey = GlobalKey<FormState>();

  final signInPhoneController = TextEditingController();
  final signInPasswordController = TextEditingController();

  final signUpUsernameController = TextEditingController();
  final signUpPhoneController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final signUpRePasswordController = TextEditingController();
  final signUpEmailController = TextEditingController();
  final signUpDateOfBirthController = TextEditingController();
  final signUpNationalitySearchController = TextEditingController();

  final forgotPasswordFormKey = GlobalKey<FormState>();
  final forgotPasswordPhoneController = TextEditingController();

  final createNewPasswordFormKey = GlobalKey<FormState>();
  final createNewPasswordController = TextEditingController();
  final createNewRePasswordController = TextEditingController();

  Future<NationalityResponse>? nationalityFuture;

  @override
  AuthUiState onInitUiState() => const AuthUiState();

  @override
  void onInit() {
    super.onInit();
    _loadLanguageFromPref();
  }

  void submitForgotPassword(BuildContext context) {
    final valid = forgotPasswordFormKey.currentState?.validate() ?? false;
    if (!valid) return;
    User().forgotPassword(context, forgotPasswordPhoneController.text);
  }

  void toggleCreateNewPasswordVisibility() {
    uiState.value =
        state.copyWith(newPasswordVisible: !state.newPasswordVisible);
  }

  void toggleCreateNewRePasswordVisibility() {
    uiState.value =
        state.copyWith(newRePasswordVisible: !state.newRePasswordVisible);
  }

  void submitCreateNewPassword(BuildContext context, {required String token}) {
    final valid = createNewPasswordFormKey.currentState?.validate() ?? false;
    if (!valid) return;

    User().createNewPassword(
      context,
      createNewPasswordController.text,
      token,
    );
  }

  void setVerifyIdentify(int identify) {
    uiState.value = state.copyWith(verifyIdentify: identify);
  }

  void setVerifyTimeExpired(bool expired) {
    uiState.value = state.copyWith(verifyTimeExpired: expired);
  }

  void markVerifyResent() {
    uiState.value = state.copyWith(verifyResend: true, verifyTimeExpired: false);
  }

  void verifyCodeCompleted(
    BuildContext context, {
    required String code,
    required int identify,
    required String token,
    required String phone,
    required bool resend,
    required String newToken,
  }) {
    if (state.verifyTimeExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('code_expired'.tr)),
      );
      return;
    }

    if (identify == 1) {
      resend
          ? User().verification(context, code, newToken)
          : User().verification(context, code, token);
    } else if (identify == 2 || identify == 3) {
      User().verifyForgotPassword(context, code, token);
    } else {
      resend
          ? User().verification(context, code, newToken)
          : User().verification(context, code, token);
    }
  }

  Future<void> onVerifyResendPressed(
    BuildContext context, {
    required int identify,
    required String token,
    required String phone,
  }) async {
    final nextCount = state.verifyCountResend + 1;
    uiState.value = state.copyWith(verifyCountResend: nextCount);

    if (nextCount == 2) {
      uiState.value = state.copyWith(verifyCountResend: 0);
      return;
    }

    if (identify == 1) {
      User().reSendVerification(context, phone);
    } else if (identify == 2) {
      User().reSendPasswordVerification(context, token);
    } else if (identify == 3) {
      User().forgotPasswordByTelegram(context, phone);
      Navigator.pop(context);
    } else {
      User().registerByTelegram(context, '2', phone);
      Navigator.pop(context);
    }

    markVerifyResent();
  }

  @override
  void onClose() {
    signInPhoneController.dispose();
    signInPasswordController.dispose();
    signUpUsernameController.dispose();
    signUpPhoneController.dispose();
    signUpPasswordController.dispose();
    signUpRePasswordController.dispose();
    signUpEmailController.dispose();
    signUpDateOfBirthController.dispose();
    signUpNationalitySearchController.dispose();

    forgotPasswordPhoneController.dispose();
    createNewPasswordController.dispose();
    createNewRePasswordController.dispose();
    super.onClose();
  }

  void _loadLanguageFromPref() {
    final languagePref = AppPref.getLanguage();
    if (languagePref == Constrains.ENGLISH) {
      uiState.value = state.copyWith(activeLanguage: 'en');
    } else if (languagePref == Constrains.CHINESE) {
      uiState.value = state.copyWith(activeLanguage: 'zh');
    } else {
      uiState.value = state.copyWith(activeLanguage: 'km');
    }
  }

  void setLanguage(String langCode) {
    if (langCode == 'km') {
      Get.updateLocale(const Locale('km', 'KH'));
      AppPref.setLanguage('km');
    } else if (langCode == 'en') {
      Get.updateLocale(const Locale('en', 'US'));
      AppPref.setLanguage('en');
    } else if (langCode == 'zh') {
      Get.updateLocale(const Locale('zh', 'CN'));
      AppPref.setLanguage('zh');
    }
    uiState.value = state.copyWith(activeLanguage: langCode);
  }

  void toggleSignInPasswordVisibility() {
    uiState.value = state.copyWith(
      signInPasswordVisible: !state.signInPasswordVisible,
    );
  }

  void toggleSignUpPasswordVisibility() {
    uiState.value = state.copyWith(
      signUpPasswordVisible: !state.signUpPasswordVisible,
    );
  }

  void toggleSignUpRePasswordVisibility() {
    uiState.value = state.copyWith(
      signUpRePasswordVisible: !state.signUpRePasswordVisible,
    );
  }

  void submitLogin(BuildContext context) {
    final valid = signInFormKey.currentState?.validate() ?? false;
    if (!valid) return;

    login(
      context,
      username: signInPhoneController.text.trim(),
      password: signInPasswordController.text.trim(),
    );
  }

  void ensureNationalityLoaded(BuildContext context) {
    nationalityFuture ??= User().getNationality(context);
  }

  void setSignUpGender(String? value) {
    uiState.value = state.copyWith(signUpGender: value);
  }

  void setSignUpNationality({required String? value, required int? id}) {
    uiState.value = state.copyWith(
      signUpNationalityValue: value,
      signUpNationalityId: id,
    );
    if (value != null) {
      ValueStatic.nationalityName = value;
    }
    if (id != null) {
      ValueStatic.nationalityId = id;
    }
  }

  Future<void> login(
    BuildContext context, {
    required String username,
    required String password,
  }) async {
    uiState.value = state.copyWith(isLoading: true, errorMessage: null);
    Loading().loadingShow(context);

    final deviceId = AppPref.getDeviceId() ?? 'VET_Express_DeviceID';
    final deviceName = AppPref.getDeviceName() ?? 'VET_Express_DeviceName';

    try {
      final response = await authUseCase.login(
        LoginRequest(
          deviceId: deviceId,
          deviceName: deviceName,
          username: username,
          password: password,
        ),
      );

      Loading().loadingClose(context);

      if (response.header?.result == false &&
          response.header?.statusCode == 401) {
        alertDialogOneButton(
          title: 'invalid'.tr,
          description: 'check_password'.tr,
          buttonText: 'yes'.tr,
        );
        return;
      }

      final tokenType = response.body?.tokenType;
      final token = response.body?.accessToken;

      if (tokenType == null || token == null) {
        uiState.value = state.copyWith(errorMessage: 'try_again'.tr);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
        return;
      }

      await AppPref.setToken('$tokenType $token');

      final userController = Get.find<UserController>();
      userController.fetchUserMe();

      await AppPref.setLogin();

      Get.offAllNamed(AppRoutes.home);
    } on Exception catch (e) {
      Loading().loadingClose(context);
      log('login error', error: e);
      uiState.value = state.copyWith(errorMessage: e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
    } finally {
      uiState.value = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout(BuildContext context) async {
    uiState.value = state.copyWith(isLoading: true, errorMessage: null);
    Loading().loadingShow(context);

    try {
      final deviceId = AppPref.getDeviceId() ?? '';
      await authUseCase.logout(deviceId: deviceId);
      await AppPref.clearAllData();

      Loading().loadingClose(context);

      Get.offAllNamed(AppRoutes.signIn);
    } catch (e) {
      Loading().loadingClose(context);
      uiState.value = state.copyWith(errorMessage: e.toString());
    } finally {
      uiState.value = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    uiState.value = state.copyWith(isLoading: true, errorMessage: null);
    Loading().loadingShow(context);

    try {
      final response = await authUseCase.deleteAccount();
      Loading().loadingClose(context);

      if (response.header?.result == false) {
        alertDialogOneButton(
          title: 'not_successful'.tr,
          description: 'fail_delete'.tr,
          buttonText: 'yes'.tr,
        );
        return;
      }

      if (response.header?.result == true &&
          response.header?.statusCode == 200) {
        alertDialogTravelPackage(
          title: 'successful'.tr,
          description: 'successful_delete'.tr,
          buttonText: 'yes'.tr,
          onButtonPressed: () async {
            await AppPref.clearAllData();
            Get.offAllNamed(AppRoutes.signIn);
          },
        );
      }
    } catch (e) {
      Loading().loadingClose(context);
      uiState.value = state.copyWith(errorMessage: e.toString());
    } finally {
      uiState.value = state.copyWith(isLoading: false);
    }
  }
}
