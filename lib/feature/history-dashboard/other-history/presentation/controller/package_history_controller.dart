import 'package:express_vet/base/state_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../domain/uscase/package_history_usecase.dart';
import '../uiState/package_history_ui_state.dart';
import '../../../../../controller/connectivity_controller.dart';

class PackageHistoryController extends StateController<PackageHistoryUiState> {
  final PackageHistoryUseCase packageHistoryUseCase;

  PackageHistoryController(this.packageHistoryUseCase);

  @override
  PackageHistoryUiState onInitUiState() => const PackageHistoryUiState();

  @override
  void onInit() {
    super.onInit();
    ever(Get.find<ConnectivityController>().isConnected, (bool connected) {
      if (connected) {
        final ctx = Get.context;
        if (ctx != null) {
          loadBuyList(context: ctx);
        }
      }
    });
  }

  @override
  void onReady() {
    super.onReady();

    if (state.futureBuyList != null) return;

    final ctx = Get.context;
    if (ctx != null) {
      loadBuyList(context: ctx);
    }
  }

  void loadBuyList({required BuildContext context}) {
    uiState.value = state.copyWith(
      futureBuyList: packageHistoryUseCase.fetchBuyList(context: context),
    );
  }
}
