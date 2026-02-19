import 'package:get/get.dart';

import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';
import '../../data/network/goods_transfer_history_network_request.dart';
import '../../data/repositoryImpl/goods_transfer_history_repository_impl.dart';
import '../../domain/repository/goods_transfer_history_repository.dart';
import '../../domain/uscase/goods_transfer_history_usecase.dart';
import '../controller/goods_transfer_history_controller.dart';

class GoodsTransferHistoryBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GoodsTransferHistoryNetworkRequest>()) {
      Get.lazyPut(
        () => GoodsTransferHistoryNetworkRequest(
          NetworkDataSource(baseUrl: BaseUrl.BASE_URL),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<GoodsTransferHistoryRepository>()) {
      Get.lazyPut<GoodsTransferHistoryRepository>(
        () => GoodsTransferHistoryRepositoryImpl(
          Get.find<GoodsTransferHistoryNetworkRequest>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<GoodsTransferHistoryUseCase>()) {
      Get.lazyPut(
        () => GoodsTransferHistoryUseCase(
          Get.find<GoodsTransferHistoryRepository>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<GoodsTransferHistoryController>()) {
      Get.lazyPut(
        () => GoodsTransferHistoryController(
          Get.find<GoodsTransferHistoryUseCase>(),
        ),
        fenix: true,
      );
    }
  }
}
