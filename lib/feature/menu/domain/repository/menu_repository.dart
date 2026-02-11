import '../../data/model/response/notification_response.dart';

abstract class MenuRepository {
  Future<NotificationResponse> getNotificationCount();
}
