import 'dart:async';

import 'package:express_vet/base/network_data_source.dart';
import '../model/response/ev_charger_response.dart';
import '../model/response/ev_contact_response.dart';
import '../model/response/ev_faq_response.dart';
import '../model/response/ev_news_feed_response.dart';
import '../model/response/ev_policy_response.dart';
import '../model/response/ev_province_response.dart';
import '../model/response/ev_scan_qr_response.dart';
import '../model/response/ev_slide_show_response.dart';
import '../model/response/ev_station_list_response.dart';
import '../model/response/ev_top_up_response.dart';
import '../model/response/ev_wallet_amount_response.dart';
import '../model/response/ev_wallet_list_response.dart';
import 'package:get/get.dart';
import '../../../../../base/endpoint.dart';
import '../../../../../models/destination/destination_ev.dart';
import '../../../../../models/simple_response.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/contains.dart';
import '../../../../../utils/loading.dart';

class EvChargerNetworkRequest {
  final NetWorkDataSource ticketDataSource;
  final NetWorkDataSource evDataSource;

  EvChargerNetworkRequest({
    required this.ticketDataSource,
    required this.evDataSource,
  });

  Future<EvChargerResponse> fetchTicketEvStationList({
    required dynamic context,
    String? name,
    String? provinceId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = <String, dynamic>{};
      if (provinceId != null && provinceId.isNotEmpty) {
        requestBody['provinceId'] = provinceId;
      }
      if (name != null && name.isNotEmpty) {
        requestBody['name'] = name;
      }

      final json = await ticketDataSource.postJson(
        Endpoint.ticketEvStationList,
        body: requestBody,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return EvChargerResponse.fromJson(json);
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

  Future<DestinationEvResponse> fetchTicketProvinceList({
    required dynamic context,
  }) async {
    try {
      final json = await ticketDataSource.postJson(
        Endpoint.ticketProvinceList,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return DestinationEvResponse.fromJson(json);
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

  Future<EvContactResponse> fetchEvContactUs({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evDropdownContactUsList,
        body: <String, dynamic>{
          'page': page,
          'rowsPerPage': rowsPerPage,
          'searchText': '',
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return EvContactResponse.fromJson(json);
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

  Future<EvFaqResponse> fetchEvFaqs({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evDropdownFaqsList,
        body: <String, dynamic>{
          'page': page,
          'rowsPerPage': rowsPerPage,
          'searchText': '',
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return EvFaqResponse.fromJson(json);
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

  Future<EvPolicyResponse> fetchEvPolicy({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evDropdownPrivacyPolicyList,
        body: <String, dynamic>{
          'page': page,
          'rowsPerPage': rowsPerPage,
          'searchText': '',
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return EvPolicyResponse.fromJson(json);
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

  Future<EvSlideShowResponse> fetchEvSlideShows({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evDropdownSlideShowsList,
        body: <String, dynamic>{
          'page': page,
          'rowsPerPage': rowsPerPage,
          'searchText': '',
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return EvSlideShowResponse.fromJson(json);
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

  Future<EvNewsFeedResponse> fetchEvNewsFeed({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evDropdownNewFeedList,
        body: <String, dynamic>{
          'page': page,
          'rowsPerPage': rowsPerPage,
          'searchText': '',
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return EvNewsFeedResponse.fromJson(json);
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

  Future<EvProvinceResponse> fetchEvProvinceList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evDropdownProvinceList,
        body: <String, dynamic>{
          'page': page,
          'rowsPerPage': rowsPerPage,
          'searchText': '',
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return EvProvinceResponse.fromJson(json);
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

  Future<EvStationListResponse> fetchEvStationList({
    required dynamic context,
    String? searchText,
    int? provinceId,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evStationList,
        body: <String, dynamic>{
          'page': 1,
          'rowsPerPage': 100,
          'searchText': searchText,
          'provinceId': provinceId,
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return EvStationListResponse.fromJson(json);
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

  Future<SimpleResponse> addStationFavorite({
    required dynamic context,
    required int stationId,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evStationAddFavorites(stationId.toString()),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return SimpleResponse.fromJson(json);
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

  Future<EvWalletListResponse> fetchWalletList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evSaleOrderWalletList,
        body: <String, dynamic>{
          'page': page,
          'rowsPerPage': rowsPerPage,
          'searchText': '',
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return EvWalletListResponse.fromJson(json);
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

  Future<EvWalletAmountResponse> fetchWalletAmount({
    required dynamic context,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evSaleOrderWalletAmount,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return EvWalletAmountResponse.fromJson(json);
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

  Future<EvTopUpResponse> walletTopUp({
    required dynamic context,
    required double amount,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evSaleOrderWalletTopUp,
        body: <String, dynamic>{'amount': amount},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return EvTopUpResponse.fromJson(json);
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

  Future<EvTopUpResponse> walletTopUpStatus({
    required dynamic context,
    required String transactionId,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evSaleOrderWalletTopUpStatus(transactionId),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return EvTopUpResponse.fromJson(json);
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

  Future<EvScanQrResponse> scanQrFindSaleOrder({
    required dynamic context,
    required String transactionId,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evSaleOrderFind(transactionId),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return EvScanQrResponse.fromJson(json);
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

  Future<SimpleResponse> confirmPayment({
    required dynamic context,
    required String transactionId,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evPaymentConfirmPayment(transactionId),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      return SimpleResponse.fromJson(json);
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
}
