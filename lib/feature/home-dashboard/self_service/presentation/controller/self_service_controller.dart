import 'dart:async';

import 'package:express_vet/feature/home-dashboard/self_service/data/model/response/uom.dart';
import 'package:express_vet/feature/home-dashboard/self_service/presentation/uistate/self_service_uiState.dart';
import 'package:express_vet/feature/home-dashboard/self_service/data/model/response/destination_province.dart';
import 'package:express_vet/base/state_controller.dart';
import 'package:express_vet/activities/ticket/value_statics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/routes/app_routes.dart';
import 'package:express_vet/utils/alert_dialog.dart';

import '../../domain/uscase/self_service_usecase.dart';

class SelfServiceController extends StateController<SelfServiceUistate> {
  final SelfServiceUsecase selfServiceUsecase;

  SelfServiceController(this.selfServiceUsecase);

  @override
  SelfServiceUistate onInitUiState() => SelfServiceUistate();

  TextEditingController get phoneSenderController =>
      uiState.value.phoneSenderController;
  TextEditingController get phoneReceivedController =>
      uiState.value.phoneReceivedController;
  TextEditingController get provinceController =>
      uiState.value.provinceController;
  TextEditingController get locationController =>
      uiState.value.locationController;
  TextEditingController get itemPriceController =>
      uiState.value.itemPriceController;
  TextEditingController get amountController => uiState.value.amountController;
  TextEditingController get unitController => uiState.value.unitController;

  @override
  void onInit() {
    super.onInit();
    initSelfServiceFormDefaults();
  }

  void initSelfServiceFormDefaults() {
    uiState.value.phoneSenderController.text = ValueStatic.phone;
    if (uiState.value.amountController.text.isEmpty) {
      uiState.value.amountController.text = '1';
    }
    syncSelectionFieldsFromValueStatic();
    uiState.refresh();
  }

  void syncSelectionFieldsFromValueStatic() {
    provinceController.text = ValueStatic.provinceName;
    locationController.text = ValueStatic.locationName;
    unitController.text = ValueStatic.uomName;
    uiState.refresh();
  }

  @override
  void onClose() {
    uiState.value.debounceTimer?.cancel();
    uiState.value.phoneSenderController.dispose();
    uiState.value.phoneReceivedController.dispose();
    uiState.value.provinceController.dispose();
    uiState.value.locationController.dispose();
    uiState.value.itemPriceController.dispose();
    uiState.value.amountController.dispose();
    uiState.value.unitController.dispose();
    super.onClose();
  }

  void initSelect({
    required BuildContext context,
    required String selectType,
    String? provinceId,
  }) {
    final shouldReuse = () {
      if (state.selectType != selectType) return false;
      if (selectType == 'uom') return state.futureSelectUom != null;
      if (selectType == 'location') {
        return state.futureSelect != null &&
            state.locationProvinceId == provinceId;
      }
      return state.futureSelect != null;
    }();

    if (shouldReuse) return;

    final Future<ProvinceResponse>? provinceFuture =
        selectType == 'province'
            ? selfServiceUsecase.fetchProvinceList(context: context)
            : selectType == 'location'
            ? selfServiceUsecase.fetchDestinationByProvince(
              context: context,
              provinceId: provinceId ?? '',
            )
            : null;

    final Future<UomListResponse>? uomFuture =
        selectType == 'uom'
            ? selfServiceUsecase.fetchUomList(context: context)
            : null;

    state.selectType = selectType;
    state.locationProvinceId = selectType == 'location' ? provinceId : null;
    state.searchText = '';
    state.allProvinceData = null;
    state.filteredProvinceData = null;
    state.allUomData = null;
    state.filteredUomData = null;
    state.futureSelect = provinceFuture;
    state.futureSelectUom = uomFuture;
    uiState.refresh();

    provinceFuture
        ?.then((res) {
          final data = res.body?.data;
          if (data != null) setLoadedProvinceData(data);
        })
        .catchError((_) {});

    uomFuture
        ?.then((res) {
          final data = res.body?.data;
          if (data != null) setLoadedUomData(data);
        })
        .catchError((_) {});
  }

  void setLoadedProvinceData(List<Data> data) {
    if (state.allProvinceData != null) return;
    state.allProvinceData = data;
    state.filteredProvinceData = data;
    uiState.refresh();
  }

  void setLoadedUomData(List<UomData> data) {
    if (state.allUomData != null) return;
    state.allUomData = data;
    state.filteredUomData = data;
    uiState.refresh();
  }

  void onSearchChanged(String value) {
    state.debounceTimer?.cancel();
    state.debounceTimer = Timer(const Duration(milliseconds: 300), () {
      filterData(value);
    });
    uiState.refresh();
  }

  void filterData(String searchText) {
    final query = searchText.toLowerCase().trim();

    if (state.selectType == 'uom') {
      final all = state.allUomData;
      if (all == null) return;

      final filtered =
          query.isEmpty
              ? all
              : all.where((item) {
                final name = item.name?.toLowerCase() ?? '';
                return name.contains(query);
              }).toList();

      state.searchText = searchText;
      state.filteredUomData = filtered;
      uiState.refresh();
      return;
    }

    final all = state.allProvinceData;
    if (all == null) return;

    final filtered =
        query.isEmpty
            ? all
            : all.where((item) {
              final name = item.name?.toLowerCase() ?? '';
              return name.contains(query);
            }).toList();

    state.searchText = searchText;
    state.filteredProvinceData = filtered;
    uiState.refresh();
  }

  Future<void> saveSelfService(
    BuildContext context,
    String destinationToId,
    String itemQty,
    String itemValue,
    String receiverTelephone,
    String senderTelephone,
    String uomId,
  ) async {
    try {
      final res = await selfServiceUsecase.saveGoodsSelfService(
        context: context,
        destinationToId: destinationToId,
        itemQty: itemQty,
        itemValue: itemValue,
        receiverTelephone: receiverTelephone,
        senderTelephone: senderTelephone,
        uomId: uomId,
      );

      if (res.header?.statusCode == 200 && res.header?.result == true) {
        Get.toNamed(
          AppRoutes.selfServiceQr,
          arguments: {'qrCode': (res.body?.message).toString()},
        );
      } else {
        alertDialogOneButton(
          title: 'Save not Success',
          description: 'Please try agian!',
          buttonText: 'ok'.tr,
        );
      }
    } catch (_) {}
  }
}
