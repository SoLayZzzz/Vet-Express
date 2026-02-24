import 'package:express_vet/feature/auth/data/model/request/verification_request.dart';

import '../../domain/repository/auth_repository.dart';
import '../model/request/login_request.dart';
import '../model/request/register_request.dart';
import '../model/response/check_token_response.dart';
import '../model/response/check_version_response.dart';
import '../model/response/login_response.dart';
import '../model/response/nationality_response.dart';
import '../../../../models/simple_response.dart';
import '../model/response/user_me.dart';
import '../network/auth_network_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthNetworkRequest authNetworkRequest;

  AuthRepositoryImpl(this.authNetworkRequest);

  @override
  Future<LoginResponse> login(LoginRequest request) =>
      authNetworkRequest.login(request);

  @override
  Future<void> logout({required String deviceId}) =>
      authNetworkRequest.logout(deviceId: deviceId);

  @override
  Future<CheckTokenResponse> checkToken() => authNetworkRequest.checkToken();

  @override
  Future<CheckVersionResponse> checkVersion() =>
      authNetworkRequest.checkVersion();

  @override
  Future<SimpleResponse> deleteAccount() => authNetworkRequest.deleteAccount();

  // ===== Delegations for migrated legacy endpoints =====
  @override
  Future<SimpleResponse> register(RegisterRequest request) =>
      authNetworkRequest.register(request);

  @override
  Future<SimpleResponse> verification(VerificationRequest request) =>
      authNetworkRequest.verification(request);

  @override
  Future<SimpleResponse> resendVerification({required String phone}) =>
      authNetworkRequest.resendVerification(phone: phone);

  @override
  Future<SimpleResponse> resetPasswordSendSms({required String phone}) =>
      authNetworkRequest.resetPasswordSendSms(phone: phone);

  @override
  Future<SimpleResponse> resetPasswordVerify({
    required String code,
    required String token,
  }) => authNetworkRequest.resetPasswordVerify(code: code, token: token);

  @override
  Future<SimpleResponse> resendCode({required String token}) =>
      authNetworkRequest.resendCode(token: token);

  @override
  Future<SimpleResponse> newPassword({
    required String newPassword,
    required String token,
  }) => authNetworkRequest.newPassword(newPassword: newPassword, token: token);

  @override
  Future<UserMeResponse> getUserMe() => authNetworkRequest.getUserMe();

  @override
  Future<SimpleResponse> profileUpdate({
    required String name,
    String? telephone,
    String? email,
    String? filename,
    int? gender,
    int? nationalityId,
  }) => authNetworkRequest.profileUpdate(
    name: name,
    telephone: telephone,
    email: email,
    filename: filename,
    gender: gender,
    nationalityId: nationalityId,
  );

  @override
  Future<NationalityResponse> nationalityList() =>
      authNetworkRequest.nationalityList();

  @override
  Future<NationalityResponse> nationalityListTicket() =>
      authNetworkRequest.nationalityListTicket();

  @override
  Future<SimpleResponse> sendOtpForgetPassword({required String phone}) =>
      authNetworkRequest.sendOtpForgetPassword(phone: phone);

  @override
  Future<SimpleResponse> sendOtpRegister({
    required String type,
    required String phone,
  }) => authNetworkRequest.sendOtpRegister(type: type, phone: phone);
}
