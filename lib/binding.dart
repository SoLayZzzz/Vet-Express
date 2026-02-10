import 'package:get/get.dart';

import 'base/network_data_source.dart';
import 'controller/ev/ev_contact_controller.dart';
import 'controller/ev/ev_news_feed_controller.dart';
import 'controller/ev/ev_slide_show_controller.dart';
import 'controller/ev/ev_wallet_controller.dart';
import 'controller/user_controller.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserController(), fenix: true);

    Get.lazyPut(() => NetworkDataSource(), fenix: true);

    Get.lazyPut(() => EvContactController(), fenix: true);
    Get.lazyPut(() => EvSlideshowController(), fenix: true);
    Get.lazyPut(() => EvNewsFeedController(), fenix: true);
    Get.lazyPut(() => EvWalletController(), fenix: true);
  }
}
