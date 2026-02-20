import 'package:flutter/widgets.dart';

import '../../../../home-dashboard/passenger/data/model/response/booking_list_model.dart';

abstract class TicketHistoryRepository {
  Future<BookingListModel> fetchBookingList({required BuildContext context});
}
