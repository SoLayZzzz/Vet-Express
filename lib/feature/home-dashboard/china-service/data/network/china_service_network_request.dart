import 'dart:async';

import 'package:express_vet/base/network_data_source.dart';
import 'package:express_vet/models/china/customer_china_response.dart';
import 'package:express_vet/models/china/list_by_province.dart';
import 'package:express_vet/models/china/province_response.dart';
import 'package:express_vet/models/china/warehouse_response.dart';
import 'package:express_vet/models/simple_response.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../utils/contains.dart';

class ChinaServiceNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  ChinaServiceNetworkRequest(this.netWorkDataSource);

  Future<ProvinceResponse> fetchProvinceList({required String lang}) async {
    final json = await netWorkDataSource.postJson(
      Endpoint.provinceList,
      body: <String, dynamic>{'lang': lang},
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return ProvinceResponse.fromJson(json);
  }

  Future<BranchByProvinceResponse> fetchBranchByProvince({
    required String lang,
    required String provinceId,
  }) async {
    final json = await netWorkDataSource.postJson(
      Endpoint.branchListByProvince,
      body: <String, dynamic>{'lang': lang, 'provinceId': provinceId},
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return BranchByProvinceResponse.fromJson(json);
  }

  Future<CustomerChinaListResponse> fetchCustomerList() async {
    final json = await netWorkDataSource.postJson(
      Endpoint.chinaCustomerList,
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return CustomerChinaListResponse.fromJson(json);
  }

  Future<WarehouseResponse> fetchWarehouseList({required int type}) async {
    final json = await netWorkDataSource.postJson(
      Endpoint.chinaCustomerWarehouseList,
      body: <String, dynamic>{'type': type},
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return WarehouseResponse.fromJson(json);
  }

  Future<SimpleResponse> addChinaCustomer({
    required String address,
    required String branchId,
    required String name,
    required String telephone,
  }) async {
    final json = await netWorkDataSource.postMultipart(
      Endpoint.chinaCustomerAdd,
      fields: <String, String>{
        'address': address,
        'branch_id': branchId,
        'name': name,
        'telephone': telephone,
      },
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return SimpleResponse.fromJson(json);
  }

  Future<SimpleResponse> updateChinaCustomer({
    required String address,
    required String branchId,
    required String name,
    required String telephone,
  }) async {
    final json = await netWorkDataSource.postMultipart(
      Endpoint.chinaCustomerUpdate,
      fields: <String, String>{
        'address': address,
        'branch_id': branchId,
        'name': name,
        'telephone': telephone,
      },
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return SimpleResponse.fromJson(json);
  }
}
