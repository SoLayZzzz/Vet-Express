import 'dart:async';

import 'package:express_vet/base/state_controller.dart';
import 'package:express_vet/models/china/customer_china_response.dart';
import 'package:express_vet/models/china/list_by_province.dart';
import 'package:express_vet/models/china/province_response.dart';
import 'package:express_vet/models/china/warehouse_response.dart';
import 'package:express_vet/models/simple_response.dart';
import 'package:get/get.dart';

import '../../domain/uscase/china_service_usecase.dart';
import '../uiState/china_ui_state.dart';
import '../../../../../controller/connectivity_controller.dart';

class ChinaController extends StateController<ChinaUiState> {
  final ChinaServiceUseCase useCase;

  ChinaController(this.useCase);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final transportType = 1.obs;

  final provinces = <ProvinceBody>[].obs;
  final filteredProvinces = <ProvinceBody>[].obs;
  final provinceSearchText = ''.obs;

  final branches = <BranchByProvinceData>[].obs;
  final filteredBranches = <BranchByProvinceData>[].obs;
  final branchSearchText = ''.obs;

  final customerList = <CustomerChinaListData>[].obs;
  final warehouseList = <WarehouseData>[].obs;

  final selectedProvince = Rxn<ProvinceBody>();
  final selectedBranch = Rxn<BranchByProvinceData>();
  final selectedCustomer = Rxn<CustomerChinaListData>();
  final selectedWarehouse = Rxn<WarehouseData>();

  final name = ''.obs;
  final phone = ''.obs;
  final address = ''.obs;

  @override
  ChinaUiState onInitUiState() => ChinaUiState.initial();

  @override
  void onInit() {
    super.onInit();

    ever<ChinaUiState>(uiState, (_) {
      _syncLegacyState();
    });
    _syncLegacyState();

    ever(Get.find<ConnectivityController>().isConnected, (bool connected) {
      if (connected) {
        fetchInitialData();
      }
    });

    fetchInitialData();
  }

  void _syncLegacyState() {
    isLoading.value = state.isLoading;
    errorMessage.value = state.errorMessage;
    transportType.value = state.transportType;

    provinces.assignAll(state.provinces);
    filteredProvinces.assignAll(state.filteredProvinces);
    provinceSearchText.value = state.provinceSearchText;

    branches.assignAll(state.branches);
    filteredBranches.assignAll(state.filteredBranches);
    branchSearchText.value = state.branchSearchText;

    customerList.assignAll(state.customerList);
    warehouseList.assignAll(state.warehouseList);

    selectedProvince.value = state.selectedProvince;
    selectedBranch.value = state.selectedBranch;
    selectedCustomer.value = state.selectedCustomer;
    selectedWarehouse.value = state.selectedWarehouse;
  }

  String get _currentLanguageCode {
    final currentLocale = Get.locale?.languageCode ?? 'en';

    switch (currentLocale) {
      case 'en':
        return 'en';
      case 'zh':
        return 'cn';
      default:
        return 'kh';
    }
  }

  bool get hasExistingCustomer => state.customerList.isNotEmpty;

  bool get hasProvinces => state.provinces.isNotEmpty;
  bool get hasBranches => state.branches.isNotEmpty;
  bool get hasCustomers => state.customerList.isNotEmpty;
  bool get hasWarehouses => state.warehouseList.isNotEmpty;

  bool get isProvinceSelected => state.selectedProvince != null;
  bool get isBranchSelected => state.selectedBranch != null;

  Future<void> fetchInitialData() async {
    uiState.value = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final provinceResponse = await useCase.fetchProvinceList(
        lang: _currentLanguageCode,
      );

      if (provinceResponse.header?.result == true) {
        final provinces = provinceResponse.body ?? <ProvinceBody>[];
        uiState.value = state.copyWith(
          provinces: provinces,
          filteredProvinces: provinces,
        );
      } else {
        uiState.value = state.copyWith(
          errorMessage: 'Failed to load provinces',
        );
      }

      await fetchCustomerList();
    } on TimeoutException {
      uiState.value = state.copyWith(errorMessage: 'request_timed_out'.tr);
      rethrow;
    } catch (e) {
      uiState.value = state.copyWith(errorMessage: 'Failed to load data: $e');
    } finally {
      uiState.value = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchCustomerList() async {
    uiState.value = state.copyWith(isLoading: true);

    try {
      final response = await useCase.fetchCustomerList();
      if (response.body?.status == true) {
        final list = response.body?.data ?? <CustomerChinaListData>[];
        uiState.value = state.copyWith(
          customerList: list,
          selectedCustomer:
              state.selectedCustomer ?? (list.isNotEmpty ? list.last : null),
        );
      }
    } finally {
      uiState.value = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchWarehouseList(int type) async {
    uiState.value = state.copyWith(
      isLoading: true,
      transportType: type,
      selectedWarehouse: null,
      warehouseList: <WarehouseData>[],
    );

    try {
      final response = await useCase.fetchWarehouseList(type: type);
      if (response.body?.status == true) {
        final list = response.body?.data ?? <WarehouseData>[];
        uiState.value = state.copyWith(
          warehouseList: list,
          selectedWarehouse: list.isNotEmpty ? list.first : null,
        );
      } else {
        uiState.value = state.copyWith(
          warehouseList: <WarehouseData>[],
          selectedWarehouse: null,
        );
      }
    } finally {
      uiState.value = state.copyWith(isLoading: false);
    }
  }

  void updateTransportMode(int type) {
    fetchWarehouseList(type);
  }

  Future<void> selectProvince(ProvinceBody province) async {
    uiState.value = state.copyWith(
      selectedProvince: province,
      selectedBranch: null,
    );

    await loadBranches(province.id.toString());
  }

  Future<void> loadBranches(String provinceId) async {
    uiState.value = state.copyWith(
      isLoading: true,
      branchSearchText: '',
      errorMessage: '',
    );

    try {
      final response = await useCase.fetchBranchByProvince(
        lang: _currentLanguageCode,
        provinceId: provinceId,
      );

      if (response.body?.status == true) {
        final branches = response.body?.data ?? <BranchByProvinceData>[];
        uiState.value = state.copyWith(
          branches: branches,
          filteredBranches: branches,
        );

        if (branches.isEmpty) {
          uiState.value = state.copyWith(
            errorMessage: 'No branches available in this province',
          );
        }
      } else {
        uiState.value = state.copyWith(
          branches: <BranchByProvinceData>[],
          filteredBranches: <BranchByProvinceData>[],
          errorMessage: response.body?.message ?? 'Failed to load branches',
        );
      }
    } catch (e) {
      uiState.value = state.copyWith(
        branches: <BranchByProvinceData>[],
        filteredBranches: <BranchByProvinceData>[],
        errorMessage: 'Failed to load branches: $e',
      );
    } finally {
      uiState.value = state.copyWith(isLoading: false);
    }
  }

  void selectBranch(BranchByProvinceData branch) {
    uiState.value = state.copyWith(selectedBranch: branch, errorMessage: '');
  }

  void clearBranchSelection() {
    uiState.value = state.copyWith(selectedBranch: null);
  }

  void clearBranchData() {
    uiState.value = state.copyWith(
      branches: <BranchByProvinceData>[],
      filteredBranches: <BranchByProvinceData>[],
      branchSearchText: '',
      selectedBranch: null,
    );
  }

  void clearAllSelections() {
    uiState.value = state.copyWith(
      selectedProvince: null,
      selectedBranch: null,
      branches: <BranchByProvinceData>[],
      filteredBranches: <BranchByProvinceData>[],
      provinceSearchText: '',
      branchSearchText: '',
    );
  }

  void selectCustomer(CustomerChinaListData customer) {
    uiState.value = state.copyWith(selectedCustomer: customer);
  }

  void selectWarehouse(WarehouseData warehouse) {
    uiState.value = state.copyWith(selectedWarehouse: warehouse);
  }

  void searchProvinces(String query) {
    final text = query;
    final filtered =
        text.isEmpty
            ? List<ProvinceBody>.from(state.provinces)
            : state.provinces
                .where(
                  (p) =>
                      (p.name ?? '').toLowerCase().contains(text.toLowerCase()),
                )
                .toList();

    uiState.value = state.copyWith(
      provinceSearchText: text,
      filteredProvinces: filtered,
    );
  }

  void clearProvinceSearch() {
    uiState.value = state.copyWith(
      provinceSearchText: '',
      filteredProvinces: List<ProvinceBody>.from(state.provinces),
    );
  }

  void searchBranches(String query) {
    final text = query;
    final filtered =
        text.isEmpty
            ? List<BranchByProvinceData>.from(state.branches)
            : state.branches
                .where(
                  (b) =>
                      (b.name ?? '').toLowerCase().contains(text.toLowerCase()),
                )
                .toList();

    uiState.value = state.copyWith(
      branchSearchText: text,
      filteredBranches: filtered,
    );
  }

  void clearBranchSearch() {
    uiState.value = state.copyWith(
      branchSearchText: '',
      filteredBranches: List<BranchByProvinceData>.from(state.branches),
    );
  }

  Future<SimpleResponse> addChinaCustomer({
    required String address,
    required String branchId,
    required String name,
    required String telephone,
  }) {
    return useCase.addChinaCustomer(
      address: address,
      branchId: branchId,
      name: name,
      telephone: telephone.replaceAll(' ', ''),
    );
  }

  Future<SimpleResponse> updateChinaCustomer({
    required String address,
    required String branchId,
    required String name,
    required String telephone,
  }) {
    return useCase.updateChinaCustomer(
      address: address,
      branchId: branchId,
      name: name,
      telephone: telephone.replaceAll(' ', ''),
    );
  }

  Future<bool> registerCustomer() async {
    final branchId = selectedBranch.value?.id?.toString() ?? '';
    if (branchId.isEmpty) {
      errorMessage.value = 'please_select_branch'.tr;
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';
    uiState.value = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final res = await addChinaCustomer(
        address: address.value,
        branchId: branchId,
        name: name.value,
        telephone: phone.value,
      );

      final ok = res.header?.result == true && res.header?.statusCode == 200;
      if (!ok) {
        errorMessage.value = 'try_again'.tr;
        uiState.value = state.copyWith(errorMessage: errorMessage.value);
        return false;
      }

      if (res.body?.status != true) {
        errorMessage.value = res.body?.message ?? 'try_again'.tr;
        uiState.value = state.copyWith(errorMessage: errorMessage.value);
        return false;
      }

      await fetchCustomerList();
      return true;
    } on TimeoutException {
      errorMessage.value = 'request_timed_out'.tr;
      uiState.value = state.copyWith(errorMessage: errorMessage.value);
      rethrow;
    } catch (e) {
      errorMessage.value = e.toString();
      uiState.value = state.copyWith(errorMessage: errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
      uiState.value = state.copyWith(isLoading: false);
    }
  }
}
