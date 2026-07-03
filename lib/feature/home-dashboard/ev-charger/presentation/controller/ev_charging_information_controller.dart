import 'dart:convert';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/amount_price_kwh_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_sale_order_apptmp_res.dart' show EvSaleOrderApptmpResponse;
import 'package:express_vet/feature/home-dashboard/ev-charger/domain/uscase/ev_charger_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/ev_calculate_request.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_calculate_reponse.dart' as calc_resp;
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_voucher_list_response.dart'
    as list_resp;
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_point_list_response.dart'
    as point_resp;
import '../../data/model/request/ev_voucher_apply_request.dart';
import '../../data/model/request/ev_sale_order_apptmp_request.dart';
import '../../../../../routes/app_routes.dart';
import 'package:express_vet/utils/loading.dart';

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

  final Rxn<calc_resp.EvCalculateResponse> calculateResponse = Rxn<calc_resp.EvCalculateResponse>();
  final RxBool isLoadingCalculate = false.obs;

  final RxList<list_resp.Data> voucherList = <list_resp.Data>[].obs;
  final RxBool isLoadingVouchers = false.obs;
  final RxString selectedVoucherCode = ''.obs;
  final RxString searchQuery = ''.obs;

  final RxnDouble applyVoucherDiscount = RxnDouble();
  final RxnDouble applyVoucherDiscountPercentage = RxnDouble();

  final RxList<point_resp.Data> pointList = <point_resp.Data>[].obs;
  final RxBool isLoadingPoints = false.obs;

  final TextEditingController kwhController = TextEditingController();
  final TextEditingController khrController = TextEditingController();
  final TextEditingController promoCodeController = TextEditingController();
  final TextEditingController pointController = TextEditingController();

  final RxString chargerUsername = ''.obs;
  final RxInt plugId = 0.obs;
  final RxBool isContinuing = false.obs;

  final RxString inputAmount = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map) {
      chargerUsername.value = args['chargerUsername']?.toString() ?? '';
      plugId.value = int.tryParse(args['plugId']?.toString() ?? '0') ?? 0;
    }
    fetchKwhData();
    fetchPriceData();
    fetchVoucherList();
    fetchPointList();

    // Set up search debounce for real-time search
    debounce(searchQuery, (String query) {
      searchVoucher(query);
    }, time: const Duration(milliseconds: 500));

    kwhController.addListener(() {
      if (kwhController.text != inputAmount.value) {
        applyVoucherDiscount.value = null;
        applyVoucherDiscountPercentage.value = null;
      }
      inputAmount.value = kwhController.text;
    });
    khrController.addListener(() {
      if (khrController.text != inputAmount.value) {
        applyVoucherDiscount.value = null;
        applyVoucherDiscountPercentage.value = null;
      }
      inputAmount.value = khrController.text;
    });

    debounce(inputAmount, (_) => runPromotionCalculate(), time: const Duration(milliseconds: 500));
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
      runPromotionCalculate();
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
      runPromotionCalculate();
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
    applyVoucherDiscount.value = null;
    applyVoucherDiscountPercentage.value = null;
    _syncTextFieldWithSelection();
    runPromotionCalculate();

    // Refresh data when switching tabs (real-time fetch)
    if (isKwh) {
      fetchKwhData();
    } else {
      fetchPriceData();
    }
  }

  void selectGridItem(int index) {
    selectedGridIndex.value = index;
    applyVoucherDiscount.value = null;
    applyVoucherDiscountPercentage.value = null;
    _syncTextFieldWithSelection();
    runPromotionCalculate();
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
        applyVoucherDiscount.value = response.body?.discount;
        applyVoucherDiscountPercentage.value = response.body?.discountPercentage;
        runPromotionCalculate();
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

  list_resp.Data? getAppliedVoucher() {
    final code = promoCodeController.text.trim();
    if (code.isEmpty) return null;
    for (var v in voucherList) {
      if (v.voucherCode == code) return v;
    }
    return null;
  }

  int getCalculatedTotalKwh() {
    if (isKwhTab.value) {
      final text = kwhController.text.trim();
      if (text == "Full Charge" || text.isEmpty) {
        for (var item in kwhList) {
          if (item.isFullCharge == 1) {
            return (item.value ?? 999.0).round();
          }
        }
        return 999;
      }
      final val = double.tryParse(text) ?? 10.0;
      return val.round();
    } else {
      final text = khrController.text.replaceAll(',', '').trim();
      if (text == "Full Charge" || text.isEmpty) {
        for (var item in priceList) {
          if (item.isFullCharge == 1) {
            return ((item.value ?? 100000.0) / 2400).round();
          }
        }
        return 42;
      }
      final priceVal = double.tryParse(text) ?? 12000.0;
      return (priceVal / 2400).round();
    }
  }

  int getCalculatedTotalPrice() {
    if (isKwhTab.value) {
      final text = kwhController.text.trim();
      if (text == "Full Charge" || text.isEmpty) {
        for (var item in kwhList) {
          if (item.isFullCharge == 1) {
            return ((item.value ?? 999.0) * 2400).round();
          }
        }
        return (999.0 * 2400).round();
      }
      final val = double.tryParse(text) ?? 10.0;
      return (val * 2400).round();
    } else {
      final text = khrController.text.replaceAll(',', '').trim();
      if (text == "Full Charge" || text.isEmpty) {
        for (var item in priceList) {
          if (item.isFullCharge == 1) {
            return (item.value ?? 100000.0).round();
          }
        }
        return 100000;
      }
      final priceVal = double.tryParse(text) ?? 12000.0;
      return priceVal.round();
    }
  }

  int getCalculatedDiscount() {
    if (applyVoucherDiscount.value != null) {
      return applyVoucherDiscount.value!.round();
    }
    final apiDiscount = calculateResponse.value?.body?.data?.discountAmountKhr;
    if (apiDiscount != null) {
      return apiDiscount.round();
    }

    final totalPrice = getCalculatedTotalPrice();
    final voucher = getAppliedVoucher();
    if (voucher != null) {
      if (voucher.discountType == 1) {
        final pct = voucher.discountValue ?? 0.0;
        return ((totalPrice * pct) / 100).round();
      } else {
        final val = voucher.discountValue ?? 0.0;
        return val <= 100 ? (val * 4000).round() : val.round();
      }
    }
    return 0;
  }

  int getCalculatedDiscountPercentage() {
    if (applyVoucherDiscountPercentage.value != null) {
      return applyVoucherDiscountPercentage.value!.round();
    }
    final apiPct = calculateResponse.value?.body?.data?.discountPercentage;
    if (apiPct != null) {
      return apiPct.round();
    }

    final voucher = getAppliedVoucher();
    if (voucher != null) {
      if (voucher.discountType == 1) {
        return (voucher.discountValue ?? 0.0).round();
      }
    }
    return 0;
  }

  int getCalculatedGrandTotalPrice() {
    final totalPrice = getCalculatedTotalPrice();
    final discount = getCalculatedDiscount();
    final grandTotal = totalPrice - discount;
    return grandTotal < 0 ? 0 : grandTotal;
  }

  Future<EvSaleOrderApptmpResponse?> createSaleOrderAppTmp() async {
    if (isContinuing.value) return null;
    isContinuing.value = true;
    Loading().loadingShow();
    bool didNavigate = false;

    try {
      final appliedVoucher = getAppliedVoucher();
      final request = EvSaleOrderApptmpRequest(
        chargerUsername: chargerUsername.value.isEmpty ? 'ev01' : chargerUsername.value,
        plugId: plugId.value == 0 ? 1 : plugId.value,
        paymentMethod: 3,
        discountPercentage: getCalculatedDiscountPercentage(),
        discount: getCalculatedDiscount(),
        voucherId: appliedVoucher?.id ?? 0,
        membershipRedeemId: 0,
        totalKwh: getCalculatedTotalKwh(),
        totalPrice: getCalculatedTotalPrice(),
        grandTotalPrice: getCalculatedGrandTotalPrice(),
      );

      debugPrint("ev sale order apptmp request: ${jsonEncode(request.toJson())}");

      final response = await useCase.evSaleOrderApptmp(
        context: Get.context!,
        request: request,
      );

      debugPrint("ev sale order apptmp response: ${jsonEncode(response.toJson())}");

      if (response.header?.statusCode == 200) {
        Loading().loadingClose();
        didNavigate = true;
        await Future.delayed(const Duration(milliseconds: 100));
        Get.toNamed(
          AppRoutes.evVerification,
          arguments: response,
        );
        return response;
      }

      Get.snackbar(
        'error'.tr,
        response.body?.message ?? 'Failed to create sale order',
        backgroundColor: Colors.white,
        colorText: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        backgroundColor: Colors.white,
        colorText: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    } finally {
      if (!didNavigate) {
        Loading().loadingClose();
      }
      isContinuing.value = false;
    }
  }

  Future<void> runPromotionCalculate() async {
    final charger = chargerUsername.value.isEmpty ? 'ev01' : chargerUsername.value;
    final totalPrice = getCalculatedTotalPrice();
    final amountKh = totalPrice.toString();
    final voucher = getAppliedVoucher();
    final voucherId = voucher?.id;

    try {
      isLoadingCalculate(true);
      final req = EvCalculateRequest(
        chargerUserName: charger,
        voucherId: voucherId ?? 0,
        amountKh: amountKh,
      );
      
      final res = await useCase.evCalculate(
        context: Get.context!,
        request: req,
      );
      calculateResponse.value = res;
    } catch (e) {
      debugPrint("Error running promotion calculate: $e");
    } finally {
      isLoadingCalculate(false);
    }
  }
}
