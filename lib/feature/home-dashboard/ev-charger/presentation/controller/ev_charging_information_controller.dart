import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/amount_price_kwh_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/domain/uscase/ev_charger_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_voucher_list_response.dart'
    as list_resp;
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_point_list_response.dart'
    as point_resp;
import '../../data/model/request/ev_voucher_apply_request.dart';

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

  final RxList<list_resp.Data> voucherList = <list_resp.Data>[].obs;
  final RxBool isLoadingVouchers = false.obs;
  final RxString selectedVoucherCode = ''.obs;
  final RxString searchQuery = ''.obs;

  final RxList<point_resp.Data> pointList = <point_resp.Data>[].obs;
  final RxBool isLoadingPoints = false.obs;

  final TextEditingController kwhController = TextEditingController();
  final TextEditingController khrController = TextEditingController();
  final TextEditingController promoCodeController = TextEditingController();
  final TextEditingController pointController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchKwhData();
    fetchPriceData();
    fetchVoucherList();
    fetchPointList();

    // Set up search debounce for real-time search
    debounce(searchQuery, (String query) {
      searchVoucher(query);
    }, time: const Duration(milliseconds: 500));
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

  Future<void> fetchVoucherList() async {
    try {
      isLoadingVouchers(true);
      final response = await useCase.fetchVoucherList(context: Get.context!);
      if (response.body?.status == true) {
        voucherList.value = response.body?.data ?? [];
      } else {
        voucherList.clear();
      }
    } catch (e) {
      debugPrint("Error fetching voucher list: $e");
    } finally {
      isLoadingVouchers(false);
    }
  }

  Future<void> fetchPointList() async {
    try {
      isLoadingPoints(true);
      final response = await useCase.fetchPoint(context: Get.context!);
      if (response.body?.status == true) {
        pointList.value = response.body?.data ?? [];
      } else {
        pointList.clear();
      }
    } catch (e) {
      debugPrint("Error fetching point list: $e");
    } finally {
      isLoadingPoints(false);
    }
  }

  Future<void> searchVoucher(String code) async {
    if (code.trim().isEmpty) {
      fetchVoucherList();
      return;
    }
    try {
      isLoadingVouchers(true);
      final response = await useCase.searchVoucher(
        context: Get.context!,
        request: EvVoucherRequest(code: code.trim()),
      );

      if (response.body?.status == true) {
        final searchDataList = response.body?.data ?? [];
        voucherList.value = searchDataList.map((searchItem) {
          return list_resp.Data(
            id: searchItem.id,
            voucherCode: searchItem.voucherCode,
            voucherBatchId: searchItem.voucherBatchId,
            batchTitle: searchItem.batchTitle,
            banner: searchItem.banner,
            bannerName: searchItem.bannerName,
            discountType: searchItem.discountType,
            discountValue: searchItem.discountValue,
            expiresDate: searchItem.expiresDate,
            displayStatus: searchItem.displayStatus,
            statusText: searchItem.statusText,
          );
        }).toList();
      } else {
        voucherList.clear();
      }
    } catch (e) {
      debugPrint("Error searching vouchers: $e");
      voucherList.clear();
    } finally {
      isLoadingVouchers(false);
    }
  }

  Future<void> applySelectedVoucher(String code) async {
    if (code.trim().isEmpty) {
      Get.snackbar(
        'error'.tr,
        'Please select or enter a voucher code',
        backgroundColor: Colors.white,
        colorText: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    try {
      final response = await useCase.applyVoucher(
        context: Get.context!,
        request: EvVoucherRequest(code: code.trim()),
      );

      if (response.body?.status == true) {
        Get.snackbar(
          'success'.tr,
          response.body?.message ?? 'Voucher applied successfully',
          backgroundColor: Colors.white,
          colorText: Colors.green,
          snackPosition: SnackPosition.TOP,
        );
        promoCodeController.text = code.trim();
        Get.back();
      } else {
        Get.snackbar(
          'error'.tr,
          response.body?.message ?? 'Failed to apply voucher',
          backgroundColor: Colors.white,
          colorText: Colors.red,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        backgroundColor: Colors.white,
        colorText: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
