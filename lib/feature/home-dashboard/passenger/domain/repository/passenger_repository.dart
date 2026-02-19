import 'package:express_vet/feature/passenger/data/model/request/check_booking_package_request.dart';
import 'package:express_vet/feature/passenger/data/model/response/check_booking_package_apply_response.dart';

abstract class PassengerRepository {
  Future<CheckPackageApplyResponse> checkPackageApply(
    CheckBookingPackageRequest body,
  );
}
