import 'dart:convert';

import 'package:express_vet/base/network_data_source.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/ev_sale_order_apptmp_request.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/ev_voucher_apply_request.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/ev_calculate_request.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_calculate_reponse.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/ev_checkZone_request.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_checkZone_reponse.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/request_body.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/amount_price_kwh_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_point_list_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_sale_order_apptmp_res.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_voucher_apply_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_voucher_list_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_voucher_search_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/membership_info_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/menbership_benefit_response.dart';
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
import '../model/response/membership_transaction_detail_response.dart';
import '../model/response/ev_charging_status_response.dart';
import '../model/response/membership_transaction_list_response.dart';
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

  Future<MembershipInfoResponse> fetchMembershipInfo({
    required dynamic context,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evMembershipinfo,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('fetchMembershipInfo response: ${jsonEncode(json)}');
      return MembershipInfoResponse.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }

  Future<MembershipBenefitResponse> fetchMembershipBenefit({
    required dynamic context,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evMembershipBenefit,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('fetchMembershipBenefit response: ${jsonEncode(json)}');
      return MembershipBenefitResponse.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }

  Future<MembershipTransactionListResponse> fetchMembershipTransactionList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
    String orderBy = '',
    String searchText = '',
    int? type,
  }) async {
    try {
      final Map<String, dynamic> body = <String, dynamic>{
        'page': page,
        'rowsPerPage': rowsPerPage,
        'orderBy': orderBy,
        'searchText': searchText,
      };
      if (type != null && type != 0) {
        body['type'] = type;
      }

      final json = await evDataSource.postJson(
        Endpoint.evMembershipTransactionList,
        body: body,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint(
        'fetchMembershipTransactionList response: ${jsonEncode(json)}',
      );
      return MembershipTransactionListResponse.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }

  Future<MembershipTransactionDetailResponse> fetchMembershipTransactionDetail({
    required dynamic context,
    required int id,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evMembershipTransactionDetail(id.toString()),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint(
        'fetchMembershipTransactionDetail response: ${jsonEncode(json)}',
      );
      return MembershipTransactionDetailResponse.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }

  Future<AmountPriceAndKwhResponse> fetchAmountKwh({
    required dynamic context,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evkwhlist,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('fetch kwh  response: ${jsonEncode(json)}');
      return AmountPriceAndKwhResponse.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }

  Future<AmountPriceAndKwhResponse> fetchAmountPrice({
    required dynamic context,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evpricelist,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('fetch price response: ${jsonEncode(json)}');
      return AmountPriceAndKwhResponse.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }

  Future<EvPointListResponse> fetchPoint({required dynamic context}) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evpointlist,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('fetch point response: ${jsonEncode(json)}');
      return EvPointListResponse.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }

  Future<EvVoucherApplyResponse> applyVoucher({
    required dynamic context,
    required EvVoucherRequest request,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evVoucherApply,
        body: request.toJson(),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('apply voucher response: ${jsonEncode(json)}');
      return EvVoucherApplyResponse.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }

  Future<EvVoucherSearchResponse> searchVoucher({
    required dynamic context,
    required EvVoucherRequest request,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evVoucherSearch,
        body: request.toJson(),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('search voucher response: ${jsonEncode(json)}');
      return EvVoucherSearchResponse.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }

  Future<EvVoucherListResponse> fetchVoucherList({
    required dynamic context,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evVoucherList,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('fetch voucher list response: ${jsonEncode(json)}');
      return EvVoucherListResponse.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }

  Future<EvChargingStatusResponse> fetchChargingStatus({
    required dynamic context,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evChargingStatus,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('======> fetchChargingStatus response: ${jsonEncode(json)}');
      return EvChargingStatusResponse.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }

  Future<EvSaleOrderApptmpResponse> evSaleOrderApptmp({
    required dynamic context,
    required EvSaleOrderApptmpRequest request,
  }) async {
    try {
      final json = await evDataSource.postJson(
        Endpoint.evSaleOrderAppTmp,
        body: request.toJson(),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('ev sale order apptmp response: ${jsonEncode(json)}');
      return EvSaleOrderApptmpResponse.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }

  Future<EvCalculateResponse> evCalculate({
    required dynamic context,
    required EvCalculateRequest request,
  }) async {
    try {
      debugPrint('ev calculate request: ${jsonEncode(request.toJson())}');
      final json = await evDataSource.postJson(
        Endpoint.ev_calculate,
        body: request.toJson(),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('ev calculate response: ${jsonEncode(json)}');
      return EvCalculateResponse.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }

  Future<EvCheckZoneResponse> evCheckZone({
    required dynamic context,
    required EvCheckZoneRequest request,
  }) async {
    try {
      debugPrint('ev check zone request: ${jsonEncode(request.toJson())}');
      final json = await evDataSource.postJson(
        Endpoint.ev_checkZone,
        body: request.toJson(),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      debugPrint('ev check zone response: ${jsonEncode(json)}');
      return EvCheckZoneResponse.fromJson(json);
    } catch (_) {
      rethrow;
    }
  }
}

