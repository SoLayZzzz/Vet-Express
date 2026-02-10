import 'package:get/get.dart';

import '../api/user.dart';
import '../models/user/user_me.dart';

class UserController extends GetxController {
  var userMeResponse = Rxn<UserMeResponse>();
  var isLoading = true.obs;
  var hasError = false.obs;

  @override
  void onInit() {
    fetchUserMe();
    super.onInit();
  }

  Future<void> fetchUserMe() async {
    try {
      isLoading(true);
      hasError(false);

      var response = await User().getUserMe(Get.context!);
      userMeResponse.value = response;
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
  String get nationalityName => userMeResponse.value?.body?.nationalityName ?? '';
  int get nationalityId => userMeResponse.value?.body?.nationalityId ?? 0;

  /// Optional: clear data (e.g. on logout)
  void clearUserData() {
    userMeResponse.value = null;
  }
}
