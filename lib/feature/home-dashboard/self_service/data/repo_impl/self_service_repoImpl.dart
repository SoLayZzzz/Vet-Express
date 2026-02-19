import 'package:flutter/widgets.dart';

import '../../domain/repository/self_service_repo.dart';
import '../model/response/uom.dart';
import '../network/self_service_network_request.dart';
import 'package:express_vet/models/destination/destination_province.dart';

class SelfServiceRepoimpl implements SelfServiceRepo {
  final SelfServiceNetworkRequest selfServiceNetworkRequest;

  SelfServiceRepoimpl(this.selfServiceNetworkRequest);

  @override
  Future<ProvinceResponse> fetchProvinceList({
    required BuildContext context,
    String searchText = '',
  }) {
    return selfServiceNetworkRequest.fetchProvinceList(
      context: context,
      searchText: searchText,
    );
  }

  @override
  Future<ProvinceResponse> fetchDestinationByProvince({
    required BuildContext context,
    required String provinceId,
    String searchText = '',
  }) {
    return selfServiceNetworkRequest.fetchDestinationByProvince(
      context: context,
      provinceId: provinceId,
      searchText: searchText,
    );
  }

  @override
  Future<UomListResponse> fetchUomList({required BuildContext context}) {
    return selfServiceNetworkRequest.fetchUomList(context: context);
  }
}
