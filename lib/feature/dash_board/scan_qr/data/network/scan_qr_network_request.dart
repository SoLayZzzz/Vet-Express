import 'dart:async';

import 'package:express_vet/base/network_data_source.dart';
import 'package:get/get.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/contains.dart';

class ScanQrNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  ScanQrNetworkRequest(this.netWorkDataSource);

  Future<Map<String, dynamic>> searchCode({
    required dynamic context,
    required String code,
  }) async {
    try {
      return await netWorkDataSource.postMultipart(
        Endpoint.goodsTransferSearchCode,
        fields: <String, String>{'code': code},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: false,
      );
    } on TimeoutException {
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

  Future<Map<String, dynamic>> findGoodsTransfer({
    required dynamic context,
    required int id,
  }) async {
    try {
      return await netWorkDataSource.postJson(
        Endpoint.goodsTransferFind(id.toString()),
        body: <String, dynamic>{},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
    } on TimeoutException {
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
