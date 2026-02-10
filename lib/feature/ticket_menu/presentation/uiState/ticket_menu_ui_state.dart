class TicketMenuUiState {
  final bool isLoading;
  final String language;

  const TicketMenuUiState({this.isLoading = false, this.language = 'kh'});

  TicketMenuUiState copyWith({bool? isLoading, String? language}) =>
      TicketMenuUiState(
        isLoading: isLoading ?? this.isLoading,
        language: language ?? this.language,
      );
}
