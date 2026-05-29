import 'package:get/get.dart';

import '../../../../../base/base_url.dart';
import '../../../../../base/state_controller.dart';
import '../../domain/uscase/ev_charger_usecase.dart';
import '../../data/model/response/ev_contact_response.dart';
import '../../data/model/response/ev_news_feed_response.dart';
import '../../data/model/response/ev_slide_show_response.dart';
import '../../data/model/response/ev_charger_response.dart';
import '../../data/model/response/destination_ev.dart';
import '../uiState/ev_charger_ui_state.dart';

class EvChargerController extends StateController<EvChargerUiState> {
  final EvChargerUseCase useCase;

  EvChargerController(this.useCase);

  @override
  EvChargerUiState onInitUiState() => const EvChargerUiState();

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  void refreshData() {
    loadHomeData();
  }

  void refreshContacts() {
    fetchContacts(page: 1, rowsPerPage: 10);
  }

  void setStationSearchSource(List<BodyEV> stations) {
    if (state.stationSearchSource.length == stations.length) return;
    uiState.value = state.copyWith(stationSearchSource: stations);
  }

  void updateStationSearchQuery(String query) {
    uiState.value = state.copyWith(stationSearchQuery: query);
  }

  List<BodyEV> get filteredStations {
    final query = state.stationSearchQuery.toLowerCase().trim();
    if (query.isEmpty) return state.stationSearchSource;
    return state.stationSearchSource.where((station) {
      final name = station.name?.toLowerCase() ?? '';
      final address = station.address?.toLowerCase() ?? '';
      return name.contains(query) || address.contains(query);
    }).toList();
  }

  Future<void> loadTicketProvinces() async {
    uiState.value = state.copyWith(
      isLoadingTicketProvinces: true,
      hasErrorTicketProvinces: false,
    );

    try {
      final res = await useCase.fetchTicketProvinceList(context: Get.context!);
      uiState.value = state.copyWith(ticketProvinces: res.body ?? <BodyEv>[]);
    } catch (e) {
      uiState.value = state.copyWith(hasErrorTicketProvinces: true);
    } finally {
      uiState.value = state.copyWith(isLoadingTicketProvinces: false);
    }
  }

  void loadTicketProvincesIfNeeded() {
    if (state.ticketProvinces.isNotEmpty || state.isLoadingTicketProvinces) {
      return;
    }
    loadTicketProvinces();
  }

  void updateProvinceSearchQuery(String query) {
    uiState.value = state.copyWith(ticketProvinceSearchQuery: query);
  }

  List<BodyEv> get filteredTicketProvinces {
    final query = state.ticketProvinceSearchQuery.toLowerCase().trim();
    if (query.isEmpty) return state.ticketProvinces;
    return state.ticketProvinces.where((p) {
      final n1 = p.name?.toLowerCase() ?? '';
      final n2 = p.nameKh?.toLowerCase() ?? '';
      final n3 = p.nameCn?.toLowerCase() ?? '';
      return n1.contains(query) || n2.contains(query) || n3.contains(query);
    }).toList();
  }

  Future<void> loadHomeData() async {
    await Future.wait([
      fetchContacts(page: 1, rowsPerPage: 10),
      fetchSlides(page: 1, rowsPerPage: 10),
      fetchNewsFeed(page: 1, rowsPerPage: 10),
      fetchWalletAmount(),
      fetchWalletList(page: 1, rowsPerPage: 10),
    ]);
  }

  Future<void> fetchContacts({
    required int page,
    required int rowsPerPage,
  }) async {
    uiState.value = state.copyWith(
      isLoadingContact: true,
      hasErrorContact: false,
    );
    try {
      final res = await useCase.fetchEvContactUs(
        context: Get.context!,
        page: page,
        rowsPerPage: rowsPerPage,
      );
      uiState.value = state.copyWith(contactResponse: res);
    } catch (e) {
      uiState.value = state.copyWith(hasErrorContact: true);
    } finally {
      uiState.value = state.copyWith(isLoadingContact: false);
    }
  }

  void refreshSlides() {
    fetchSlides(page: 1, rowsPerPage: 10);
  }

  List<EvContactDatum> get contactList =>
      state.contactResponse?.body?.data ?? [];

  List<EvContactDatum> getPhoneContacts() {
    return contactList.where((c) => c.typeOfContactId == 2).toList();
  }

  List<EvContactDatum> getSocialContacts() {
    return contactList.where((c) => c.typeOfContactId == 1).toList();
  }

  String getFullIconUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) return '';
    if (relativeUrl.startsWith('http')) return relativeUrl;
    final cleanUrl =
        relativeUrl.startsWith('/') ? relativeUrl.substring(1) : relativeUrl;
    // Use BASE_URL_SLIDE_IMAGE_EV which hosts static assets
    return "${BaseUrl.BASE_URL_SLIDE_IMAGE_EV}$cleanUrl";
  }

  String getIconUrl(EvContactDatum contact) => getFullIconUrl(contact.iconUrl);

  String getLocalizedName(EvContactDatum contact) {
    final locale = Get.locale?.languageCode;
    switch (locale) {
      case 'km':
        return contact.nameKh ?? contact.nameEn ?? 'Contact';
      case 'zh':
      case 'cn':
        return contact.nameCn ?? contact.nameEn ?? 'Contact';
      default:
        return contact.nameEn ?? 'Contact';
    }
  }

  Future<void> fetchSlides({
    required int page,
    required int rowsPerPage,
  }) async {
    uiState.value = state.copyWith(
      isLoadingSlides: true,
      hasErrorSlides: false,
    );
    try {
      final res = await useCase.fetchEvSlideShows(
        context: Get.context!,
        page: page,
        rowsPerPage: rowsPerPage,
      );
      uiState.value = state.copyWith(slideShowResponse: res);
    } catch (e) {
      uiState.value = state.copyWith(hasErrorSlides: true);
    } finally {
      uiState.value = state.copyWith(isLoadingSlides: false);
    }
  }

  List<EvSlideShowDatum> get slideshowList =>
      state.slideShowResponse?.body?.data ?? [];

  List<String> get slideshowImageUrls {
    return slideshowList
        .where((s) => s.imageUrl != null && s.imageUrl!.isNotEmpty)
        .map((s) {
          final imageUrl = s.imageUrl!;
          if (imageUrl.startsWith('http')) return imageUrl;
          final clean =
              imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
          return "${BaseUrl.BASE_URL_SLIDE_IMAGE_EV}$clean";
        })
        .toList();
  }

  void updateCurrentSlideIndex(int index) {
    uiState.value = state.copyWith(currentSlideIndex: index);
  }

  Future<void> fetchNewsFeed({
    required int page,
    required int rowsPerPage,
  }) async {
    uiState.value = state.copyWith(
      isLoadingNews: page == 1,
      hasErrorNews: false,
    );
    try {
      final res = await useCase.fetchEvNewsFeed(
        context: Get.context!,
        page: page,
        rowsPerPage: rowsPerPage,
      );

      if (page == 1) {
        uiState.value = state.copyWith(newsFeedResponse: res);
      } else {
        final existing = state.newsFeedResponse;
        final existingData = existing?.body?.data;
        if (existing != null && existingData != null) {
          existingData.addAll(res.body?.data ?? <EvNewsFeedDatum>[]);
          uiState.value = state.copyWith(newsFeedResponse: existing);
        } else {
          uiState.value = state.copyWith(newsFeedResponse: res);
        }
      }
    } catch (e) {
      uiState.value = state.copyWith(hasErrorNews: true);
    } finally {
      if (page == 1) {
        uiState.value = state.copyWith(isLoadingNews: false);
      }
    }
  }

  void refreshNewsFeed() {
    fetchNewsFeed(page: 1, rowsPerPage: 10);
  }

  String formatDate(String? dateString) {
    return dateString ?? 'Unknown date';
  }

  List<EvNewsFeedDatum> get newsList =>
      state.newsFeedResponse?.body?.data ?? [];

  String getFullImageUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) return '';
    if (relativeUrl.startsWith('http')) return relativeUrl;
    final cleanUrl =
        relativeUrl.startsWith('/') ? relativeUrl.substring(1) : relativeUrl;
    return "${BaseUrl.BASE_URL_EV}$cleanUrl";
  }

  String getFeedImageUrl(EvNewsFeedDatum item) => getFullImageUrl(item.feedUrl);

  String getProfileImageUrl(EvNewsFeedDatum item) =>
      getFullImageUrl(item.profileUrl);

  String getLocalizedTitle(EvNewsFeedDatum item) {
    final locale = Get.locale?.languageCode;
    switch (locale) {
      case 'km':
        return item.titleKh ?? item.titleEn ?? 'No title';
      case 'zh':
        return item.titleCn ?? item.titleEn ?? 'No title';
      default:
        return item.titleEn ?? 'No title';
    }
  }

  String getLocalizedDescription(EvNewsFeedDatum item) {
    final locale = Get.locale?.languageCode;
    switch (locale) {
      case 'km':
        return item.descriptionKh ?? item.descriptionEn ?? 'No description';
      default:
        return item.descriptionEn ?? 'No description';
    }
  }

  Future<void> fetchWalletAmount() async {
    uiState.value = state.copyWith(
      isLoadingWalletBalance: true,
      hasErrorWallet: false,
    );
    try {
      final res = await useCase.fetchWalletAmount(context: Get.context!);
      uiState.value = state.copyWith(walletAmountResponse: res);
    } catch (e) {
      uiState.value = state.copyWith(hasErrorWallet: true);
    } finally {
      uiState.value = state.copyWith(isLoadingWalletBalance: false);
    }
  }

  Future<void> fetchWalletList({
    required int page,
    required int rowsPerPage,
  }) async {
    uiState.value = state.copyWith(
      isLoadingWalletList: true,
      hasErrorWallet: false,
    );
    try {
      final res = await useCase.fetchWalletList(
        context: Get.context!,
        page: page,
        rowsPerPage: rowsPerPage,
      );
      uiState.value = state.copyWith(walletListResponse: res);
    } catch (e) {
      uiState.value = state.copyWith(hasErrorWallet: true);
    } finally {
      uiState.value = state.copyWith(isLoadingWalletList: false);
    }
  }

  double get walletBalance {
    final amount = state.walletAmountResponse?.body?.data;
    if (amount == null) return 0.0;
    return double.tryParse(amount) ?? 0.0;
  }
}
