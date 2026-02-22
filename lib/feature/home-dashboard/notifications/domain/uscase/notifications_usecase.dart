import '../../../../../models/simple_response.dart';
import '../../../menu/data/model/response/notification_response.dart';
import '../repository/notifications_repository.dart';

class NotificationsUseCase {
  final NotificationsRepository repository;

  NotificationsUseCase(this.repository);

  Future<NotificationResponse> fetchNotificationList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return repository.fetchNotificationList(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }

  Future<NotificationResponse> readAll({
    required dynamic context,
  }) {
    return repository.readAll(context: context);
  }

  Future<SimpleResponse> readNotification({
    required dynamic context,
    required String id,
  }) {
    return repository.readNotification(context: context, id: id);
  }

  Future<SimpleResponse> notificationRegister({
    required dynamic context,
    required String appType,
    required String? deviceId,
    required String? deviceToken,
  }) {
    return repository.notificationRegister(
      context: context,
      appType: appType,
      deviceId: deviceId,
      deviceToken: deviceToken,
    );
  }
}
