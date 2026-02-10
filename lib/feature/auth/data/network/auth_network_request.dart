import 'dart:async';

import 'package:express_vet/base/endpoint.dart';

import '../../../../base/network_data_source.dart';
import '../../../../utils/contains.dart';
import '../../../../models/simple_response.dart';
import '../model/request/login_request.dart';
import '../model/response/check_token_response.dart';
import '../model/response/check_version_response.dart';
import '../model/response/login_response.dart';

class AuthNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  AuthNetworkRequest(this.netWorkDataSource);

  Future<LoginResponse> login(LoginRequest request) async {
    final json = await netWorkDataSource.postMultipart(
      // 'auth/login',
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
}
