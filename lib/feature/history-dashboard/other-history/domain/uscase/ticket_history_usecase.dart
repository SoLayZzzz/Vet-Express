import 'package:flutter/widgets.dart';

import '../../../../home-dashboard/passenger/data/model/response/booking_list_model.dart';
import '../../data/model/response/ticket_detail_response.dart';
import '../repository/ticket_history_repository.dart';

class TicketHistoryUseCase {
  final TicketHistoryRepository ticketHistoryRepository;

  TicketHistoryUseCase(this.ticketHistoryRepository);

  Future<BookingListModel> fetchBookingList({
    required BuildContext context,
    required int ticketType,
  }) {
    return ticketHistoryRepository.fetchBookingList(
      context: context,
      ticketType: ticketType,
    );
  }

  Future<TicketDetailScreenReponse> fetchTicketDetail({
    required BuildContext context,
    required int id,
  }) {
    return ticketHistoryRepository.fetchTicketDetail(
      context: context,
      id: id,
    );
  }
}
