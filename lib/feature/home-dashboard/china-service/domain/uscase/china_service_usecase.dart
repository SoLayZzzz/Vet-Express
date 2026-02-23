import 'package:express_vet/models/china/customer_china_response.dart';
import 'package:express_vet/models/china/list_by_province.dart';
import 'package:express_vet/models/china/province_response.dart';
import 'package:express_vet/models/china/warehouse_response.dart';
import 'package:express_vet/models/simple_response.dart';

import '../repository/china_service_repository.dart';

class ChinaServiceUseCase {
  final ChinaServiceRepository repository;

  ChinaServiceUseCase(this.repository);

  Future<ProvinceResponse> fetchProvinceList({required String lang}) {
    return repository.fetchProvinceList(lang: lang);
  }

  Future<BranchByProvinceResponse> fetchBranchByProvince({
    required String lang,
    required String provinceId,
  }) {
    return repository.fetchBranchByProvince(lang: lang, provinceId: provinceId);
  }

  Future<CustomerChinaListResponse> fetchCustomerList() {
    return repository.fetchCustomerList();
  }

  Future<WarehouseResponse> fetchWarehouseList({required int type}) {
    return repository.fetchWarehouseList(type: type);
  }

  Future<SimpleResponse> addChinaCustomer({
    required String address,
    required String branchId,
    required String name,
    required String telephone,
  }) {
    return repository.addChinaCustomer(
      address: address,
      branchId: branchId,
      name: name,
      telephone: telephone,
    );
  }

  Future<SimpleResponse> updateChinaCustomer({
    required String address,
    required String branchId,
    required String name,
    required String telephone,
  }) {
    return repository.updateChinaCustomer(
      address: address,
      branchId: branchId,
      name: name,
      telephone: telephone,
    );
  }
}
