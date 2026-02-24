import 'dart:developer';

import 'package:express_vet/base/state_controller.dart';
import 'package:express_vet/utils/alert_dialog.dart';
import 'package:express_vet/utils/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../home-dashboard/schedule/data/network/schedule_network_request.dart';
import '../../data/network/rate_schedule_network_request.dart';
import '../uiState/rate_schedule_ui_state.dart';

class RateScheduleController extends StateController<RateScheduleUiState> {
  final ScheduleNetworkRequest scheduleNetworkRequest;
  final RateScheduleNetworkRequest rateScheduleNetworkRequest;

  RateScheduleController(
    this.scheduleNetworkRequest,
    this.rateScheduleNetworkRequest,
  );

  final TextEditingController reviewController = TextEditingController();

  int scheduleId = 0;
  String ticketId = '';

  bool _argsInitialized = false;

  @override
  RateScheduleUiState onInitUiState() => const RateScheduleUiState();

  void ensureInitialized({required int scheduleId, required String ticketId}) {
    if (_argsInitialized) return;
    _argsInitialized = true;

    this.scheduleId = scheduleId;
    this.ticketId = ticketId;

    final ctx = Get.context;
    if (ctx != null) {
      loadTotalByJourney(context: ctx);
    }
  }

  @override
  void onReady() {
    super.onReady();

    final ctx = Get.context;
    if (ctx == null) return;

    if (_argsInitialized && state.futureTotalByJourney == null) {
      loadTotalByJourney(context: ctx);
    }
  }

  void loadTotalByJourney({required BuildContext context}) {
    uiState.value = state.copyWith(
      futureTotalByJourney: scheduleNetworkRequest.fetchTotalByJourney(
        context: context,
        scheduleId: scheduleId,
      ),
    );
  }

  void toggleRating(int index) {
    final current = state.selectedRating;
    final next = (current == index + 1) ? (current - 1) : (index + 1);
    uiState.value = state.copyWith(selectedRating: next);
  }

  void clearReview() {
    reviewController.clear();
    uiState.value = state.copyWith(selectedRating: 0);
  }

  Future<void> post({required BuildContext context}) async {
    if (state.selectedRating <= 0) return;

    final fields = <String, String>{
      'score': state.selectedRating.toString(),
      'ticketId': ticketId,
    };

    final note = reviewController.text.trim();
    if (note.isNotEmpty) {
      fields['note'] = note;
    }

    Loading().loadingShow();

    try {
      final json = await rateScheduleNetworkRequest.saveRateSchedule(
        context: context,
        fields: fields,
      );

      Loading().loadingClose();

      final body = json['body'];
      final status = body is Map ? body['status'] : null;
      final message = body is Map ? body['message'] : null;

      if (status == true) {
        alertDialogTravelPackage(
          title: 'info'.tr,
          description:
              (message is String && message.isNotEmpty)
                  ? message
                  : 'Successfully posted, Thank you for your rating.',
          buttonText: 'close'.tr,
          onButtonPressed: () {
            Get.back();
            Get.back(result: true);
          },
        );
        clearReview();
      } else {
        alertDialogTravelPackage(
          title: 'info'.tr,
          description:
              (message is String && message.isNotEmpty)
                  ? message
                  : 'Server responded with success status, but operation failed.',
          buttonText: 'close'.tr,
          onButtonPressed: () {
            Get.back();
            Get.back(result: false);
          },
        );
      }
    } catch (e) {
      Loading().loadingClose();
      log('An error occurred: $e');
      rethrow;
    }
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
