import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../feature/menu/data/model/response/notification_response.dart';
import '../models/simple_response.dart';
import '../utils/alert_dialog.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../utils/loading.dart';
import '../base/base_url.dart';

class Notifications {
  // for get notification for logistic
  Future<NotificationResponse> getNotification(
    context,
    int page,
    int rowPerPage,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}notification/list'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: json.encode({
              "page": page,
              "rowsPerPage": rowPerPage,
              "searchText": "",
              "orderBy": "",
            }),
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response notification ==>>${response.body}');
        return NotificationResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load to server!!');
      }
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // for get notification read all for logistic
  void readAll(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}notification/read-all'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response notification read all ==>>${response.body}');
        var data = NotificationResponse.fromJson(jsonDecode(response.body));
        if (data.header?.statusCode == 200 && data.header?.result == true) {
          // Read all Notification
        }
      } else {
        throw Exception('Failed to load to server!!');
      }
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  void readNotification(context, String id) async {
    var map = <String, dynamic>{};
    map['id'] = id;

    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}notification/read'),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
            body: map,
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response read notification ==>>${response.body}');
      } else {
        throw Exception('Failed to load to server!');
      }
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // for get notification read all for ticket
  void notificationRegister(context, appType, deviceId, deviceToken) async {
    var map = <String, dynamic>{};
    map['appType'] = appType;
    map['deviceId'] = deviceId;
    map['deviceToken'] = deviceToken;

    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}notification/register'),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
            body: map,
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response notification register ==>>${response.body}');
        var data = SimpleResponse.fromJson(jsonDecode(response.body));
        if (data.header?.statusCode == 200 && data.header?.result == true) {
          log("${data.body?.message}");
        }
      } else {
        throw Exception('Failed to load to server!!');
      }
    } catch (e) {
      throw Exception('Failed to load to server!!');
    }
  }
}
