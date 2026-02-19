import 'package:express_vet/feature/home-dashboard/self_service/data/model/response/uom.dart';
import 'package:express_vet/models/destination/destination_province.dart';
import 'package:flutter/widgets.dart';

import '../repository/self_service_repo.dart';

class SelfServiceUsecase {
  final SelfServiceRepo selfServiceRepo;

  SelfServiceUsecase(this.selfServiceRepo);

  Future<ProvinceResponse> fetchProvinceList({
    required BuildContext context,
    String searchText = '',
  }) {
    return selfServiceRepo.fetchProvinceList(
      context: context,
      searchText: searchText,
    );
  }

  Future<ProvinceResponse> fetchDestinationByProvince({
    required BuildContext context,
    required String provinceId,
    String searchText = '',
  }) {
    return selfServiceRepo.fetchDestinationByProvince(
      context: context,
      provinceId: provinceId,
      searchText: searchText,
    );
  }

  Future<UomListResponse> fetchUomList({required BuildContext context}) {
    return selfServiceRepo.fetchUomList(context: context);
  }
}
