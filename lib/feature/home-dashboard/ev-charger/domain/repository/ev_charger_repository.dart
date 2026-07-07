import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/ev_sale_order_apptmp_request.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/ev_voucher_apply_request.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/ev_calculate_request.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/choosePayment_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_calculate_reponse.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/ev_checkZone_request.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_checkZone_reponse.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/amount_price_kwh_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/destination_ev.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_point_list_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_sale_order_apptmp_res.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_voucher_apply_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_voucher_list_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_voucher_search_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/menbership_benefit_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/membership_info_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/membership_transaction_detail_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/membership_transaction_list_response.dart';
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
import '../../data/model/response/ev_charging_status_response.dart';

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

  Future<EvWalletAmountResponse> fetchWalletAmount({required dynamic context});

  Future<EvTopUpResponse> walletTopUp({
    required dynamic context,
    required double amount,
    required int paymentMethod,
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

  Future<MembershipInfoResponse> fetchMembershipInfo({
    required dynamic context,
  });

  Future<MembershipBenefitResponse> fetchMembershipBenefit({
    required dynamic context,
  });

  Future<MembershipTransactionListResponse> fetchMembershipTransactionList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
    String orderBy = '',
    String searchText = '',
    int? type,
  });

  Future<MembershipTransactionDetailResponse> fetchMembershipTransactionDetail({
    required dynamic context,
    required int id,
  });

  Future<AmountPriceAndKwhResponse> fetchAmountKwh({
    required dynamic context
  });

  Future<AmountPriceAndKwhResponse> fetchAmountPrice({
    required dynamic context
  });

  Future<EvPointListResponse> fetchPoint({
    required dynamic context
  });
  
  Future<EvVoucherApplyResponse> applyVoucher({
    required dynamic context,
    required EvVoucherRequest request,
  });

  Future<EvVoucherSearchResponse> searchVoucher({
    required dynamic context,
    required EvVoucherRequest request,
  });

  Future<EvVoucherListResponse> fetchVoucherList({
    required dynamic context,
  });

  Future<EvChargingStatusResponse> fetchChargingStatus({
    required dynamic context,
  });

  Future<EvSaleOrderApptmpResponse> evSaleOrderApptmp({
    required dynamic context,
    required EvSaleOrderApptmpRequest request,
  });

  Future<EvCalculateResponse> evCalculate({
    required dynamic context,
    required EvCalculateRequest request,
  });

  Future<EvCheckZoneResponse> evCheckZone({
    required dynamic context,
    required EvCheckZoneRequest request,
  });

  Future<ChoosePaymentResponse> fetchChoosePaymentMethod({
    required dynamic context,
  });
}
