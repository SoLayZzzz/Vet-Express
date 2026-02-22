import '../../../menu/data/model/response/notification_response.dart';

class NotificationsUiState {
  final Future<NotificationResponse>? futureList;

  const NotificationsUiState({this.futureList});

  NotificationsUiState copyWith({
    Future<NotificationResponse>? futureList,
  }) => NotificationsUiState(
    futureList: futureList ?? this.futureList,
  );
}
