import 'package:express_vet/feature/home-dashboard/passenger/data/model/request/check_booking_package_request.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/response/check_booking_package_apply_response.dart';
import 'package:express_vet/models/boarding_point.dart';
import 'package:flutter/material.dart';

abstract class PassengerRepository {
  Future<CarPointResponse> getBoardingPoint({
    required BuildContext context,
    required String date,
    required String journeyId,
  });

  Future<CarPointResponse> getDropOffPoint({
    required BuildContext context,
    required String journeyId,
  });

  Future<CheckPackageApplyResponse> checkPackageApply(
    CheckBookingPackageRequest body,
  );
}
