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

  int _currentTicketType = 1;

  @override
  TicketHistoryUiState onInitUiState() => const TicketHistoryUiState();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_onTabChanged);
    ever(Get.find<ConnectivityController>().isConnected, (bool connected) {
      if (connected) {
        final ctx = Get.context;
        if (ctx != null) {
          loadBookingList(context: ctx, ticketType: _currentTicketType);
        }
      }
    });
  }

  void _onTabChanged() {
    if (tabController.indexIsChanging) return;
    final ticketType = tabController.index + 1;
    if (ticketType == _currentTicketType) return;

    final ctx = Get.context;
    if (ctx != null) {
      loadBookingList(context: ctx, ticketType: ticketType);
    }
  }

  @override
  void onReady() {
    super.onReady();
    final ctx = Get.context;
    if (ctx != null) {
      loadBookingList(context: ctx);
    }
  }

  void loadBookingList({required BuildContext context, int ticketType = 1}) {
    _currentTicketType = ticketType;
    uiState.value = state.copyWith(
      futureListBooking: ticketHistoryUseCase.fetchBookingList(
        context: context,
        ticketType: ticketType,
      ),
    );
  }

  void reloadBookingList() {
    final ctx = Get.context;
    if (ctx != null) {
      loadBookingList(context: ctx, ticketType: _currentTicketType);
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
