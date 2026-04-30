import 'package:express_vet/base/network_data_source.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../utils/contains.dart';

class RateScheduleNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  RateScheduleNetworkRequest(this.netWorkDataSource);

  Future<Map<String, dynamic>> saveRateSchedule({
    required dynamic context,
    required Map<String, String> fields,
  }) async {
    final json = await netWorkDataSource.postFormUrlEncoded(
      Endpoint.scheduleRateSave,
      fields: fields,
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return json;
  }
}
