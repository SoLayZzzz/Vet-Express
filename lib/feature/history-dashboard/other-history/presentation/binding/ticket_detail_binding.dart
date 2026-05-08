import 'package:get/get.dart';

import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';
import '../../data/network/ticket_history_network_request.dart';
import '../../data/repositoryImpl/ticket_history_repository_impl.dart';
import '../../domain/repository/ticket_history_repository.dart';
import '../../domain/uscase/ticket_history_usecase.dart';
import '../controller/ticket_detail_controller.dart';

class TicketDetailBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TicketHistoryNetworkRequest>()) {
      Get.lazyPut(
        () => TicketHistoryNetworkRequest(
          NetworkDataSource(baseUrl: BaseUrl.BASE_URL_TICKET),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<TicketHistoryRepository>()) {
      Get.lazyPut<TicketHistoryRepository>(
        () => TicketHistoryRepositoryImpl(Get.find<TicketHistoryNetworkRequest>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<TicketHistoryUseCase>()) {
      Get.lazyPut(
        () => TicketHistoryUseCase(Get.find<TicketHistoryRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<TicketDetailController>()) {
      Get.lazyPut(
        () => TicketDetailController(Get.find<TicketHistoryUseCase>()),
        fenix: true,
      );
    }
  }
}
