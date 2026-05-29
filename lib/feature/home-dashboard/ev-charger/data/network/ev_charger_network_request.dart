import 'dart:convert';

import 'package:express_vet/base/network_data_source.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/request_body.dart';
import 'package:flutter/material.dart';
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
import '../../../../../base/endpoint.dart';
import '../model/response/destination_ev.dart';
import '../../../../../models/simple_response.dart';
import '../../../../../utils/contains.dart';

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
      final request = EvTicketStationListRequest(
        name: name,
        provinceId: provinceId,
      );

      final json = await ticketDataSource.postJson(
        Endpoint.ticketEvStationList,
        body: request.toJson(),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('fetchTicketEvStationList response: ${jsonEncode(json)}');
      return EvChargerResponse.fromJson(json);
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
      debugPrint('fetchTicketProvinceList response: ${jsonEncode(json)}');
      return DestinationEvResponse.fromJson(json);
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
        body: EvPagedListRequest(page: page, rowsPerPage: rowsPerPage).toJson(),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('fetchEvContactUs response: ${jsonEncode(json)}');
      return EvContactResponse.fromJson(json);
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
        body: EvPagedListRequest(page: page, rowsPerPage: rowsPerPage).toJson(),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('fetchEvFaqs response: ${jsonEncode(json)}');
      return EvFaqResponse.fromJson(json);
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
        body: EvPagedListRequest(page: page, rowsPerPage: rowsPerPage).toJson(),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('fetchEvPolicy response: ${jsonEncode(json)}');
      return EvPolicyResponse.fromJson(json);
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
        body: EvPagedListRequest(page: page, rowsPerPage: rowsPerPage).toJson(),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('fetchEvSlideShows response: ${jsonEncode(json)}');
      return EvSlideShowResponse.fromJson(json);
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
        body: EvPagedListRequest(page: page, rowsPerPage: rowsPerPage).toJson(),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('fetchEvNewsFeed response: ${jsonEncode(json)}');
      return EvNewsFeedResponse.fromJson(json);
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
        body: EvPagedListRequest(page: page, rowsPerPage: rowsPerPage).toJson(),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('fetchEvProvinceList response: ${jsonEncode(json)}');
      return EvProvinceResponse.fromJson(json);
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
        body:
            EvStationListRequest(
              page: 1,
              rowsPerPage: 100,
              searchText: searchText,
              provinceId: provinceId,
            ).toJson(),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('fetchEvStationList response: ${jsonEncode(json)}');
      return EvStationListResponse.fromJson(json);
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
      debugPrint('addStationFavorite response: ${jsonEncode(json)}');
      return SimpleResponse.fromJson(json);
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
        body: EvPagedListRequest(page: page, rowsPerPage: rowsPerPage).toJson(),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('fetchWalletList response: ${jsonEncode(json)}');
      debugPrint('Wallet List: ${json['body']['data']}');

      return EvWalletListResponse.fromJson(json);
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
      debugPrint('fetchWalletAmount response: ${jsonEncode(json)}');
      debugPrint('Wallet Amount: ${json['body']['data']}');

      return EvWalletAmountResponse.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }

  Future<EvTopUpResponse> walletTopUp({
    required dynamic context,
    required double amount,
    required int paymentMethod,
  }) async {
    try {
      final body =
          EvWalletTopUpRequest(
            amount: amount,
            paymentMethod: paymentMethod,
          ).toJson();
      debugPrint(
        'EvChargerNetworkRequest.walletTopUp.request '
        'url=${evDataSource.baseUrl}${Endpoint.evSaleOrderWalletTopUp} '
        'body=$body',
      );
      final json = await evDataSource.postJson(
        Endpoint.evSaleOrderWalletTopUp,
        body: body,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('walletTopUp response: ${jsonEncode(json)}');
      final parsed = EvTopUpResponse.fromJson(json);
      debugPrint(
        'EvChargerNetworkRequest.walletTopUp.response '
        'statusCode=${parsed.header?.statusCode}, '
        'status=${parsed.body?.status}, '
        'message=${parsed.body?.message}, '
        'transactionId=${parsed.body?.data?.transactionId}, '
        'hasDeepLink=${((parsed.body?.data?.deeplink ?? '').isNotEmpty)}, '
        'hasCheckoutQrUrl=${((parsed.body?.data?.checkoutQrUrl ?? '').isNotEmpty)}',
      );

      return parsed;
    } catch (_) {
      rethrow;
    }
  }

  Future<EvTopUpResponse> walletTopUpStatus({
    required dynamic context,
    required String transactionId,
  }) async {
    try {
      debugPrint(
        'EvChargerNetworkRequest.walletTopUpStatus.request '
        'url=${evDataSource.baseUrl}${Endpoint.evSaleOrderWalletTopUpStatus(transactionId)}',
      );
      final json = await evDataSource.postJson(
        Endpoint.evSaleOrderWalletTopUpStatus(transactionId),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('walletTopUpStatus response: ${jsonEncode(json)}');
      final parsed = EvTopUpResponse.fromJson(json);
      debugPrint(
        'EvChargerNetworkRequest.walletTopUpStatus.response '
        'statusCode=${parsed.header?.statusCode}, '
        'status=${parsed.body?.status}, '
        'message=${parsed.body?.message}, '
        'paymentStatus=${parsed.body?.data?.paymentStatus}',
      );

      return parsed;
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
      debugPrint('scanQrFindSaleOrder response: ${jsonEncode(json)}');
      return EvScanQrResponse.fromJson(json);
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
      debugPrint('confirmPayment response: ${jsonEncode(json)}');
      return SimpleResponse.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }
}
