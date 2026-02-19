import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_slide_show_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../base/base_url.dart';
import '../../../../../base/state_controller.dart';
import '../../domain/uscase/ev_charger_usecase.dart';
import '../uiState/ev_slideshow_ui_state.dart';

class EvSlideshowController extends StateController<EvSlideshowUiState> {
  final EvChargerUseCase useCase = Get.find<EvChargerUseCase>();

  @override
  EvSlideshowUiState onInitUiState() => const EvSlideshowUiState();

  @override
  void onInit() {
    fetchEvSlideshow(1, 10);
    super.onInit();
  }

  Future<void> fetchEvSlideshow(int page, int rowPerPage) async {
    try {
      uiState.value = state.copyWith(
        isLoading: true,
        hasError: false,
        errorMessage: '',
      );

      final response = await useCase.fetchEvSlideShows(
        context: Get.context!,
        page: page,
        rowsPerPage: rowPerPage,
      );
      uiState.value = state.copyWith(response: response);

      // Update pagination info
      final pagination = response.body?.pagination;
      if (pagination != null) {
        uiState.value = state.copyWith(
          currentPage: pagination.page ?? 0,
          hasMore:
              (pagination.page ?? 0) * (pagination.rowsPerPage ?? 10) <
              (pagination.total ?? 0),
        );
      }
    } catch (e) {
      uiState.value = state.copyWith(
        hasError: true,
        errorMessage: e.toString(),
      );
      _showErrorDialog(e);
    } finally {
      uiState.value = state.copyWith(isLoading: false);
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
  List<EvSlideShowDatum> get slideshowList => state.response?.body?.data ?? [];
  bool get hasSlides => slideshowList.isNotEmpty;
  String get message => state.response?.body?.message ?? '';
  bool get status => state.response?.body?.status ?? false;

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
    uiState.value = state.copyWith(currentSlideIndex: index);
  }

  /// Load more data for pagination
  void loadMore() {
    if (!state.isLoading && state.hasMore) {
      fetchEvSlideshow(state.currentPage + 1, 10);
    }
  }

  /// Refresh data
  void refreshData() {
    fetchEvSlideshow(1, 10);
  }

  /// Clear data
  void clearData() {
    uiState.value = const EvSlideshowUiState();
  }
}
