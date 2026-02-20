import '../../data/model/request/login_request.dart';
import '../../data/model/response/check_token_response.dart';
import '../../data/model/response/check_version_response.dart';
import '../../data/model/response/login_response.dart';
import '../../data/model/response/nationality_response.dart';
import '../../data/model/response/user_me.dart';
import '../../../../models/simple_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(LoginRequest request);

  Future<void> logout({required String deviceId});

  Future<CheckTokenResponse> checkToken();

  Future<CheckVersionResponse> checkVersion();

  Future<SimpleResponse> deleteAccount();

  // Migrated endpoints from legacy api/user.dart
  Future<SimpleResponse> register({
    required String name,
    required String password,
    required String telephone,
    String? email,
    String? dob,
    String? filename,
    int? gender,
    int? nationalityId,
  });

  Future<SimpleResponse> verification({
    required String code,
    required String deviceId,
    required String deviceName,
    required String token,
  });

  Future<SimpleResponse> resendVerification({required String phone});

  Future<SimpleResponse> resetPasswordSendSms({required String phone});

  Future<SimpleResponse> resetPasswordVerify({
    required String code,
    required String token,
  });

  Future<SimpleResponse> resendCode({required String token});

  Future<SimpleResponse> newPassword({
    required String newPassword,
    required String token,
  });

  Future<UserMeResponse> getUserMe();

  Future<SimpleResponse> profileUpdate({
    required String name,
    String? telephone,
    String? email,
    String? filename,
    int? gender,
    int? nationalityId,
  });

  Future<NationalityResponse> nationalityList();

  Future<NationalityResponse> nationalityListTicket();

  Future<SimpleResponse> sendOtpForgetPassword({required String phone});

  Future<SimpleResponse> sendOtpRegister({
    required String type,
    required String phone,
  });
}
