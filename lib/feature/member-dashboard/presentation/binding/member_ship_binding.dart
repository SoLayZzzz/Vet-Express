import 'package:get/get.dart';

import '../../../../base/network_data_source.dart';
import '../../data/network/member_ship_network_request.dart';
import '../../data/repositoryImpl/member_ship_repository_impl.dart';
import '../../domain/repository/member_ship_repository.dart';
import '../../domain/uscase/member_ship_usecase.dart';
import '../controller/member_ship_controller.dart';

class MemberShipBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MemberShipNetworkRequest>()) {
      Get.lazyPut(
        () => MemberShipNetworkRequest(Get.find<NetworkDataSource>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<MemberShipRepository>()) {
      Get.lazyPut<MemberShipRepository>(
        () => MemberShipRepositoryImpl(Get.find<MemberShipNetworkRequest>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<MemberShipUseCase>()) {
      Get.lazyPut(
        () => MemberShipUseCase(Get.find<MemberShipRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<MemberShipController>()) {
      Get.lazyPut(
        () => MemberShipController(Get.find<MemberShipUseCase>()),
        fenix: true,
      );
    }
  }
}
