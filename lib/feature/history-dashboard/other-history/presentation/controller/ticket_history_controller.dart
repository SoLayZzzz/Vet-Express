import 'package:express_vet/base/state_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../domain/uscase/ticket_history_usecase.dart';
import '../uiState/ticket_history_ui_state.dart';

class TicketHistoryController extends StateController<TicketHistoryUiState> {
  final TicketHistoryUseCase ticketHistoryUseCase;

  TicketHistoryController(this.ticketHistoryUseCase);

  @override
  TicketHistoryUiState onInitUiState() => const TicketHistoryUiState();

  @override
  void onReady() {
    super.onReady();

    if (state.futureListBooking != null) return;

    final ctx = Get.context;
    if (ctx != null) {
      loadBookingList(context: ctx);
    }
  }

  void loadBookingList({required BuildContext context}) {
    uiState.value = state.copyWith(
      futureListBooking: ticketHistoryUseCase.fetchBookingList(context: context),
    );
  }
}
