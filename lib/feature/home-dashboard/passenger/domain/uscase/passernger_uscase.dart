import 'package:express_vet/feature/passenger/data/model/request/check_booking_package_request.dart';
import 'package:express_vet/feature/passenger/data/model/response/check_booking_package_apply_response.dart';
import '../repository/passenger_repository.dart';

class PasserngerUscase {
  final PassengerRepository passengerRepository;

  PasserngerUscase(this.passengerRepository);

  Future<CheckPackageApplyResponse> checkPackageApply(
    CheckBookingPackageRequest body,
  ) => passengerRepository.checkPackageApply(body);
}
