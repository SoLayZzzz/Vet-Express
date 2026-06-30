import 'package:express_vet/models/china/customer_china_response.dart';
import 'package:express_vet/models/china/list_by_province.dart';
import 'package:express_vet/models/china/province_response.dart';
import 'package:express_vet/models/china/warehouse_response.dart';

class ChinaUiState {
  static const Object _unset = Object();

  final bool isLoading;
  final String errorMessage;
  final int transportType;

  final List<ProvinceBody> provinces;
  final List<ProvinceBody> filteredProvinces;
  final String provinceSearchText;

  final List<BranchByProvinceData> branches;
  final List<BranchByProvinceData> filteredBranches;
  final String branchSearchText;

  final List<CustomerChinaListData> customerList;
  final List<WarehouseData> warehouseList;

  final ProvinceBody? selectedProvince;
  final BranchByProvinceData? selectedBranch;
  final CustomerChinaListData? selectedCustomer;
  final WarehouseData? selectedWarehouse;

  const ChinaUiState({
    required this.isLoading,
    required this.errorMessage,
    required this.transportType,
    required this.provinces,
    required this.filteredProvinces,
    required this.provinceSearchText,
    required this.branches,
    required this.filteredBranches,
    required this.branchSearchText,
    required this.customerList,
    required this.warehouseList,
    required this.selectedProvince,
    required this.selectedBranch,
    required this.selectedCustomer,
    required this.selectedWarehouse,
  });

  factory ChinaUiState.initial() => const ChinaUiState(
        isLoading: false,
        errorMessage: '',
        transportType: 1,
        provinces: <ProvinceBody>[],
        filteredProvinces: <ProvinceBody>[],
        provinceSearchText: '',
        branches: <BranchByProvinceData>[],
        filteredBranches: <BranchByProvinceData>[],
        branchSearchText: '',
        customerList: <CustomerChinaListData>[],
        warehouseList: <WarehouseData>[],
        selectedProvince: null,
        selectedBranch: null,
        selectedCustomer: null,
        selectedWarehouse: null,
      );

  ChinaUiState copyWith({
    bool? isLoading,
    String? errorMessage,
    int? transportType,
    List<ProvinceBody>? provinces,
    List<ProvinceBody>? filteredProvinces,
    String? provinceSearchText,
    List<BranchByProvinceData>? branches,
    List<BranchByProvinceData>? filteredBranches,
    String? branchSearchText,
    List<CustomerChinaListData>? customerList,
    List<WarehouseData>? warehouseList,
    Object? selectedProvince = _unset,
    Object? selectedBranch = _unset,
    Object? selectedCustomer = _unset,
    Object? selectedWarehouse = _unset,
  }) {
    return ChinaUiState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      transportType: transportType ?? this.transportType,
      provinces: provinces ?? this.provinces,
      filteredProvinces: filteredProvinces ?? this.filteredProvinces,
      provinceSearchText: provinceSearchText ?? this.provinceSearchText,
      branches: branches ?? this.branches,
      filteredBranches: filteredBranches ?? this.filteredBranches,
      branchSearchText: branchSearchText ?? this.branchSearchText,
      customerList: customerList ?? this.customerList,
      warehouseList: warehouseList ?? this.warehouseList,
      selectedProvince:
          identical(selectedProvince, _unset)
              ? this.selectedProvince
              : selectedProvince as ProvinceBody?,
      selectedBranch:
          identical(selectedBranch, _unset)
              ? this.selectedBranch
              : selectedBranch as BranchByProvinceData?,
      selectedCustomer:
          identical(selectedCustomer, _unset)
              ? this.selectedCustomer
              : selectedCustomer as CustomerChinaListData?,
      selectedWarehouse:
          identical(selectedWarehouse, _unset)
              ? this.selectedWarehouse
              : selectedWarehouse as WarehouseData?,
    );
  }
}
