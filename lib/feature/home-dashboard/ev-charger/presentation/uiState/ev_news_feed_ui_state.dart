import '../../data/model/response/ev_news_feed_response.dart';

class EvNewsFeedUiState {
  final EvNewsFeedResponse? response;
  final bool isLoading;
  final bool hasError;
  final int currentPage;
  final bool hasMore;

  const EvNewsFeedUiState({
    this.response,
    this.isLoading = false,
    this.hasError = false,
    this.currentPage = 0,
    this.hasMore = true,
  });

  EvNewsFeedUiState copyWith({
    EvNewsFeedResponse? response,
    bool? isLoading,
    bool? hasError,
    int? currentPage,
    bool? hasMore,
  }) {
    return EvNewsFeedUiState(
      response: response ?? this.response,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
