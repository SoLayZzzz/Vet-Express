import 'package:express_vet/models/goods_transfer/review_response.dart';

import '../../domain/repository/goods_transfer_action_repository.dart';
import '../model/request/goods_transfer_add_request_body.dart';
import '../model/request/goods_transfer_review_request_body.dart';
import '../network/goods_transfer_action_network_request.dart';
import '../../../../home-dashboard/booking_delivery/data/model/response/booking_delivery_add_response.dart';

class GoodsTransferActionRepositoryImpl implements GoodsTransferActionRepository {
  final GoodsTransferActionNetworkRequest networkRequest;

  GoodsTransferActionRepositoryImpl(this.networkRequest);

  @override
  Future<BookingDeliveryAddResponse> addGoodsTransfer({
    required GoodsTransferAddRequestBody body,
  }) {
    return networkRequest.addGoodsTransfer(body: body);
  }

  @override
  Future<ReviewResponse> review({
    required GoodsTransferReviewRequestBody body,
  }) {
    return networkRequest.review(body: body);
  }
}
