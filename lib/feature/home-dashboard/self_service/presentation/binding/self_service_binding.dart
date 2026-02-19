import 'package:get/get.dart';

import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';
import '../../data/network/self_service_network_request.dart';
import '../../data/repo_impl/self_service_repoImpl.dart';
import '../../domain/repository/self_service_repo.dart';
import '../../domain/uscase/self_service_usecase.dart';

import '../controller/self_service_controller.dart';

class SelfServiceBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SelfServiceNetworkRequest>()) {
      Get.lazyPut(
        () => SelfServiceNetworkRequest(
          NetworkDataSource(baseUrl: BaseUrl.BASE_URL),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<SelfServiceRepo>()) {
      Get.lazyPut<SelfServiceRepo>(
        () => SelfServiceRepoimpl(Get.find<SelfServiceNetworkRequest>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<SelfServiceUsecase>()) {
      Get.lazyPut(
        () => SelfServiceUsecase(Get.find<SelfServiceRepo>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<SelfServiceController>()) {
      Get.lazyPut(
        () => SelfServiceController(Get.find<SelfServiceUsecase>()),
        fenix: true,
      );
    }
  }
}
