import 'package:get/get.dart';

import 'base/network_data_source.dart';
import 'controller/user_controller.dart';
import 'controller/connectivity_controller.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserController(Get.find()), fenix: true);

    Get.lazyPut(() => NetworkDataSource(), fenix: true);

    if (!Get.isRegistered<ConnectivityController>()) {
      Get.put(ConnectivityController(), permanent: true);
    }
  }
}

