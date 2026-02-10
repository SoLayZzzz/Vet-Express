import '../../data/model/response/schedule_response.dart';

class ScheduleListUiState {
  final bool isBack;
  final String currentDate;
  final String titleRoute;
  final Future<ScheduleResponse>? futureSchedule;

  const ScheduleListUiState({
    this.isBack = false,
    this.currentDate = '',
    this.titleRoute = '',
    this.futureSchedule,
  });

  ScheduleListUiState copyWith({
    bool? isBack,
    String? currentDate,
    String? titleRoute,
    Future<ScheduleResponse>? futureSchedule,
  }) => ScheduleListUiState(
    isBack: isBack ?? this.isBack,
    currentDate: currentDate ?? this.currentDate,
    titleRoute: titleRoute ?? this.titleRoute,
    futureSchedule: futureSchedule ?? this.futureSchedule,
  );
}
