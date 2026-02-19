import 'package:express_vet/feature/home-dashboard/self_service/data/model/response/uom.dart';
import 'package:express_vet/models/destination/destination_province.dart';
import 'package:flutter/widgets.dart';

abstract class SelfServiceRepo {
  Future<ProvinceResponse> fetchProvinceList({
    required BuildContext context,
    String searchText = '',
  });

  Future<ProvinceResponse> fetchDestinationByProvince({
    required BuildContext context,
    required String provinceId,
    String searchText = '',
  });

  Future<UomListResponse> fetchUomList({required BuildContext context});
}
