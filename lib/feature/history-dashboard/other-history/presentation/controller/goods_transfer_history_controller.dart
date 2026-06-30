import 'package:express_vet/base/state_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../domain/uscase/goods_transfer_history_usecase.dart';
import '../uiState/goods_transfer_history_ui_state.dart';
import '../../../../../controller/connectivity_controller.dart';

class GoodsTransferHistoryController
    extends StateController<GoodsTransferHistoryUiState>
    with GetSingleTickerProviderStateMixin {
  final GoodsTransferHistoryUseCase goodsTransferHistoryUseCase;

  GoodsTransferHistoryController(this.goodsTransferHistoryUseCase);

  late final TabController tabController;

  final RxBool isFiltering = false.obs;

  final RxInt expandedIndex = (-1).obs;

  int desFromId = 0;
  int desToId = 0;
  int statusId = 0;

  GoodsTransferHistoryUiState onInitUiState() =>
      const GoodsTransferHistoryUiState();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    ever(Get.find<ConnectivityController>().isConnected, (bool connected) {
      if (connected) {
        final ctx = Get.context;
        if (ctx != null) {
          loadTransferList(context: ctx, type: 1);
          loadTransferList(context: ctx, type: 2);
          loadSelfServiceList(context: ctx);
        }
      }
    });
  }

  @override
  void onReady() {
    super.onReady();

    final ctx = Get.context;
    if (ctx == null) return;

    if (state.futureSending == null) {
      loadTransferList(context: ctx, type: 1);
    }
    if (state.futureReceiving == null) {
      loadTransferList(context: ctx, type: 2);
    }
    if (state.futureSelfService == null) {
      loadSelfServiceList(context: ctx);
    }
  }

  // var expandedIndex = (-1).obs;

  void toggleExpansion(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1; // Close if already open
    } else {
      expandedIndex.value = index; // Open the selected one
    }
  }

  void loadTransferList({required BuildContext context, required int type}) {
    final future = goodsTransferHistoryUseCase.fetchTransferList(
      context: context,
      page: 1,
      rowPerPage: 100,
      desFrom: desFromId,
      desTo: desToId,
      type: type,
      status: statusId,
    );

    if (type == 1) {
      uiState.value = state.copyWith(futureSending: future);
    } else if (type == 2) {
      uiState.value = state.copyWith(futureReceiving: future);
    }
  }

  void loadSelfServiceList({required BuildContext context}) {
    uiState.value = state.copyWith(
      futureSelfService: goodsTransferHistoryUseCase.fetchSelfServiceList(
        context: context,
      ),
    );
  }

  Future<void> applyFilter({
    required BuildContext context,
    required int desFrom,
    required int desTo,
    required int status,
  }) {
    if (isFiltering.value) return Future.value();
    isFiltering.value = true;

    desFromId = desFrom;
    desToId = desTo;
    statusId = status;

    final f1 = goodsTransferHistoryUseCase.fetchTransferList(
      context: context,
      page: 1,
      rowPerPage: 100,
      desFrom: desFromId,
      desTo: desToId,
      type: 1,
      status: statusId,
    );
    final f2 = goodsTransferHistoryUseCase.fetchTransferList(
      context: context,
      page: 1,
      rowPerPage: 100,
      desFrom: desFromId,
      desTo: desToId,
      type: 2,
      status: statusId,
    );

    uiState.value = state.copyWith(futureSending: f1, futureReceiving: f2);

    return Future.wait([
      f1.then((_) => null),
      f2.then((_) => null),
    ]).whenComplete(() {
      isFiltering.value = false;
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
