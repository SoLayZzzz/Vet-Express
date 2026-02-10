import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../models/boarding_point.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../utils/loading.dart';
import '../base/base_url.dart';

class CarPoint {
  // for get boarding point
  Future<CarPointResponse> getBoardingPoint(
    context,
    String date,
    String id,
  ) async {
    var map = <String, dynamic>{};
    map['date'] = date;
    map['id'] = id;

    try {
      final response = await http
          .post(
            Uri.parse(
              '${BaseUrl.BASE_URL_TICKET}boarding-point/listByScheduleDate',
            ),
            headers: <String, String>{
              "Content-type": "application/x-www-form-urlencoded",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: map,
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response boarding point ==>>${response.body}');
        return CarPointResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load to server!');
      }
    } on TimeoutException {
      Loading().loadingClose(context);
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // for get drop off point
  Future<CarPointResponse> getDropOffPoint(context, String id) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '${BaseUrl.BASE_URL_TICKET}drop-off-point/findBySchedule/$id',
            ),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response drop off point ==>>${response.body}');
        return CarPointResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load to server!!');
      }
    } on TimeoutException {
      Loading().loadingClose(context);
      rethrow;
    } catch (e) {
      Loading().loadingClose(context);
      rethrow;
    }
  }
}
