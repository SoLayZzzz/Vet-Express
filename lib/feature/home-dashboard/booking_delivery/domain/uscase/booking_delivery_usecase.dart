import 'package:flutter/widgets.dart';

import '../../data/model/request/booking_delivery_add_request_body.dart';
import '../../data/model/response/booking_delivery_add_response.dart';
import '../repository/booking_delivery_repository.dart';

class BookingDeliveryUseCase {
  final BookingDeliveryRepository bookingDeliveryRepository;

  BookingDeliveryUseCase(this.bookingDeliveryRepository);

  Future<BookingDeliveryAddResponse> addBookingDelivery({
    required BuildContext context,
    required BookingDeliveryAddRequestBody body,
  }) {
    return bookingDeliveryRepository.addBookingDelivery(context: context, body: body);
  }
}
