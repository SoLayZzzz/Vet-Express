import 'package:express_vet/feature/location-dashboard/data/model/response/branch_response.dart';

class LocationUiState {
  final List<Data> branches;
  final bool loading;
  final bool error;

  const LocationUiState({
    this.branches = const [],
    this.loading = false,
    this.error = false,
  });

  LocationUiState copyWith({
    List<Data>? branches,
    bool? loading,
    bool? error,
  }) => LocationUiState(
    branches: branches ?? this.branches,
    loading: loading ?? this.loading,
    error: error ?? this.error,
  );
}
