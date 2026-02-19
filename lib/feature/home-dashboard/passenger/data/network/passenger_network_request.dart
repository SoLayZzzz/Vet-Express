import 'dart:async';

import 'package:express_vet/base/network_data_source.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/request/check_booking_package_request.dart';
import 'package:get/get.dart';

import '../../../../../base/endpoint.dart';
import '../model/response/check_booking_package_apply_response.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/contains.dart';
import '../../../../../utils/loading.dart';

class PassengerNetworkRequest {
  final NetworkDataSource networkDataSource;

  PassengerNetworkRequest({required this.networkDataSource});

  Future<CheckPackageApplyResponse> checkPackageApply(
    CheckBookingPackageRequest body,
  ) async {
    try {
      final json = await networkDataSource.postFormUrlEncoded(
        Endpoint.ticketBookingCheckPackageApply,
        fields: <String, String>{
          'code': body.code,
          'journeyId': body.journeyId,
          'travelDate': body.travelDate,
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return CheckPackageApplyResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(body.context);
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
