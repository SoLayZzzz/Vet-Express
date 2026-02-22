import 'package:get/get.dart';

import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';
import '../../data/network/notifications_network_request.dart';
import '../../data/repositoryImpl/notifications_repository_impl.dart';
import '../../domain/repository/notifications_repository.dart';
import '../../domain/uscase/notifications_usecase.dart';
import '../controller/notifications_controller.dart';

class NotificationsBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NotificationsNetworkRequest>()) {
      Get.lazyPut(
        () => NotificationsNetworkRequest(
          NetworkDataSource(baseUrl: BaseUrl.BASE_URL),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<NotificationsRepository>()) {
      Get.lazyPut<NotificationsRepository>(
        () => NotificationsRepositoryImpl(Get.find<NotificationsNetworkRequest>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<NotificationsUseCase>()) {
      Get.lazyPut(
        () => NotificationsUseCase(Get.find<NotificationsRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<NotificationsController>()) {
      Get.lazyPut(
        () => NotificationsController(Get.find<NotificationsUseCase>()),
        fenix: true,
      );
    }
  }
}
