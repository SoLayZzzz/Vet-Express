import '../../data/model/request/login_request.dart';
import '../../data/model/response/check_token_response.dart';
import '../../data/model/response/check_version_response.dart';
import '../../data/model/response/login_response.dart';
import '../../../../models/simple_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(LoginRequest request);

  Future<void> logout({required String deviceId});

  Future<CheckTokenResponse> checkToken();

  Future<CheckVersionResponse> checkVersion();

  Future<SimpleResponse> deleteAccount();
}
