import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/ev_voucher_apply_request.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/amount_price_kwh_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/destination_ev.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_point_list_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_voucher_apply_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_voucher_list_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_voucher_search_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/menbership_benefit_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/membership_info_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/membership_transaction_detail_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/membership_transaction_list_response.dart';
import 'package:express_vet/models/simple_response.dart';

import '../../domain/repository/ev_charger_repository.dart';
import '../network/ev_charger_network_request.dart';
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
import '../model/response/ev_charging_status_response.dart';

class EvChargerRepositoryImpl implements EvChargerRepository {
  final EvChargerNetworkRequest networkRequest;

  EvChargerRepositoryImpl(this.networkRequest);

  @override
  Future<EvChargerResponse> fetchTicketEvStationList({
    required dynamic context,
    String? name,
    String? provinceId,
  }) {
    return networkRequest.fetchTicketEvStationList(
      context: context,
      name: name,
      provinceId: provinceId,
    );
  }

  @override
  Future<DestinationEvResponse> fetchTicketProvinceList({
    required dynamic context,
  }) {
    return networkRequest.fetchTicketProvinceList(context: context);
  }

  @override
  Future<EvContactResponse> fetchEvContactUs({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return networkRequest.fetchEvContactUs(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }

  @override
  Future<EvFaqResponse> fetchEvFaqs({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return networkRequest.fetchEvFaqs(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }

  @override
  Future<EvPolicyResponse> fetchEvPolicy({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return networkRequest.fetchEvPolicy(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }

  @override
  Future<EvSlideShowResponse> fetchEvSlideShows({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return networkRequest.fetchEvSlideShows(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }

  @override
  Future<EvNewsFeedResponse> fetchEvNewsFeed({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return networkRequest.fetchEvNewsFeed(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }

  @override
  Future<EvProvinceResponse> fetchEvProvinceList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return networkRequest.fetchEvProvinceList(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }

  @override
  Future<EvStationListResponse> fetchEvStationList({
    required dynamic context,
    String? searchText,
    int? provinceId,
  }) {
    return networkRequest.fetchEvStationList(
      context: context,
      searchText: searchText,
      provinceId: provinceId,
    );
  }

  @override
  Future<SimpleResponse> addStationFavorite({
    required dynamic context,
    required int stationId,
  }) {
    return networkRequest.addStationFavorite(
      context: context,
      stationId: stationId,
    );
  }

  @override
  Future<EvWalletListResponse> fetchWalletList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return networkRequest.fetchWalletList(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }

  @override
  Future<EvWalletAmountResponse> fetchWalletAmount({required dynamic context}) {
    return networkRequest.fetchWalletAmount(context: context);
  }

  @override
  Future<EvTopUpResponse> walletTopUp({
    required dynamic context,
    required double amount,
    required int paymentMethod,
  }) {
    return networkRequest.walletTopUp(
      context: context,
      amount: amount,
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<EvTopUpResponse> walletTopUpStatus({
    required dynamic context,
    required String transactionId,
  }) {
    return networkRequest.walletTopUpStatus(
      context: context,
      transactionId: transactionId,
    );
  }

  @override
  Future<EvScanQrResponse> scanQrFindSaleOrder({
    required dynamic context,
    required String transactionId,
  }) {
    return networkRequest.scanQrFindSaleOrder(
      context: context,
      transactionId: transactionId,
    );
  }

  @override
  Future<SimpleResponse> confirmPayment({
    required dynamic context,
    required String transactionId,
  }) {
    return networkRequest.confirmPayment(
      context: context,
      transactionId: transactionId,
    );
  }

  @override
  Future<MembershipInfoResponse> fetchMembershipInfo({
    required dynamic context,
  }) {
    return networkRequest.fetchMembershipInfo(context: context);
  }

  @override
  Future<MembershipBenefitResponse> fetchMembershipBenefit({
    required dynamic context,
  }) {
    return networkRequest.fetchMembershipBenefit(context: context);
  }

  @override
  Future<MembershipTransactionListResponse> fetchMembershipTransactionList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
    String orderBy = '',
    String searchText = '',
    int? type,
  }) {
    return networkRequest.fetchMembershipTransactionList(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
      orderBy: orderBy,
      searchText: searchText,
      type: type,
    );
  }

  @override
  Future<MembershipTransactionDetailResponse> fetchMembershipTransactionDetail({
    required dynamic context,
    required int id,
  }) {
    return networkRequest.fetchMembershipTransactionDetail(
      context: context,
      id: id,
    );
  }

  @override
  Future<AmountPriceAndKwhResponse> fetchAmountKwh({required context}) {
    return networkRequest.fetchAmountKwh(context: context);
  }

  @override
  Future<AmountPriceAndKwhResponse> fetchAmountPrice({required context}) {
    return networkRequest.fetchAmountPrice(context: context);
  }

  @override
  Future<EvVoucherApplyResponse> applyVoucher({required context, required EvVoucherRequest request}) {
    return networkRequest.applyVoucher(context: context, request: request);
  }

  @override
  Future<EvVoucherListResponse> fetchVoucherList({required context}) {
    return networkRequest.fetchVoucherList(context: context);
  }

  @override
  Future<EvVoucherSearchResponse> searchVoucher({required context, required EvVoucherRequest request}) {
    return networkRequest.searchVoucher(context: context, request: request);
  }

  @override
  Future<EvPointListResponse> fetchPoint({required context}) {
    return networkRequest.fetchPoint(context: context);
  }

  @override
  Future<EvChargingStatusResponse> fetchChargingStatus({
    required dynamic context,
  }) {
    return networkRequest.fetchChargingStatus(context: context);
  }
}
