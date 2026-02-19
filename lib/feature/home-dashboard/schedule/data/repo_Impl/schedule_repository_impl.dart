import 'package:express_vet/feature/home-dashboard/schedule/data/model/request/schedule_request_body.dart';
import 'package:flutter/widgets.dart';
import '../../domain/repository/schedule_repository.dart';
import '../model/response/schedule_response.dart';
import '../network/schedule_network_request.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleNetworkRequest scheduleNetworkRequest;

  ScheduleRepositoryImpl(this.scheduleNetworkRequest);

  @override
  Future<ScheduleResponse> fetchSchedule({
    required BuildContext context,
    required ScheduleRequestBody body,
  }) {
    return scheduleNetworkRequest.fetchScheduleWithBody(
      context: context,
      body: body,
    );
  }
}
