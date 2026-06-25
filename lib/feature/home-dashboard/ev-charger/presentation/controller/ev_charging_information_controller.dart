import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/amount_price_kwh_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/domain/uscase/ev_charger_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EvChargingInformationController extends GetxController {
  final EvChargerUseCase useCase;

  EvChargingInformationController(this.useCase);

  final RxBool isKwhTab = true.obs;
  final RxInt selectedGridIndex = 0.obs;

  final RxList<Data> kwhList = <Data>[].obs;
  final RxList<Data> priceList = <Data>[].obs;

  final RxBool isLoadingKwh = false.obs;
  final RxBool isLoadingPrice = false.obs;
  final RxBool hasErrorKwh = false.obs;
  final RxBool hasErrorPrice = false.obs;

  final TextEditingController kwhController = TextEditingController();
  final TextEditingController khrController = TextEditingController();
  final TextEditingController promoCodeController = TextEditingController();
  final TextEditingController pointController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchKwhData();
    fetchPriceData();
  }

  @override
  void onClose() {
    kwhController.dispose();
    khrController.dispose();
    promoCodeController.dispose();
    pointController.dispose();
    super.onClose();
  }

  Future<void> fetchKwhData() async {
    try {
      isLoadingKwh(true);
      hasErrorKwh(false);
      final response = await useCase.fetchAmountKwh(context: Get.context!);
      final list = response.body?.data ?? [];
      kwhList.assignAll(list);
      _syncTextFieldWithSelection();
    } catch (e) {
      hasErrorKwh(true);
      debugPrint("Error fetching kWh data: $e");
    } finally {
      isLoadingKwh(false);
    }
  }

  Future<void> fetchPriceData() async {
    try {
      isLoadingPrice(true);
      hasErrorPrice(false);
      final response = await useCase.fetchAmountPrice(context: Get.context!);
      final list = response.body?.data ?? [];
      priceList.assignAll(list);
      _syncTextFieldWithSelection();
    } catch (e) {
      hasErrorPrice(true);
      debugPrint("Error fetching price data: $e");
    } finally {
      isLoadingPrice(false);
    }
  }

  void selectTab(bool isKwh) {
    isKwhTab.value = isKwh;
    selectedGridIndex.value = 0;
    _syncTextFieldWithSelection();
    
    // Refresh data when switching tabs (real-time fetch)
    if (isKwh) {
      fetchKwhData();
    } else {
      fetchPriceData();
    }
  }

  void selectGridItem(int index) {
    selectedGridIndex.value = index;
    _syncTextFieldWithSelection();
  }

  void _syncTextFieldWithSelection() {
    final index = selectedGridIndex.value;
    if (isKwhTab.value) {
      if (kwhList.isNotEmpty && index >= 0 && index < kwhList.length) {
        final item = kwhList[index];
        if (item.isFullCharge == 1) {
          kwhController.text = "Full Charge";
        } else {
          kwhController.text = item.value?.toString() ?? "";
        }
      }
    } else {
      if (priceList.isNotEmpty && index >= 0 && index < priceList.length) {
        final item = priceList[index];
        if (item.isFullCharge == 1) {
          khrController.text = "Full Charge";
        } else {
          khrController.text = item.value?.toString() ?? "";
        }
      }
    }
  }
}
