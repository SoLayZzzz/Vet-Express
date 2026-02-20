import 'package:express_vet/feature/home-dashboard/self_service/data/model/response/uom.dart';
import 'package:express_vet/feature/home-dashboard/self_service/data/model/response/destination_province.dart';
import 'package:flutter/widgets.dart';
import 'package:express_vet/models/request_transfer/add_goods.dart';

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

  Future<AddGoodsResponse> saveGoodsSelfService({
    required BuildContext context,
    required String destinationToId,
    required String itemQty,
    required String itemValue,
    required String receiverTelephone,
    required String senderTelephone,
    required String uomId,
  });
}
