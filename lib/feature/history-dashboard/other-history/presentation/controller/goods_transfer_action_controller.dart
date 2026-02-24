import 'dart:async';

import 'package:express_vet/base/state_controller.dart';
import 'package:express_vet/utils/alert_dialog.dart';
import 'package:express_vet/utils/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/model/request/goods_transfer_add_request_body.dart';
import '../../data/model/request/goods_transfer_review_request_body.dart';
import '../../domain/uscase/goods_transfer_action_usecase.dart';
import '../../../../home-dashboard/booking_delivery/data/model/response/booking_delivery_add_response.dart';
import '../../../../../models/goods_transfer/review_response.dart';
import '../uiState/goods_transfer_action_ui_state.dart';

class GoodsTransferActionController
    extends StateController<GoodsTransferActionUiState> {
  final GoodsTransferActionUseCase useCase;

  GoodsTransferActionController(this.useCase);

  @override
  GoodsTransferActionUiState onInitUiState() =>
      const GoodsTransferActionUiState();

  Future<BookingDeliveryAddResponse> addGoodsTransfer({
    required BuildContext context,
    required GoodsTransferAddRequestBody body,
    required VoidCallback onSuccess,
  }) async {
    Loading().loadingShow();

    try {
      final res = await useCase.addGoodsTransfer(body: body);
      Loading().loadingClose();

      if (res.header?.statusCode == 200 && res.header?.result == true) {
        alertDialogOneButton(
          title: 'success'.tr,
          description: 'success_info'.tr,
          buttonText: 'close'.tr,
        );
        onSuccess();
      }

      return res;
    } on TimeoutException {
      Loading().loadingClose();
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      Loading().loadingClose();
      rethrow;
    }
  }

  Future<ReviewResponse> review({
    required BuildContext context,
    required GoodsTransferReviewRequestBody body,
    required VoidCallback onSuccess,
  }) async {
    Loading().loadingShow();

    try {
      final res = await useCase.review(body: body);
      Loading().loadingClose();

      if (res.header?.statusCode == 200 && res.header?.result == true) {
        if (res.body?.status == true) {
          ScaffoldMessenger.of(
            Get.context!,
          ).showSnackBar(SnackBar(content: Text('survey_submitted'.tr)));
          onSuccess();
        } else {
          ScaffoldMessenger.of(
            Get.context!,
          ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
        }
      }

      return res;
    } on TimeoutException {
      Loading().loadingClose();
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      Loading().loadingClose();
      rethrow;
    }
  }
}
