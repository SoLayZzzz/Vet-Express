import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:express_vet/base/endpoint.dart';
import 'package:express_vet/feature/auth/data/model/request/refreshToken_login_request.dart';
import 'package:express_vet/feature/auth/data/model/request/register_request.dart';
import 'package:express_vet/feature/auth/data/model/request/verification_request.dart';
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

  String _resolveUrl(String base, String path) {
    final normalizedBase = base.endsWith('/') ? base : '$base/';
    return Uri.parse(normalizedBase).resolve(path).toString();
  }

  String _maskToken(String token) {
    final t = token.trim();
    if (t.isEmpty) return '';
    if (t.length <= 12) return '***';
    return '${t.substring(0, 6)}...${t.substring(t.length - 6)}';
  }

  Map<String, dynamic> _redactMap(Map<String, dynamic> input) {
    final out = <String, dynamic>{};
    for (final entry in input.entries) {
      final k = entry.key;
      final lower = k.toLowerCase();
      final v = entry.value;
      if (lower.contains('password')) {
        out[k] = v;
      } else if (lower.contains('token') || lower.contains('authorization')) {
        out[k] = v is String ? _maskToken(v) : '***';
      } else {
        out[k] = v;
      }
    }
    return out;
  }

  Map<String, dynamic> _redactDynamicJson(dynamic input) {
    if (input is Map) {
      return _redactMap(
        input.map((k, v) => MapEntry(k.toString(), v)),
      );
    }
    return <String, dynamic>{'data': input};
  }

  Future<LoginResponse> login(LoginRequest request) async {
    final fields = request.toFields();
    final startedAt = DateTime.now();
    if (kDebugMode) {
      debugPrint('========== AUTH LOGIN (REQUEST) ==========');
      debugPrint('url=${_resolveUrl(netWorkDataSource.baseUrl, Endpoint.authLogin)}');
      debugPrint('fields=${jsonEncode(_redactMap(fields.map((k, v) => MapEntry(k, v))))}');
    }
    try {
      final json = await netWorkDataSource.postMultipart(
        Endpoint.authLogin,
        fields: fields,
        attachAuth: false,
        timeout: const Duration(seconds: Constrains.timeout180),
      );
      if (kDebugMode) {
        final ms = DateTime.now().difference(startedAt).inMilliseconds;
        debugPrint('========== AUTH LOGIN (RESPONSE) =========');
        debugPrint('durationMs=$ms');
        debugPrint('json=${jsonEncode(_redactDynamicJson(json))}');
      }
      return LoginResponse.fromJson(json);
    } catch (e) {
      if (kDebugMode) {
        final ms = DateTime.now().difference(startedAt).inMilliseconds;
        debugPrint('========== AUTH LOGIN (ERROR) ===========');
        debugPrint('durationMs=$ms error=$e');
      }
      rethrow;
    }
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

  Future<SimpleResponse> register(RegisterRequest request) async {
    final fields = <String, String>{
      if (request.name != null) 'name': request.name!,
      if (request.password != null) 'password': request.password!,
      if (request.telephone != null) 'telephone': request.telephone!,
      if (request.email != null) 'email': request.email!,
      if (request.dob != null) 'dob': request.dob!,
      if (request.filename != null) 'filename': request.filename!,
      if (request.gender != null) 'gender': request.gender!.toString(),
      if (request.nationalityId != null)
        'nationalityId': request.nationalityId!.toString(),
    };
    final json = await netWorkDataSource.postMultipart(
      Endpoint.userRegister,
      fields: fields,
      attachAuth: false,
      timeout: const Duration(seconds: Constrains.timeout90),
    );
    return SimpleResponse.fromJson(json);
  }

  Future<SimpleResponse> verification(VerificationRequest request) async {
    final json = await netWorkDataSource.postMultipart(
      Endpoint.userVerification,
      fields: request.toJson(),
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

  Future<LoginResponse> loginWithRefreshToken(
    RefreshtokenLoginRequest request,
  ) async {
    final json = await netWorkDataSource.postMultipart(
      Endpoint.authLoginWithRefreshToken,
      fields: request.toFields(),
      attachAuth: false,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return LoginResponse.fromJson(json);
  }
}
