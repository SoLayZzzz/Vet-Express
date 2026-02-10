import 'package:get/get.dart';

import '../../../../base/network_data_source.dart';
import '../../data/network/auth_network_request.dart';
import '../../data/repo_Impl/auth_repository_impl.dart';
import '../../domain/uscase/auth_usecase.dart';
import '../controller/auth_controller.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthNetworkRequest>()) {
      Get.lazyPut(
        () => AuthNetworkRequest(Get.find<NetworkDataSource>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<AuthRepositoryImpl>()) {
      Get.lazyPut(
        () => AuthRepositoryImpl(Get.find<AuthNetworkRequest>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<AuthUseCase>()) {
      Get.lazyPut(
        () => AuthUseCase(Get.find<AuthRepositoryImpl>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut(() => AuthController(Get.find<AuthUseCase>()), fenix: true);
    }
  }
}
