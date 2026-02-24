import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../value_statics.dart';
import '../../../../base/state_controller.dart';
import '../../../../controller/user_controller.dart';
import '../../../../utils/alert_dialog.dart';
import '../../../../utils/app_pref.dart';
import '../../../../utils/contains.dart';
import '../../../../utils/loading.dart';
import '../../data/model/request/login_request.dart';
import '../../domain/uscase/auth_usecase.dart';
import '../uiState/auth_ui_state.dart';
import '../../../../routes/app_routes.dart';

class AuthController extends StateController<AuthUiState> {
  final AuthUseCase authUseCase;

  AuthController(this.authUseCase);

  @override
  AuthUiState onInitUiState() => AuthUiState();

  @override
  void onInit() {
    super.onInit();

    uiState.value.signInPhoneController.value;
    uiState.value.signInPasswordController.value;

    uiState.value.signUpUsernameController.value;
    uiState.value.signUpPhoneController.value;
    uiState.value.signUpPasswordController.value;
    uiState.value.signUpRePasswordController.value;
    uiState.value.signUpEmailController.value;
    uiState.value.signUpDateOfBirthController.value;
    uiState.value.signUpNationalitySearchController.value;

    uiState.value.forgotPasswordPhoneController.value;

    uiState.value.createNewPasswordController.value;
    uiState.value.createNewRePasswordController.value;
    _loadLanguageFromPref();
  }

  // ===== Auth flow helpers using AuthUseCase =====
  Future<void> register(
    BuildContext context, {
    required String name,
    required String password,
    required String telephone,
    String? email,
    String? dob,
    String? filename,
    int? gender,
    int? nationalityId,
  }) async {
    Loading().loadingShow();
    try {
      final res = await authUseCase.register(
        name: name,
        password: password,
        telephone: telephone,
        email: email,
        dob: dob,
        filename: filename,
        gender: gender,
        nationalityId: nationalityId,
      );
      Loading().loadingClose();
      if (res.header?.result == true && res.header?.statusCode == 200) {
        if (res.body?.status == true) {
          final token = res.body?.message?.toString() ?? '';
          Get.toNamed(
            AppRoutes.verifyCode,
            arguments: {'identify': 1, 'token': token, 'phone': telephone},
          );
          return;
        }
        alertDialogOneButton(
          title: 'information'.tr,
          description: 'this_phone_number_have_been_registered'.tr,
          buttonText: 'yes'.tr,
        );
        return;
      }
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
    } catch (e) {
      Loading().loadingClose();
      uiState.value.errorMessage.value = e.toString();
    }
  }

  Future<void> _verification(
    BuildContext context, {
    required String code,
    required String deviceId,
    required String deviceName,
    required String token,
  }) async {
    Loading().loadingShow();
    try {
      final res = await authUseCase.verification(
        code: code,
        deviceId: deviceId,
        deviceName: deviceName,
        token: token,
      );
      Loading().loadingClose();
      if (res.header?.result == true && res.header?.statusCode == 200) {
        if (res.body?.status == true) {
          final newToken = res.body?.message?.toString() ?? '';
          await AppPref.setToken('Bearer $newToken');
          final userController = Get.find<UserController>();
          userController.fetchUserMe();
          await AppPref.setLogin();

          Get.offAllNamed(AppRoutes.home);
          return;
        }
        alertDialogOneButton(
          title: 'information'.tr,
          description: 'code_verify_invalid'.tr,
          buttonText: 'yes'.tr,
        );
        return;
      }
      alertDialogOneButton(
        title: 'information'.tr,
        description: 'code_verify_invalid'.tr,
        buttonText: 'yes'.tr,
      );
    } catch (e) {
      Loading().loadingClose();
      uiState.value.errorMessage.value = e.toString();
    }
  }

  Future<void> _resendVerification(
    BuildContext context, {
    required String phone,
  }) async {
    try {
      await authUseCase.resendVerification(phone: phone);
    } catch (_) {}
  }

  Future<void> _resetPasswordVerify(
    BuildContext context, {
    required String code,
    required String token,
  }) async {
    Loading().loadingShow();
    try {
      final res = await authUseCase.resetPasswordVerify(
        code: code,
        token: token,
      );
      Loading().loadingClose();
      if (res.header?.result == true && res.header?.statusCode == 200) {
        if (res.body?.status == true) {
          final newToken = res.body?.message?.toString() ?? '';
          Get.offNamed(AppRoutes.newPassword, arguments: {'token': newToken});
          return;
        }
        alertDialogOneButton(
          title: 'information'.tr,
          description: 'sms_code_invalid'.tr,
          buttonText: 'yes'.tr,
        );
        return;
      }
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
    } catch (e) {
      Loading().loadingClose();
      uiState.value.errorMessage.value = e.toString();
    }
  }

  Future<void> _resendCode(
    BuildContext context, {
    required String token,
  }) async {
    try {
      await authUseCase.resendCode(token: token);
    } catch (_) {}
  }

  Future<void> _createNewPassword(
    BuildContext context,
    String password,
    String token,
  ) async {
    Loading().loadingShow();
    try {
      final res = await authUseCase.newPassword(
        newPassword: password,
        token: token,
      );
      Loading().loadingClose();
      if (res.header?.result == true && res.header?.statusCode == 200) {
        if (res.body?.status == true) {
          Get.offAllNamed(AppRoutes.signIn);
          return;
        }
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
      }
    } catch (e) {
      Loading().loadingClose();
    }
  }

  Future<void> _forgotPassword(BuildContext context, String phone) async {
    Loading().loadingShow();
    try {
      final res = await authUseCase.resetPasswordSendSms(phone: phone);
      Loading().loadingClose();
      if (res.header?.result == true && res.header?.statusCode == 200) {
        if (res.body?.status == true) {
          final token = res.body?.message?.toString() ?? '';
          Get.toNamed(
            AppRoutes.verifyCode,
            arguments: {'identify': 2, 'token': token, 'phone': phone},
          );
          return;
        }
        alertDialogOneButton(
          title: 'information'.tr,
          description: 'this_phone_number_not_registered'.tr,
          buttonText: 'yes'.tr,
        );
        return;
      }
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
    } catch (e) {
      Loading().loadingClose();
    }
  }

  Future<void> _sendOtpForgetPassword(
    BuildContext context, {
    required String phone,
  }) async {
    try {
      await authUseCase.sendOtpForgetPassword(phone: phone);
    } catch (_) {}
  }

  Future<void> _sendOtpRegister(
    BuildContext context, {
    required String type,
    required String phone,
  }) async {
    try {
      await authUseCase.sendOtpRegister(type: type, phone: phone);
    } catch (_) {}
  }

  void submitForgotPassword(BuildContext context) {
    final valid =
        uiState.value.forgotPasswordFormKey.currentState?.validate() ?? false;
    if (!valid) return;
    _forgotPassword(context, uiState.value.forgotPasswordPhoneController.text);
  }

  void toggleCreateNewPasswordVisibility() {
    uiState.value.newPasswordVisible.value =
        !uiState.value.newPasswordVisible.value;
  }

  void toggleCreateNewRePasswordVisibility() {
    uiState.value.newRePasswordVisible.value =
        !uiState.value.newRePasswordVisible.value;
  }

  void submitCreateNewPassword(BuildContext context, {required String token}) {
    final valid =
        uiState.value.createNewPasswordFormKey.currentState?.validate() ??
        false;
    if (!valid) return;
    _createNewPassword(
      context,
      uiState.value.createNewPasswordController.text,
      token,
    );
  }

  void setVerifyIdentify(int identify) {
    uiState.value.verifyIdentify.value = identify;
  }

  void setVerifyTimeExpired(bool expired) {
    uiState.value.verifyTimeExpired.value = expired;
  }

  void markVerifyResent() {
    uiState.value.verifyResend.value = true;
    uiState.value.verifyTimeExpired.value = false;
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
    if (uiState.value.verifyTimeExpired.value) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('code_expired'.tr)));
      return;
    }

    if (identify == 1) {
      final deviceId = AppPref.getDeviceId() ?? 'VET_Express_DeviceID';
      final deviceName = AppPref.getDeviceName() ?? 'VET_Express_DeviceName';
      _verification(
        context,
        code: code,
        deviceId: deviceId,
        deviceName: deviceName,
        token: resend ? newToken : token,
      );
    } else if (identify == 2 || identify == 3) {
      _resetPasswordVerify(context, code: code, token: token);
    } else {
      final deviceId = AppPref.getDeviceId() ?? 'VET_Express_DeviceID';
      final deviceName = AppPref.getDeviceName() ?? 'VET_Express_DeviceName';
      _verification(
        context,
        code: code,
        deviceId: deviceId,
        deviceName: deviceName,
        token: resend ? newToken : token,
      );
    }
  }

  Future<void> onVerifyResendPressed(
    BuildContext context, {
    required int identify,
    required String token,
    required String phone,
  }) async {
    final nextCount = uiState.value.verifyCountResend.value + 1;
    uiState.value.verifyCountResend.value = nextCount;

    if (nextCount == 2) {
      uiState.value.verifyCountResend.value = 0;
      return;
    }

    if (identify == 1) {
      await _resendVerification(context, phone: phone);
    } else if (identify == 2) {
      await _resendCode(context, token: token);
    } else if (identify == 3) {
      await _sendOtpForgetPassword(context, phone: phone);
      Get.back();
    } else {
      await _sendOtpRegister(context, type: '2', phone: phone);
      Get.back();
    }

    markVerifyResent();
  }

  void _loadLanguageFromPref() {
    final languagePref = AppPref.getLanguage();
    if (languagePref == Constrains.ENGLISH) {
      uiState.value.activeLanguage.value = 'en';
    } else if (languagePref == Constrains.CHINESE) {
      uiState.value.activeLanguage.value = 'zh';
    } else {
      uiState.value.activeLanguage.value = 'km';
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
    uiState.value.activeLanguage.value = langCode;
  }

  void toggleSignInPasswordVisibility() {
    uiState.value.signInPasswordVisible.value =
        !uiState.value.signInPasswordVisible.value;
  }

  void toggleSignUpPasswordVisibility() {
    uiState.value.signUpPasswordVisible.value =
        !uiState.value.signUpPasswordVisible.value;
  }

  void toggleSignUpRePasswordVisibility() {
    uiState.value.signUpRePasswordVisible.value =
        !uiState.value.signUpRePasswordVisible.value;
  }

  void submitLogin(BuildContext context) {
    final valid = uiState.value.signInFormKey.currentState?.validate() ?? false;
    if (!valid) return;

    login(
      context,
      username: uiState.value.signInPhoneController.text.trim(),
      password: uiState.value.signInPasswordController.text.trim(),
    );
  }

  void ensureNationalityLoaded(BuildContext context) {
    uiState.value.nationalityFuture ??= authUseCase.nationalityList();
  }

  void setSignUpGender(String? value) {
    uiState.value.signUpGender.value = value ?? '';
  }

  void setSignUpNationality({required String? value, required int? id}) {
    uiState.value.signUpNationalityValue.value = value ?? '';
    uiState.value.signUpNationalityId.value = id ?? 0;
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
    uiState.value.isLoading.value = true;
    uiState.value.errorMessage.value = '';
    Loading().loadingShow();

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

      Loading().loadingClose();

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
        uiState.value.errorMessage.value = 'try_again'.tr;
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
        return;
      }

      await AppPref.setToken('$tokenType $token');

      final userController = Get.find<UserController>();
      userController.fetchUserMe();

      await AppPref.setLogin();

      Get.offAllNamed(AppRoutes.home);
    } on Exception catch (e) {
      Loading().loadingClose();
      log('login error', error: e);
      uiState.value.errorMessage.value = e.toString();
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
    } finally {
      uiState.value.isLoading.value = false;
    }
  }

  Future<void> logout(BuildContext context) async {
    uiState.value.isLoading.value = true;
    uiState.value.errorMessage.value = '';
    Loading().loadingShow();

    try {
      final deviceId = AppPref.getDeviceId() ?? '';
      await authUseCase.logout(deviceId: deviceId);
      await AppPref.clearAllData();

      Loading().loadingClose();

      Get.offAllNamed(AppRoutes.signIn);
    } catch (e) {
      Loading().loadingClose();
      uiState.value.errorMessage.value = e.toString();
    } finally {
      uiState.value.isLoading.value = false;
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    uiState.value.isLoading.value = true;
    uiState.value.errorMessage.value = '';
    Loading().loadingShow();

    try {
      final response = await authUseCase.deleteAccount();
      Loading().loadingClose();

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
      Loading().loadingClose();
      uiState.value.errorMessage.value = e.toString();
    } finally {
      uiState.value.isLoading.value = false;
    }
  }
}
