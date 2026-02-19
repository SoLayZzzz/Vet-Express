import 'package:get/get.dart';
import '../../../../../base/network_data_source.dart';
import '../../data/network/ticket_menu_network_request.dart';
import '../../data/repo_Impl/ticket_menu_repository_impl.dart';
import '../../domain/uscase/ticket_menu_usecase.dart';
import '../controller/select_ticket_controller.dart';
import '../controller/ticket_menu_page_controller.dart';
import '../controller/ticket_menu_form_controller.dart';
import '../controller/ticket_menu_controller.dart';

class TicketMenuBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TicketMenuNetworkRequest>()) {
      Get.lazyPut(
        () => TicketMenuNetworkRequest(Get.find<NetworkDataSource>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<TicketMenuRepositoryImpl>()) {
      Get.lazyPut(
        () => TicketMenuRepositoryImpl(Get.find<TicketMenuNetworkRequest>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<TicketMenuUseCase>()) {
      Get.lazyPut(
        () => TicketMenuUseCase(Get.find<TicketMenuRepositoryImpl>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<TicketMenuController>()) {
      Get.lazyPut(
        () => TicketMenuController(Get.find<TicketMenuUseCase>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<TicketMenuFormController>()) {
      Get.lazyPut(() => TicketMenuFormController(), fenix: true);
    }

    if (!Get.isRegistered<SelectDestinationController>()) {
      Get.lazyPut(
        () => SelectDestinationController(Get.find<TicketMenuController>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<TicketMenuPageController>()) {
      Get.lazyPut(() => TicketMenuPageController(), fenix: true);
    }
  }
}
