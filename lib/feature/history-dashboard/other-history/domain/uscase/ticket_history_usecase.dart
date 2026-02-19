import 'package:flutter/widgets.dart';

import '../../../../../models/booking/booking_list_model.dart';
import '../repository/ticket_history_repository.dart';

class TicketHistoryUseCase {
  final TicketHistoryRepository ticketHistoryRepository;

  TicketHistoryUseCase(this.ticketHistoryRepository);

  Future<BookingListModel> fetchBookingList({
    required BuildContext context,
  }) {
    return ticketHistoryRepository.fetchBookingList(context: context);
  }
}
