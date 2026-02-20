import 'package:flutter/widgets.dart';

import '../model/response/transfer_list_response.dart';
import '../../../../../models/request_transfer/self_service_response.dart';
import '../../domain/repository/goods_transfer_history_repository.dart';
import '../network/goods_transfer_history_network_request.dart';

class GoodsTransferHistoryRepositoryImpl
    implements GoodsTransferHistoryRepository {
  final GoodsTransferHistoryNetworkRequest goodsTransferHistoryNetworkRequest;

  GoodsTransferHistoryRepositoryImpl(this.goodsTransferHistoryNetworkRequest);

  @override
  Future<TransferListResponse> fetchTransferList({
    required BuildContext context,
    required int page,
    required int rowPerPage,
    required int desFrom,
    required int desTo,
    required int type,
    required int status,
  }) {
    return goodsTransferHistoryNetworkRequest.fetchTransferList(
      context: context,
      page: page,
      rowPerPage: rowPerPage,
      desFrom: desFrom,
      desTo: desTo,
      type: type,
      status: status,
    );
  }

  @override
  Future<RequestGoodsTransferResponse> fetchSelfServiceList({
    required BuildContext context,
  }) {
    return goodsTransferHistoryNetworkRequest.fetchSelfServiceList(
      context: context,
    );
  }
}
