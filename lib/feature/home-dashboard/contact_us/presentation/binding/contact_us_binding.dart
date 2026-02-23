import 'package:get/get.dart';

import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';
import '../../data/network/contact_us_network_request.dart';
import '../../data/repositoryImpl/contact_us_repository_impl.dart';
import '../../domain/repository/contact_us_repository.dart';
import '../../domain/uscase/contact_us_usecase.dart';
import '../controller/contact_us_controller.dart';

class ContactUsBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ContactUsNetworkRequest>()) {
      Get.lazyPut(
        () => ContactUsNetworkRequest(
          NetworkDataSource(baseUrl: BaseUrl.BASE_URL),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ContactUsRepository>()) {
      Get.lazyPut<ContactUsRepository>(
        () => ContactUsRepositoryImpl(Get.find<ContactUsNetworkRequest>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ContactUsUseCase>()) {
      Get.lazyPut(
        () => ContactUsUseCase(Get.find<ContactUsRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ContactUsController>()) {
      Get.lazyPut(
        () => ContactUsController(Get.find<ContactUsUseCase>()),
        fenix: true,
      );
    }
  }
}
