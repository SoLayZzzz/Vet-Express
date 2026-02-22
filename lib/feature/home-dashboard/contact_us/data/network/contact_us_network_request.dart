import 'dart:async';

import 'package:get/get.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../base/network_data_source.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/contains.dart';
import '../../../../../utils/loading.dart';
import '../../../ev-charger/data/model/response/ev_contact_response.dart';

class ContactUsNetworkRequest {
  final NetWorkDataSource dataSource;

  ContactUsNetworkRequest(this.dataSource);

  Future<EvContactResponse> fetchContactList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) async {
    try {
      final json = await dataSource.postJson(
        Endpoint.evDropdownContactUsList,
        body: {'page': page, 'rowsPerPage': rowsPerPage},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return EvContactResponse.fromJson(json);
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
