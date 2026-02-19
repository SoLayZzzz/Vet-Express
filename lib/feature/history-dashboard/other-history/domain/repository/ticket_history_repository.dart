import 'package:flutter/widgets.dart';

import '../../../../../models/booking/booking_list_model.dart';

abstract class TicketHistoryRepository {
  Future<BookingListModel> fetchBookingList({
    required BuildContext context,
  });
}
