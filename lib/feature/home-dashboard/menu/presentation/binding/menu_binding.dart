import 'package:get/get.dart';

import '../../../../../base/network_data_source.dart';
import '../../data/network/menu_network_request.dart';
import '../../data/repo_Impl/menu_repository_impl.dart';
import '../../domain/uscase/menu_usecase.dart';
import '../controller/menu_controller.dart';

class MenuBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MenuNetworkRequest>()) {
      Get.lazyPut(
        () => MenuNetworkRequest(Get.find<NetworkDataSource>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<MenuRepositoryImpl>()) {
      Get.lazyPut(
        () => MenuRepositoryImpl(Get.find<MenuNetworkRequest>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<MenuUseCase>()) {
      Get.lazyPut(
        () => MenuUseCase(Get.find<MenuRepositoryImpl>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<MenuController>()) {
      Get.lazyPut(() => MenuController(Get.find<MenuUseCase>()), fenix: true);
    }
  }
}
