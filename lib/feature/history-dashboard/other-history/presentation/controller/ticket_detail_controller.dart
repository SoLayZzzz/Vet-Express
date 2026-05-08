import 'package:express_vet/base/state_controller.dart';
import 'package:flutter/widgets.dart';

import '../../domain/uscase/ticket_history_usecase.dart';
import '../uiState/ticket_detail_ui_state.dart';

class TicketDetailController extends StateController<TicketDetailUiState> {
  final TicketHistoryUseCase ticketHistoryUseCase;

  TicketDetailController(this.ticketHistoryUseCase);

  @override
  TicketDetailUiState onInitUiState() => const TicketDetailUiState();

  void loadTicketDetail({required BuildContext context, required int id}) {
    uiState.value = state.copyWith(
      futureTicketDetail: ticketHistoryUseCase.fetchTicketDetail(
        context: context,
        id: id,
      ),
    );
  }
}
