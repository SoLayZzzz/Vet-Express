import 'package:flutter/widgets.dart';

import '../../domain/repository/self_service_repo.dart';
import '../model/response/uom.dart';
import '../network/self_service_network_request.dart';
import 'package:express_vet/feature/home-dashboard/self_service/data/model/response/destination_province.dart';
import 'package:express_vet/models/request_transfer/add_goods.dart';

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

  @override
  Future<AddGoodsResponse> saveGoodsSelfService({
    required BuildContext context,
    required String destinationToId,
    required String itemQty,
    required String itemValue,
    required String receiverTelephone,
    required String senderTelephone,
    required String uomId,
  }) {
    return selfServiceNetworkRequest.saveGoodsSelfService(
      context: context,
      destinationToId: destinationToId,
      itemQty: itemQty,
      itemValue: itemValue,
      receiverTelephone: receiverTelephone,
      senderTelephone: senderTelephone,
      uomId: uomId,
    );
  }
}
