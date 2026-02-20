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
