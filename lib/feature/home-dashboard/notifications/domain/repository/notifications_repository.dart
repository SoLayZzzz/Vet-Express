import '../../../../../models/simple_response.dart';
import '../../../menu/data/model/response/notification_response.dart';

abstract class NotificationsRepository {
  Future<NotificationResponse> fetchNotificationList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  });

  Future<NotificationResponse> readAll({
    required dynamic context,
  });

  Future<SimpleResponse> readNotification({
    required dynamic context,
    required String id,
  });

  Future<SimpleResponse> notificationRegister({
    required dynamic context,
    required String appType,
    required String? deviceId,
    required String? deviceToken,
  });
}
