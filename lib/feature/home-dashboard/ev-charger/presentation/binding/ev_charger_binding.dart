import 'package:get/get.dart';

import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';
import '../../data/network/ev_charger_network_request.dart';
import '../../data/repositoryImpl/ev_charger_repository_impl.dart';
import '../../domain/repository/ev_charger_repository.dart';
import '../../domain/uscase/ev_charger_usecase.dart';
import '../controller/ev_charger_controller.dart';

class EvChargerBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<EvChargerNetworkRequest>()) {
      Get.lazyPut(
        () => EvChargerNetworkRequest(
          ticketDataSource: NetworkDataSource(baseUrl: BaseUrl.BASE_URL_TICKET),
          evDataSource: NetworkDataSource(baseUrl: BaseUrl.BASE_URL_EV),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<EvChargerRepository>()) {
      Get.lazyPut<EvChargerRepository>(
        () => EvChargerRepositoryImpl(Get.find<EvChargerNetworkRequest>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<EvChargerUseCase>()) {
      Get.lazyPut(
        () => EvChargerUseCase(Get.find<EvChargerRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<EvChargerController>()) {
      Get.lazyPut(() => EvChargerController(), fenix: true);
    }
  }
}
