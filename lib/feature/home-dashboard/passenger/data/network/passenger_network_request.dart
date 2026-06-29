import 'dart:convert';
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

import '../../../../../base/endpoint.dart';
import '../model/response/booking_detail_model.dart';
import '../model/response/check_booking_package_apply_response.dart';
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
    } catch (_) {
      Loading().loadingClose();
      rethrow;
    }
  }

  Future<CheckPackageApplyResponse> checkPackageApply(
    CheckBookingPackageRequest body,
  ) async {
    try {
      debugPrint(
        '[Package] checkPackageApply -> code: ${body.code}, journeyId: ${body.journeyId}, travelDate: ${body.travelDate}',
      );
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
      final res = CheckPackageApplyResponse.fromJson(json);
      debugPrint(
        '[Package] checkPackageApply <- status: '
        'header.statusCode=${res.header?.statusCode}, '
        'header.result=${res.header?.result}, '
        'body.status=${res.body?.status}, '
        'body.msg=${res.body?.msg}, '
        'body.discount=${res.body?.discount}',
      );
      return res;
    } catch (_) {
      rethrow;
    }
  }

  Future<ConfirmBookingResponse> confirmBooking({
    required BuildContext context,
    required Map<String, String> fields,
  }) async {
    try {
      debugPrint('[Booking] confirmBooking -> fields: $fields');
      final json = await networkDataSource.postFormUrlEncoded(
        Endpoint.ticketBookingConfirm,
        fields: fields,
        timeout: const Duration(seconds: Constrains.timeout180),
        attachAuth: true,
      );
      final res = ConfirmBookingResponse.fromJson(json);
      debugPrint(
        '[Booking] confirmBooking <- status: \n+        header.statusCode=${res.header?.statusCode}, \n+        header.result=${res.header?.result}, \n+        body.status=${res.body?.status}, \n+        body.msg=${res.body?.msg}, \n+        body.transactionId=${res.body?.transactionId}',
      );
      return res;
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
    } catch (e) {
      debugPrint(
          'PassengerNetworkRequest.processPayment.error ${e.toString()}',
        );
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
    } catch (e) {
      debugPrint(
          'PassengerNetworkRequest.checkCoupon.error ${e.toString()}',
        );
      rethrow;
    }
  }

  Future<WingResponse> checkTicketStatus({
    required BuildContext context,
    required String transactionId,
  }) async {
    try {
      debugPrint(
        'PassengerNetworkRequest.checkTicketStatus.request transactionId=$transactionId',
      );
      final json = await networkDataSource.postMultipart(
        Endpoint.ticketBookingCheckTicketStatus,
        fields: <String, String>{'transactionId': transactionId},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      final prettyResponse = const JsonEncoder.withIndent('  ').convert(json);
      debugPrint(
        'PassengerNetworkRequest.checkTicketStatus.responseJson\n$prettyResponse',
      );
      return WingResponse.fromJson(json);
    } catch (e) {
      debugPrint('PassengerNetworkRequest.checkTicketStatus.error $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> bookingComplete({
    required BuildContext context,
    required String reference,
    required String transactionId,
  }) async {
    final fields = <String, String>{
      'reference': reference,
      'trasactionId': transactionId,
      'transactionId': transactionId,
    };
    final fullUrl = '${networkDataSource.baseUrl}${Endpoint.bookingComplete}';

    try {
      final json = await networkDataSource.postFormUrlEncoded(
        Endpoint.bookingComplete,
        fields: fields,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      final prettyFields = const JsonEncoder.withIndent('  ').convert(fields);
      final prettyResponse = const JsonEncoder.withIndent('  ').convert(json);

      debugPrint(
        '--------------------------------------------------\n'
        '🚀 REQUEST: bookingComplete\n'
        '🛣️ Endpoint: /${Endpoint.bookingComplete}\n'
        '🔗 URL: $fullUrl\n'
        '📦 Fields:\n$prettyFields\n'
        '--------------------------------------------------\n'
        '📥 RESPONSE:\n$prettyResponse\n'
        '--------------------------------------------------',
      );

      return json;
    } catch (e) {
      debugPrint('PassengerNetworkRequest.bookingComplete.error: $e');
      rethrow;
    }
  }
}

