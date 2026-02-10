import 'package:express_vet/models/china/customer_china_response.dart';
import 'package:express_vet/models/china/list_by_province.dart';
import 'package:express_vet/models/china/province_response.dart';
import 'package:express_vet/models/china/warehouse_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/china.dart';

class ChinaController extends GetxController {
  final ChinaService chinaService = ChinaService();

  // Observables
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  // final transportMode = 'land'.tr.obs;
  final transportType = 1.obs; // 1=Land, 2=Sea, 3=Air

  // Data lists
  final provinces = <ProvinceBody>[].obs;
  final branches = <BranchByProvinceData>[].obs;
  final customerList = <CustomerChinaListData>[].obs;
  final warehouseList = <WarehouseData>[].obs;

  // Filtered lists for search
  final filteredProvinces = <ProvinceBody>[].obs;
  final filteredBranches = <BranchByProvinceData>[].obs;

  // Search controllers
  final provinceSearchText = ''.obs;
  final branchSearchText = ''.obs;

  // Selected items
  final selectedProvince = Rxn<ProvinceBody>();
  final selectedBranch = Rxn<BranchByProvinceData>();
  final selectedCustomer = Rxn<CustomerChinaListData>();
  final selectedWarehouse = Rxn<WarehouseData>();

  // Form data
  final name = ''.obs;
  final phone = ''.obs;
  final address = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();

    // Initialize filtered lists when data changes
    ever(provinces, (_) => _filterProvinces());
    ever(branches, (_) => _filterBranches());

    // Also filter when search text changes
    ever(provinceSearchText, (_) => _filterProvinces());
    ever(branchSearchText, (_) => _filterBranches());
  }

  // Helper method to get current language code for API calls
  String get _currentLanguageCode {
    final currentLocale = Get.locale?.languageCode ?? 'en';

    switch (currentLocale) {
      case 'en': // English
        return 'en';
      case 'zh': // Chinese
        return 'cn';
      default: // Khmer or other languages
        return 'kh';
    }
  }

  // Add this method to ChinaController
  bool get hasExistingCustomer {
    return customerList.isNotEmpty;
  }

  Future<void> fetchInitialData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Fetch provinces
      final provinceResponse = await chinaService.getProvinceList(
        Get.context!,
        _currentLanguageCode,
      );
      if (provinceResponse.header?.result == true) {
        provinces.value = provinceResponse.body ?? [];
        // Initialize filtered provinces
        _filterProvinces();
      } else {
        errorMessage.value = 'Failed to load provinces';
      }

      // Fetch customer list
      await fetchCustomerList();
    } catch (e) {
      errorMessage.value = 'Failed to load data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCustomerList() async {
    try {
      isLoading.value = true;
      final response = await chinaService.chinaCustomerList(Get.context!);
      if (response.body?.status == true) {
        customerList.value = response.body?.data ?? [];
        // Auto-select last registered customer if none selected
        if (selectedCustomer.value == null && customerList.isNotEmpty) {
          selectedCustomer.value = customerList.last;
        }
      }
    } catch (e) {
      print('Failed to fetch customer list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWarehouseList(int type) async {
    try {
      isLoading.value = true;
      transportType.value = type; // Update the transport type

      // Clear previous warehouse selection to trigger UI update
      selectedWarehouse.value = null;
      warehouseList.clear();

      final response = await chinaService.chinaWarehouse(Get.context!, type);
      if (response.body?.status == true) {
        warehouseList.value = response.body?.data ?? [];
        // Auto-select first warehouse if available
        if (warehouseList.isNotEmpty) {
          selectedWarehouse.value = warehouseList.first;
        } else {
          selectedWarehouse.value = null;
        }
      } else {
        warehouseList.clear();
        selectedWarehouse.value = null;
      }
    } catch (e) {
      warehouseList.clear();
      selectedWarehouse.value = null;
      print('Failed to fetch warehouse list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateTransportMode(/*String mode,*/ int type) {
    //transportMode.value = mode;
    transportType.value = type;
    fetchWarehouseList(type);
  }

  Future<void> selectProvince(ProvinceBody province) async {
    selectedProvince.value = province;
    selectedBranch.value = null; // Clear branch when province changes

    // Load branches for this province
    await loadBranches(province.id.toString());
  }

  Future<void> loadBranches(String provinceId) async {
    try {
      isLoading.value = true;
      final response = await chinaService.getBranchByProvince(
        Get.context!,
        _currentLanguageCode,
        provinceId,
      );

      if (response.body?.status == true) {
        branches.value = response.body?.data ?? [];
        // Clear search when loading new branches
        branchSearchText.value = '';
        _filterBranches(); // Update filtered list
        if (branches.isEmpty) {
          errorMessage.value = 'No branches available in this province';
        }
      } else {
        branches.clear();
        filteredBranches.clear();
        errorMessage.value = response.body?.message ?? 'Failed to load branches';
      }
    } catch (e) {
      branches.clear();
      filteredBranches.clear();
      errorMessage.value = 'Failed to load branches: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void selectBranch(BranchByProvinceData branch) {
    selectedBranch.value = branch;
    errorMessage.value = '';
  }

  void clearBranchSelection() {
    selectedBranch.value = null;
  }

  // NEW: Clear branch data when changing province
  void clearBranchData() {
    branches.clear();
    filteredBranches.clear();
    branchSearchText.value = '';
    selectedBranch.value = null;
  }

  // NEW: Clear all selections
  void clearAllSelections() {
    selectedProvince.value = null;
    selectedBranch.value = null;
    branches.clear();
    filteredBranches.clear();
    provinceSearchText.value = '';
    branchSearchText.value = '';
  }

  void selectCustomer(CustomerChinaListData customer) {
    selectedCustomer.value = customer;
  }

  void selectWarehouse(WarehouseData warehouse) {
    selectedWarehouse.value = warehouse;
  }

  // Province search methods
  void searchProvinces(String query) {
    provinceSearchText.value = query;
  }

  void _filterProvinces() {
    if (provinceSearchText.value.isEmpty) {
      filteredProvinces.value = List.from(provinces);
    } else {
      filteredProvinces.value =
          provinces.where((province) {
            final name = province.name?.toLowerCase() ?? '';
            return name.contains(provinceSearchText.value.toLowerCase());
          }).toList();
    }
  }

  void clearProvinceSearch() {
    provinceSearchText.value = '';
  }

  // Branch search methods
  void searchBranches(String query) {
    branchSearchText.value = query;
  }

  void _filterBranches() {
    if (branchSearchText.value.isEmpty) {
      filteredBranches.value = List.from(branches);
    } else {
      filteredBranches.value =
          branches.where((branch) {
            final name = branch.name?.toLowerCase() ?? '';
            return name.contains(branchSearchText.value.toLowerCase());
          }).toList();
    }
  }

  void clearBranchSearch() {
    branchSearchText.value = '';
  }

  Future<bool> registerCustomer() async {
    try {
      // Validation
      if (name.value.isEmpty) {
        errorMessage.value = 'Please enter your name';
        return false;
      }
      if (phone.value.isEmpty) {
        errorMessage.value = 'Please enter your phone number';
        return false;
      }
      if (selectedBranch.value == null) {
        errorMessage.value = 'Please select a branch';
        return false;
      }
      if (address.value.isEmpty) {
        errorMessage.value = 'Please enter your address';
        return false;
      }

      isLoading.value = true;
      errorMessage.value = '';

      final response = await chinaService.addChinaCustomer(
        Get.context!,
        address: address.value,
        branchId: selectedBranch.value!.id.toString(),
        name: name.value,
        telephone: phone.value,
      );

      if (response.header?.statusCode == 200 && response.header?.result == true) {
        // Show success message
        Get.snackbar(
          'Success',
          response.body?.message ?? 'Customer registered successfully',
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh customer list
        await fetchCustomerList();

        // Fetch warehouse data ONLY AFTER successful registration
        await fetchWarehouseList(transportType.value);

        // Clear form
        clearForm();

        return true;
      } else {
        errorMessage.value = response.body?.message ?? 'Registration failed';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Registration error: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    name.value = '';
    phone.value = '';
    address.value = '';
    selectedProvince.value = null;
    selectedBranch.value = null;
    branches.clear();
    filteredBranches.clear();
    provinceSearchText.value = '';
    branchSearchText.value = '';
    errorMessage.value = '';
  }

  // Helper getters
  bool get hasProvinces => provinces.isNotEmpty;
  bool get hasBranches => branches.isNotEmpty;
  bool get hasCustomers => customerList.isNotEmpty;
  bool get hasWarehouses => warehouseList.isNotEmpty;

  bool get isBranchSelected => selectedBranch.value != null;
  bool get isProvinceSelected => selectedProvince.value != null;
  bool get isCustomerSelected => selectedCustomer.value != null;
  bool get isWarehouseSelected => selectedWarehouse.value != null;

  // Get filtered list status
  bool get hasFilteredProvinces => filteredProvinces.isNotEmpty;
  bool get hasFilteredBranches => filteredBranches.isNotEmpty;

  // Get warehouse data for current transport type
  WarehouseData? get currentWarehouseData => selectedWarehouse.value;
}
