import 'package:get/get.dart';
import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';
import '../../data/network/china_service_network_request.dart';
import '../../data/repositoryImpl/china_service_repository_impl.dart';
import '../../domain/repository/china_service_repository.dart';
import '../../domain/uscase/china_service_usecase.dart';
import '../controller/china_controller.dart';

class ChinaServiceBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ChinaServiceNetworkRequest>()) {
      Get.lazyPut(
        () => ChinaServiceNetworkRequest(
          NetworkDataSource(baseUrl: BaseUrl.BASE_URL),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ChinaServiceRepository>()) {
      Get.lazyPut<ChinaServiceRepository>(
        () =>
            ChinaServiceRepositoryImpl(Get.find<ChinaServiceNetworkRequest>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ChinaServiceUseCase>()) {
      Get.lazyPut(
        () => ChinaServiceUseCase(Get.find<ChinaServiceRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ChinaController>()) {
      Get.lazyPut(
        () => ChinaController(Get.find<ChinaServiceUseCase>()),
        fenix: true,
      );
    }
  }
}
