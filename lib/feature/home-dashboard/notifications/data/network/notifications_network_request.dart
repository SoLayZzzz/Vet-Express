import 'dart:async';

import 'package:get/get.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../base/network_data_source.dart';
import '../../../../../models/simple_response.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/contains.dart';
import '../../../../../utils/loading.dart';
import '../../../menu/data/model/response/notification_response.dart';

class NotificationsNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  NotificationsNetworkRequest(this.netWorkDataSource);

  Future<NotificationResponse> fetchNotificationList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) async {
    try {
      final json = await netWorkDataSource.postJson(
        Endpoint.notificationList,
        body: <String, dynamic>{
          'page': page,
          'rowsPerPage': rowsPerPage,
          'searchText': '',
          'orderBy': '',
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return NotificationResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose();
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<NotificationResponse> readAll({required dynamic context}) async {
    try {
      final json = await netWorkDataSource.postJson(
        Endpoint.notificationReadAll,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return NotificationResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose();
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<SimpleResponse> readNotification({
    required dynamic context,
    required String id,
  }) async {
    try {
      final json = await netWorkDataSource.postFormUrlEncoded(
        Endpoint.notificationRead,
        fields: <String, String>{'id': id},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return SimpleResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose();
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<SimpleResponse> notificationRegister({
    required dynamic context,
    required String appType,
    required String? deviceId,
    required String? deviceToken,
  }) async {
    try {
      final json = await netWorkDataSource.postFormUrlEncoded(
        Endpoint.notificationRegister,
        fields: <String, String>{
          'appType': appType,
          if (deviceId != null) 'deviceId': deviceId,
          if (deviceToken != null) 'deviceToken': deviceToken,
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return SimpleResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose();
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
