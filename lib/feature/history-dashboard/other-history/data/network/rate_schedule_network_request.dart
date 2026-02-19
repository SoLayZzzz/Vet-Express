import 'dart:async';

import 'package:express_vet/base/network_data_source.dart';
import 'package:get/get.dart';
import 'package:express_vet/utils/alert_dialog.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../utils/contains.dart';
import '../../../../../utils/loading.dart';

class RateScheduleNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  RateScheduleNetworkRequest(this.netWorkDataSource);

  Future<Map<String, dynamic>> saveRateSchedule({
    required dynamic context,
    required Map<String, String> fields,
  }) async {
    try {
      final json = await netWorkDataSource.postFormUrlEncoded(
        Endpoint.scheduleRateSave,
        fields: fields,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return json;
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
