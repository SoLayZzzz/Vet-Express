import 'package:flutter/widgets.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../base/network_data_source.dart';
import '../../../../../utils/contains.dart';
import '../model/request/booking_delivery_add_request_body.dart';
import '../model/response/booking_delivery_add_response.dart';

class BookingDeliveryNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  BookingDeliveryNetworkRequest(this.netWorkDataSource);

  Future<BookingDeliveryAddResponse> addBookingDelivery({
    required BuildContext context,
    required BookingDeliveryAddRequestBody body,
  }) async {
    final json = await netWorkDataSource.postMultipartWithFile(
      Endpoint.requestTransferAdd,
      fields: body.toFormFields(),
      fileField: 'file',
      filePath: body.filePath,
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return BookingDeliveryAddResponse.fromJson(json);
  }
}
