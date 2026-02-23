import 'package:express_vet/models/china/customer_china_response.dart';
import 'package:express_vet/models/china/list_by_province.dart';
import 'package:express_vet/models/china/province_response.dart';
import 'package:express_vet/models/china/warehouse_response.dart';
import 'package:express_vet/models/simple_response.dart';

abstract class ChinaServiceRepository {
  Future<ProvinceResponse> fetchProvinceList({required String lang});

  Future<BranchByProvinceResponse> fetchBranchByProvince({
    required String lang,
    required String provinceId,
  });

  Future<CustomerChinaListResponse> fetchCustomerList();

  Future<WarehouseResponse> fetchWarehouseList({required int type});

  Future<SimpleResponse> addChinaCustomer({
    required String address,
    required String branchId,
    required String name,
    required String telephone,
  });

  Future<SimpleResponse> updateChinaCustomer({
    required String address,
    required String branchId,
    required String name,
    required String telephone,
  });
}
