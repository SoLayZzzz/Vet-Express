import 'package:express_vet/feature/schedule/data/model/request/schedule_request_body.dart';
import 'package:flutter/widgets.dart';

import '../../data/model/response/schedule_response.dart';

abstract class ScheduleRepository {
  Future<ScheduleResponse> fetchSchedule({
    required BuildContext context,
    required ScheduleRequestBody body,
  });
}
