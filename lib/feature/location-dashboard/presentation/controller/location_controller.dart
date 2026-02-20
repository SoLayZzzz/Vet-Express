import 'package:express_vet/base/state_controller.dart';
import 'package:express_vet/feature/location-dashboard/domain/uscase/location_usecase.dart';
import 'package:express_vet/feature/location-dashboard/presentation/uistate/location_ui_state.dart';
import 'package:express_vet/feature/location-dashboard/data/model/response/branch_response.dart';
import 'package:flutter/material.dart';

class LocationController extends StateController<LocationUiState> {
  final LocationUseCase useCase;

  LocationController(this.useCase);

  @override
  LocationUiState onInitUiState() => const LocationUiState();

  Future<void> fetchBranches({required BuildContext context}) async {
    uiState.value = state.copyWith(loading: true, error: false);
    try {
      final res = await useCase.getBranchList(context: context);
      final list = res.body?.data ?? <Data>[];
      uiState.value = state.copyWith(
        branches: list,
        loading: false,
        error: false,
      );
    } catch (_) {
      uiState.value = state.copyWith(loading: false, error: true);
    }
  }
}
