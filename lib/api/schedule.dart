import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/schedule/list_by_journey_response.dart';
import '../feature/schedule/data/model/response/schedule_response.dart';
import '../models/schedule/total_by_journey_response.dart';
import '../utils/alert_dialog.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../utils/loading.dart';
import '../base/base_url.dart';

class Schedule {
  /// for get schedule
  Future<ScheduleResponse> schedule(
    context,
    String date,
    String desFrom,
    String desTo,
    String type,
    String app,
    String national,
  ) async {
    var map = <String, dynamic>{};
    map['date'] = date;
    map['destinationFrom'] = desFrom;
    map['destinationTo'] = desTo;
    map['type'] = type;
    map['app'] = app;
    map['nationally'] = national;

    log("field request $map");

    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}schedule/listByDate'),
            headers: <String, String>{
              "Content-type": "application/x-www-form-urlencoded",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: map,
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response Des schedule go ==>>${response.body}');
        return ScheduleResponse.fromJson(jsonDecode(response.body));
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

  ///for get list of user comment, use in review rate screen
  Future<ListByJourneyResponse> getListByJourney(
    context,
    int? scheduleId,
  ) async {
    var map = <String, String>{};
    map['scheduleId'] = scheduleId.toString();

    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}schedule-rate/listByJourney'),
            headers: <String, String>{
              "Content-type": "application/x-www-form-urlencoded",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: map,
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response list by journey ==>>${response.body}');
        return ListByJourneyResponse.fromJson(jsonDecode(response.body));
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

  ///for get star and rating, use in review rate screen and rate schedule screen
  Future<TotalByJourneyResponse> getTotalByJourney(
    context,
    int? scheduleId,
  ) async {
    var map = <String, String>{};
    map['scheduleId'] = scheduleId.toString();

    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}schedule-rate/totalByJourney'),
            headers: <String, String>{
              "Content-type": "application/x-www-form-urlencoded",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: map,
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response total by journey ==>>${response.body}');
        return TotalByJourneyResponse.fromJson(jsonDecode(response.body));
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
}
