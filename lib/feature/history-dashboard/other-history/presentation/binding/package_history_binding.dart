import 'package:get/get.dart';

import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';
import '../../data/network/package_history_network_request.dart';
import '../../data/repositoryImpl/package_history_repository_impl.dart';
import '../../domain/repository/package_history_repository.dart';
import '../../domain/uscase/package_history_usecase.dart';
import '../controller/package_history_controller.dart';

class PackageHistoryBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PackageHistoryNetworkRequest>()) {
      Get.lazyPut(
        () => PackageHistoryNetworkRequest(
          NetworkDataSource(baseUrl: BaseUrl.BASE_URL_TICKET),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<PackageHistoryRepository>()) {
      Get.lazyPut<PackageHistoryRepository>(
        () => PackageHistoryRepositoryImpl(Get.find<PackageHistoryNetworkRequest>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<PackageHistoryUseCase>()) {
      Get.lazyPut(
        () => PackageHistoryUseCase(Get.find<PackageHistoryRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<PackageHistoryController>()) {
      Get.lazyPut(
        () => PackageHistoryController(Get.find<PackageHistoryUseCase>()),
        fenix: true,
      );
    }
  }
}
