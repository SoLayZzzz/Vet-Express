import 'package:flutter/widgets.dart';

import '../../../../home-dashboard/passenger/data/model/response/booking_list_model.dart';
import '../../data/model/response/ticket_detail_response.dart';

abstract class TicketHistoryRepository {
  Future<BookingListModel> fetchBookingList({required BuildContext context});
  Future<TicketDetailScreenReponse> fetchTicketDetail({
    required BuildContext context,
    required int id,
  });
}
