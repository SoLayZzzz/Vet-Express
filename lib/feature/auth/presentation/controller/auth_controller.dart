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
import '../../data/model/response/nationality_response.dart';
import '../../data/model/request/login_request.dart';
import '../../domain/uscase/auth_usecase.dart';
import '../uiState/auth_ui_state.dart';
import '../../../../routes/app_routes.dart';
import '../screen/verify_code_screen.dart';
import '../screen/new_password_screen.dart';

class AuthController extends StateController<AuthUiState> {
  final AuthUseCase authUseCase;

  AuthController(this.authUseCase);

  final signInFormKey = GlobalKey<FormState>();
  final signUpFormKey = GlobalKey<FormState>();

  late TextEditingController signInPhoneController;
  late TextEditingController signInPasswordController;

  late TextEditingController signUpUsernameController;
  late TextEditingController signUpPhoneController;
  late TextEditingController signUpPasswordController;
  late TextEditingController signUpRePasswordController;
  late TextEditingController signUpEmailController;
  late TextEditingController signUpDateOfBirthController;
  late TextEditingController signUpNationalitySearchController;

  final forgotPasswordFormKey = GlobalKey<FormState>();
  late TextEditingController forgotPasswordPhoneController;

  final createNewPasswordFormKey = GlobalKey<FormState>();
  late TextEditingController createNewPasswordController;
  late TextEditingController createNewRePasswordController;

  Future<NationalityResponse>? nationalityFuture;

  @override
  AuthUiState onInitUiState() => const AuthUiState();

  @override
  void onInit() {
    super.onInit();
    // Initialize all text controllers here to ensure fresh instances after DI recreation
    signInPhoneController = TextEditingController();
    signInPasswordController = TextEditingController();

    signUpUsernameController = TextEditingController();
    signUpPhoneController = TextEditingController();
    signUpPasswordController = TextEditingController();
    signUpRePasswordController = TextEditingController();
    signUpEmailController = TextEditingController();
    signUpDateOfBirthController = TextEditingController();
    signUpNationalitySearchController = TextEditingController();

    forgotPasswordPhoneController = TextEditingController();

    createNewPasswordController = TextEditingController();
    createNewRePasswordController = TextEditingController();
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
    Loading().loadingShow(context);
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
      Loading().loadingClose(context);
      if (res.header?.result == true && res.header?.statusCode == 200) {
        if (res.body?.status == true) {
          final token = res.body?.message?.toString() ?? '';
          Get.to(
            () => VerifyCodeScreen(identify: 1, token: token, phone: telephone),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: Constrains.duration),
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
        context,
      ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
    } catch (e) {
      Loading().loadingClose(context);
      uiState.value = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> _verification(
    BuildContext context, {
    required String code,
    required String deviceId,
    required String deviceName,
    required String token,
  }) async {
    Loading().loadingShow(context);
    try {
      final res = await authUseCase.verification(
        code: code,
        deviceId: deviceId,
        deviceName: deviceName,
        token: token,
      );
      Loading().loadingClose(context);
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
      Loading().loadingClose(context);
      uiState.value = state.copyWith(errorMessage: e.toString());
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
    Loading().loadingShow(context);
    try {
      final res = await authUseCase.resetPasswordVerify(
        code: code,
        token: token,
      );
      Loading().loadingClose(context);
      if (res.header?.result == true && res.header?.statusCode == 200) {
        if (res.body?.status == true) {
          final newToken = res.body?.message?.toString() ?? '';
          Get.off(() => CreateNewPasswordScreen(token: newToken));
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
        context,
      ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
    } catch (e) {
      Loading().loadingClose(context);
      uiState.value = state.copyWith(errorMessage: e.toString());
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
    Loading().loadingShow(context);
    try {
      final res = await authUseCase.newPassword(
        newPassword: password,
        token: token,
      );
      Loading().loadingClose(context);
      if (res.header?.result == true && res.header?.statusCode == 200) {
        if (res.body?.status == true) {
          Get.offAllNamed(AppRoutes.signIn);
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
      }
    } catch (e) {
      Loading().loadingClose(context);
    }
  }

  Future<void> _forgotPassword(BuildContext context, String phone) async {
    Loading().loadingShow(context);
    try {
      final res = await authUseCase.resetPasswordSendSms(phone: phone);
      Loading().loadingClose(context);
      if (res.header?.result == true && res.header?.statusCode == 200) {
        if (res.body?.status == true) {
          final token = res.body?.message?.toString() ?? '';
          Get.to(
            () => VerifyCodeScreen(identify: 2, token: token, phone: phone),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: Constrains.duration),
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
        context,
      ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
    } catch (e) {
      Loading().loadingClose(context);
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
    final valid = forgotPasswordFormKey.currentState?.validate() ?? false;
    if (!valid) return;
    _forgotPassword(context, forgotPasswordPhoneController.text);
  }

  void toggleCreateNewPasswordVisibility() {
    uiState.value = state.copyWith(
      newPasswordVisible: !state.newPasswordVisible,
    );
  }

  void toggleCreateNewRePasswordVisibility() {
    uiState.value = state.copyWith(
      newRePasswordVisible: !state.newRePasswordVisible,
    );
  }

  void submitCreateNewPassword(BuildContext context, {required String token}) {
    final valid = createNewPasswordFormKey.currentState?.validate() ?? false;
    if (!valid) return;
    _createNewPassword(context, createNewPasswordController.text, token);
  }

  void setVerifyIdentify(int identify) {
    uiState.value = state.copyWith(verifyIdentify: identify);
  }

  void setVerifyTimeExpired(bool expired) {
    uiState.value = state.copyWith(verifyTimeExpired: expired);
  }

  void markVerifyResent() {
    uiState.value = state.copyWith(
      verifyResend: true,
      verifyTimeExpired: false,
    );
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
    final nextCount = state.verifyCountResend + 1;
    uiState.value = state.copyWith(verifyCountResend: nextCount);

    if (nextCount == 2) {
      uiState.value = state.copyWith(verifyCountResend: 0);
      return;
    }

    if (identify == 1) {
      await _resendVerification(context, phone: phone);
    } else if (identify == 2) {
      await _resendCode(context, token: token);
    } else if (identify == 3) {
      await _sendOtpForgetPassword(context, phone: phone);
      Navigator.pop(context);
    } else {
      await _sendOtpRegister(context, type: '2', phone: phone);
      Navigator.pop(context);
    }

    markVerifyResent();
  }

  @override
  void onClose() {
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
    nationalityFuture ??= authUseCase.nationalityList();
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
