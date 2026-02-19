import 'package:flutter/widgets.dart';

import '../../../../../models/goods_transfer/transfer_list_response.dart';
import '../../../../../models/request_transfer/self_service_response.dart';

abstract class GoodsTransferHistoryRepository {
  Future<TransferListResponse> fetchTransferList({
    required BuildContext context,
    required int page,
    required int rowPerPage,
    required int desFrom,
    required int desTo,
    required int type,
    required int status,
  });

  Future<RequestGoodsTransferResponse> fetchSelfServiceList({
    required BuildContext context,
  });
}
