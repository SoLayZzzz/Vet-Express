import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/ev_plug_request.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/ev_sale_order_apptmp_request.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/ev_voucher_apply_request.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/ev_calculate_request.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/choosePayment_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_calculate_reponse.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/request/ev_checkZone_request.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_checkZone_reponse.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/amount_price_kwh_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/destination_ev.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_plug_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_point_list_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_pricePerWkh_response.dart';
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
    required int paymentMethod,
  }) {
    return repository.walletTopUp(
      context: context,
      amount: amount,
      paymentMethod: paymentMethod,
    );
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

  Future<MembershipInfoResponse> fetchMembershipInfo({
    required dynamic context,
  }) {
    return repository.fetchMembershipInfo(
      context: context,
    );
  }

  Future<MembershipBenefitResponse> fetchMembershipBenefit({
    required dynamic context,
  }) {
    return repository.fetchMembershipBenefit(
      context: context,
    );
  }

  Future<MembershipTransactionListResponse> fetchMembershipTransactionList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
    String orderBy = '',
    String searchText = '',
    int? type,
  }) {
    return repository.fetchMembershipTransactionList(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
      orderBy: orderBy,
      searchText: searchText,
      type: type,
    );
  }

  Future<MembershipTransactionDetailResponse> fetchMembershipTransactionDetail({
    required dynamic context,
    required int id,
  }) {
    return repository.fetchMembershipTransactionDetail(
      context: context,
      id: id,
    );
  }

  Future<AmountPriceAndKwhResponse> fetchAmountKwh({
    required dynamic context
  }) {
    return repository.fetchAmountKwh(context: context);
  }

  Future<AmountPriceAndKwhResponse> fetchAmountPrice({
    required dynamic context
  }) {
    return repository.fetchAmountPrice(context: context);
  }

   Future<EvPointListResponse> fetchPoint({
    required dynamic context
  }) {
    return repository.fetchPoint(context: context);
  }

  Future<EvVoucherApplyResponse> applyVoucher({ 
    required dynamic context,
    required EvVoucherRequest request,
  }) {
    return repository.applyVoucher(context: context, request: request);
  }

  Future<EvVoucherSearchResponse> searchVoucher({
    required dynamic context,
    required EvVoucherRequest request,
  }) {
    return repository.searchVoucher(context: context, request: request);
  }

  Future<EvVoucherListResponse> fetchVoucherList({
    required dynamic context,
  }) {
    return repository.fetchVoucherList(context: context);
  }

  Future<EvChargingStatusResponse> fetchChargingStatus({
    required dynamic context,
  }) {
    return repository.fetchChargingStatus(context: context);
  }

  Future<EvSaleOrderApptmpResponse> evSaleOrderApptmp({
    required dynamic context,
    required EvSaleOrderApptmpRequest request,
  }) {
    return repository.evSaleOrderApptmp(context: context, request: request);
  }

  Future<EvCalculateResponse> evCalculate({
    required dynamic context,
    required EvCalculateRequest request,
  }) {
    return repository.evCalculate(context: context, request: request);
  }

  Future<EvCheckZoneResponse> evCheckZone({
    required dynamic context,
    required EvCheckZoneRequest request,
  }) {
    return repository.evCheckZone(context: context, request: request);
  }

  Future<ChoosePaymentResponse> fetchChoosePaymentMethod({
    required dynamic context,
  }) {
    return repository.fetchChoosePaymentMethod(context: context);
  }

  Future<EvPlugResponse> evPlug({
    required dynamic context,
    required EvPlugRequest request,
  }) {
    return repository.evPlug(context: context, request: request);
  }

  Future<EvPricePerWkhResponse> evPricePerWkh({
    required dynamic context,
    required EvPlugRequest request,
  }) {
    return repository.evPricePerWkh(context: context, request: request);
  }
}
