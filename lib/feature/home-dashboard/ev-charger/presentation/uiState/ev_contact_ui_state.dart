import '../../data/model/response/ev_contact_response.dart';

class EvContactUiState {
  final EvContactResponse? response;
  final bool isLoading;
  final bool hasError;
  final int currentPage;
  final bool hasMore;

  const EvContactUiState({
    this.response,
    this.isLoading = false,
    this.hasError = false,
    this.currentPage = 0,
    this.hasMore = true,
  });

  EvContactUiState copyWith({
    EvContactResponse? response,
    bool? isLoading,
    bool? hasError,
    int? currentPage,
    bool? hasMore,
  }) {
    return EvContactUiState(
      response: response ?? this.response,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
