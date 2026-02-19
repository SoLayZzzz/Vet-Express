import 'package:get/get.dart';

import 'base/network_data_source.dart';
import 'controller/user_controller.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserController(), fenix: true);

    Get.lazyPut(() => NetworkDataSource(), fenix: true);
  }
}
