import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/request/ev_voucher_apply_request.dart';
import '../../data/model/response/ev_voucher_list_response.dart';
import '../../data/model/response/ev_point_list_response.dart' as point_resp;
import '../../domain/uscase/ev_charger_usecase.dart';

class EvVoucherController extends GetxController {
  final EvChargerUseCase useCase;
  EvVoucherController(this.useCase);

  var voucherList = <Data>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  var pointList = <point_resp.Data>[].obs;
  var isLoadingPoints = false.obs;

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  String _lastSearchCode = '';
  DateTime? _lastSearchAt;

  @override
  void onInit() {
    fetchVouchers();
    fetchPoints();

    // Set up search debounce for real-time search
    debounce(searchQuery, (String query) {
      searchVoucher(query);
    }, time: const Duration(milliseconds: 500));

    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchVouchers() async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage.value = '';

      final response = await useCase.fetchVoucherList(context: Get.context!);
      if (response.body?.status == true) {
        voucherList.value = response.body?.data ?? [];
      } else {
        voucherList.clear();
        errorMessage.value =
            response.body?.message ?? 'Failed to fetch vouchers';
      }
    } catch (e) {
      hasError(true);
      errorMessage.value = e.toString();
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> addVoucher(String code) async {
    try {
      isLoading(true);
      final response = await useCase.applyVoucher(
        context: Get.context!,
        request: EvVoucherRequest(code: code),
      );

      if (response.body?.status == true) {
        Get.snackbar(
          'success'.tr,
          response.body?.message ?? 'Voucher added successfully',
          backgroundColor: Colors.white,
          colorText: Colors.green,
          snackPosition: SnackPosition.TOP,
        );
        // Reset search query and refetch voucher list in real-time
        searchQuery.value = '';
        searchController.clear();
        await fetchVouchers();
      } else {
        Get.snackbar(
          'error'.tr,
          response.body?.message ?? 'Failed to add voucher',
          backgroundColor: Colors.white,
          colorText: Colors.red,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> searchVoucher(String code) async {
    if (code.trim().isEmpty) {
       _lastSearchCode = '';
      _lastSearchAt = DateTime.now();
      fetchVouchers();
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
      isLoading(true);
      hasError(false);
      errorMessage.value = '';

      final response = await useCase.searchVoucher(
        context: Get.context!,
        request: EvVoucherRequest(code: code.trim()),
      );

      if (response.body?.status == true) {
        final searchDataList = response.body?.data ?? [];
        voucherList.value =
            searchDataList.map((searchItem) {
              return Data(
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
        errorMessage.value = response.body?.message ?? 'No vouchers found';
      }
    } catch (e) {
      hasError(true);
      errorMessage.value = e.toString();
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchPoints() async {
    try {
      isLoadingPoints(true);
      final response = await useCase.fetchPoint(context: Get.context!);
      if (response.body?.status == true) {
        pointList.value = response.body?.data ?? [];
      } else {
        pointList.clear();
      }
    } catch (e) {
      debugPrint("Error fetching point list in EvVoucherController: $e");
    } finally {
      isLoadingPoints(false);
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
