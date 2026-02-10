import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/ev.dart';
import '../../base/base_url.dart';
import '../../models/ev/ev_news_feed_response.dart';

class EvNewsFeedController extends GetxController {
  var newsFeedResponse = Rxn<EvNewsFeedResponse>();
  var isLoading = false.obs;
  var hasError = false.obs;
  var currentPage = 0.obs;
  var hasMore = true.obs;

  @override
  void onInit() {
    fetchNewsFeed(1, 10);
    super.onInit();
  }

  Future<void> fetchNewsFeed(int page, int rowPerPage) async {
    if (page == 1) {
      isLoading(true);
      hasError(false);
    }

    try {
      final response = await EV().getEvNewsFeed(Get.context!, page, rowPerPage);

      if (page == 1) {
        newsFeedResponse.value = response;
      } else {
        final existing = newsFeedResponse.value;
        if (existing?.body?.data != null) {
          final newData = response.body?.data ?? [];
          existing!.body!.data!.addAll(newData);
          newsFeedResponse.value = existing;
        }
      }

      final pagination = response.body?.pagination;
      if (pagination != null) {
        currentPage.value = pagination.page ?? 0;
        hasMore.value =
            (pagination.page ?? 0) * (pagination.rowsPerPage ?? 10) <
            (pagination.total ?? 0);
      }
    } catch (e) {
      hasError(true);
      Get.dialog(
        AlertDialog(
          title: Text('error'.tr),
          content: Text(e.toString()),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('ok'.tr)),
          ],
        ),
      );
    } finally {
      if (page == 1) isLoading(false);
    }
  }

  void loadMore() {
    if (!isLoading.value && hasMore.value) {
      fetchNewsFeed(currentPage.value + 1, 10);
    }
  }

  void refreshData() {
    currentPage.value = 0;
    hasMore.value = true;
    fetchNewsFeed(1, 10);
  }

  // ─────────────────────────────────────
  // Helper Getters
  // ─────────────────────────────────────

  List<EvNewsFeedDatum> get newsList =>
      newsFeedResponse.value?.body?.data ?? [];
  List<EvNewsFeedDatum> get displayNewsList => newsList;

  /// Get full image URL by concatenating with base URL (similar to slideshow)
  String getFullImageUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) {
      return ''; // Return empty string if no URL
    }

    // If it's already a full URL (starts with http), return as-is
    if (relativeUrl.startsWith('http')) {
      return relativeUrl;
    }

    // Remove leading slash to avoid double slashes
    String cleanUrl =
        relativeUrl.startsWith('/') ? relativeUrl.substring(1) : relativeUrl;

    // BASE_URL_EV already has trailing slash
    return "${BaseUrl.BASE_URL_EV}$cleanUrl";
  }

  /// Get feed image URL with base URL
  String getFeedImageUrl(EvNewsFeedDatum item) {
    return getFullImageUrl(item.feedUrl);
  }

  /// Get profile image URL with base URL
  String getProfileImageUrl(EvNewsFeedDatum item) {
    return getFullImageUrl(item.profileUrl);
  }

  /// Get localized title
  String getLocalizedTitle(EvNewsFeedDatum item) {
    final locale = Get.locale?.languageCode;
    switch (locale) {
      case 'km':
        return item.titleKh ?? item.titleEn ?? 'No title';
      case 'en':
        return item.titleEn ?? 'No title';
      case 'zh':
        return item.titleCn ?? item.titleEn ?? 'No title';
      default:
        return item.titleEn ?? 'No title';
    }
  }

  /// Get localized description
  String getLocalizedDescription(EvNewsFeedDatum item) {
    final locale = Get.locale?.languageCode;
    switch (locale) {
      case 'km':
        return item.descriptionKh ?? item.descriptionEn ?? 'No description';
      case 'en':
        return item.descriptionEn ?? 'No description';
      case 'zh':
        return item.descriptionEn ?? item.descriptionEn ?? 'No description';
      default:
        return item.descriptionEn ?? 'No description';
    }
  }

  /// Simple date formatter - just returns the original string
  String formatDate(String? dateString) {
    return dateString ?? 'Unknown date';
  }
}
