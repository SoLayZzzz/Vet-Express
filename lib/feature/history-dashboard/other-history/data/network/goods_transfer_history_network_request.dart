import 'dart:async';

import 'package:express_vet/base/network_data_source.dart';
import 'package:get/get.dart';

import '../../../../../base/endpoint.dart';
import '../model/response/transfer_list_response.dart';
import '../../../../../models/request_transfer/self_service_response.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/contains.dart';
import '../../../../../utils/loading.dart';

class GoodsTransferHistoryNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  GoodsTransferHistoryNetworkRequest(this.netWorkDataSource);

  Future<TransferListResponse> fetchTransferList({
    required dynamic context,
    required int page,
    required int rowPerPage,
    required int desFrom,
    required int desTo,
    required int type,
    required int status,
  }) async {
    try {
      final json = await netWorkDataSource.postJson(
        Endpoint.goodsTransferList,
        body: <String, dynamic>{
          'destinationFromId': desFrom,
          'destinationToId': desTo,
          'page': page,
          'rowsPerPage': rowPerPage,
          'type': type,
          'status': status,
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return TransferListResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose();
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<RequestGoodsTransferResponse> fetchSelfServiceList({
    required dynamic context,
  }) async {
    try {
      final json = await netWorkDataSource.postJson(
        Endpoint.requestTransferGoodsList,
        body: <String, dynamic>{},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return RequestGoodsTransferResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose();
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
