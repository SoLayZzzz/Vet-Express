class SelectSeatUiState {
  final bool isBack;
  final String journeyId;
  final String date;
  final String title;

  final Future<Map<dynamic, dynamic>>? futureSeatLayout;

  final List<String> selectedSeat;
  final List<String> selectedSeatValue;
  final List<String> unavailableSeat;
  final List<String> unavailableSeatGender;

  const SelectSeatUiState({
    this.isBack = false,
    this.journeyId = '',
    this.date = '',
    this.title = '',
    this.futureSeatLayout,
    this.selectedSeat = const <String>[],
    this.selectedSeatValue = const <String>[],
    this.unavailableSeat = const <String>[],
    this.unavailableSeatGender = const <String>[],
  });

  SelectSeatUiState copyWith({
    bool? isBack,
    String? journeyId,
    String? date,
    String? title,
    Future<Map<dynamic, dynamic>>? futureSeatLayout,
    List<String>? selectedSeat,
    List<String>? selectedSeatValue,
    List<String>? unavailableSeat,
    List<String>? unavailableSeatGender,
  }) => SelectSeatUiState(
    isBack: isBack ?? this.isBack,
    journeyId: journeyId ?? this.journeyId,
    date: date ?? this.date,
    title: title ?? this.title,
    futureSeatLayout: futureSeatLayout ?? this.futureSeatLayout,
    selectedSeat: selectedSeat ?? this.selectedSeat,
    selectedSeatValue: selectedSeatValue ?? this.selectedSeatValue,
    unavailableSeat: unavailableSeat ?? this.unavailableSeat,
    unavailableSeatGender: unavailableSeatGender ?? this.unavailableSeatGender,
  );
}
