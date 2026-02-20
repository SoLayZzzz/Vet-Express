import 'package:flutter/widgets.dart';

import '../../data/model/response/transfer_list_response.dart';
import '../../../../../models/request_transfer/self_service_response.dart';
import '../repository/goods_transfer_history_repository.dart';

class GoodsTransferHistoryUseCase {
  final GoodsTransferHistoryRepository goodsTransferHistoryRepository;

  GoodsTransferHistoryUseCase(this.goodsTransferHistoryRepository);

  Future<TransferListResponse> fetchTransferList({
    required BuildContext context,
    required int page,
    required int rowPerPage,
    required int desFrom,
    required int desTo,
    required int type,
    required int status,
  }) {
    return goodsTransferHistoryRepository.fetchTransferList(
      context: context,
      page: page,
      rowPerPage: rowPerPage,
      desFrom: desFrom,
      desTo: desTo,
      type: type,
      status: status,
    );
  }

  Future<RequestGoodsTransferResponse> fetchSelfServiceList({
    required BuildContext context,
  }) {
    return goodsTransferHistoryRepository.fetchSelfServiceList(
      context: context,
    );
  }
}
