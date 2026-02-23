import 'package:flutter/widgets.dart';

import '../../domain/repository/booking_delivery_repository.dart';
import '../model/request/booking_delivery_add_request_body.dart';
import '../model/response/booking_delivery_add_response.dart';
import '../network/booking_delivery_network_request.dart';

class BookingDeliveryRepositoryImpl implements BookingDeliveryRepository {
  final BookingDeliveryNetworkRequest bookingDeliveryNetworkRequest;

  BookingDeliveryRepositoryImpl(this.bookingDeliveryNetworkRequest);

  @override
  Future<BookingDeliveryAddResponse> addBookingDelivery({
    required BuildContext context,
    required BookingDeliveryAddRequestBody body,
  }) {
    return bookingDeliveryNetworkRequest.addBookingDelivery(
      context: context,
      body: body,
    );
  }
}
