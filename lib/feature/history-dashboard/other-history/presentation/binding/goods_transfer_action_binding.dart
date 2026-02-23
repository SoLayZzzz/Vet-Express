import 'package:get/get.dart';

import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';
import '../../data/network/goods_transfer_action_network_request.dart';
import '../../data/repositoryImpl/goods_transfer_action_repository_impl.dart';
import '../../domain/repository/goods_transfer_action_repository.dart';
import '../../domain/uscase/goods_transfer_action_usecase.dart';
import '../controller/goods_transfer_action_controller.dart';

class GoodsTransferActionBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GoodsTransferActionNetworkRequest>()) {
      Get.lazyPut(
        () => GoodsTransferActionNetworkRequest(
          NetworkDataSource(baseUrl: BaseUrl.BASE_URL),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<GoodsTransferActionRepository>()) {
      Get.lazyPut<GoodsTransferActionRepository>(
        () => GoodsTransferActionRepositoryImpl(
          Get.find<GoodsTransferActionNetworkRequest>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<GoodsTransferActionUseCase>()) {
      Get.lazyPut(
        () => GoodsTransferActionUseCase(
          Get.find<GoodsTransferActionRepository>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<GoodsTransferActionController>()) {
      Get.lazyPut(
        () => GoodsTransferActionController(
          Get.find<GoodsTransferActionUseCase>(),
        ),
        fenix: true,
      );
    }
  }
}
