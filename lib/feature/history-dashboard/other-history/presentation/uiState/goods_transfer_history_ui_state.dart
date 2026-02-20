import '../../data/model/response/transfer_list_response.dart';
import '../../../../../models/request_transfer/self_service_response.dart';

class GoodsTransferHistoryUiState {
  final Future<TransferListResponse>? futureSending;
  final Future<TransferListResponse>? futureReceiving;
  final Future<RequestGoodsTransferResponse>? futureSelfService;

  const GoodsTransferHistoryUiState({
    this.futureSending,
    this.futureReceiving,
    this.futureSelfService,
  });

  GoodsTransferHistoryUiState copyWith({
    Future<TransferListResponse>? futureSending,
    Future<TransferListResponse>? futureReceiving,
    Future<RequestGoodsTransferResponse>? futureSelfService,
  }) => GoodsTransferHistoryUiState(
    futureSending: futureSending ?? this.futureSending,
    futureReceiving: futureReceiving ?? this.futureReceiving,
    futureSelfService: futureSelfService ?? this.futureSelfService,
  );
}
