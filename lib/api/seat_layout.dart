import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../utils/alert_dialog.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../utils/loading.dart';
import '../base/base_url.dart';

class Seat {
  // For get SeatLayout
  Future<Map> getSeatLayout(context, String date, String journey) async {
    var map = <String, dynamic>{};
    map['date'] = date;
    map['journey'] = journey;

    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}seat/layout'),
            headers: <String, String>{
              "Content-type": "application/x-www-form-urlencoded",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: map,
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response Des schedule go ==>>${response.body}');

        Map<dynamic, dynamic> result = jsonDecode(response.body);

        return result;
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
