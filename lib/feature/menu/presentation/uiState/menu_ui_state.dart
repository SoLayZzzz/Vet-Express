class MenuUiState {
  final String language;
  final int badge;

  const MenuUiState({this.language = 'km', this.badge = 0});

  MenuUiState copyWith({String? language, int? badge}) => MenuUiState(
        language: language ?? this.language,
        badge: badge ?? this.badge,
      );
}
