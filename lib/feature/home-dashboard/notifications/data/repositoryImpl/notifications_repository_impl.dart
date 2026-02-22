import 'package:express_vet/feature/home-dashboard/notifications/data/network/notifications_network_request.dart';
import 'package:express_vet/feature/home-dashboard/notifications/domain/repository/notifications_repository.dart';
import 'package:express_vet/feature/home-dashboard/menu/data/model/response/notification_response.dart';
import '../../../../../models/simple_response.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsNetworkRequest networkRequest;

  NotificationsRepositoryImpl(this.networkRequest);

  @override
  Future<NotificationResponse> fetchNotificationList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return networkRequest.fetchNotificationList(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }

  @override
  Future<NotificationResponse> readAll({
    required dynamic context,
  }) {
    return networkRequest.readAll(context: context);
  }

  @override
  Future<SimpleResponse> notificationRegister({
    required dynamic context,
    required String appType,
    required String? deviceId,
    required String? deviceToken,
  }) {
    return networkRequest.notificationRegister(
      context: context,
      appType: appType,
      deviceId: deviceId,
      deviceToken: deviceToken,
    );
  }

  @override
  Future<SimpleResponse> readNotification({
    required dynamic context,
    required String id,
  }) {
    return networkRequest.readNotification(context: context, id: id);
  }
}
