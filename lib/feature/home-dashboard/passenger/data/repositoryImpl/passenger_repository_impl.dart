import 'package:express_vet/feature/home-dashboard/passenger/data/model/request/check_booking_package_request.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/response/check_booking_package_apply_response.dart';
import 'package:express_vet/models/boarding_point.dart';
import 'package:flutter/material.dart';

import '../../domain/repository/passenger_repository.dart';
import '../network/passenger_network_request.dart';

class PassengerRepositoryImpl implements PassengerRepository {
  final PassengerNetworkRequest passengerNetworkRequest;

  PassengerRepositoryImpl(this.passengerNetworkRequest);

  @override
  Future<CarPointResponse> getBoardingPoint({
    required BuildContext context,
    required String date,
    required String journeyId,
  }) {
    return passengerNetworkRequest.getBoardingPoint(
      context: context,
      date: date,
      journeyId: journeyId,
    );
  }

  @override
  Future<CarPointResponse> getDropOffPoint({
    required BuildContext context,
    required String journeyId,
  }) {
    return passengerNetworkRequest.getDropOffPoint(
      context: context,
      journeyId: journeyId,
    );
  }

  @override
  Future<CheckPackageApplyResponse> checkPackageApply(
    CheckBookingPackageRequest body,
  ) {
    return passengerNetworkRequest.checkPackageApply(body);
  }
}
