import 'package:express_vet/feature/passenger/presentation/controller/passenger_deatail_controller.dart';
import 'package:get/get.dart';

import '../../../../base/base_url.dart';
import '../../../../base/network_data_source.dart';
import '../../data/network/passenger_network_request.dart';
import '../../data/repositoryImpl/passenger_repository_impl.dart';
import '../../domain/repository/passenger_repository.dart';
import '../../domain/uscase/passernger_uscase.dart';

class PassengerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PassengerNetworkRequest>()) {
      Get.lazyPut(
        () => PassengerNetworkRequest(
          networkDataSource: NetworkDataSource(
            baseUrl: BaseUrl.BASE_URL_TICKET,
          ),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<PassengerRepository>()) {
      Get.lazyPut<PassengerRepository>(
        () => PassengerRepositoryImpl(Get.find<PassengerNetworkRequest>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<PasserngerUscase>()) {
      Get.lazyPut(
        () => PasserngerUscase(Get.find<PassengerRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<PassengerDetailController>()) {
      Get.lazyPut(
        () => PassengerDetailController(Get.find<PasserngerUscase>()),
        fenix: true,
      );
    }
  }
}
