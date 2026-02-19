import 'package:get/get.dart';

import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';
import '../../../../home-dashboard/schedule/data/network/schedule_network_request.dart';
import '../../data/network/rate_schedule_network_request.dart';
import '../controller/rate_schedule_controller.dart';

class RateScheduleBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ScheduleNetworkRequest>()) {
      Get.lazyPut(
        () => ScheduleNetworkRequest(
          NetworkDataSource(baseUrl: BaseUrl.BASE_URL_TICKET),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<RateScheduleNetworkRequest>()) {
      Get.lazyPut(
        () => RateScheduleNetworkRequest(
          NetworkDataSource(baseUrl: BaseUrl.BASE_URL),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<RateScheduleController>()) {
      Get.lazyPut(
        () => RateScheduleController(
          Get.find<ScheduleNetworkRequest>(),
          Get.find<RateScheduleNetworkRequest>(),
        ),
        fenix: true,
      );
    }
  }
}
