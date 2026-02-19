import 'package:express_vet/feature/home-dashboard/passenger/data/model/request/check_booking_package_request.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/response/check_booking_package_apply_response.dart';

import '../../domain/repository/passenger_repository.dart';
import '../network/passenger_network_request.dart';

class PassengerRepositoryImpl implements PassengerRepository {
  final PassengerNetworkRequest passengerNetworkRequest;

  PassengerRepositoryImpl(this.passengerNetworkRequest);

  @override
  Future<CheckPackageApplyResponse> checkPackageApply(
    CheckBookingPackageRequest body,
  ) {
    return passengerNetworkRequest.checkPackageApply(body);
  }
}
