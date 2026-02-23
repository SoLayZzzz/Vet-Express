import '../../../../../models/resort/resort_response.dart';

class ResortUiState {
  final bool isLoading;
  final List<ResortBody> resorts;

  const ResortUiState({
    required this.isLoading,
    required this.resorts,
  });

  factory ResortUiState.initial() => const ResortUiState(
        isLoading: true,
        resorts: <ResortBody>[],
      );

  ResortUiState copyWith({
    bool? isLoading,
    List<ResortBody>? resorts,
  }) {
    return ResortUiState(
      isLoading: isLoading ?? this.isLoading,
      resorts: resorts ?? this.resorts,
    );
  }
}
