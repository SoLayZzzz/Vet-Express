import 'package:express_vet/models/china/customer_china_response.dart';
import 'package:express_vet/models/china/list_by_province.dart';
import 'package:express_vet/models/china/province_response.dart';
import 'package:express_vet/models/china/warehouse_response.dart';
import 'package:express_vet/models/simple_response.dart';

import '../../domain/repository/china_service_repository.dart';
import '../network/china_service_network_request.dart';

class ChinaServiceRepositoryImpl implements ChinaServiceRepository {
  final ChinaServiceNetworkRequest networkRequest;

  ChinaServiceRepositoryImpl(this.networkRequest);

  @override
  Future<ProvinceResponse> fetchProvinceList({required String lang}) {
    return networkRequest.fetchProvinceList(lang: lang);
  }

  @override
  Future<BranchByProvinceResponse> fetchBranchByProvince({
    required String lang,
    required String provinceId,
  }) {
    return networkRequest.fetchBranchByProvince(
      lang: lang,
      provinceId: provinceId,
    );
  }

  @override
  Future<CustomerChinaListResponse> fetchCustomerList() {
    return networkRequest.fetchCustomerList();
  }

  @override
  Future<WarehouseResponse> fetchWarehouseList({required int type}) {
    return networkRequest.fetchWarehouseList(type: type);
  }

  @override
  Future<SimpleResponse> addChinaCustomer({
    required String address,
    required String branchId,
    required String name,
    required String telephone,
  }) {
    return networkRequest.addChinaCustomer(
      address: address,
      branchId: branchId,
      name: name,
      telephone: telephone,
    );
  }

  @override
  Future<SimpleResponse> updateChinaCustomer({
    required String address,
    required String branchId,
    required String name,
    required String telephone,
  }) {
    return networkRequest.updateChinaCustomer(
      address: address,
      branchId: branchId,
      name: name,
      telephone: telephone,
    );
  }
}
