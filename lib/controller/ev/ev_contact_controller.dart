import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/ev.dart';
import '../../base/base_url.dart';
import '../../models/ev/ev_contact_response.dart';

class EvContactController extends GetxController {
  var evContactResponse = Rxn<EvContactResponse>();
  var isLoading = false.obs;
  var hasError = false.obs;
  var currentPage = 0.obs;
  var hasMore = true.obs;

  @override
  void onInit() {
    fetchEvContactUs(1, 10);
    super.onInit();
  }

  Future<void> fetchEvContactUs(int page, int rowPerPage) async {
    try {
      isLoading(true);
      hasError(false);

      var response = await EV().getEvContactUs(Get.context!, page, rowPerPage);
      evContactResponse.value = response;

      // Update pagination info
      final pagination = response.body?.pagination;
      if (pagination != null) {
        currentPage.value = pagination.page ?? 0;
        hasMore.value =
            (pagination.page ?? 0) * (pagination.rowsPerPage ?? 10) <
            (pagination.total ?? 0);
      }
    } catch (e) {
      hasError(true);
      _showErrorDialog(e);
    } finally {
      isLoading(false);
    }
  }

  void _showErrorDialog(dynamic error) {
    Get.dialog(
      AlertDialog(
        title: Text('error'.tr),
        content: Text(error.toString()),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('ok'.tr)),
        ],
      ),
    );
  }

  /// ✅ Helper getters to access EV contact info easily
  List<EvContactDatum> get contactList =>
      evContactResponse.value?.body?.data ?? [];
  bool get hasContacts => contactList.isNotEmpty;
  String get message => evContactResponse.value?.body?.message ?? '';
  bool get status => evContactResponse.value?.body?.status ?? false;

  /// Get full icon URL by concatenating with base URL (similar to slideshow)
  String getFullIconUrl(String? relativeUrl) {
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

  /// Get icon URL with base URL
  String getIconUrl(EvContactDatum contact) {
    return getFullIconUrl(contact.iconUrl);
  }

  /// Get localized name
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

  /// Get contact by type
  List<EvContactDatum> getPhoneContacts() {
    return contactList
        .where((contact) => contact.typeOfContactId == 2)
        .toList();
  }

  List<EvContactDatum> getSocialContacts() {
    return contactList
        .where((contact) => contact.typeOfContactId == 1)
        .toList();
  }

  /// Load more data for pagination
  void loadMore() {
    if (!isLoading.value && hasMore.value) {
      fetchEvContactUs(currentPage.value + 1, 10);
    }
  }

  /// Refresh data
  void refreshData() {
    fetchEvContactUs(1, 10);
  }

  /// Clear data (e.g., on logout)
  void clearData() {
    evContactResponse.value = null;
    currentPage.value = 0;
    hasMore.value = true;
  }
}
