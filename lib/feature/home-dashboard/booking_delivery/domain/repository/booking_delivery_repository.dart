import 'package:flutter/widgets.dart';

import '../../data/model/request/booking_delivery_add_request_body.dart';
import '../../data/model/response/booking_delivery_add_response.dart';

abstract class BookingDeliveryRepository {
  Future<BookingDeliveryAddResponse> addBookingDelivery({
    required BuildContext context,
    required BookingDeliveryAddRequestBody body,
  });
}
