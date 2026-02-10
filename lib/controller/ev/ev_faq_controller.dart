import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/ev.dart';
import '../../models/ev/ev_faq_response.dart';

class EvFaqController extends GetxController {
  var evFaqResponse = Rxn<EvFaqResponse>();
  var isLoading = false.obs;
  var hasError = false.obs;
  var currentPage = 0.obs;
  var hasMore = true.obs;

  @override
  void onInit() {
    fetchEvFaq(1, 10);
    super.onInit();
  }

  Future<void> fetchEvFaq(int page, int rowPerPage) async {
    try {
      isLoading(true);
      hasError(false);

      var response = await EV().getEvFaQ(Get.context!, page, rowPerPage);
      evFaqResponse.value = response;

      // Update pagination info
      final pagination = response.body?.pagination;
      if (pagination != null) {
        currentPage.value = pagination.page ?? 0;
        hasMore.value =
            (pagination.page ?? 0) * (pagination.rowsPerPage ?? 10) < (pagination.total ?? 0);
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
        actions: [TextButton(onPressed: () => Get.back(), child: Text('ok'.tr))],
      ),
    );
  }

  /// ✅ Helper getters to access FAQ info easily
  List<EvFaqDatum> get faqList => evFaqResponse.value?.body?.data ?? [];
  bool get hasFaqs => faqList.isNotEmpty;
  String get message => evFaqResponse.value?.body?.message ?? '';
  bool get status => evFaqResponse.value?.body?.status ?? false;

  /// Get localized FAQ title based on app language
  String getLocalizedQuestion(EvFaqDatum faq) {
    final locale = Get.locale?.languageCode;
    switch (locale) {
      case 'km':
        return faq.questionKh ?? faq.questionEn ?? 'No Question';
      case 'cn':
        return faq.questionCh ?? faq.questionEn ?? 'No Question';
      default:
        return faq.questionEn ?? 'No Question';
    }
  }

  /// Get localized FAQ answer based on app language
  String getLocalizedAnswer(EvFaqDatum faq) {
    final locale = Get.locale?.languageCode;
    switch (locale) {
      case 'km':
        return faq.answerKh ?? faq.answerEn ?? 'No Answer Available';
      case 'cn':
        return faq.answerCh ?? faq.answerEn ?? 'No Answer Available';
      default:
        return faq.answerEn ?? 'No Answer Available';
    }
  }

  /// Load more data for pagination
  void loadMore() {
    if (!isLoading.value && hasMore.value) {
      fetchEvFaq(currentPage.value + 1, 10);
    }
  }

  /// Refresh data
  void refreshData() {
    fetchEvFaq(1, 10);
  }

  /// Clear data
  void clearData() {
    evFaqResponse.value = null;
    currentPage.value = 0;
    hasMore.value = true;
  }
}
