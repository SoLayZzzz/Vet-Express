import 'package:express_vet/feature/home-dashboard/car_rental/data/model/request/car_rental_add_request_body.dart';
import 'package:flutter/widgets.dart';

import '../../../../../base/state_controller.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/loading.dart';
import '../../data/model/response/car_rental_add_response.dart';
import '../../domain/uscase/car_rental_usecase.dart';
import '../uiState/car_rental_ui_state.dart';

class CarRentalController extends StateController<CarRentalUiState> {
  final CarRentalUseCase carRentalUseCase;

  CarRentalController(this.carRentalUseCase);

  @override
  CarRentalUiState onInitUiState() => const CarRentalUiState();

  void loadCarTypes({required BuildContext context}) {
    uiState.value = state.copyWith(
      futureCarTypes: carRentalUseCase.fetchCarTypeList(context: context),
    );
  }

  void loadProvinces({required BuildContext context}) {
    uiState.value = state.copyWith(
      futureProvinces: carRentalUseCase.fetchProvinceList(context: context),
    );
  }

  Future<CarRentalAddResponse> saveRental({
    required BuildContext context,
    required CarRentalAddRequestBody body,
    required List<Map<String, String>> successDetails,
  }) async {
    Loading().loadingShow(context);

    try {
      final res = await carRentalUseCase.addCarRental(
        context: context,
        body: body,
      );
      Loading().loadingClose(context);

      if (res.header?.statusCode == 200 && res.header?.result == true) {
        alertDialogRental(context: context, details: successDetails);
      }

      return res;
    } catch (e) {
      Loading().loadingClose(context);
      rethrow;
    }
  }
}
