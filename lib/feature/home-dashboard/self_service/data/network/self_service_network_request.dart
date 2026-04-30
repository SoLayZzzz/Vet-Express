import 'dart:io';

import 'package:express_vet/base/endpoint.dart';
import 'package:express_vet/base/network_data_source.dart';
import 'package:express_vet/feature/home-dashboard/self_service/data/model/response/destination_province.dart';
import '../../../../../utils/contains.dart';
import '../model/response/uom.dart';
import 'package:express_vet/models/request_transfer/add_goods.dart';

class SelfServiceNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  SelfServiceNetworkRequest(this.netWorkDataSource);

  Future<ProvinceResponse> fetchProvinceList({
    required dynamic context,
    String searchText = '',
  }) async {
    final json = await netWorkDataSource.postJson(
      Endpoint.destinationsProvince,
      body: <String, dynamic>{
        'page': '1',
        'rowsPerPage': '100',
        'searchText': searchText,
      },
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return ProvinceResponse.fromJson(json);
  }

  Future<ProvinceResponse> fetchDestinationByProvince({
    required dynamic context,
    required String provinceId,
    String searchText = '',
  }) async {
    final json = await netWorkDataSource.postJson(
      Endpoint.destinationsDestinationByProvince,
      body: <String, dynamic>{
        'page': '1',
        'rowsPerPage': '100',
        'provinceId': provinceId,
        'searchText': searchText,
      },
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return ProvinceResponse.fromJson(json);
  }

  Future<UomListResponse> fetchUomList({required dynamic context}) async {
    final json = await netWorkDataSource.postJson(
      Endpoint.uomList,
      body: <String, dynamic>{},
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return UomListResponse.fromJson(json);
  }

  Future<AddGoodsResponse> saveGoodsSelfService({
    required dynamic context,
    required String destinationToId,
    required String itemQty,
    required String itemValue,
    required String receiverTelephone,
    required String senderTelephone,
    required String uomId,
  }) async {
    const maxAttempts = 3;
    int attempt = 0;
    while (true) {
      try {
        final json = await netWorkDataSource.postFormUrlEncoded(
          Endpoint.requestTransferAddGoods,
          fields: <String, String>{
            'destinationToId': destinationToId,
            'itemQty': itemQty,
            'itemValue': itemValue,
            'receiverTelephone': receiverTelephone,
            'senderTelephone': senderTelephone,
            'uomId': uomId,
          },
          timeout: const Duration(seconds: Constrains.timeout30),
          attachAuth: true,
        );
        return AddGoodsResponse.fromJson(json);
      } on SocketException catch (_) {
        if (++attempt >= maxAttempts) rethrow;
        await Future.delayed(const Duration(milliseconds: 800));
        continue;
      } on HttpException catch (_) {
        if (++attempt >= maxAttempts) rethrow;
        await Future.delayed(const Duration(milliseconds: 800));
        continue;
      } catch (_) {
        rethrow;
      }
    }
  }
}
