import 'dart:async';

import 'package:get/get.dart';

import '../../../../base/endpoint.dart';
import '../../../../base/network_data_source.dart';
import '../../../../models/seat/seat_unavailable.dart';
import '../../../../utils/alert_dialog.dart';
import '../../../../utils/contains.dart';
import '../../../../utils/loading.dart';

class SeatNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  SeatNetworkRequest(this.netWorkDataSource);

  Future<Map<dynamic, dynamic>> getSeatLayout({
    required dynamic context,
    required String date,
    required String journeyId,
  }) async {
    try {
      final json = await netWorkDataSource.postFormUrlEncoded(
        Endpoint.ticketSeatLayout,
        fields: <String, String>{'date': date, 'journey': journeyId},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return Map<dynamic, dynamic>.from(json);
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

  Future<SeatUnavailable> getUnavailable({
    required dynamic context,
    required String date,
    required String journeyId,
  }) async {
    try {
      final json = await netWorkDataSource.postFormUrlEncoded(
        Endpoint.ticketSeatUnavailable,
        fields: <String, String>{'date': date, 'journey': journeyId},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return SeatUnavailable.fromJson(json);
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
