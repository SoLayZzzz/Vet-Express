import 'package:flutter/widgets.dart';

import '../../../../home-dashboard/passenger/data/model/response/booking_list_model.dart';
import '../../domain/repository/ticket_history_repository.dart';
import '../network/ticket_history_network_request.dart';

class TicketHistoryRepositoryImpl implements TicketHistoryRepository {
  final TicketHistoryNetworkRequest ticketHistoryNetworkRequest;

  TicketHistoryRepositoryImpl(this.ticketHistoryNetworkRequest);

  @override
  Future<BookingListModel> fetchBookingList({required BuildContext context}) {
    return ticketHistoryNetworkRequest.fetchBookingList(context: context);
  }
}
