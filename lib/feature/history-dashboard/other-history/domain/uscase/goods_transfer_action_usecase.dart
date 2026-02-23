import 'package:express_vet/models/goods_transfer/review_response.dart';

import '../../data/model/request/goods_transfer_add_request_body.dart';
import '../../data/model/request/goods_transfer_review_request_body.dart';
import '../repository/goods_transfer_action_repository.dart';
import '../../../../home-dashboard/booking_delivery/data/model/response/booking_delivery_add_response.dart';

class GoodsTransferActionUseCase {
  final GoodsTransferActionRepository repository;

  GoodsTransferActionUseCase(this.repository);

  Future<BookingDeliveryAddResponse> addGoodsTransfer({
    required GoodsTransferAddRequestBody body,
  }) {
    return repository.addGoodsTransfer(body: body);
  }

  Future<ReviewResponse> review({
    required GoodsTransferReviewRequestBody body,
  }) {
    return repository.review(body: body);
  }
}
