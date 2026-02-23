import 'package:get/get.dart';

import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';
import '../../data/network/resort_network_request.dart';
import '../../data/repositoryImpl/resort_repository_impl.dart';
import '../../domain/repository/resort_repository.dart';
import '../../domain/uscase/resort_usecase.dart';
import '../controller/resort_controller.dart';

class ResortBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ResortNetworkRequest>()) {
      Get.lazyPut(
        () => ResortNetworkRequest(
          NetworkDataSource(baseUrl: BaseUrl.BASE_URL_TICKET),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ResortRepository>()) {
      Get.lazyPut<ResortRepository>(
        () => ResortRepositoryImpl(Get.find<ResortNetworkRequest>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ResortUseCase>()) {
      Get.lazyPut(
        () => ResortUseCase(Get.find<ResortRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ResortController>()) {
      Get.lazyPut(
        () => ResortController(Get.find<ResortUseCase>()),
        fenix: true,
      );
    }
  }
}
