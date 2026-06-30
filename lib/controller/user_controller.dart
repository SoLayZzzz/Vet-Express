import 'package:get/get.dart';

import '../feature/auth/data/model/response/user_me.dart';
import '../feature/auth/domain/uscase/auth_usecase.dart';

class UserController extends GetxController {
  final AuthUseCase authUseCase;

  UserController(this.authUseCase);

  var userMeResponse = Rxn<UserMeResponse>();
  var isLoading = true.obs;
  var hasError = false.obs;
  var profileRefreshToken = 0.obs;

  @override
  void onInit() {
    fetchUserMe();
    super.onInit();
  }

  Future<void> fetchUserMe() async {
    try {
      isLoading(true);
      hasError(false);
      var response = await authUseCase.getUserMe();
      userMeResponse.value = response;
      profileRefreshToken.value++;
    } catch (e) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  /// ✅ Helper getters to access user info easily
  String get username => userMeResponse.value?.body?.username ?? '';
  String get phone => userMeResponse.value?.body?.telephone ?? '';
  String get email => userMeResponse.value?.body?.email ?? '';
  String get dob => userMeResponse.value?.body?.dob ?? '';
  int get gender => userMeResponse.value?.body?.gender ?? 0;
  String get nationalityName =>
      userMeResponse.value?.body?.nationalityName ?? '';
  int get nationalityId => userMeResponse.value?.body?.nationalityId ?? 0;

  /// Optional: clear data (e.g. on logout)
  void clearUserData() {
    userMeResponse.value = null;
    isLoading(false);
    hasError(false);
    profileRefreshToken.value++;
  }
}
