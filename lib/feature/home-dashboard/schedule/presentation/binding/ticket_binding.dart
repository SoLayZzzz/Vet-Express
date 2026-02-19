import 'package:express_vet/feature/home-dashboard/passenger/presentation/controller/passenger_deatail_controller.dart';
import 'package:get/get.dart';

import '../../data/network/schedule_network_request.dart';
import '../../data/repo_Impl/schedule_repository_impl.dart';
import '../../domain/repository/schedule_repository.dart';
import '../../domain/uscase/ticket_usecase.dart';
import '../../domain/uscase/schedule_list_usecase.dart';
import '../../../passenger/data/network/passenger_network_request.dart';
import '../../../passenger/data/repositoryImpl/passenger_repository_impl.dart';
import '../../../passenger/domain/repository/passenger_repository.dart';
import '../../../passenger/domain/uscase/passernger_uscase.dart';
import '../../../seat/data/network/seat_network_request.dart';
import '../../../seat/data/repo_Impl/seat_repository_impl.dart';
import '../../../seat/domain/repository/seat_repository.dart';
import '../../../seat/domain/uscase/select_seat_usecase.dart';
import '../controller/schedule_car_detail_controller.dart';
import '../controller/schedule_list_controller.dart';
import '../../../seat/presentation/controller/select_seat_controller.dart';
import '../controller/ticket_flow_controller.dart';
import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';

class TicketBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TicketUseCase>()) {
      Get.lazyPut(() => const TicketUseCase(), fenix: true);
    }
    if (!Get.isRegistered<TicketFlowController>()) {
      Get.lazyPut(() => TicketFlowController(), fenix: true);
    }

    if (!Get.isRegistered<ScheduleNetworkRequest>()) {
      Get.lazyPut(
        () => ScheduleNetworkRequest(
          NetworkDataSource(baseUrl: BaseUrl.BASE_URL_TICKET),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<ScheduleRepository>()) {
      Get.lazyPut<ScheduleRepository>(
        () => ScheduleRepositoryImpl(Get.find<ScheduleNetworkRequest>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<SeatNetworkRequest>()) {
      Get.lazyPut(
        () => SeatNetworkRequest(
          NetworkDataSource(baseUrl: BaseUrl.BASE_URL_TICKET),
        ),
        fenix: true,
      );
    }

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
    if (!Get.isRegistered<SeatRepository>()) {
      Get.lazyPut<SeatRepository>(
        () => SeatRepositoryImpl(Get.find<SeatNetworkRequest>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ScheduleListUseCase>()) {
      Get.lazyPut(
        () => ScheduleListUseCase(Get.find<ScheduleRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<SelectSeatUseCase>()) {
      Get.lazyPut(
        () => SelectSeatUseCase(Get.find<SeatRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ScheduleListController>()) {
      Get.lazyPut(
        () => ScheduleListController(Get.find<ScheduleListUseCase>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<SelectSeatController>()) {
      Get.lazyPut(
        () => SelectSeatController(Get.find<SelectSeatUseCase>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ScheduleCarDetailController>()) {
      Get.lazyPut(() => ScheduleCarDetailController(), fenix: true);
    }

    final args = Get.arguments as Map<dynamic, dynamic>?;
    final flowId = (args?['flowId'] as String?) ?? '';
    final isBack = (args?['isBack'] as bool?) ?? false;
    final journeyId = (args?['journeyId'] as String?) ?? '';

    if (flowId.isNotEmpty) {
      final scheduleTag = '${flowId}_schedule_${isBack ? 'back' : 'go'}';
      if (!Get.isRegistered<ScheduleListController>(tag: scheduleTag)) {
        Get.lazyPut(
          () => ScheduleListController(Get.find<ScheduleListUseCase>()),
          tag: scheduleTag,
          fenix: true,
        );
      }

      if (journeyId.isNotEmpty) {
        final seatTag = '${flowId}_seat_${isBack ? 'back' : 'go'}';
        if (!Get.isRegistered<SelectSeatController>(tag: seatTag)) {
          Get.lazyPut(
            () => SelectSeatController(Get.find<SelectSeatUseCase>()),
            tag: seatTag,
            fenix: true,
          );
        }
      }
    }
  }
}
