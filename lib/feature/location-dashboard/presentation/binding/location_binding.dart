import 'package:express_vet/feature/location-dashboard/data/network/location_network_request.dart';
import 'package:express_vet/feature/location-dashboard/data/repo_impl/location_repository_impl.dart';
import 'package:express_vet/feature/location-dashboard/domain/repository/location_repository.dart';
import 'package:express_vet/feature/location-dashboard/domain/uscase/location_usecase.dart';
import 'package:express_vet/feature/location-dashboard/presentation/controller/location_controller.dart';
import 'package:get/get.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationNetworkRequest>(() => LocationNetworkRequest());
    Get.lazyPut<LocationRepository>(() => LocationRepositoryImpl(Get.find()));
    Get.lazyPut<LocationUseCase>(() => LocationUseCase(Get.find()));
    Get.lazyPut<LocationController>(() => LocationController(Get.find()));
  }
}
