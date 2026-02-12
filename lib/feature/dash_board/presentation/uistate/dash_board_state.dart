class DashBoardState {
  final int selectedIndex;
  final bool navigated;

  const DashBoardState({this.selectedIndex = 0, this.navigated = false});

  DashBoardState copyWith({int? selectedIndex, bool? navigated}) =>
      DashBoardState(
        selectedIndex: selectedIndex ?? this.selectedIndex,
        navigated: navigated ?? this.navigated,
      );
}
