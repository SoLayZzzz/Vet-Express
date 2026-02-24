import 'package:express_vet/feature/auth/data/model/request/register_request.dart';
import 'package:express_vet/feature/auth/data/model/request/verification_request.dart';

import '../../../../models/simple_response.dart';
import '../../data/model/response/user_me.dart';
import '../../data/model/request/login_request.dart';
import '../../data/model/response/check_token_response.dart';
import '../../data/model/response/check_version_response.dart';
import '../../data/model/response/login_response.dart';
import '../../data/model/response/nationality_response.dart';
import '../repository/auth_repository.dart';

class AuthUseCase {
  final AuthRepository authRepository;

  AuthUseCase(this.authRepository);

  Future<LoginResponse> login(LoginRequest request) =>
      authRepository.login(request);

  Future<void> logout({required String deviceId}) =>
      authRepository.logout(deviceId: deviceId);

  Future<CheckTokenResponse> checkToken() => authRepository.checkToken();

  Future<CheckVersionResponse> checkVersion() => authRepository.checkVersion();

  Future<SimpleResponse> deleteAccount() => authRepository.deleteAccount();

  Future<SimpleResponse> register(RegisterRequest request) =>
      authRepository.register(request);

  Future<SimpleResponse> verification(VerificationRequest request) =>
      authRepository.verification(request);

  Future<SimpleResponse> resendVerification({required String phone}) =>
      authRepository.resendVerification(phone: phone);

  Future<SimpleResponse> resetPasswordSendSms({required String phone}) =>
      authRepository.resetPasswordSendSms(phone: phone);

  Future<SimpleResponse> resetPasswordVerify({
    required String code,
    required String token,
  }) => authRepository.resetPasswordVerify(code: code, token: token);

  Future<SimpleResponse> resendCode({required String token}) =>
      authRepository.resendCode(token: token);

  Future<SimpleResponse> newPassword({
    required String newPassword,
    required String token,
  }) => authRepository.newPassword(newPassword: newPassword, token: token);

  Future<UserMeResponse> getUserMe() => authRepository.getUserMe();

  Future<SimpleResponse> profileUpdate({
    required String name,
    String? telephone,
    String? email,
    String? filename,
    int? gender,
    int? nationalityId,
  }) => authRepository.profileUpdate(
    name: name,
    telephone: telephone,
    email: email,
    filename: filename,
    gender: gender,
    nationalityId: nationalityId,
  );

  Future<NationalityResponse> nationalityList() =>
      authRepository.nationalityList();

  Future<NationalityResponse> nationalityListTicket() =>
      authRepository.nationalityListTicket();

  Future<SimpleResponse> sendOtpForgetPassword({required String phone}) =>
      authRepository.sendOtpForgetPassword(phone: phone);

  Future<SimpleResponse> sendOtpRegister({
    required String type,
    required String phone,
  }) => authRepository.sendOtpRegister(type: type, phone: phone);
}
