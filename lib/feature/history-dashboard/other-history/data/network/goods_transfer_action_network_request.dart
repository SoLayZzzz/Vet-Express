import 'dart:async';

import 'package:express_vet/base/network_data_source.dart';
import 'package:express_vet/models/goods_transfer/review_response.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../utils/contains.dart';
import '../model/request/goods_transfer_add_request_body.dart';
import '../model/request/goods_transfer_review_request_body.dart';
import '../../../../home-dashboard/booking_delivery/data/model/response/booking_delivery_add_response.dart';

class GoodsTransferActionNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  GoodsTransferActionNetworkRequest(this.netWorkDataSource);

  Future<BookingDeliveryAddResponse> addGoodsTransfer({
    required GoodsTransferAddRequestBody body,
  }) async {
    final json = await netWorkDataSource.postMultipartWithFile(
      Endpoint.requestTransferAdd,
      fields: body.toFormFields(),
      fileField: 'file',
      filePath: body.filePath,
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );

    return BookingDeliveryAddResponse.fromJson(json);
  }

  Future<ReviewResponse> review({
    required GoodsTransferReviewRequestBody body,
  }) async {
    final json = await netWorkDataSource.postMultipart(
      Endpoint.requestTransferSaveSurvey,
      fields: <String, String>{
        'comment': body.comment,
        'goodsTransferId': body.goodsTransferId,
        'score': body.score,
        'type': body.type,
      },
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );

    return ReviewResponse.fromJson(json);
  }
}
