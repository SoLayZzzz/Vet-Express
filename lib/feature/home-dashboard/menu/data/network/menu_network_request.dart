import 'dart:async';

import '../../../../../base/endpoint.dart';
import '../../../../../base/network_data_source.dart';
import '../model/response/notification_response.dart';
import '../../../../../utils/contains.dart';

class MenuNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  MenuNetworkRequest(this.netWorkDataSource);

  Future<NotificationResponse> getNotificationCount() async {
    final json = await netWorkDataSource.postJson(
      Endpoint.notificationCountUnread,
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );

    return NotificationResponse.fromJson(json);
  }
}
