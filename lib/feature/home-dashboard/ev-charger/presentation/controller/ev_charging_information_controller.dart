import 'dart:convert';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/ev_plug_request.dart';
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

  static String formatValue(double? value) {
    if (value == null) return '';
    return value == value.toInt() ? value.toInt().toString() : value.toString();
  }

  final RxBool isKwhTab = true.obs;
  final RxInt selectedGridIndex = (-1).obs;

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
  final RxnInt selectedRedeemId = RxnInt();

  final TextEditingController kwhController = TextEditingController();
  final TextEditingController khrController = TextEditingController();
  final TextEditingController promoCodeController = TextEditingController();
  final TextEditingController pointController = TextEditingController();

  String _lastSearchCode = '';
  DateTime? _lastSearchAt;

  final FocusNode kwhFocusNode = FocusNode();
  final FocusNode khrFocusNode = FocusNode();

  final RxString chargerUsername = ''.obs;
  final RxInt plugId = 0.obs;
  final RxBool isContinuing = false.obs;

  final RxString inputAmount = ''.obs;
  final RxDouble pricePerKwh = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map) {
      chargerUsername.value = args['chargerUsername']?.toString() ?? '';
      plugId.value = int.tryParse(args['plugId']?.toString() ?? '0') ?? 0;
    }
    fetchPricePerKwh();
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
        selectedRedeemId.value = null;
      }
      inputAmount.value = kwhController.text;
    });
    khrController.addListener(() {
      if (khrController.text != inputAmount.value) {
        applyVoucherDiscount.value = null;
        applyVoucherDiscountPercentage.value = null;
        selectedRedeemId.value = null;
      }
      inputAmount.value = khrController.text;
    });

    kwhFocusNode.addListener(() {
      if (!kwhFocusNode.hasFocus && kwhController.text.isEmpty) {
        _syncTextFieldWithSelection();
      }
    });
    khrFocusNode.addListener(() {
      if (!khrFocusNode.hasFocus && khrController.text.isEmpty) {
        _syncTextFieldWithSelection();
      }
    });

    debounce(inputAmount, (_) => runPromotionCalculate(), time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    kwhController.dispose();
    khrController.dispose();
    promoCodeController.dispose();
    pointController.dispose();
    kwhFocusNode.dispose();
    khrFocusNode.dispose();
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
    selectedGridIndex.value = -1;
    kwhController.text = '';
    khrController.text = '';
    applyVoucherDiscount.value = null;
    applyVoucherDiscountPercentage.value = null;
    selectedRedeemId.value = null;
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
    selectedRedeemId.value = null;
    _syncTextFieldWithSelection();
    runPromotionCalculate();
  }

  /// Returns the display text for the currently selected option on the active tab.
  String getSelectedOptionValue() {
    final index = selectedGridIndex.value;
    final list = isKwhTab.value ? kwhList : priceList;
    if (list.isNotEmpty && index >= 0 && index < list.length) {
      final item = list[index];
      return formatValue(item.value);
    }
    return "";
  }

  void _syncTextFieldWithSelection() {
    final text = getSelectedOptionValue();
    if (text.isEmpty) return;
    if (isKwhTab.value) {
      kwhController.value = kwhController.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    } else {
      khrController.value = khrController.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  bool get canContinue {
    final text = inputAmount.value.trim().replaceAll(',', '');
    if (text.isEmpty) return false;
    final value = double.tryParse(text);
    return value != null && value > 0;
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
      _lastSearchCode = '';
      _lastSearchAt = DateTime.now();
      fetchVoucherList();
      return;
    }

    if (code.trim() == _lastSearchCode &&
        _lastSearchAt != null &&
        DateTime.now().difference(_lastSearchAt!).inMilliseconds <= 600) {
      return;
    }

    _lastSearchCode = code.trim();
    _lastSearchAt = DateTime.now();

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

    promoCodeController.text = code.trim();
    calculateResponse.value = null;
    applyVoucherDiscount.value = null;
    applyVoucherDiscountPercentage.value = null;

    await runPromotionCalculate();

    final response = calculateResponse.value;
    if (response?.body?.status == true) {
      final calculatedData = response?.body?.data;
      applyVoucherDiscount.value = calculatedData?.discountAmountKhr;
      applyVoucherDiscountPercentage.value = calculatedData?.discountPercentage;
      Get.snackbar(
        'success'.tr,
        response?.body?.message ?? 'Promotion applied successfully',
        backgroundColor: Colors.white,
        colorText: Colors.green,
        snackPosition: SnackPosition.TOP,
      );
      Get.back();
    } else {
      Get.snackbar(
        'error'.tr,
        response?.body?.message ?? 'Failed to apply promotion',
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

  double get _rate => pricePerKwh.value > 0 ? pricePerKwh.value : 2400.0;

  Future<void> fetchPricePerKwh() async {
    final username = chargerUsername.value.isEmpty ? 'ev01' : chargerUsername.value;
    try {
      final res = await useCase.evPricePerWkh(
        context: Get.context!,
        request: EvPlugRequest(chargerUserName: username),
      );
      if (res.header?.result == true && res.header?.statusCode == 200) {
        pricePerKwh.value = res.body?.data?.pricePerKwh ?? 2400.0;
      } else {
        pricePerKwh.value = 2400.0;
      }
    } catch (e) {
      debugPrint('Error fetching price per kWh: $e');
      pricePerKwh.value = 2400.0;
    } finally {
      runPromotionCalculate();
    }
  }

  int getCalculatedTotalKwh() {
    if (isKwhTab.value) {
      final text = kwhController.text.trim();
      if (text.isEmpty) return 0;
      final val = double.tryParse(text) ?? 0.0;
      return val.round();
    } else {
      final text = khrController.text.replaceAll(',', '').trim();
      if (text.isEmpty) return 0;
      final priceVal = double.tryParse(text) ?? 0.0;
      return (priceVal / _rate).round();
    }
  }

  double getCalculatedTotalPrice() {
    if (isKwhTab.value) {
      final text = kwhController.text.trim();

      if (text == "Full Charge") {
        for (var item in kwhList) {
          if (item.isFullCharge == 1) {
            return (item.value ?? 999.0) * _rate;
          }
        }
        return 999.0 * _rate;
      }

      if (text.isEmpty) return 0.0;
      final val = double.tryParse(text) ?? 0.0;
      return val * _rate;
    } else {
      final text = khrController.text.replaceAll(',', '').trim();

      if (text == "Full Charge") {
        for (var item in priceList) {
          if (item.isFullCharge == 1) {
            return item.value ?? 100000.0;
          }
        }
        return 100000.0;
      }

      if (text.isEmpty) return 0.0;
      return double.tryParse(text) ?? 0.0;
    }
  }

  // int getCalculatedTotalPrice() {
  //   if (isKwhTab.value) {
  //     final text = kwhController.text.trim();
  //     if (text == "Full Charge" || text.isEmpty) {
  //       for (var item in kwhList) {
  //         if (item.isFullCharge == 1) {
  //           return ((item.value ?? 999.0) * 2400).round();
  //         }
  //       }
  //       return (999.0 * 2400).round();
  //     }
  //     final val = double.tryParse(text) ?? 10.0;
  //     return (val * 2400).round();
  //   } else {
  //     final text = khrController.text.replaceAll(',', '').trim();
  //     if (text == "Full Charge" || text.isEmpty) {
  //       for (var item in priceList) {
  //         if (item.isFullCharge == 1) {
  //           return (item.value ?? 100000.0).round();
  //         }
  //       }
  //       return 100000;
  //     }
  //     final priceVal = double.tryParse(text) ?? 12000.0;
  //     return priceVal.round();
  //   }
  // }

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

  double getCalculatedGrandTotalPrice() {
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
        // paymentMethod: 3,
        paymentMethod: 5,
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

      if (response.header?.statusCode == 200 && response.body?.status == true) {
        didNavigate = true;
        Loading().loadingClose();
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
      // Get.snackbar(
      //   'error'.tr,
      //   e.toString(),
      //   backgroundColor: Colors.white,
      //   colorText: Colors.red,
      //   snackPosition: SnackPosition.TOP,
      // );
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
        redeemId: selectedRedeemId.value,
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

  Future<void> applyPoint(int redeemId) async {
    selectedRedeemId.value = redeemId;
    applyVoucherDiscount.value = null;
    applyVoucherDiscountPercentage.value = null;
    await runPromotionCalculate();
  }
}
