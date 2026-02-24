import 'dart:async';

import 'package:express_vet/base/network_data_source.dart';
import 'package:get/get.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../models/schedule/list_by_journey_response.dart';
import '../../../../../models/schedule/total_by_journey_response.dart';
import '../model/request/schedule_request_body.dart';
import '../model/response/schedule_response.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/loading.dart';
import '../../../../../utils/contains.dart';

class ScheduleNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  ScheduleNetworkRequest(this.netWorkDataSource);

  Future<ScheduleResponse> fetchScheduleWithBody({
    required dynamic context,
    required ScheduleRequestBody body,
  }) async {
    try {
      final json = await netWorkDataSource.postFormUrlEncoded(
        Endpoint.ticketScheduleListByDate,
        fields: body.toFormFields(),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return ScheduleResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose();
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

  Future<ListByJourneyResponse> fetchListByJourney({
    required dynamic context,
    required int scheduleId,
  }) async {
    try {
      final json = await netWorkDataSource.postFormUrlEncoded(
        Endpoint.ticketScheduleRateListByJourney,
        fields: <String, String>{'scheduleId': scheduleId.toString()},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return ListByJourneyResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose();
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

  Future<TotalByJourneyResponse> fetchTotalByJourney({
    required dynamic context,
    required int scheduleId,
  }) async {
    try {
      final json = await netWorkDataSource.postFormUrlEncoded(
        Endpoint.ticketScheduleRateTotalByJourney,
        fields: <String, String>{'scheduleId': scheduleId.toString()},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return TotalByJourneyResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose();
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
