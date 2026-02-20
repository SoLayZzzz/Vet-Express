import 'dart:async';

import 'package:express_vet/base/network_data_source.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/request/check_booking_package_request.dart';
import 'package:express_vet/models/boarding_point.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/response/booking_list_model.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/response/cancel_booking_response.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/response/check_apply_coupon_code.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/response/confirm_booking_response.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/response/process_payment_response.dart';
import 'package:express_vet/models/wing/wing_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../base/endpoint.dart';
import '../model/response/booking_detail_model.dart';
import '../model/response/check_booking_package_apply_response.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/contains.dart';
import '../../../../../utils/loading.dart';

class PassengerNetworkRequest {
  final NetworkDataSource networkDataSource;

  PassengerNetworkRequest({required this.networkDataSource});

  Future<CarPointResponse> getBoardingPoint({
    required BuildContext context,
    required String date,
    required String journeyId,
  }) async {
    try {
      final json = await networkDataSource.postFormUrlEncoded(
        Endpoint.ticketBoardingPointListByScheduleDate,
        fields: <String, String>{'date': date, 'id': journeyId},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return CarPointResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(Get.context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<CarPointResponse> getDropOffPoint({
    required BuildContext context,
    required String journeyId,
  }) async {
    try {
      final json = await networkDataSource.postFormUrlEncoded(
        Endpoint.ticketDropOffPointFindBySchedule(journeyId),
        fields: <String, String>{},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return CarPointResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(Get.context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      Loading().loadingClose(Get.context);
      rethrow;
    }
  }

  Future<CheckPackageApplyResponse> checkPackageApply(
    CheckBookingPackageRequest body,
  ) async {
    try {
      final json = await networkDataSource.postFormUrlEncoded(
        Endpoint.ticketBookingCheckPackageApply,
        fields: <String, String>{
          'code': body.code,
          'journeyId': body.journeyId,
          'travelDate': body.travelDate,
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return CheckPackageApplyResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(body.context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<ConfirmBookingResponse> confirmBooking({
    required BuildContext context,
    required Map<String, String> fields,
  }) async {
    try {
      final json = await networkDataSource.postFormUrlEncoded(
        Endpoint.ticketBookingConfirm,
        fields: fields,
        timeout: const Duration(seconds: Constrains.timeout180),
        attachAuth: true,
      );

      return ConfirmBookingResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<CancelBookingResponse> cancelBooking({
    required BuildContext context,
    required String transactionId,
  }) async {
    try {
      final json = await networkDataSource.postFormUrlEncoded(
        Endpoint.ticketBookingCancel,
        fields: <String, String>{'transactionId': transactionId},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return CancelBookingResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<BookingListModel> getBookingList({
    required BuildContext context,
    int page = 1,
    int rowsPerPage = 100,
  }) async {
    try {
      final json = await networkDataSource.postJson(
        Endpoint.ticketBookingList,
        body: <String, dynamic>{'page': page, 'rowsPerPage': rowsPerPage},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return BookingListModel.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<BookingDetailModel> getTicketDetail({
    required BuildContext context,
    required int id,
  }) async {
    try {
      final json = await networkDataSource.postJson(
        Endpoint.ticketBookingFind(id.toString()),
        body: <String, dynamic>{},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return BookingDetailModel.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<PaymentResponse> processPayment({
    required BuildContext context,
    required String code,
    required String paymentMethodId,
    required String totalAmount,
  }) async {
    try {
      final json = await networkDataSource.postFormUrlEncoded(
        Endpoint.ticketBookingProcessPayment,
        fields: <String, String>{
          'code': code,
          'paymentMethodId': paymentMethodId,
          'totalAmount': totalAmount,
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return PaymentResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<CheckPromotionCodeResponse> checkCoupon({
    required BuildContext context,
    required String amount,
    required String code,
    required String travelDate,
  }) async {
    try {
      final json = await networkDataSource.postFormUrlEncoded(
        Endpoint.ticketBookingCheckCoupon,
        fields: <String, String>{
          'amount': amount,
          'code': code,
          'travelDate': travelDate,
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return CheckPromotionCodeResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<WingResponse> checkTicketStatus({
    required BuildContext context,
    required String transactionId,
  }) async {
    try {
      final json = await networkDataSource.postMultipart(
        Endpoint.ticketBookingCheckTicketStatus,
        fields: <String, String>{'transactionId': transactionId},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return WingResponse.fromJson(json);
    } on TimeoutException {
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
