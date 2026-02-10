import '../../../../models/simple_response.dart';
import '../../data/model/request/login_request.dart';
import '../../data/model/response/check_token_response.dart';
import '../../data/model/response/check_version_response.dart';
import '../../data/model/response/login_response.dart';
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
}
