import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base/base_url.dart';
import '../../api/ev.dart';
import '../../models/ev/ev_slide_show_response.dart';

class EvSlideshowController extends GetxController {
  var evSlideshowResponse = Rxn<EvSlideShowResponse>();
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var currentPage = 0.obs;
  var hasMore = true.obs;
  var currentSlideIndex = 0.obs;

  @override
  void onInit() {
    fetchEvSlideshow(1, 10);
    super.onInit();
  }

  Future<void> fetchEvSlideshow(int page, int rowPerPage) async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage.value = '';

      var response = await EV().getEvSlideShow(Get.context!, page, rowPerPage);
      evSlideshowResponse.value = response;

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
      errorMessage.value = e.toString();
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

  /// ✅ Helper getters to access slideshow info easily
  List<EvSlideShowDatum> get slideshowList =>
      evSlideshowResponse.value?.body?.data ?? [];
  bool get hasSlides => slideshowList.isNotEmpty;
  String get message => evSlideshowResponse.value?.body?.message ?? '';
  bool get status => evSlideshowResponse.value?.body?.status ?? false;

  /// Get slideshow images URLs
  List<String> get slideshowImageUrls {
    return slideshowList
        .where((slide) => slide.imageUrl != null && slide.imageUrl!.isNotEmpty)
        .map((slide) {
          final String imageUrl = slide.imageUrl!;

          // If it's already a full URL, return as-is
          if (imageUrl.startsWith('http')) {
            return imageUrl;
          }
          // since BASE_URL_EV already ends with '/'
          final String cleanImageUrl =
              imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;

          return "${BaseUrl.BASE_URL_EV}$cleanImageUrl";
        })
        .toList();
  }

  /// Update current slide index
  void updateCurrentSlideIndex(int index) {
    currentSlideIndex.value = index;
  }

  /// Load more data for pagination
  void loadMore() {
    if (!isLoading.value && hasMore.value) {
      fetchEvSlideshow(currentPage.value + 1, 10);
    }
  }

  /// Refresh data
  void refreshData() {
    fetchEvSlideshow(1, 10);
  }

  /// Clear data
  void clearData() {
    evSlideshowResponse.value = null;
    currentPage.value = 0;
    hasMore.value = true;
    currentSlideIndex.value = 0;
  }
}
