import '../../domain/repository/auth_repository.dart';
import '../model/request/login_request.dart';
import '../model/response/check_token_response.dart';
import '../model/response/check_version_response.dart';
import '../model/response/login_response.dart';
import '../../../../models/simple_response.dart';
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
}
