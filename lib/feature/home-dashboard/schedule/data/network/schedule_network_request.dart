import 'package:express_vet/base/network_data_source.dart';
import 'package:flutter/material.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../models/schedule/list_by_journey_response.dart';
import '../../../../../models/schedule/total_by_journey_response.dart';
import '../model/request/schedule_request_body.dart';
import '../model/response/schedule_response.dart';
import '../../../../../utils/contains.dart';

class ScheduleNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  ScheduleNetworkRequest(this.netWorkDataSource);

  Future<ScheduleResponse> fetchScheduleWithBody({
    required dynamic context,
    required ScheduleRequestBody body,
  }) async {
    debugPrint(
      '[Schedule] fetchScheduleWithBody -> fields: ${body.toFormFields()}',
    );
    final json = await netWorkDataSource.postFormUrlEncoded(
      Endpoint.ticketScheduleListByDate,
      fields: body.toFormFields(),
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    debugPrint('[Schedule] fetchScheduleWithBody <- response received');
    return ScheduleResponse.fromJson(json);
  }

  Future<ListByJourneyResponse> fetchListByJourney({
    required dynamic context,
    required int scheduleId,
  }) async {
    debugPrint('[Schedule] fetchListByJourney -> scheduleId: $scheduleId');
    final json = await netWorkDataSource.postFormUrlEncoded(
      Endpoint.ticketScheduleRateListByJourney,
      fields: <String, String>{'scheduleId': scheduleId.toString()},
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    debugPrint('[Schedule] fetchListByJourney <- response received');
    return ListByJourneyResponse.fromJson(json);
  }

  Future<TotalByJourneyResponse> fetchTotalByJourney({
    required dynamic context,
    required int scheduleId,
  }) async {
    debugPrint('[Schedule] fetchTotalByJourney -> scheduleId: $scheduleId');
    final json = await netWorkDataSource.postFormUrlEncoded(
      Endpoint.ticketScheduleRateTotalByJourney,
      fields: <String, String>{'scheduleId': scheduleId.toString()},
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    debugPrint('[Schedule] fetchTotalByJourney <- response received');
    return TotalByJourneyResponse.fromJson(json);
  }
}
