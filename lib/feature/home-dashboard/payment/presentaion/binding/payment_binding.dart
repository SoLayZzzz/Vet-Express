import 'package:get/get.dart';

import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';
import '../../data/network/payment_network_request.dart';
import '../../data/repo_impl/payment_repositoryImpl.dart';
import '../../domain/repository/payment_repository.dart';
import '../../domain/uscase/payment_uscase.dart';
import '../controller/payment_controller.dart';

class PaymentBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PaymentNetworkRequest>()) {
      Get.lazyPut(
        () => PaymentNetworkRequest(
          paymentApi: NetworkDataSource(baseUrl: BaseUrl.PAYMENT_URL),
          ticketApi: NetworkDataSource(baseUrl: BaseUrl.BASE_URL_TICKET),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<PaymentRepository>()) {
      Get.lazyPut<PaymentRepository>(
        () => PaymentRepositoryImpl(Get.find<PaymentNetworkRequest>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<PaymentUscase>()) {
      Get.lazyPut(
        () => PaymentUscase(Get.find<PaymentRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<PaymentController>()) {
      Get.lazyPut(
        () => PaymentController(Get.find<PaymentUscase>()),
        fenix: true,
      );
    }
  }
}
