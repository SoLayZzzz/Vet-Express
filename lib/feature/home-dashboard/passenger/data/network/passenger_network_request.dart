import 'dart:async';

import 'package:express_vet/base/network_data_source.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/request/check_booking_package_request.dart';
import 'package:express_vet/models/boarding_point.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../base/endpoint.dart';
import '../model/response/check_booking_package_apply_response.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/contains.dart';
import '../../../../../utils/loading.dart';

class PassengerNetworkRequest {
  final NetworkDataSource networkDataSource;

  PassengerNetworkRequest({required this.networkDataSource});

  Future<CarPointResponse> getBoardingPoint({
    required BuildContext context,
    required String date,
    required String journeyId,
  }) async {
    try {
      final json = await networkDataSource.postFormUrlEncoded(
        Endpoint.ticketBoardingPointListByScheduleDate,
        fields: <String, String>{'date': date, 'id': journeyId},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return CarPointResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(Get.context);
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

  Future<CarPointResponse> getDropOffPoint({
    required BuildContext context,
    required String journeyId,
  }) async {
    try {
      final json = await networkDataSource.postFormUrlEncoded(
        Endpoint.ticketDropOffPointFindBySchedule(journeyId),
        fields: <String, String>{},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return CarPointResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(Get.context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      Loading().loadingClose(Get.context);
      rethrow;
    }
  }

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
