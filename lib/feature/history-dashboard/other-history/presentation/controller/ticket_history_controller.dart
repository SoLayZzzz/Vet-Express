import 'package:express_vet/base/state_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/uscase/ticket_history_usecase.dart';
import '../uiState/ticket_history_ui_state.dart';
import '../../../../../controller/connectivity_controller.dart';

class TicketHistoryController extends StateController<TicketHistoryUiState>
    with GetSingleTickerProviderStateMixin {
  final TicketHistoryUseCase ticketHistoryUseCase;

  TicketHistoryController(this.ticketHistoryUseCase);

  late final TabController tabController;

  @override
  TicketHistoryUiState onInitUiState() => const TicketHistoryUiState();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    ever(Get.find<ConnectivityController>().isConnected, (bool connected) {
      if (connected) {
        final ctx = Get.context;
        if (ctx != null) {
          loadBookingList(context: ctx);
        }
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    final ctx = Get.context;
    if (ctx != null) {
      loadBookingList(context: ctx);
    }
  }

  void loadBookingList({required BuildContext context}) {
    uiState.value = state.copyWith(
      futureListBooking: ticketHistoryUseCase.fetchBookingList(
        context: context,
      ),
    );
  }

  void reloadBookingList() {
    final ctx = Get.context;
    if (ctx != null) {
      loadBookingList(context: ctx);
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
