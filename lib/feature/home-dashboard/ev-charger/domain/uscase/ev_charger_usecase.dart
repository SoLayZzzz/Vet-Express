import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/destination_ev.dart';
import 'package:express_vet/models/simple_response.dart';

import '../../data/model/response/ev_charger_response.dart';
import '../../data/model/response/ev_contact_response.dart';
import '../../data/model/response/ev_faq_response.dart';
import '../../data/model/response/ev_news_feed_response.dart';
import '../../data/model/response/ev_policy_response.dart';
import '../../data/model/response/ev_province_response.dart';
import '../../data/model/response/ev_scan_qr_response.dart';
import '../../data/model/response/ev_slide_show_response.dart';
import '../../data/model/response/ev_station_list_response.dart';
import '../../data/model/response/ev_top_up_response.dart';
import '../../data/model/response/ev_wallet_amount_response.dart';
import '../../data/model/response/ev_wallet_list_response.dart';
import '../repository/ev_charger_repository.dart';

class EvChargerUseCase {
  final EvChargerRepository repository;

  EvChargerUseCase(this.repository);

  Future<EvChargerResponse> fetchTicketEvStationList({
    required dynamic context,
    String? name,
    String? provinceId,
  }) {
    return repository.fetchTicketEvStationList(
      context: context,
      name: name,
      provinceId: provinceId,
    );
  }

  Future<DestinationEvResponse> fetchTicketProvinceList({
    required dynamic context,
  }) {
    return repository.fetchTicketProvinceList(context: context);
  }

  Future<EvContactResponse> fetchEvContactUs({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return repository.fetchEvContactUs(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }

  Future<EvFaqResponse> fetchEvFaqs({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return repository.fetchEvFaqs(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }

  Future<EvPolicyResponse> fetchEvPolicy({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return repository.fetchEvPolicy(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }

  Future<EvSlideShowResponse> fetchEvSlideShows({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return repository.fetchEvSlideShows(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }

  Future<EvNewsFeedResponse> fetchEvNewsFeed({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return repository.fetchEvNewsFeed(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }

  Future<EvProvinceResponse> fetchEvProvinceList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return repository.fetchEvProvinceList(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }

  Future<EvStationListResponse> fetchEvStationList({
    required dynamic context,
    String? searchText,
    int? provinceId,
  }) {
    return repository.fetchEvStationList(
      context: context,
      searchText: searchText,
      provinceId: provinceId,
    );
  }

  Future<SimpleResponse> addStationFavorite({
    required dynamic context,
    required int stationId,
  }) {
    return repository.addStationFavorite(
      context: context,
      stationId: stationId,
    );
  }

  Future<EvWalletListResponse> fetchWalletList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return repository.fetchWalletList(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }

  Future<EvWalletAmountResponse> fetchWalletAmount({required dynamic context}) {
    return repository.fetchWalletAmount(context: context);
  }

  Future<EvTopUpResponse> walletTopUp({
    required dynamic context,
    required double amount,
  }) {
    return repository.walletTopUp(context: context, amount: amount);
  }

  Future<EvTopUpResponse> walletTopUpStatus({
    required dynamic context,
    required String transactionId,
  }) {
    return repository.walletTopUpStatus(
      context: context,
      transactionId: transactionId,
    );
  }

  Future<EvScanQrResponse> scanQrFindSaleOrder({
    required dynamic context,
    required String transactionId,
  }) {
    return repository.scanQrFindSaleOrder(
      context: context,
      transactionId: transactionId,
    );
  }

  Future<SimpleResponse> confirmPayment({
    required dynamic context,
    required String transactionId,
  }) {
    return repository.confirmPayment(
      context: context,
      transactionId: transactionId,
    );
  }
}
