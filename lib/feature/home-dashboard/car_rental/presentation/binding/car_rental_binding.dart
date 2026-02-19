import 'package:get/get.dart';

import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';
import '../../data/network/car_rental_network_request.dart';
import '../../data/repositoryImpl/car_rental_repository_impl.dart';
import '../../domain/repository/car_rental_repository.dart';
import '../../domain/uscase/car_rental_usecase.dart';
import '../controller/car_rental_controller.dart';

class CarRentalBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CarRentalNetworkRequest>()) {
      Get.lazyPut(
        () => CarRentalNetworkRequest(
          NetworkDataSource(baseUrl: BaseUrl.BASE_URL),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<CarRentalRepository>()) {
      Get.lazyPut<CarRentalRepository>(
        () => CarRentalRepositoryImpl(Get.find<CarRentalNetworkRequest>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<CarRentalUseCase>()) {
      Get.lazyPut(
        () => CarRentalUseCase(Get.find<CarRentalRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<CarRentalController>()) {
      Get.lazyPut(
        () => CarRentalController(Get.find<CarRentalUseCase>()),
        fenix: true,
      );
    }
  }
}
