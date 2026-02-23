import 'dart:async';
import 'dart:developer';

import 'package:express_vet/base/endpoint.dart';

import '../../../../base/network_data_source.dart';
import '../../../../base/base_url.dart';
import '../../../../utils/contains.dart';
import '../../../../models/simple_response.dart';
import '../model/response/user_me.dart';
import '../model/response/nationality_response.dart';
import '../model/request/login_request.dart';
import '../model/response/check_token_response.dart';
import '../model/response/check_version_response.dart';
import '../model/response/login_response.dart';

class AuthNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  AuthNetworkRequest(this.netWorkDataSource);

  Future<LoginResponse> login(LoginRequest request) async {
    final json = await netWorkDataSource.postMultipart(
      Endpoint.authLogin,
      fields: request.toFields(),
      attachAuth: false,
      timeout: const Duration(seconds: Constrains.timeout180),
    );

    return LoginResponse.fromJson(json);
  }

  Future<void> logout({required String deviceId}) async {
    await netWorkDataSource.postMultipart(
      Endpoint.authLogout,
      fields: {'deviceId': deviceId},
      attachAuth: true,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
  }

  Future<CheckTokenResponse> checkToken() async {
    final json = await netWorkDataSource.postJson(
      Endpoint.authCheckToken,
      body: null,
      attachAuth: true,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return CheckTokenResponse.fromJson(json);
  }

  Future<CheckVersionResponse> checkVersion() async {
    final json = await netWorkDataSource.postJson(
      Endpoint.authCheckVersion,
      body: null,
      attachAuth: false,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return CheckVersionResponse.fromJson(json);
  }

  Future<SimpleResponse> deleteAccount() async {
    final json = await netWorkDataSource.postJson(
      Endpoint.authDeleteAccount,
      body: null,
      attachAuth: true,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return SimpleResponse.fromJson(json);
  }

  // ===== Migrated legacy api/user.dart methods =====

  Future<SimpleResponse> register({
    required String name,
    required String password,
    required String telephone,
    String? email,
    String? dob,
    String? filename,
    int? gender,
    int? nationalityId,
  }) async {
    final fields = <String, String>{
      'name': name,
      'password': password,
      'telephone': telephone,
      if (email != null) 'email': email,
      if (dob != null) 'dob': dob,
      if (filename != null) 'filename': filename,
      if (gender != null) 'gender': gender.toString(),
      if (nationalityId != null) 'nationalityId': nationalityId.toString(),
    };
    final json = await netWorkDataSource.postMultipart(
      Endpoint.userRegister,
      fields: fields,
      attachAuth: false,
      timeout: const Duration(seconds: Constrains.timeout90),
    );
    return SimpleResponse.fromJson(json);
  }

  Future<SimpleResponse> verification({
    required String code,
    required String deviceId,
    required String deviceName,
    required String token,
  }) async {
    final json = await netWorkDataSource.postMultipart(
      Endpoint.userVerification,
      fields: {
        'code': code,
        'deviceId': deviceId,
        'deviceName': deviceName,
        'token': token,
      },
      attachAuth: false,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return SimpleResponse.fromJson(json);
  }

  Future<SimpleResponse> resendVerification({required String phone}) async {
    final json = await netWorkDataSource.postMultipart(
      Endpoint.userResendCodeVerify,
      fields: {'phone': phone},
      attachAuth: false,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return SimpleResponse.fromJson(json);
  }

  Future<SimpleResponse> resetPasswordSendSms({required String phone}) async {
    final json = await netWorkDataSource.postMultipart(
      Endpoint.userResetPasswordSendSms,
      fields: {'phone': phone},
      attachAuth: false,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return SimpleResponse.fromJson(json);
  }

  Future<SimpleResponse> resetPasswordVerify({
    required String code,
    required String token,
  }) async {
    final json = await netWorkDataSource.postMultipart(
      Endpoint.userResetPassword,
      fields: {'code': code, 'token': token},
      attachAuth: false,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return SimpleResponse.fromJson(json);
  }

  Future<SimpleResponse> resendCode({required String token}) async {
    final json = await netWorkDataSource.postMultipart(
      Endpoint.userResendCode,
      fields: {'token': token},
      attachAuth: false,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return SimpleResponse.fromJson(json);
  }

  Future<SimpleResponse> newPassword({
    required String newPassword,
    required String token,
  }) async {
    final json = await netWorkDataSource.postMultipart(
      Endpoint.userNewPassword,
      fields: {'newPassword': newPassword, 'token': token},
      attachAuth: false,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return SimpleResponse.fromJson(json);
  }

  Future<UserMeResponse> getUserMe() async {
    final json = await netWorkDataSource.postJson(
      Endpoint.userMe,
      body: null,
      attachAuth: true,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return UserMeResponse.fromJson(json);
  }

  Future<SimpleResponse> profileUpdate({
    required String name,
    String? telephone,
    String? email,
    String? filename,
    int? gender,
    int? nationalityId,
  }) async {
    final fields = <String, String>{
      'name': name,
      if (telephone != null) 'telephone': telephone,
      if (gender != null) 'gender': gender.toString(),
      if (nationalityId != null) 'nationalityId': nationalityId.toString(),
      if (email != null) 'email': email,
      if (filename != null) 'filename': filename,
    };
    final json = await netWorkDataSource.postMultipart(
      Endpoint.userUpdate,
      fields: fields,
      attachAuth: true,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return SimpleResponse.fromJson(json);
  }

  Future<NationalityResponse> nationalityList() async {
    final json = await netWorkDataSource.postJson(
      Endpoint.userNationalityList,
      body: null,
      attachAuth: false,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return NationalityResponse.fromJson(json);
  }

  Future<NationalityResponse> nationalityListTicket() async {
    final ds = NetworkDataSource(baseUrl: BaseUrl.BASE_URL_TICKET);
    final json = await ds.postJson(
      Endpoint.ticketUserNationalityList,
      body: null,
      attachAuth: false,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return NationalityResponse.fromJson(json);
  }

  Future<SimpleResponse> sendOtpForgetPassword({required String phone}) async {
    final json = await netWorkDataSource.postMultipart(
      Endpoint.userSendOtpForgetPassword,
      fields: {'phone': phone, 'type': '2'},
      attachAuth: false,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return SimpleResponse.fromJson(json);
  }

  Future<SimpleResponse> sendOtpRegister({
    required String type,
    required String phone,
  }) async {
    final json = await netWorkDataSource.postMultipart(
      Endpoint.userSendOtpRegister,
      fields: {'phone': phone, 'type': type},
      attachAuth: false,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return SimpleResponse.fromJson(json);
  }
}
