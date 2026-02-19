import '../../data/model/response/ev_slide_show_response.dart';

class EvSlideshowUiState {
  final EvSlideShowResponse? response;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final int currentPage;
  final bool hasMore;
  final int currentSlideIndex;

  const EvSlideshowUiState({
    this.response,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
    this.currentPage = 0,
    this.hasMore = true,
    this.currentSlideIndex = 0,
  });

  EvSlideshowUiState copyWith({
    EvSlideShowResponse? response,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    int? currentSlideIndex,
  }) {
    return EvSlideshowUiState(
      response: response ?? this.response,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      currentSlideIndex: currentSlideIndex ?? this.currentSlideIndex,
    );
  }
}
