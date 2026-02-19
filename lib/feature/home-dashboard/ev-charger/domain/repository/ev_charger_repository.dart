import 'package:express_vet/models/destination/destination_ev.dart';
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

abstract class EvChargerRepository {
  Future<EvChargerResponse> fetchTicketEvStationList({
    required dynamic context,
    String? name,
    String? provinceId,
  });

  Future<DestinationEvResponse> fetchTicketProvinceList({
    required dynamic context,
  });

  Future<EvContactResponse> fetchEvContactUs({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  });

  Future<EvFaqResponse> fetchEvFaqs({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  });

  Future<EvPolicyResponse> fetchEvPolicy({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  });

  Future<EvSlideShowResponse> fetchEvSlideShows({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  });

  Future<EvNewsFeedResponse> fetchEvNewsFeed({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  });

  Future<EvProvinceResponse> fetchEvProvinceList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  });

  Future<EvStationListResponse> fetchEvStationList({
    required dynamic context,
    String? searchText,
    int? provinceId,
  });

  Future<SimpleResponse> addStationFavorite({
    required dynamic context,
    required int stationId,
  });

  Future<EvWalletListResponse> fetchWalletList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  });

  Future<EvWalletAmountResponse> fetchWalletAmount({
    required dynamic context,
  });

  Future<EvTopUpResponse> walletTopUp({
    required dynamic context,
    required double amount,
  });

  Future<EvTopUpResponse> walletTopUpStatus({
    required dynamic context,
    required String transactionId,
  });

  Future<EvScanQrResponse> scanQrFindSaleOrder({
    required dynamic context,
    required String transactionId,
  });

  Future<SimpleResponse> confirmPayment({
    required dynamic context,
    required String transactionId,
  });
}
