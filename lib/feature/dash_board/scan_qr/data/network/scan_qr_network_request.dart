import 'package:express_vet/base/network_data_source.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../utils/contains.dart';

class ScanQrNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  ScanQrNetworkRequest(this.netWorkDataSource);

  Future<Map<String, dynamic>> searchCode({
    required dynamic context,
    required String code,
  }) async {
    return await netWorkDataSource.postMultipart(
      Endpoint.goodsTransferSearchCode,
      fields: <String, String>{'code': code},
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: false,
    );
  }

  Future<Map<String, dynamic>> findGoodsTransfer({
    required dynamic context,
    required int id,
  }) async {
    return await netWorkDataSource.postJson(
      Endpoint.goodsTransferFind(id.toString()),
      body: <String, dynamic>{},
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
  }
}
