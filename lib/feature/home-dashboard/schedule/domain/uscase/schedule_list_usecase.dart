import 'package:express_vet/feature/home-dashboard/schedule/data/model/request/schedule_request_body.dart';
import 'package:flutter/widgets.dart';

import '../../data/model/response/schedule_response.dart';
import '../repository/schedule_repository.dart';

class ScheduleListUseCase {
  final ScheduleRepository scheduleRepository;

  ScheduleListUseCase(this.scheduleRepository);

  Future<ScheduleResponse> fetchSchedule({
    required BuildContext context,
    required ScheduleRequestBody body,
  }) {
    return scheduleRepository.fetchSchedule(context: context, body: body);
  }
}
