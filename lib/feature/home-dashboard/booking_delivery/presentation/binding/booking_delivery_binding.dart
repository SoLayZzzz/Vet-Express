import 'package:get/get.dart';

import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';
import '../../data/network/booking_delivery_network_request.dart';
import '../../data/repositoryImpl/booking_delivery_repository_impl.dart';
import '../../domain/repository/booking_delivery_repository.dart';
import '../../domain/uscase/booking_delivery_usecase.dart';
import '../controller/booking_delivery_controller.dart';

class BookingDeliveryBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<BookingDeliveryNetworkRequest>()) {
      Get.lazyPut(
        () => BookingDeliveryNetworkRequest(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<BookingDeliveryRepository>()) {
      Get.lazyPut<BookingDeliveryRepository>(
        () => BookingDeliveryRepositoryImpl(Get.find<BookingDeliveryNetworkRequest>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<BookingDeliveryUseCase>()) {
      Get.lazyPut(
        () => BookingDeliveryUseCase(Get.find<BookingDeliveryRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<BookingDeliveryController>()) {
      Get.lazyPut(
        () => BookingDeliveryController(Get.find<BookingDeliveryUseCase>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<NetworkDataSource>()) {
      Get.lazyPut(
        () => NetworkDataSource(baseUrl: BaseUrl.BASE_URL),
        fenix: true,
      );
    }
  }
}
