import 'package:express_vet/base/state_controller.dart';
import 'package:express_vet/activities/ticket/value_statics.dart';
import 'package:express_vet/feature/passenger/data/model/request/check_booking_package_request.dart';
import 'package:express_vet/feature/passenger/presentation/uistate/passenger_uistate.dart';
import '../../domain/uscase/passernger_uscase.dart';

class PassengerDetailController extends StateController<PassengerUistate> {
  final PasserngerUscase passerngerUscase;

  PassengerDetailController(this.passerngerUscase);

  @override
  PassengerUistate onInitUiState() => PassengerUistate();

  Future<bool> checkPackageApply() async {
    final body = CheckBookingPackageRequest(
      context: uiState.value.context,
      code: uiState.value.code,
      journeyId: uiState.value.journeyId,
      travelDate: uiState.value.travelDate,
    );

    final res = await passerngerUscase.checkPackageApply(body);

    if (res.header?.statusCode == 200 && res.header?.result == true) {
      final ok = (res.body?.status ?? 0) == 1;
      if (ok) {
        ValueStatic.travelPackageDis = res.body?.discount ?? 0;
        uiState.value = state.copyWith(msgPackage: '', isTravelPackageOk: true);
        return true;
      }

      uiState.value = state.copyWith(
        isTravelPackageOk: false,
        msgPackage: res.body?.msg ?? '',
      );
      return false;
    }

    uiState.value = state.copyWith(
      isTravelPackageOk: false,
      msgPackage: res.body?.msg ?? '',
    );
    return false;
  }
}
