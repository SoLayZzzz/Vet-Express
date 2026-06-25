import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/membership_info_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/menbership_benefit_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/membership_transaction_detail_response.dart';

import '../../data/model/response/ev_contact_response.dart';
import '../../data/model/response/ev_news_feed_response.dart';
import '../../data/model/response/ev_slide_show_response.dart';
import '../../data/model/response/ev_wallet_amount_response.dart';
import '../../data/model/response/ev_wallet_list_response.dart';
import '../../data/model/response/ev_charger_response.dart';
import '../../data/model/response/ev_faq_response.dart';
import '../../data/model/response/ev_policy_response.dart';
import '../../data/model/response/destination_ev.dart';

class EvChargerUiState {
  final EvContactResponse? contactResponse;
  final bool isLoadingContact;
  final bool hasErrorContact;

  final MembershipInfoResponse? membershipInfoResponse;
  final bool isLoadingMembershipInfo;
  final bool hasErrorMembershipInfo;

  final MembershipBenefitResponse? membershipBenefitResponse;
  final bool isLoadingMembershipBenefit;
  final bool hasErrorMembershipBenefit;

  final List<Group> membershipTransactionGroups;
  final bool isLoadingMembershipTransactionList;
  final bool isLoadingMoreMembershipTransactionList;
  final bool hasErrorMembershipTransactionList;
  final int membershipTransactionCurrentPage;
  final int membershipTransactionTotal;
  final bool membershipTransactionHasMore;
  final int membershipTransactionType;

  final MembershipTransactionDetailResponse? membershipTransactionDetailResponse;
  final bool isLoadingMembershipTransactionDetail;
  final bool hasErrorMembershipTransactionDetail;

  final EvSlideShowResponse? slideShowResponse;
  final bool isLoadingSlides;
  final bool hasErrorSlides;
  final int currentSlideIndex;

  final EvNewsFeedResponse? newsFeedResponse;
  final bool isLoadingNews;
  final bool hasErrorNews;

  final EvWalletAmountResponse? walletAmountResponse;
  final EvWalletListResponse? walletListResponse;
  final bool isLoadingWalletBalance;
  final bool isLoadingWalletList;
  final bool hasErrorWallet;

  final List<BodyEV> stationSearchSource;
  final String stationSearchQuery;

  final List<BodyEv> ticketProvinces;
  final bool isLoadingTicketProvinces;
  final bool hasErrorTicketProvinces;
  final String ticketProvinceSearchQuery;

  final EvFaqResponse? faqResponse;
  final bool isLoadingFaq;
  final bool hasErrorFaq;
  final int faqCurrentPage;
  final bool faqHasMore;

  final EvPolicyResponse? policyResponse;
  final bool isLoadingPolicy;
  final bool hasErrorPolicy;
  final int policyCurrentPage;
  final bool policyHasMore;
  final String policyHtmlContent;
  final bool isFetchingPolicyHtml;
  final String policyHtmlError;

  const EvChargerUiState({
    this.contactResponse,
    this.isLoadingContact = false,
    this.hasErrorContact = false,

    this.membershipInfoResponse,
    this.isLoadingMembershipInfo = false,
    this.hasErrorMembershipInfo = false,

    this.membershipBenefitResponse,
    this.isLoadingMembershipBenefit = false,
    this.hasErrorMembershipBenefit = false,

    this.membershipTransactionGroups = const <Group>[],
    this.isLoadingMembershipTransactionList = false,
    this.isLoadingMoreMembershipTransactionList = false,
    this.hasErrorMembershipTransactionList = false,
    this.membershipTransactionCurrentPage = 0,
    this.membershipTransactionTotal = 0,
    this.membershipTransactionHasMore = true,
    this.membershipTransactionType = 0,

    this.membershipTransactionDetailResponse,
    this.isLoadingMembershipTransactionDetail = false,
    this.hasErrorMembershipTransactionDetail = false,

    this.slideShowResponse,
    this.isLoadingSlides = false,
    this.hasErrorSlides = false,
    this.currentSlideIndex = 0,
    this.newsFeedResponse,
    this.isLoadingNews = false,
    this.hasErrorNews = false,
    this.walletAmountResponse,
    this.walletListResponse,
    this.isLoadingWalletBalance = false,
    this.isLoadingWalletList = false,
    this.hasErrorWallet = false,

    this.stationSearchSource = const <BodyEV>[],
    this.stationSearchQuery = '',

    this.ticketProvinces = const <BodyEv>[],
    this.isLoadingTicketProvinces = false,
    this.hasErrorTicketProvinces = false,
    this.ticketProvinceSearchQuery = '',

    this.faqResponse,
    this.isLoadingFaq = false,
    this.hasErrorFaq = false,
    this.faqCurrentPage = 0,
    this.faqHasMore = true,

    this.policyResponse,
    this.isLoadingPolicy = false,
    this.hasErrorPolicy = false,
    this.policyCurrentPage = 0,
    this.policyHasMore = true,
    this.policyHtmlContent = '',
    this.isFetchingPolicyHtml = false,
    this.policyHtmlError = '',
  });

  EvChargerUiState copyWith({
    EvContactResponse? contactResponse,
    bool? isLoadingContact,
    bool? hasErrorContact,
    MembershipInfoResponse? membershipInfoResponse,
    bool? isLoadingMembershipInfo,
    bool? hasErrorMembershipInfo,
    MembershipBenefitResponse? membershipBenefitResponse,
    bool? isLoadingMembershipBenefit,
    bool? hasErrorMembershipBenefit,

    List<Group>? membershipTransactionGroups,
    bool? isLoadingMembershipTransactionList,
    bool? isLoadingMoreMembershipTransactionList,
    bool? hasErrorMembershipTransactionList,
    int? membershipTransactionCurrentPage,
    int? membershipTransactionTotal,
    bool? membershipTransactionHasMore,
    int? membershipTransactionType,

    MembershipTransactionDetailResponse? membershipTransactionDetailResponse,
    bool? isLoadingMembershipTransactionDetail,
    bool? hasErrorMembershipTransactionDetail,
    EvSlideShowResponse? slideShowResponse,
    bool? isLoadingSlides,
    bool? hasErrorSlides,
    int? currentSlideIndex,
    EvNewsFeedResponse? newsFeedResponse,
    bool? isLoadingNews,
    bool? hasErrorNews,
    EvWalletAmountResponse? walletAmountResponse,
    EvWalletListResponse? walletListResponse,
    bool? isLoadingWalletBalance,
    bool? isLoadingWalletList,
    bool? hasErrorWallet,

    List<BodyEV>? stationSearchSource,
    String? stationSearchQuery,

    List<BodyEv>? ticketProvinces,
    bool? isLoadingTicketProvinces,
    bool? hasErrorTicketProvinces,
    String? ticketProvinceSearchQuery,

    EvFaqResponse? faqResponse,
    bool? isLoadingFaq,
    bool? hasErrorFaq,
    int? faqCurrentPage,
    bool? faqHasMore,

    EvPolicyResponse? policyResponse,
    bool? isLoadingPolicy,
    bool? hasErrorPolicy,
    int? policyCurrentPage,
    bool? policyHasMore,
    String? policyHtmlContent,
    bool? isFetchingPolicyHtml,
    String? policyHtmlError,
  }) {
    return EvChargerUiState(
      contactResponse: contactResponse ?? this.contactResponse,
      isLoadingContact: isLoadingContact ?? this.isLoadingContact,
      hasErrorContact: hasErrorContact ?? this.hasErrorContact,

      membershipInfoResponse:
          membershipInfoResponse ?? this.membershipInfoResponse,
      isLoadingMembershipInfo:
          isLoadingMembershipInfo ?? this.isLoadingMembershipInfo,
      hasErrorMembershipInfo:
          hasErrorMembershipInfo ?? this.hasErrorMembershipInfo,

      membershipBenefitResponse:
          membershipBenefitResponse ?? this.membershipBenefitResponse,
      isLoadingMembershipBenefit:
          isLoadingMembershipBenefit ?? this.isLoadingMembershipBenefit,
      hasErrorMembershipBenefit:
          hasErrorMembershipBenefit ?? this.hasErrorMembershipBenefit,

      membershipTransactionGroups:
          membershipTransactionGroups ?? this.membershipTransactionGroups,
      isLoadingMembershipTransactionList:
          isLoadingMembershipTransactionList ??
          this.isLoadingMembershipTransactionList,
      isLoadingMoreMembershipTransactionList:
          isLoadingMoreMembershipTransactionList ??
          this.isLoadingMoreMembershipTransactionList,
      hasErrorMembershipTransactionList:
          hasErrorMembershipTransactionList ??
          this.hasErrorMembershipTransactionList,
      membershipTransactionCurrentPage:
          membershipTransactionCurrentPage ??
          this.membershipTransactionCurrentPage,
      membershipTransactionTotal:
          membershipTransactionTotal ?? this.membershipTransactionTotal,
      membershipTransactionHasMore:
          membershipTransactionHasMore ?? this.membershipTransactionHasMore,
      membershipTransactionType:
          membershipTransactionType ?? this.membershipTransactionType,

      membershipTransactionDetailResponse:
          membershipTransactionDetailResponse ??
          this.membershipTransactionDetailResponse,
      isLoadingMembershipTransactionDetail:
          isLoadingMembershipTransactionDetail ??
          this.isLoadingMembershipTransactionDetail,
      hasErrorMembershipTransactionDetail:
          hasErrorMembershipTransactionDetail ??
          this.hasErrorMembershipTransactionDetail,

      slideShowResponse: slideShowResponse ?? this.slideShowResponse,
      isLoadingSlides: isLoadingSlides ?? this.isLoadingSlides,
      hasErrorSlides: hasErrorSlides ?? this.hasErrorSlides,
      currentSlideIndex: currentSlideIndex ?? this.currentSlideIndex,
      newsFeedResponse: newsFeedResponse ?? this.newsFeedResponse,
      isLoadingNews: isLoadingNews ?? this.isLoadingNews,
      hasErrorNews: hasErrorNews ?? this.hasErrorNews,
      walletAmountResponse: walletAmountResponse ?? this.walletAmountResponse,
      walletListResponse: walletListResponse ?? this.walletListResponse,
      isLoadingWalletBalance:
          isLoadingWalletBalance ?? this.isLoadingWalletBalance,
      isLoadingWalletList: isLoadingWalletList ?? this.isLoadingWalletList,
      hasErrorWallet: hasErrorWallet ?? this.hasErrorWallet,

      stationSearchSource: stationSearchSource ?? this.stationSearchSource,
      stationSearchQuery: stationSearchQuery ?? this.stationSearchQuery,

      ticketProvinces: ticketProvinces ?? this.ticketProvinces,
      isLoadingTicketProvinces:
          isLoadingTicketProvinces ?? this.isLoadingTicketProvinces,
      hasErrorTicketProvinces:
          hasErrorTicketProvinces ?? this.hasErrorTicketProvinces,
      ticketProvinceSearchQuery:
          ticketProvinceSearchQuery ?? this.ticketProvinceSearchQuery,

      faqResponse: faqResponse ?? this.faqResponse,
      isLoadingFaq: isLoadingFaq ?? this.isLoadingFaq,
      hasErrorFaq: hasErrorFaq ?? this.hasErrorFaq,
      faqCurrentPage: faqCurrentPage ?? this.faqCurrentPage,
      faqHasMore: faqHasMore ?? this.faqHasMore,

      policyResponse: policyResponse ?? this.policyResponse,
      isLoadingPolicy: isLoadingPolicy ?? this.isLoadingPolicy,
      hasErrorPolicy: hasErrorPolicy ?? this.hasErrorPolicy,
      policyCurrentPage: policyCurrentPage ?? this.policyCurrentPage,
      policyHasMore: policyHasMore ?? this.policyHasMore,
      policyHtmlContent: policyHtmlContent ?? this.policyHtmlContent,
      isFetchingPolicyHtml: isFetchingPolicyHtml ?? this.isFetchingPolicyHtml,
      policyHtmlError: policyHtmlError ?? this.policyHtmlError,
    );
  }
}
