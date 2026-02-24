import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../../base/state_controller.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/loading.dart';
import '../../data/model/request/booking_delivery_add_request_body.dart';
import '../../data/model/response/booking_delivery_add_response.dart';
import '../../domain/uscase/booking_delivery_usecase.dart';
import '../uiState/booking_delivery_ui_state.dart';

class BookingDeliveryController
    extends StateController<BookingDeliveryUiState> {
  final BookingDeliveryUseCase bookingDeliveryUseCase;

  BookingDeliveryController(this.bookingDeliveryUseCase);

  @override
  BookingDeliveryUiState onInitUiState() => const BookingDeliveryUiState();

  Future<BookingDeliveryAddResponse> submit({
    required BuildContext context,
    required BookingDeliveryAddRequestBody body,
    required VoidCallback onSuccess,
  }) async {
    Loading().loadingShow();

    try {
      final res = await bookingDeliveryUseCase.addBookingDelivery(
        context: context,
        body: body,
      );

      Loading().loadingClose();

      if (res.header?.statusCode == 200 && res.header?.result == true) {
        alertDialogOneButton(
          title: 'success'.tr,
          description: 'success_info'.tr,
          buttonText: 'close'.tr,
        );
        onSuccess();
      }

      return res;
    } catch (e) {
      Loading().loadingClose();
      rethrow;
    }
  }
}
