import 'package:get/get.dart';

import '../../controller/menu_controller.dart';

class MenuBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MenuController>()) {
      Get.lazyPut(() => MenuController(), fenix: true);
    }
  }
}
