import 'package:express_vet/models/schedule/total_by_journey_response.dart';

class RateScheduleUiState {
  final Future<TotalByJourneyResponse>? futureTotalByJourney;
  final int selectedRating;

  const RateScheduleUiState({
    this.futureTotalByJourney,
    this.selectedRating = 0,
  });

  RateScheduleUiState copyWith({
    Future<TotalByJourneyResponse>? futureTotalByJourney,
    int? selectedRating,
  }) => RateScheduleUiState(
    futureTotalByJourney: futureTotalByJourney ?? this.futureTotalByJourney,
    selectedRating: selectedRating ?? this.selectedRating,
  );
}
