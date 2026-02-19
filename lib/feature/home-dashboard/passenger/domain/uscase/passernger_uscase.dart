import 'package:express_vet/feature/home-dashboard/passenger/data/model/request/check_booking_package_request.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/response/check_booking_package_apply_response.dart';
import 'package:express_vet/models/boarding_point.dart';
import 'package:flutter/material.dart';
import '../repository/passenger_repository.dart';

class PasserngerUscase {
  final PassengerRepository passengerRepository;

  PasserngerUscase(this.passengerRepository);

  Future<CarPointResponse> getBoardingPoint({
    required BuildContext context,
    required String date,
    required String journeyId,
  }) => passengerRepository.getBoardingPoint(
    context: context,
    date: date,
    journeyId: journeyId,
  );

  Future<CarPointResponse> getDropOffPoint({
    required BuildContext context,
    required String journeyId,
  }) => passengerRepository.getDropOffPoint(
    context: context,
    journeyId: journeyId,
  );

  Future<CheckPackageApplyResponse> checkPackageApply(
    CheckBookingPackageRequest body,
  ) => passengerRepository.checkPackageApply(body);
}
