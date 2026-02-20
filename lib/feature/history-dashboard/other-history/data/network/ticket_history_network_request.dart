import 'dart:async';

import 'package:express_vet/base/network_data_source.dart';
import 'package:get/get.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/contains.dart';
import '../../../../../utils/loading.dart';
import '../../../../home-dashboard/passenger/data/model/response/booking_list_model.dart';

class TicketHistoryNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  TicketHistoryNetworkRequest(this.netWorkDataSource);

  Future<BookingListModel> fetchBookingList({required dynamic context}) async {
    try {
      final json = await netWorkDataSource.postJson(
        Endpoint.ticketBookingList,
        body: <String, dynamic>{'page': 1, 'rowsPerPage': 100},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return BookingListModel.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
